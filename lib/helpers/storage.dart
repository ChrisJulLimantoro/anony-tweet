import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

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
}

void downloadImage(String fileUrl) async {
  var response = await http.get(Uri.parse(fileUrl), headers: {
    "responseType": "blob",
  });

  await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.bodyBytes),
      quality: 80,
      name: "PCUFess_${DateTime.now().millisecondsSinceEpoch}");
}
