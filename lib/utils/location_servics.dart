import 'package:location/location.dart';

class LocationServices {
  Location location = Location();

  Future<bool> checkAndRquestLocationServices() async {
    var isServicedEnabled = await location.serviceEnabled();
    if (!isServicedEnabled) {
      var isServicedEnabled = await location.requestService();
      if (!isServicedEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkAndRquestPermissionServices() async {
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionStatus == PermissionStatus.denied) {
      var permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    }
    return true;
  }

  getLocatioin( void Function(LocationData)? onData) {
    location.onLocationChanged.listen(onData);
  }
}
