import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinks {
  // create a link with params
  static Future<Uri> createLinkWithParams(Map<String, String> data) =>
      _getLink('mylink', data);

  // create a short link with params
  static FutureOr<Uri> _getLink(
      String category, Map<String, String> args) async {
    final Uri longLink = await _getParams(category, args).buildUrl();

    final ShortDynamicLink shortLink = await DynamicLinkParameters.shortenUrl(
      longLink,
      new DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );

    return shortLink.shortUrl;
  }

  // create a link with all our params and retrun DynamucLinkParameters
  static DynamicLinkParameters _getParams(
          String category, Map<String, String> args) =>
      DynamicLinkParameters(
        uriPrefix: 'https://fleepage.page.link',
        link: Uri.https('fleepage.page.link', category, args),
        androidParameters: AndroidParameters(
          packageName: 'fleepage.pocketshopping',
        ),
        iosParameters: IosParameters(bundleId: 'fleepage.pocketshopping'),
      );
}
