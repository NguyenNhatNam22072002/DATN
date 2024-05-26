import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  // Private constructor to prevent instantiation
  MapUtils._();

  /// [sourceLat] and [sourceLng] represent the source coordinates.
  /// [destinationLat] and [destinationLng] represent the destination coordinates.
  static Future<void> launchMapFromSourceToDestination(
    double sourceLat,
    double sourceLng,
    double destinationLat,
    double destinationLng,
  ) async {
    final mapOptions = [
      'saddr=$sourceLat,$sourceLng',
      'daddr=$destinationLat,$destinationLng',
      'dir_action=navigate',
    ].join('&');

    final mapUrl = Uri.parse('https://www.google.com/maps?$mapOptions');

    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl);
    } else {
      throw Exception("Could not launch $mapUrl");
    }
  }
}
