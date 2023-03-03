import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

// final storageRef =
//     FirebaseStorage.instanceFor(bucket: "gs://tome-8879a.appspot.com");

// Future<String> uploadFileToFireBase(
//     File? selectedGameImage, String filePath) async {
//   String result = "";
//   if (selectedGameImage == null) {
//     return result;
//   }

//   try {
//     final fileName = basename(selectedGameImage.path);
//     String imagePath = '$filePath$fileName';
//     final ref = storageRef.ref(imagePath);
//     var res = await ref.putFile(selectedGameImage);
//     if (res.state == TaskState.success) {
//       result = imagePath;
//     }
//   } catch (e) {
//     print(e);
//   }

//   return result;
// }

// Future<String> getImageFromFirebase(String path) async {
//   return await storageRef.ref(path).getDownloadURL();
// }

bool isOfficallySupportedPlatform() {
  return (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
}
