import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../providers/progress_provider.dart';
import '../providers/user_provider.dart';

class ProgressGalleryScreen extends StatefulWidget {
  @override
  _ProgressGalleryScreenState createState() => _ProgressGalleryScreenState();
}

class _ProgressGalleryScreenState extends State<ProgressGalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      _showWeightDialog(image);
    }
  }

  void _showWeightDialog(XFile image) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final weightController = TextEditingController(text: userProvider.weight.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Add weight (Optional)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Weight (kg)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              Provider.of<ProgressProvider>(context, listen: false).addPhoto(image, weight);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.nearlyDarkBlue),
            child: Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final photos = progressProvider.photos;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Progress Gallery", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.darkText,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPickerOptions(),
        backgroundColor: AppTheme.nearlyDarkBlue,
        child: Icon(Icons.add_a_photo, color: Colors.white),
      ),
      body: photos.isEmpty 
        ? _buildEmptyState()
        : GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) => _buildPhotoCard(photos[index]),
          ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Progress Photo", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerBtn(Icons.camera_alt, "Camera", () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildPickerBtn(Icons.photo_library, "Gallery", () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.nearlyDarkBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.nearlyDarkBlue, size: 30),
          ),
          SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 16),
          Text("No progress photos yet", style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text("Tap the + button to add your first photo!", style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(ProgressPhoto photo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: kIsWeb
                    ? Image.network(photo.imagePath, fit: BoxFit.cover)
                    : Image.file(File(photo.imagePath), fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(photo.date), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (photo.weight != null)
                      Text("${photo.weight} kg", style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.nearlyDarkBlue)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _confirmDelete(photo.id),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Photo?"),
        content: Text("Are you sure you want to remove this photo?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<ProgressProvider>(context, listen: false).deletePhoto(id);
              Navigator.pop(context);
            }, 
            child: Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
