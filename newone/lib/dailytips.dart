import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class DailyTipPage extends StatefulWidget {
  const DailyTipPage({super.key});

  @override
  State<DailyTipPage> createState() => _DailyTipPageState();
}

class _DailyTipPageState extends State<DailyTipPage> {
  Map<String, dynamic>? tip;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchRandomTip();
  }

  Future<void> fetchRandomTip() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('daily_tips').get();
    if (snapshot.docs.isEmpty) return;
    final docs = snapshot.docs;
    final randomDoc = (docs..shuffle()).first;
    setState(() {
      tip = randomDoc.data();
    });
  }

  Future<void> saveTip() async {
    if (tip == null || isSaving) return;
    setState(() => isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('saved_tips').add({
        'uid': uid,
        'tip': tip!['text'],
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Tip saved!")),
      );
    } catch (e) {
      print("Error saving tip: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = tip?['text'] ?? "Loading...";
    final author = tip?['author'] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("💡 Daily Tip"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.teal.shade100, Colors.teal.shade300]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '"$quote"',
                      style: const TextStyle(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          color: Colors.teal),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "- $author",
                      style: const TextStyle(fontSize: 16, color: Colors.teal),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: fetchRandomTip,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Another Tip"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                  ElevatedButton.icon(
                    onPressed: saveTip,
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent),
                  ),
                 
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                   onPressed: () {
                      Share.share('💡 $quote',
                          subject: 'Today\'s English Learning Tip');
                    },
                  icon: const Icon(Icons.share),
                  label: const Text("Share"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
