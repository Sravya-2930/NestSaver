import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isUploading = false;
  final _auth = FirebaseAuth.instance;
  late String userId;

  final List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'jpg', 'png'];
  final int maxFileSize = 10 * 1024 * 1024; // 10MB

  final List<Map<String, dynamic>> categories = [
    {'name': 'College', 'color': const Color(0xFFA8D5BA), 'icon': Icons.school},
    {
      'name': 'Personal',
      'color': const Color(0xFFFED6C1),
      'icon': Icons.person,
    },
    {'name': 'Office', 'color': const Color(0xFFBFD7ED), 'icon': Icons.work},
    {'name': 'Others', 'color': const Color(0xFFE6C8F2), 'icon': Icons.folder},
  ];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
    } else {
      userId = '';
    }
  }

  Color _darkerColor(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Future<void> _pickAndUploadFiles(String category) async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not signed in')));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null) return;

    setState(() => _isUploading = true);

    for (final file in result.files) {
      try {
        final fileName = file.name;
        final fileBytes = file.bytes;
        final fileSize = file.size;
        final fileExt = fileName.split('.').last.toLowerCase();

        if (!allowedExtensions.contains(fileExt)) continue;
        if (fileSize > maxFileSize) continue;
        if (fileBytes == null) throw 'Failed to read file bytes';

        final storageRef = FirebaseStorage.instance.ref().child(
          'uploads/$userId/$category/$fileName',
        );
        await storageRef.putData(fileBytes);
        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('documents').add({
          'userId': userId,
          'category': category,
          'fileName': fileName,
          'fileType': fileExt,
          'downloadUrl': downloadUrl,
          'uploadedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName uploaded in $category ✅'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading ${file.name}: $e')),
        );
      }
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Scaffold(body: Center(child: Text('No user signed in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Files by Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          physics: const NeverScrollableScrollPhysics(), // No scroll
          children: categories.map((category) {
            final iconColor = _darkerColor(category['color']);
            return Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: InkWell(
                onTap: _isUploading
                    ? null
                    : () => _pickAndUploadFiles(category['name']),
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.black12,
                child: Container(
                  decoration: BoxDecoration(
                    color: category['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'],
                        size: 40, // smaller icon
                        color: iconColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isUploading)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: iconColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
