// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http; // Import HTTP package
// import 'dart:convert'; // For JSON decoding


// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
//     return const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
//   }
// }

// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   File? _selectedImageFile;
//   Uint8List? _selectedImageBytes;
//   String? _backendResponse; // Variable to store backend response

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xff1D1E22),
//         title: const Text('Image Picker'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             MaterialButton(
//               color: Colors.blue,
//               child: const Text(
//                 "Pick Image from Gallery",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               onPressed: () {
//                 _pickImageFromGallery();
//               },
//             ),
//             MaterialButton(
//               color: Colors.red,
//               child: const Text(
//                 "Pick Image from Camera",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               onPressed: () {
//                 _pickImageFromCamera();
//               },
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             _selectedImageBytes != null
//                 ? Image.memory(_selectedImageBytes!)
//                 : _selectedImageFile != null
//                     ? Image.file(_selectedImageFile!)
//                     : const Text("Please select an image"),
//             const SizedBox(height: 20),
//             _backendResponse != null
//                 ? Text("Backend Response: $_backendResponse")
//                 : const Text("No response from backend yet."),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImageFromGallery() async {
//     final returnedImage =
//         await ImagePicker().pickImage(source: ImageSource.gallery);

//     if (returnedImage == null) return;

//     if (kIsWeb) {
//       final imageBytes = await returnedImage.readAsBytes();
//       setState(() {
//         _selectedImageBytes = imageBytes;
//         _selectedImageFile = null;
//       });
//     } else {
//       setState(() {
//         _selectedImageFile = File(returnedImage.path);
//         _selectedImageBytes = null;
//       });
//     }

//     await _testConnection(); // Call test connection after selecting image
//   }

//   Future<void> _pickImageFromCamera() async {
//     final returnedImage =
//         await ImagePicker().pickImage(source: ImageSource.camera);

//     if (returnedImage == null) return;

//     if (kIsWeb) {
//       final imageBytes = await returnedImage.readAsBytes();
//       setState(() {
//         _selectedImageBytes = imageBytes;
//         _selectedImageFile = null;
//       });
//     } else {
//       setState(() {
//         _selectedImageFile = File(returnedImage.path);
//         _selectedImageBytes = null;
//       });
//     }

//     await _testConnection(); // Call test connection after selecting image
//   }

//   // Function to test backend connection
//   Future<void> _testConnection() async {
//     try {
//       final response = await http.get(Uri.parse('http://10.100.238.70:5002/test'));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _backendResponse = data['message']; // Log the "test string"
//         });
//       } else {
//         setState(() {
//           _backendResponse = "Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _backendResponse = "Error: $e";
//       });
//     }
//   }
// }

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Disease Detection',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const DiseaseDetectionScreen(),
    );
  }
}

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  _DiseaseDetectionScreenState createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _backendResponse;
  bool _isLoading = false;

  Future<void> _testConnection() async {
    const url = 'http://10.100.240.189:5002/test'; // Update Flask API URL
    setState(() {
      _isLoading = true;
      _backendResponse = null;
    });
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          _backendResponse = decodedResponse['message']; // Should return "test string"
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to connect to API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _backendResponse = 'Error connecting to API: $e';
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    if (kIsWeb) {
      final imageBytes = await returnedImage.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
        _selectedImageFile = null;
      });
    } else {
      setState(() {
        _selectedImageFile = File(returnedImage.path);
        _selectedImageBytes = null;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;

    if (kIsWeb) {
      final imageBytes = await returnedImage.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
        _selectedImageFile = null;
      });
    } else {
      setState(() {
        _selectedImageFile = File(returnedImage.path);
        _selectedImageBytes = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedImageBytes != null
                  ? Image.memory(_selectedImageBytes!, height: 200)
                  : _selectedImageFile != null
                      ? Image.file(_selectedImageFile!, height: 200)
                      : const Text('No image selected'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick from Gallery'),
                onPressed: _pickImageFromGallery,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture with Camera'),
                onPressed: _pickImageFromCamera,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_backendResponse != null)
                Text(
                  'Backend Response: $_backendResponse',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Test Connection'),
                  onPressed: _testConnection,
                ),
            ],
          ),
        ),
      ),
    );
  }
}