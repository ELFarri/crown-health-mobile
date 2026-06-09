import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart' show XFile;

class ProgressPhoto {
  final String id;
  final String imagePath;
  final DateTime date;
  final double? weight;

  ProgressPhoto({
    required this.id,
    required this.imagePath,
    required this.date,
    this.weight,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'imagePath': imagePath,
    'date': date.toIso8601String(),
    'weight': weight,
  };

  factory ProgressPhoto.fromMap(Map<String, dynamic> map) => ProgressPhoto(
    id: map['id'],
    imagePath: map['imagePath'],
    date: DateTime.parse(map['date']),
    weight: map['weight']?.toDouble(),
  );
}

class ProgressProvider extends ChangeNotifier {
  List<ProgressPhoto> _photos = [];
  List<ProgressPhoto> get photos => _photos;
  String _userEmail = '';

  ProgressProvider() {
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? '';
    await _loadPhotos();
  }

  Future<void> initForUser(String email) async {
    _userEmail = email;
    _photos = [];
    await _loadPhotos();
  }

  void reset() {
    _photos = [];
    _userEmail = '';
    notifyListeners();
  }

  String get _storageKey => 'progress_photos_json_${_userEmail.isNotEmpty ? _userEmail : "local"}';

  Future<void> addPhoto(XFile image, double? weight) async {
    String savedPath;
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      final extension = path.extension(image.path).replaceAll('.', '');
      final mimeType = extension.isEmpty ? 'png' : extension;
      savedPath = 'data:image/$mimeType;base64,${base64Encode(bytes)}';
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
      savedPath = savedImage.path;
    }

    final newPhoto = ProgressPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: savedPath,
      date: DateTime.now(),
      weight: weight,
    );

    _photos.insert(0, newPhoto);
    await _savePhotos();
    notifyListeners();
  }

  Future<void> deletePhoto(String id) async {
    final photoIndex = _photos.indexWhere((p) => p.id == id);
    if (photoIndex != -1) {
      if (!kIsWeb) {
        final photo = _photos[photoIndex];
        final file = File(photo.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _photos.removeAt(photoIndex);
      await _savePhotos();
      notifyListeners();
    }
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? photosJson = prefs.getString(_storageKey);
    if (photosJson != null) {
      final List<dynamic> decoded = jsonDecode(photosJson);
      _photos = decoded.map((item) => ProgressPhoto.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_photos.map((p) => p.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

