import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SlingButton extends StatelessWidget {
  const new({super.key, required this._authorizationToken});

  final String? _authorizationToken;

  Future<void> loginToSling(BuildContext context) async {
    var isLoading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Log in to Sling'),
              content: SizedBox(
                width: 360,
                child: const Text(
                  'Continue with your Google account to connect Sling.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);

                          try {
                            final oauthResponse = await http.get(
                              Uri.parse(
                                'https://api.getsling.com/v1/account/oauth/google/url',
                              ),
                            );

                            if (!dialogContext.mounted) return;

                            debugPrint(
                              'Sling Google OAuth response: '
                              '${oauthResponse.statusCode} ${oauthResponse.reasonPhrase}',
                            );
                            debugPrint(
                              'Sling Google OAuth body: ${oauthResponse.body}',
                            );

                            if (oauthResponse.statusCode != 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Sling Google login failed '
                                    '(${oauthResponse.statusCode}).',
                                  ),
                                ),
                              );
                              return;
                            }

                            final payload = jsonDecode(oauthResponse.body);
                            final oauthUrl = payload is Map
                                ? payload['url'] ??
                                      payload['redirectUrl'] ??
                                      payload['redirect_url']
                                : null;

                            if (oauthUrl is! String) {
                              throw StateError(
                                'Sling did not return a Google OAuth URL.',
                              );
                            }

                            final launched = await launchUrl(
                              Uri.parse(oauthUrl),
                              mode: LaunchMode.externalApplication,
                            );

                            if (!launched) {
                              throw StateError(
                                'The Google OAuth URL could not be opened.',
                              );
                            }
                          } catch (error) {
                            debugPrint(
                              'Sling login exception: ${error.runtimeType}: $error',
                            );
                            debugPrintStack(
                              label: 'Sling login stack trace',
                              stackTrace: StackTrace.current,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Unable to log in to Sling: $error',
                                ),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setDialogState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue with Google'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => loginToSling(context),
      icon: Icon(
        _authorizationToken == null ? Icons.login : Icons.check_circle,
      ),
      label: Text(
        _authorizationToken == null ? 'Log in to Sling' : 'Sling connected',
      ),
    );
  }
}
