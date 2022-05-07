import 'package:permission_handler/permission_handler.dart' as appPermissions;


List<String> extractNumbers(List<String> contacts) {
  return contacts.map((e) {
    return e.substring(e.length - 13);
  }).toList();
}


checkPermission() async {
    appPermissions.PermissionStatus conPer =
        await appPermissions.Permission.contacts.status;
    appPermissions.PermissionStatus locPer =
        await appPermissions.Permission.location.status;
    appPermissions.PermissionStatus phonePer =
        await appPermissions.Permission.phone.status;
    appPermissions.PermissionStatus smsPer =
        await appPermissions.Permission.sms.status;
    if (conPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.contacts.request();
    }
    if (locPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.location.request();
    }
    if (phonePer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.phone.request();
    }
    if (smsPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.sms.request();
    }
  }