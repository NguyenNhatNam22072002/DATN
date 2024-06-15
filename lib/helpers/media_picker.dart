import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/color.dart';
import '../resources/assets_manager.dart';

class MediaPicker extends StatefulWidget {
  const MediaPicker({
    Key? key,
    required this.selectMedia,
    this.isReg = true,
    this.imgUrl = AssetManager.avatar,
  }) : super(key: key);

  final Function(File, String) selectMedia;
  final bool isReg;
  final String imgUrl;

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  XFile? selectedMedia;
  final ImagePicker _picker = ImagePicker();

  // for selecting photo or video
  Future _selectMedia(String mediaType) async {
    XFile? pickedMedia;
    if (mediaType == 'image') {
      pickedMedia = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
      );
    } else if (mediaType == 'video') {
      pickedMedia = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
    }

    if (pickedMedia == null) {
      return null;
    }

    widget.selectMedia(File(pickedMedia.path), mediaType);

    // assign the picked media to the selectedMedia
    setState(() {
      selectedMedia = pickedMedia;
    });
  }

  // widget for each media selector
  Widget mediaButton(String mediaType, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _selectMedia(mediaType),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: selectedMedia == null
                ? widget.isReg
                    ? Image.asset(
                        AssetManager.addImage,
                        color: accentColor,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        widget.imgUrl,
                        fit: BoxFit.cover,
                      )
                : selectedMedia!.path.endsWith('.mp4')
                    ? const Icon(
                        Icons.videocam,
                        size: 50,
                        color: accentColor,
                      )
                    : Image.file(
                        File(selectedMedia!.path),
                        fit: BoxFit.cover,
                      ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            mediaButton('image', Icons.photo, Colors.blueAccent),
            const SizedBox(width: 20),
            mediaButton('video', Icons.videocam, Colors.redAccent),
          ],
        ),
      ],
    );
  }
}
