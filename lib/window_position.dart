import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:nativeapi/nativeapi.dart' show DisplayManager;
import 'package:points_sheet/database.dart';
import 'package:window_manager/window_manager.dart';

class WindowPositionTracker {
  WindowPositionTracker(this._window, this._database);

  final Window _window;
  final AppDatabase _database;
  Timer? _saveTimer;
  Rect? _normalBounds;
  Rect? _pendingBounds;
  bool _isMaximized = false;
  bool? _pendingMaximized;
  Future<void> _writes = Future.value();

  Future<void> initialize() async {
    try {
      final saved = await _database.getWindowPosition();
      if (saved != null) {
        final position = Offset(saved.x, saved.y);
        if (!position.dx.isFinite || !position.dy.isFinite) {
          throw StateError('The saved window position is invalid.');
        }
        Size? savedSize;
        if (saved.width != null || saved.height != null) {
          final width = saved.width;
          final height = saved.height;
          if (width == null ||
              height == null ||
              !width.isFinite ||
              !height.isFinite ||
              width <= 0 ||
              height <= 0) {
            _reportError(
              'restoring the window size',
              StateError('The saved window size is invalid.'),
              StackTrace.current,
            );
          } else {
            savedSize = Size(width, height);
          }
        }
        if (_isVisible(position, savedSize?.width ?? _window.size.width)) {
          if (savedSize == null) {
            _window.position = position.toNative();
          } else {
            _window.bounds = (position & savedSize).toNative();
          }
        } else {
          debugPrint('Saved window position is not on an available display.');
          if (savedSize != null) _window.setSize(savedSize.toNative(), false);
        }
        _normalBounds = _window.bounds.toRect();
        if (saved.isMaximized) _window.maximize();
      }
    } catch (error, stack) {
      _reportError('restoring the window state', error, stack);
    }

    _normalBounds ??= _window.bounds.toRect();
    _isMaximized = _window.isMaximized;
    _window.addListener(_onWindowEvent);
  }

  bool _isVisible(Offset position, double width) {
    final titleBar = Rect.fromLTWH(position.dx, position.dy, width, 32);
    final displays = DisplayManager.instance.getAll();
    try {
      if (displays.isEmpty) {
        throw StateError('No displays were available to restore the window.');
      }
      return displays.any(
        (display) => display.workArea.toRect().overlaps(titleBar),
      );
    } finally {
      for (final display in displays) {
        display.dispose();
      }
    }
  }

  bool get _isNormal =>
      !_window.isMaximized && !_window.isMinimized && !_window.isFullScreen;

  void _updateNormalBounds() {
    if (_isNormal) {
      _normalBounds = _window.bounds.toRect();
      return;
    }
    if (!_window.isMaximized ||
        _window.isMinimized ||
        _window.isFullScreen ||
        _normalBounds == null) {
      return;
    }

    try {
      final bounds = _normalBounds!;
      final maximizedCenter = _window.bounds.toRect().center;
      final displays = DisplayManager.instance.getAll();
      try {
        Rect? sourceArea;
        Rect? targetArea;
        for (final display in displays) {
          final screen = display.position.toOffset() & display.size.toSize();
          if (screen.contains(bounds.center)) {
            sourceArea = display.workArea.toRect();
          }
          if (screen.contains(maximizedCenter)) {
            targetArea = display.workArea.toRect();
          }
        }
        if (targetArea == null) {
          throw StateError('Could not find the maximized window display.');
        }
        if (sourceArea == targetArea) return;

        final x = sourceArea == null
            ? targetArea.center.dx - bounds.width / 2
            : targetArea.left + bounds.left - sourceArea.left;
        final y = sourceArea == null
            ? targetArea.center.dy - bounds.height / 2
            : targetArea.top + bounds.top - sourceArea.top;
        _normalBounds = Rect.fromLTWH(
          bounds.width > targetArea.width
              ? targetArea.center.dx - bounds.width / 2
              : x.clamp(targetArea.left, targetArea.right - bounds.width),
          bounds.height > targetArea.height
              ? targetArea.top
              : y.clamp(targetArea.top, targetArea.bottom - bounds.height),
          bounds.width,
          bounds.height,
        );
      } finally {
        for (final display in displays) {
          display.dispose();
        }
      }
    } catch (error, stack) {
      _reportError('tracking the maximized window display', error, stack);
    }
  }

  Future<void> _onWindowEvent(WindowEvent event) async {
    if (event is WindowMovedEvent ||
        event is WindowResizedEvent ||
        event is WindowMaximizedEvent ||
        event is WindowRestoredEvent) {
      if (!_window.isMinimized) _isMaximized = _window.isMaximized;
      _updateNormalBounds();
      if ((event is WindowMovedEvent || event is WindowResizedEvent) &&
          !_isNormal &&
          (!_window.isMaximized ||
              _window.isMinimized ||
              _window.isFullScreen)) {
        return;
      }
      _pendingBounds = _normalBounds;
      _pendingMaximized = _isMaximized;
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(milliseconds: 250), _queueSave);
    } else if (event is WindowCloseRequestedEvent) {
      _saveTimer?.cancel();
      if (!_window.isMinimized) _isMaximized = _window.isMaximized;
      _updateNormalBounds();
      _pendingBounds = _normalBounds;
      _pendingMaximized = _isMaximized;
      _queueSave();
      await _writes;
    }
  }

  void _queueSave() {
    final bounds = _pendingBounds;
    final isMaximized = _pendingMaximized;
    _pendingBounds = null;
    _pendingMaximized = null;
    if (bounds == null) return;
    _writes = _writes.then((_) async {
      try {
        if (!bounds.left.isFinite ||
            !bounds.top.isFinite ||
            !bounds.width.isFinite ||
            !bounds.height.isFinite ||
            bounds.width <= 0 ||
            bounds.height <= 0) {
          throw StateError('The window bounds are invalid.');
        }
        await _database.saveWindowPosition(
          bounds.left,
          bounds.top,
          width: bounds.width,
          height: bounds.height,
          isMaximized: isMaximized,
        );
      } catch (error, stack) {
        _reportError('saving the window bounds', error, stack);
      }
    });
  }

  void _reportError(String action, Object error, StackTrace stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'window position',
        context: ErrorDescription('while $action'),
      ),
    );
  }
}
