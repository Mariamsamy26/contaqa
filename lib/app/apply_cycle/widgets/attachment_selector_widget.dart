import 'dart:io';
import 'package:contaqa/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/styles/text_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AttachmentSelectorWidget extends StatefulWidget {
  final Function(File?) onImageSelected;
  const AttachmentSelectorWidget({super.key, required this.onImageSelected});

  @override
  State<AttachmentSelectorWidget> createState() =>
      _AttachmentSelectorWidgetState();
}

class _AttachmentSelectorWidgetState extends State<AttachmentSelectorWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        widget.onImageSelected(_selectedImage);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('supporting_document'),
          style: mediumText.copyWith(fontSize: 14.sp, color: black),
        ),
        SizedBox(height: 10.h),
        if (_selectedImage != null)
          Stack(
            children: [
              Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: royalBlue.withOpacity(0.5)),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: _clearImage,
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: white, size: 16.sp),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildSelectorButton(
                  icon: Icons.camera_alt,
                  label: languageProvider.translate('camera'),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: _buildSelectorButton(
                  icon: Icons.photo_library,
                  label: languageProvider.translate('gallery'),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSelectorButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: black.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: royalBlue.withValues(alpha: 0.85), size: 28.sp),
            SizedBox(height: 5.h),
            Text(
              label,
              style: mediumText.copyWith(
                color: royalBlue.withValues(alpha: 0.85),
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
