import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeDashboard extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final String userName = data['name'] ?? 'User';
            final double progress = (data['progress'] ?? 0.0).toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi $userName 👋", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text("Let's learn something new today!",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
                  SizedBox(height: 30),

                  Text("Today's Progress",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  SizedBox(height: 30),

                  Text("Today's Plan",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10),
                  _taskCard("🗣️ Speaking Practice", "10 minutes conversation"),
                  _taskCard("📖 Vocabulary Quiz", "10 new words today"),
                  _taskCard("✍️ Writing Task", "Write 1 short paragraph"),
                  SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/flashcards');
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("🧠 Learn with Flashcards", style: GoogleFonts.poppins(fontSize: 16)),
                          Icon(Icons.arrow_forward_ios, color: Colors.teal)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  Row(
                    children: [
                      _miniCard("🔥 3-day streak", Colors.orange[100]!),
                      SizedBox(width: 16),
                      _miniCard("💡 Tip: Read out loud", Colors.yellow[100]!),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _taskCard(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.teal),
          SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
          ]),
        ],
      ),
    );
  }

  Widget _miniCard(String text, Color bgColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 14)),
      ),
    );
  }
}
