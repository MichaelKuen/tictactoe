// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/services/google_identity.dart';

const _user = GoogleSignInUserData(
  id: 'sub-42',
  email: 'player@example.com',
  displayName: 'Player',
);

/// Stands in for the Android plugin.
class FakeGoogle extends GoogleSignInPlatform {
  GoogleSignInExceptionCode? fail;
  bool restorable = false;
  int initCalls = 0;
  int signOuts = 0;

  AuthenticationResults get _result => const AuthenticationResults(
    user: _user,
    authenticationTokens: AuthenticationTokenData(idToken: 'token'),
  );

  @override
  Future<void> init(InitParameters params) async => initCalls++;

  @override
  Future<AuthenticationResults?> attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async => restorable ? _result : null;

  @override
  bool supportsAuthenticate() => true;

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    if (fail case final code?) throw GoogleSignInException(code: code);
    return _result;
  }

  @override
  Future<void> signOut(SignOutParams params) async => signOuts++;

  @override
  Future<void> disconnect(DisconnectParams params) async {}

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async => null;

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async => null;
}

void main() {
  late FakeGoogle google;
  GoogleIdentityService service({String clientId = 'client.apps'}) =>
      GoogleIdentityService(serverClientId: clientId, platform: google);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    google = FakeGoogle();
  });

  test('signs in with the Google account ID and remembers it', () async {
    final identity = service();
    expect(await identity.signIn(), isTrue);
    expect(identity.player!.id, 'sub-42');
    expect(identity.player!.label, 'Player');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('tictactoe.identity.signedIn'), isTrue);

    await identity.signOut();
    expect(identity.player, isNull);
    expect(google.signOuts, 1);
    expect(prefs.getBool('tictactoe.identity.signedIn'), isFalse);
  });

  test('cancelling is not an error', () async {
    google.fail = GoogleSignInExceptionCode.canceled;
    expect(await service().signIn(), isFalse);
  });

  test('a missing OAuth client explains that sign-in is not set up', () async {
    expect(
      () => service(clientId: '').signIn(),
      throwsA(
        isA<SignInException>().having(
          (e) => e.message,
          'message',
          contains('isn’t set up'),
        ),
      ),
    );
    google.fail = GoogleSignInExceptionCode.clientConfigurationError;
    expect(service().signIn(), throwsA(isA<SignInException>()));
    expect(google.initCalls, lessThanOrEqualTo(1));
  });

  test('other failures ask the player to try again', () async {
    google.fail = GoogleSignInExceptionCode.interrupted;
    expect(
      service().signIn(),
      throwsA(
        isA<SignInException>().having(
          (e) => e.message,
          'message',
          contains('try again'),
        ),
      ),
    );
  });

  test('start-up only contacts Google for returning players', () async {
    google.restorable = true;
    final first = service();
    await first.init();
    expect(google.initCalls, 0);
    expect(first.player, isNull);

    SharedPreferences.setMockInitialValues({
      'tictactoe.identity.signedIn': true,
    });
    final returning = service();
    await returning.init();
    expect(returning.player!.id, 'sub-42');
  });

  test('signing in logs purchases in with the same ID', () async {
    final purchases = FakePurchasesService();
    final identity = service();
    CoreKit(
      config: const CoreKitConfig(gameId: 'tictactoe', gameName: 'Tic Tac Toe'),
      settings: SettingsController(gameId: 'tictactoe'),
      ads: NoAdsService(),
      purchases: purchases,
      analytics: NoAnalytics(),
      identity: identity,
    ).linkPurchasesToIdentity();
    await identity.signIn();
    expect(purchases.appUserId, 'sub-42');
  });
}
