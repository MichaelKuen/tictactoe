// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The OAuth "Web application" client ID from Google Cloud that Android
/// sign-in needs. Not set up yet: pass it at build time with
/// `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` once it exists.
const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Sign in with Google, used only to give purchases a stable player ID (the
/// Google account's OpenID subject) across App Verse Games apps.
///
/// Uses the Android implementation directly rather than the `google_sign_in`
/// app package: that package's web plugin loads Google's sign-in script at
/// start-up, and the web build must load nothing from outside.
class GoogleIdentityService extends IdentityService {
  GoogleIdentityService({
    this._serverClientId = googleServerClientId,
    GoogleSignInPlatform? platform,
  }) : _platformOverride = platform;

  final String _serverClientId;
  final GoogleSignInPlatform? _platformOverride;
  Future<void>? _ready;
  PlayerIdentity? _player;

  static const _signedInKey = 'tictactoe.identity.signedIn';
  static const _notSetUp =
      'Sign-in with Google isn’t set up in this version yet. You can keep '
      'playing without it.';

  GoogleSignInPlatform get _platform =>
      _platformOverride ?? GoogleSignInPlatform.instance;

  bool get _configured => _serverClientId.isNotEmpty;

  @override
  bool get isAvailable => true;

  @override
  PlayerIdentity? get player => _player;

  @override
  String get signInLabel => 'Sign in with Google';

  Future<void> _init() => _ready ??= _platform.init(
    InitParameters(serverClientId: _serverClientId),
  );

  @override
  Future<void> init() async {
    // Only touch Google at start-up for players who signed in before.
    final prefs = await SharedPreferences.getInstance();
    if (!_configured || !(prefs.getBool(_signedInKey) ?? false)) return;
    await _init();
    final result = await _platform.attemptLightweightAuthentication(
      const AttemptLightweightAuthenticationParameters(),
    );
    if (result != null) await _setPlayer(result.user);
  }

  @override
  Future<bool> signIn() async {
    if (!_configured) throw const SignInException(_notSetUp);
    try {
      await _init();
      final result = await _platform.authenticate(
        const AuthenticateParameters(),
      );
      await _setPlayer(result.user);
      return true;
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          return false;
        case GoogleSignInExceptionCode.clientConfigurationError ||
            GoogleSignInExceptionCode.providerConfigurationError:
          throw const SignInException(_notSetUp);
        default:
          throw const SignInException(
            'Couldn’t sign in with Google. Please try again.',
          );
      }
    }
  }

  @override
  Future<void> signOut() async {
    if (_ready != null) await _platform.signOut(const SignOutParams());
    await _setPlayer(null);
  }

  Future<void> _setPlayer(GoogleSignInUserData? user) async {
    _player = user == null
        ? null
        : PlayerIdentity(
            id: user.id,
            displayName: user.displayName,
            email: user.email,
          );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, user != null);
    notifyListeners();
  }
}
