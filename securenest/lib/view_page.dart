import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewFilesPage extends StatefulWidget {
  const ViewFilesPage({super.key});

  @override
  State<ViewFilesPage> createState() => _ViewFilesPageState();
}

class _ViewFilesPageState extends State<ViewFilesPage> {
  final _auth = FirebaseAuth.instance;
  late final String userId;

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

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Scaffold(body: Center(child: Text('No user signed in.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Uploaded Files')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('userId', isEqualTo: userId)
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No files uploaded yet.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final fileName = data['fileName'] ?? 'Unnamed';
              final fileType = data['fileType'] ?? '';
              final downloadUrl = data['downloadUrl'] ?? '';
              final uploadedAt = (data['uploadedAt'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.insert_drive_file,
                    color: Colors.blue[700],
                  ),
                  title: Text(fileName),
                  subtitle: Text(
                    'Type: $fileType\nUploaded: ${uploadedAt.toLocal()}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(downloadUrl))) {
                        await launchUrl(Uri.parse(downloadUrl));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open file')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
