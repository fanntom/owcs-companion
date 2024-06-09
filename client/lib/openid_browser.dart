import 'dart:async';
import 'dart:html';

import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;

Future<Credential> authenticate(Client client, {List<String> scopes = const []}) async {
  var authenticator = browser.Authenticator(client, scopes: scopes);

  authenticator.authorize();

  return Completer<Credential>().future;
}

Future<Credential?> getRedirectResult(Client client, {List<String> scopes = const []}) async {
  var authenticator = browser.Authenticator(client, scopes: scopes);

  var c = await authenticator.credential;

  return c;
}

Future<void> signOut(Credential credential) async {
  final tokenResponse = await credential.getTokenResponse();
  var endSessionEndpoint = credential.client.issuer.metadata.endSessionEndpoint;
  if (endSessionEndpoint != null) {
    var url = Uri.parse(endSessionEndpoint.toString() + "?id_token_hint=${tokenResponse.idToken}&post_logout_redirect_uri=http://localhost:4200/");
    window.location.href = url.toString();
  }
  credential.revoke();
}
