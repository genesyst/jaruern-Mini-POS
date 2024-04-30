


import 'package:permission_handler/permission_handler.dart';

class BLRepository{

  Future RequestAllPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.accessMediaLocation,
      Permission.notification,
      Permission.mediaLibrary,
      Permission.storage,
      Permission.photos,
      Permission.mediaLibrary
    ].request();

    if(statuses[Permission.location]!.isDenied){ //check each permission status after.
      print("Location permission is denied.");
    }

    if(statuses[Permission.camera]!.isDenied){ //check each permission status after.
      print("Camera permission is denied.");
    }

  }

  Future<bool> RequestLocationPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location
    ].request();

    if(statuses[Permission.location]!.isDenied){ //check each permission status after.
      print("Location permission is denied.");
      return Future.value(false);
    }

    return Future.value(true);

  }

}