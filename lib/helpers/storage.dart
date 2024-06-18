import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<String> uploadImage(
    String bucketName, File imageFile, String fileName) async {
  try {
    await supabase.storage.from(bucketName).upload(fileName, imageFile);

    return fileName;
  } catch (e) {
    print(e.toString());

    return "";
  }
}

String getImageUrl(String bucketName, String fileName) {
  return supabase.storage.from(bucketName).getPublicUrl(fileName);

  // return fileUrl;
}
