// =================================================================================================================
// FILE: lib/providers/progress_provider.dart
// PURPOSE: GLOBAL PROGRESS MANAGER — manages the user's progress photos (before/after).
//          Stores local file paths of photos taken by the user along with their weight and date.
//          Data is persisted locally in SharedPreferences.
// =================================================================================================================

import 'dart:io';                                             // For handling file operations on device storage
import 'dart:convert';                                        // For JSON encoding and decoding
import 'package:flutter/foundation.dart';                     // Core Flutter foundation tools (e.g. kIsWeb)
import 'package:path_provider/path_provider.dart';            // To get directories for storing files on iOS/Android
import 'package:path/path.dart' as path;                      // Utility library for file path manipulations
import 'package:shared_preferences/shared_preferences.dart';  // Persistent local storage key-value pair database
import 'package:image_picker/image_picker.dart' show XFile;   // Abstract file type returned by camera/gallery picker

// ─────────────────────────────────────────────────────────────────────────────
// ProgressPhoto — Data class for a progress photo entry
// ─────────────────────────────────────────────────────────────────────────────
class ProgressPhoto {
  final String id;          // Unique ID generated using the timestamp
  final String imagePath;   // File path (on mobile) or Base64 URI string (on Web) of the progress picture
  final DateTime date;      // The date the progress picture was taken
  final double? weight;     // The weight of the user at that date (optional)

  ProgressPhoto({
    required this.id,
    required this.imagePath,
    required this.date,
    this.weight,
  });

  // Convert progress photo object into a JSON-serializable Map (dictionary)
  Map<String, dynamic> toMap() => {
    'id': id,
    'imagePath': imagePath,
    'date': date.toIso8601String(), // Serialize DateTime to ISO 8601 string format
    'weight': weight,
  };

  // Create a progress photo object from a deserialized Map (dictionary)
  factory ProgressPhoto.fromMap(Map<String, dynamic> map) => ProgressPhoto(
    id: map['id'],
    imagePath: map['imagePath'],
    date: DateTime.parse(map['date']),
    weight: map['weight']?.toDouble(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProgressProvider — ChangeNotifier to notify UI components on state updates
// ─────────────────────────────────────────────────────────────────────────────
class ProgressProvider extends ChangeNotifier {
  List<ProgressPhoto> _photos = [];               // In-memory list storing the user's progress photo history
  List<ProgressPhoto> get photos => _photos;      // Getter for the list of photos (read-only for UI)
  String _userEmail = '';                         // Active user's email to segment storage per user profile

  ProgressProvider() {
    _loadUserEmail();                             // Automatically load the active user session on startup
  }

  // Load the current active user's email from shared preferences to isolate progress data
  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('user_email') ?? '';
    await _loadPhotos();                          // Fetch progress photos once user context is loaded
  }

  // Initialize provider and load history for a specific user upon login/switch
  Future<void> initForUser(String email) async {
    _userEmail = email;
    _photos = [];
    await _loadPhotos();
  }

  // Reset progress photos memory when user logs out
  void reset() {
    _photos = [];
    _userEmail = '';
    notifyListeners();                            // Re-build any UI listening to this progress manager
  }

  // Segmented SharedPreferences storage key to keep user photos private and separate
  String get _storageKey => 'progress_photos_json_${_userEmail.isNotEmpty ? _userEmail : "local"}';

  // Add a new photo entry to the local list, save to disk, and copy file to local storage if mobile
  Future<void> addPhoto(XFile image, double? weight) async {
    String savedPath;
    if (kIsWeb) {
      // For Flutter Web, load the raw bytes and convert them into a Base64 Data URI
      final bytes = await image.readAsBytes();
      final extension = path.extension(image.path).replaceAll('.', '');
      final mimeType = extension.isEmpty ? 'png' : extension;
      savedPath = 'data:image/$mimeType;base64,${base64Encode(bytes)}';
    } else {
      // For mobile devices, copy the temp image file to the app documents directory for permanent persistence
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
      savedPath = savedImage.path;
    }

    // Build the new progress entry model
    final newPhoto = ProgressPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: savedPath,
      date: DateTime.now(),
      weight: weight,
    );

    _photos.insert(0, newPhoto);                  // Insert the new photo at the front (reverse chronological order)
    await _savePhotos();                          // Write updated list to shared preferences database
    notifyListeners();                            // Update the gallery view UI
  }

  // Remove a photo entry by ID, delete the file from mobile storage, and save changes
  Future<void> deletePhoto(String id) async {
    final photoIndex = _photos.indexWhere((p) => p.id == id);
    if (photoIndex != -1) {
      if (!kIsWeb) {
        // On mobile, delete the actual image file from storage to free up user device space
        final photo = _photos[photoIndex];
        final file = File(photo.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _photos.removeAt(photoIndex);               // Remove item from in-memory list
      await _savePhotos();                        // Save modified list to disk
      notifyListeners();                          // Refresh the UI screen
    }
  }

  // Read saved JSON progress photo list from SharedPreferences and parse into models
  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? photosJson = prefs.getString(_storageKey);
    if (photosJson != null) {
      final List<dynamic> decoded = jsonDecode(photosJson);
      _photos = decoded.map((item) => ProgressPhoto.fromMap(item)).toList();
      notifyListeners();
    }
  }

  // Convert the current list of photos to JSON string and store in SharedPreferences
  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_photos.map((p) => p.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
