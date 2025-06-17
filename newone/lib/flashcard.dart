import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardScreen extends StatefulWidget {
  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  final FlipCardController controller = FlipCardController();

  // ✅ Sample flashcard data
  final List<Map<String, String>> flashcards = [
    {'word': 'Apple', 'meaning': 'A red or green fruit 🍎'},
    {'word': 'Run', 'meaning': 'To move fast on foot 🏃‍♂️'},
    {'word': 'Beautiful', 'meaning': 'Very pleasing to the eyes 🌸'},
  ];

  // ✅ Next button logic
  void nextCard() async {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // ✅ All cards viewed: update progress in Firestore
      await _updateProgress(0.3); // Increment by 30%
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 Well done! Progress updated.")),
      );

      // Restart or close
      setState(() {
        currentIndex = 0;
      });
    }
  }

  // ✅ Firestore progress update function
  Future<void> _updateProgress(double valueToAdd) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    final current = (snapshot.data()?['progress'] ?? 0.0).toDouble();
    final updated = (current + valueToAdd).clamp(0.0, 1.0);

    await userDoc.update({'progress': updated});
  }

  @override
  Widget build(BuildContext context) {
    final card = flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Flashcards"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Expanded(
              child: FlipCard(
                controller: controller,
                rotateSide: RotateSide.left,
                frontWidget: _cardFace(card['word']!, isFront: true),
                backWidget: _cardFace(card['meaning']!, isFront: false),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: nextCard,
              child: Text(currentIndex == flashcards.length - 1 ? "Finish" : "Next"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📇 Card UI
  Widget _cardFace(String text, {required bool isFront}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isFront ? Colors.white : Colors.teal[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isFront ? Colors.teal[800] : Colors.black87,
          ),
        ),
      ),
    );
  }
}
