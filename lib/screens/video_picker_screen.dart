import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class VideoPickerScreen extends StatefulWidget {
  const VideoPickerScreen({super.key});

  @override
  State<VideoPickerScreen> createState() => _VideoPickerScreenState();
}

class _VideoPickerScreenState extends State<VideoPickerScreen> {
  late String _filePath;
  late String _framePath;
  late TextEditingController frameNumberController;

  @override
  void initState() {
    super.initState();
    _filePath = '';
    _framePath = '';
    frameNumberController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Frame Extractor'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        pickVideo();
                      },
                      child: const Text('Pick Video'),
                    ),
                    if (_filePath.isNotEmpty)
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _filePath = '';
                              _framePath = '';
                              frameNumberController.text = '';
                            });
                          },
                          child: const Text('Clear'))
                  ],
                ),
                Text(_filePath),
                const SizedBox(height: 16),
                if (_filePath.isNotEmpty)
                  TextField(
                    controller: frameNumberController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter the frame number',
                      hintText: 'e.g. 100',
                    ),
                    inputFormatters: [
                      //To remove whitespaces after each character
                      FilteringTextInputFormatter.deny(RegExp(r' \s+')),
                    ],
                  ),
                if (_filePath.isNotEmpty)
                  ValueListenableBuilder(
                    valueListenable: frameNumberController,
                    builder: (context, value, child) => Opacity(
                      opacity: frameNumberController.text.isNotEmpty ? 1 : 0.5,
                      child: ElevatedButton(
                          onPressed: () {
                            if (_filePath.isNotEmpty &&
                                frameNumberController.text.isNotEmpty) {
                              extractFrame(
                                  int.tryParse(frameNumberController.text) ?? 0,
                                  _filePath);
                            }
                          },
                          child: const Text('Get Frame')),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_filePath.isNotEmpty)
                  Center(
                    child: _framePath.isNotEmpty
                        ? FutureBuilder(
                            key: UniqueKey(),
                            future: () async {
                              imageCache.clear();
                              imageCache.clearLiveImages();
                            }(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Container(
                                  color: Colors.black.withOpacity(0.1),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.file(File(_framePath),
                                        fit: BoxFit.fitHeight),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          )
                        : const Text('Extracting frame...'),
                  ),
              ],
            ),
          ),
        ));
  }

  Future<void> pickVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (file != null) {
      setState(() {
        _filePath = file.path;
      });
    }
  }

  Future<void> extractFrame(int frameNumber, String videoPath) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final String framePath =
          await const MethodChannel('video_frame_extractor').invokeMethod(
              'extractFrame',
              {'frameNumber': frameNumber, 'videoPath': videoPath});
      setState(() {
        _framePath = framePath;
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to extract frame: '${e.message}'.");
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Failed to extract frame: '${e.message}'."),
          ),
        );
      }
    }
  }
}
