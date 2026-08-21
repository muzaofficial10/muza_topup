import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';

class ScreenshotUploader extends StatefulWidget {
  final ValueChanged<File?> onChanged;
  const ScreenshotUploader({super.key, required this.onChanged});

  @override
  State<ScreenshotUploader> createState() => _ScreenshotUploaderState();
}

class _ScreenshotUploaderState extends State<ScreenshotUploader> {
  File? _file;
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _file = File(picked.path));
      widget.onChanged(_file);
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.neonBlue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.neonBlue),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceElevated,
          border: Border.all(
            color: _file != null ? AppColors.neonBlue : Colors.white.withOpacity(0.08),
            style: BorderStyle.solid,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_upload_rounded, color: AppColors.neonBlue, size: 34),
                  SizedBox(height: 10),
                  Text('Upload Payment Screenshot',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Tap to select an image', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_file!, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: () {
                          setState(() => _file = null);
                          widget.onChanged(null);
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
