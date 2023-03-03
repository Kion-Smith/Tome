import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';
import 'package:window_screenshot/window_screenshot.dart';

typedef ImageSelectorOnSave<T> = void Function(File? newValue);

class ImageSelectorButton extends StatefulWidget {
  final Function(File?) onSelected;
  const ImageSelectorButton({super.key, required this.onSelected});

  @override
  // ignore: library_private_types_in_public_api
  _ImageSelectorButtonState createState() => _ImageSelectorButtonState();
}

class _ImageSelectorButtonState extends State<ImageSelectorButton> {
  final ImagePicker _picker = ImagePicker();

  File? selectedImageFile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * .3,
        width: MediaQuery.of(context).size.width * .95,
        child: Column(
          children: [
            selectedImageFile != null
                ? Expanded(
                    child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRect(
                            child: PhotoView(
                          maxScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained * .1,
                          imageProvider: FileImage(selectedImageFile!),
                        ))))
                : Container(),
            const Padding(padding: EdgeInsets.only(bottom: 15)),
            Wrap(
              spacing: 15.0, // gap between adjacent chips
              runSpacing: 5.0, // gap between lines
              children: defaultTargetPlatform != TargetPlatform.windows
                  ? [
                      ElevatedButton.icon(
                          onPressed: () {
                            _pickPhoneImage(ImageSource.camera);
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Camera")),
                      ElevatedButton.icon(
                          onPressed: () {
                            _pickPhoneImage(ImageSource.gallery);
                          },
                          icon: const Icon(Icons.storage_rounded),
                          label: const Text("Storage"))
                    ]
                  : [
                      ElevatedButton.icon(
                          onPressed: () {
                            _screenshotImage();
                          },
                          icon: const Icon(Icons.storage_rounded),
                          label: const Text("Screenshot an Image")),
                      ElevatedButton.icon(
                          onPressed: () {
                            _pickDesktopImage();
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Pick an Image")),
                    ],
            )
          ],
        ));
  }

  Widget _buildSelectionButton() {
    return ElevatedButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).toggleableActiveColor)),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => _buildAddGamePopUp());

        Navigator.of(context).pop(selectedImageFile);
      },
      child: const Text("Select Image"),
    );
  }

  Widget _buildAddGamePopUp() {
    return AlertDialog(
      content: Column(
        children: [
          selectedImageFile != null
              ? Expanded(
                  child: PhotoView(
                  imageProvider: FileImage(selectedImageFile!),
                ))
              : Container(),
          ElevatedButton(
              onPressed: () {
                _pickPhoneImage(ImageSource.camera);
              },
              child: const Text("Camera")),
          ElevatedButton(
              onPressed: () {
                _pickPhoneImage(ImageSource.gallery);
              },
              child: const Text("Storage")),
        ],
      ),
      actions: [_buildCancelButton(), _buildSelectButton()],
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).errorColor)),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );
  }

  Widget _buildSelectButton() {
    return ElevatedButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).toggleableActiveColor)),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Select"),
    );
  }

  void _pickPhoneImage(ImageSource source) async {
    final selectedImage = await _picker.pickImage(source: source);
    setState(() {
      if (selectedImage != null) {
        selectedImageFile = File(selectedImage.path);
        widget.onSelected(selectedImageFile);
        //widget._image = selectedImageFile;
      }
    });
  }

  void _pickDesktopImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      String? x = result.files.single.path;
      File selectedImage = File(x!);
      setState(() {
        if (selectedImage != null) {
          selectedImageFile = File(selectedImage.path);
          widget.onSelected(selectedImageFile);
        }
      });
    }
  }

  void _screenshotImage() async {
    Uint8List? screenshot = await WindowScreenshot().getMonitorScreenshot(0, 5);
    if (screenshot != null) {
      //File screenshotImage = File.fromRawPath(screenshot);
      Uuid uuid = Uuid();
      final tempDir = await getTemporaryDirectory();
      File screenshotImage =
          await File('${tempDir.path}\\${uuid.v4()}.png').create();
      screenshotImage.writeAsBytesSync(screenshot);

      setState(() {
        selectedImageFile = screenshotImage;
        widget.onSelected(selectedImageFile);
      });
    }
  }
}
