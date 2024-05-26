//// Function for getting current location
//import 'package:geocoding/geocoding.dart';
//import 'package:geolocator/geolocator.dart';
//
//import '../global/global.dart';
//
//class UserLocation {
//  Future<Position?> getCurrentLocation() async {
//    bool serviceEnabled;
//    LocationPermission permission;
//
//    // Check if location services are enabled
//    serviceEnabled = await Geolocator.isLocationServiceEnabled();
//    if (!serviceEnabled) {
//      return Future.error('Location services are disabled.');
//    }
//
//    // Check and request location permissions
//    permission = await Geolocator.checkPermission();
//    if (permission == LocationPermission.denied) {
//      permission = await Geolocator.requestPermission();
//      if (permission == LocationPermission.denied) {
//        return Future.error('Location permissions are denied.');
//      }
//    }
//
//    if (permission == LocationPermission.deniedForever) {
//      return Future.error(
//          'Location permissions are permanently denied, we cannot request permissions.');
//    }
//
//    // Get the current position
//    Position newPosition = await Geolocator.getCurrentPosition(
//      desiredAccuracy: LocationAccuracy.high,
//    );
//
//    // Update global position variable
//    position = newPosition;
//
//    // Get placemarks from coordinates
//    List<Placemark> placeMarks = await placemarkFromCoordinates(
//      position!.latitude,
//      position!.longitude,
//    );
//
//    // Get the first placemark
//    Placemark pMark = placeMarks[0];
//
//    // Form the complete address
//    completeAddress =
//        '${pMark.thoroughfare}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea}, ${pMark.country}';
//
//    return newPosition;
//  }
//}
//