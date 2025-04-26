// lib/core/services/image_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  // Mengambil gambar dari kamera
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Kompresi untuk mengurangi ukuran file
      );
      
      if (image != null) {
        return await _saveImageToLocalStorage(File(image.path));
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }
  
  // Mengambil gambar dari galeri
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi untuk mengurangi ukuran file
      );
      
      if (image != null) {
        return await _saveImageToLocalStorage(File(image.path));
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }
  
  // Menyimpan gambar ke penyimpanan lokal
  Future<String> _saveImageToLocalStorage(File imageFile) async {
    try {
      // Mendapatkan direktori aplikasi
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appDirPath = appDir.path;
      
      // Membuat direktori untuk gambar jika belum ada
      final Directory imageDir = Directory('$appDirPath/transaction_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // Membuat nama file unik
      final String fileName = 'img_${const Uuid().v4()}${path.extension(imageFile.path)}';
      final String filePath = '${imageDir.path}/$fileName';
      
      // Menyalin gambar ke direktori aplikasi
      final File localImage = await imageFile.copy(filePath);
      
      return localImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      throw Exception('Failed to save image');
    }
  }
  
  // Menghapus gambar dari penyimpanan lokal
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null) return;
    
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}
