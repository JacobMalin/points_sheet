import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

class UpdateApp extends StatefulWidget {
  const UpdateApp({super.key});

  @override
  State<UpdateApp> createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  bool _doUpdateApp = false;
  bool _dismissed = false;
  bool _isDownloading = false;
  String? _latestVersion;
  String? _currentVersion;
  String? _zipDownloadUrl;

  static const requiredAssetName = 'PointsSheet.zip';

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows && !kDebugMode) unawaited(_checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final String currentVersion = _normalizeVersion(info.version);

      const endpoint =
          'https://api.github.com/repos/JacobMalin/points_sheet/releases/latest';

      final http.Response response = await http.get(
        Uri.parse(endpoint),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('GitHub returned HTTP ${response.statusCode}.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final String latestVersion = _normalizeVersion(
        (data['tag_name'] as String?) ?? '',
      );
      if (latestVersion.isEmpty) {
        throw Exception('Latest release tag is missing.');
      }

      String? zipDownloadUrl;
      for (final asset in (data['assets'] as List<dynamic>?) ?? const []) {
        if (asset is! Map<String, dynamic>) continue;
        if (asset['name'] != requiredAssetName) continue;
        final downloadUrl = asset['browser_download_url'] as String?;
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          zipDownloadUrl = downloadUrl;
          break;
        }
      }
      if (!mounted) return;

      setState(() {
        _currentVersion = currentVersion;
        _latestVersion = latestVersion;
        _zipDownloadUrl = zipDownloadUrl;
        _doUpdateApp =
            zipDownloadUrl != null &&
            _isVersionNewer(latestVersion, currentVersion);
      });
    } on Exception catch (error) {
      if (!mounted || error is SocketException) return;

      final String reason = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to check for updates: $reason'),
          duration: const Duration(days: 1),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }

  Future<void> _downloadUpdateZip() async {
    final String? url = _zipDownloadUrl;
    if (url == null || url.isEmpty || _isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Download failed with status ${response.statusCode}.');
      }

      final Directory directory = File(Platform.resolvedExecutable).parent;
      final extractionDirectory = Directory(
        p.join(directory.path, p.basenameWithoutExtension(requiredAssetName)),
      );
      if (extractionDirectory.existsSync()) {
        extractionDirectory.deleteSync(recursive: true);
      }
      extractionDirectory.createSync(recursive: true);

      await _extractZip(
        zipBytes: response.bodyBytes,
        outputDirectory: extractionDirectory,
      );
      await _runUpdaterScript(
        targetDirectory: directory,
        extractionDirectory: extractionDirectory,
      );

      exit(0);
    } on Exception catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update download failed: $error')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _runUpdaterScript({
    required Directory targetDirectory,
    required Directory extractionDirectory,
  }) async {
    final String script = await rootBundle.loadString('assets/ApplyUpdate.cmd');
    final scriptFile = File(
      p.join(
        Directory.systemTemp.path,
        'apply_update_${DateTime.now().millisecondsSinceEpoch}.cmd',
      ),
    );
    await scriptFile.writeAsString(script, flush: true);

    _startHiddenWithCreateProcess(
      scriptPath: scriptFile.path,
      targetDirectoryPath: targetDirectory.path,
      extractionDirectoryPath: extractionDirectory.path,
      exeName: p.basename(Platform.resolvedExecutable),
    );
  }

  void _startHiddenWithCreateProcess({
    required String scriptPath,
    required String targetDirectoryPath,
    required String extractionDirectoryPath,
    required String exeName,
  }) {
    final String cmdExe =
        Platform.environment['ComSpec'] ?? r'C:\Windows\System32\cmd.exe';
    final commandLine =
        '/d /s /c '
        '"${_quoteCmdArg(scriptPath)} '
        '${_quoteCmdArg(targetDirectoryPath)} '
        '${_quoteCmdArg(extractionDirectoryPath)} '
        '${_quoteCmdArg(exeName)}"';

    using((arena) {
      final PCWSTR appNamePtr = arena.pcwstr(cmdExe);
      final PWSTR cmdLinePtr = arena.pwstr(commandLine);
      final ffi.Pointer<STARTUPINFO> startupInfo = arena<STARTUPINFO>();
      final ffi.Pointer<PROCESS_INFORMATION> processInfo =
          arena<PROCESS_INFORMATION>();

      startupInfo.ref.cb = ffi.sizeOf<STARTUPINFO>();

      final Win32Result(:bool value, :WIN32_ERROR error) = CreateProcess(
        appNamePtr,
        cmdLinePtr,
        null,
        null,
        false,
        CREATE_NO_WINDOW,
        null,
        null,
        startupInfo,
        processInfo,
      );

      if (!value) throw WindowsException(error.toHRESULT());

      CloseHandle(processInfo.ref.hThread);
      CloseHandle(processInfo.ref.hProcess);
    });
  }

  String _quoteCmdArg(String value) => '"${value.replaceAll('"', '""')}"';

  Future<void> _extractZip({
    required List<int> zipBytes,
    required Directory outputDirectory,
  }) async {
    final Archive archive = ZipDecoder().decodeBytes(zipBytes);
    final String outputRoot = p.normalize(outputDirectory.path).toLowerCase();

    for (final file in archive) {
      final String outputPath = p.normalize(
        p.join(outputDirectory.path, file.name),
      );
      if (!p.isWithin(outputRoot, outputPath.toLowerCase())) {
        throw Exception('Unsafe zip entry path: ${file.name}');
      }

      if (file.isFile) {
        final outFile = File(outputPath);
        outFile.parent.createSync(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>, flush: true);
      } else {
        Directory(outputPath).createSync(recursive: true);
      }
    }
  }

  String _normalizeVersion(String value) {
    final String trimmed = value.trim();
    return trimmed.toLowerCase().startsWith('v')
        ? trimmed.substring(1)
        : trimmed;
  }

  bool _isVersionNewer(String latest, String current) {
    final List<int> latestParts = _versionParts(latest);
    final List<int> currentParts = _versionParts(current);
    final int length = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (var index = 0; index < length; index++) {
      final int latestPart = index < latestParts.length
          ? latestParts[index]
          : 0;
      final int currentPart = index < currentParts.length
          ? currentParts[index]
          : 0;
      if (latestPart != currentPart) return latestPart > currentPart;
    }
    return false;
  }

  List<int> _versionParts(String version) => version
      .split(RegExp('[^0-9]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => int.tryParse(part) ?? 0)
      .toList();

  @override
  Widget build(BuildContext context) {
    if (_dismissed ||
        !_doUpdateApp ||
        _latestVersion == null ||
        _currentVersion == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _isDownloading
                      ? 'Downloading version v$_latestVersion...'
                      : 'Update available: v$_latestVersion '
                            '(current v$_currentVersion)',
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
              TextButton(
                onPressed: _isDownloading ? null : _downloadUpdateZip,
                child: const Text('Update'),
              ),
              IconButton(
                onPressed: () => setState(() => _dismissed = true),
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
