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
  Widget kContainer(String mediaType) {
    return GestureDetector(
      onTap: () => _selectMedia(mediaType),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: mediaType == 'image'
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
        ),
        child: Center(
          child: Icon(
            mediaType == 'image' ? Icons.photo : Icons.videocam,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: selectedMedia == null ? 60 : 80,
          backgroundColor: Colors.white,
          child: Center(
            child: selectedMedia == null
                ? widget.isReg
                    ? Image.asset(
                        AssetManager.addImage,
                        color: accentColor,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(widget.imgUrl),
                      ) // this will load imgUrl from firebase
                : ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: selectedMedia!.path.endsWith('.mp4')
                        ? const Icon(
                            Icons.videocam,
                            size: 50,
                            color: accentColor,
                          )
                        : Image.file(
                            File(selectedMedia!.path),
                          ),
                  ),
          ),
        ),
        const SizedBox(width: 5),
        Column(
          children: [
            kContainer('image'),
            const SizedBox(height: 5),
            kContainer('video')
          ],
        )
      ],
    );
  }
}
