import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nature_connect/services/get_location.dart';
import 'dart:io';

class CamScanner extends StatefulWidget {
  @override
  _CamScannerState createState() => _CamScannerState();
}

class _CamScannerState extends State<CamScanner> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  bool _isPlantButtonClicked = false;
  bool _isAnimalButtonClicked = false;
  XFile? _image;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Map<String, String>? getCommonName(String responseBody) {
    // Parse JSON response
    final parsedResponse = json.decode(responseBody);

    // Get the list of suggestions
    final suggestions =
        parsedResponse['result']['classification']['suggestions'];

    // Initialize variables to track the highest probability and the result map
    double highestProbability = 0.0;
    Map<String, String>? result;

    // Loop through each suggestion to find the one with the highest probability
    for (var suggestion in suggestions) {
      final probability = suggestion['probability'];
      final commonNames = suggestion['details']['common_names'];
      final description = suggestion['details']['description']['value'];

      // Check if this suggestion has a higher probability
      if (probability != null &&
          commonNames != null &&
          description != null &&
          probability > highestProbability) {
        highestProbability = probability;

        // Assuming we want the first common name if multiple are available
        final commonName = commonNames.isNotEmpty ? commonNames[0] : null;

        // Create the result map with common name as key and description as value
        result = {commonName: description};
      }
    }

    // Return the result map with the highest probability
    return result;
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  // Capture image from camera
  Future<void> _captureImage() async {
    try {
      final image = await _controller!.takePicture();
      setState(() {
        _image = image;
      });

      // Get current location
      Position? position = await _locationService.getCurrentLocation();

      if (position != null) {
        if (_isPlantButtonClicked) {
          _callPlantApi(image, position.latitude, position.longitude);
        } else if (_isAnimalButtonClicked) {
          _callAnimalApi(image, position.latitude, position.longitude);
        }
      } else {
        Fluttertoast.showToast(msg: "Unable to get location.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error capturing image: $e");
    }
  }

  // Call the plant identification API
  Future<void> _callPlantApi(
      XFile image, double latitude, double longitude) async {
    try {
      String base64Image = base64Encode(await image.readAsBytes());
      final response = await http.post(
        Uri.parse(
            'https://plant.id/api/v3/identification?details=common_names%2Cdescription'),
        headers: {
          'Api-Key': 'WrbrH6d6pyviWao0eTkL4OVx0RnBuNQl69xxVY0FsHidvPTzeM',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "images": ["data:image/jpg;base64,$base64Image"],
          "latitude": latitude,
          "longitude": longitude,
          "similar_images": true,
        }),
      );

      print(response.body);
      final result = getCommonName(response.body);
      if (result != null && result.isNotEmpty) {
        final commonName = result.keys.first;
        final description = result[commonName];

        // Show the result in a modal
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(commonName ?? 'No common name available'),
            content: Text(description ?? 'No description available'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Fluttertoast.showToast(msg: 'Failed to identify plant.');
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Error calling API: $e");
    }
  }

  // Call the animal identification API
  Future<void> _callAnimalApi(
      XFile image, double latitude, double longitude) async {
    try {
      String base64Image = base64Encode(await image.readAsBytes());
      final response = await http.post(
        Uri.parse(
            'https://api.animal.id/identify'), // Replace with actual animal API
        headers: {
          'Authorization': 'Bearer your_api_key',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "images": ["data:image/jpg;base64,$base64Image"],
        }),
      );

      if (response.statusCode == 200) {
        // Show the result in a modal
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Animal Identification'),
            content: Text('Animal identified: ${response.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Fluttertoast.showToast(msg: 'Failed to identify animal.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error calling API: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Full-screen camera preview
                Column(
                  children: [
                    Expanded(
                      child: CameraPreview(_controller!),
                    ),
                  ],
                ),
                // Back button at the top-left corner
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Overlay buttons centered on the screen
                if (!_isPlantButtonClicked && !_isAnimalButtonClicked)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isPlantButtonClicked = true;
                            });
                          },
                          child: Text('Plant'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isAnimalButtonClicked = true;
                            });
                          },
                          child: Text('Animal'),
                        ),
                      ],
                    ),
                  ),
                // Display captured image preview at the bottom
                if (_image != null)
                  Positioned(
                    bottom: 100,
                    child: Center(
                      child: Image.file(
                        File(_image!.path),
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                // Capture button at the bottom-center of the screen
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _captureImage,
                      child: Text('Capture'),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Show loader until camera initializes
    );
  }
}
