import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VocabularyQuizPage extends StatefulWidget {
  const VocabularyQuizPage({super.key});

  @override
  _VocabularyQuizPageState createState() => _VocabularyQuizPageState();
}

class _VocabularyQuizPageState extends State<VocabularyQuizPage> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool answered = false;
  int score = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }
Future<void> markVocabularyTaskComplete() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final today = DateTime.now().toString().substring(0, 10);

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('progress')
      .doc(today)
      .set({'vocabulary': true}, SetOptions(merge: true));
}

  Future<void> fetchQuestions() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('vocabulary_quiz').get();
      final fetchedQuestions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'question': data['question'] ?? '',
          'options': List<String>.from(data['options'] ?? []),
          'answerIndex': data['answerIndex'] ?? 0,
        };
      }).toList();

      setState(() {
        questions = fetchedQuestions;
        loading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void _selectOption(int index) {
    if (answered) return;

    setState(() {
      selectedOptionIndex = index;
      answered = true;

      if (index == questions[currentQuestionIndex]['answerIndex']) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    if (!answered) return;

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
        answered = false;
      });
    } else {
      _showFinalScore();
       if (score < questions.length) {
      print("Try again.");
    } else {
      markVocabularyTaskComplete(); // ✅ Save progress
    }
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text('Your score: $score / ${questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() async {
                currentQuestionIndex = 0;
                score = 0;
                selectedOptionIndex = null;
                answered = false;
              
              });
            },
            child: const Text('Restart',style: TextStyle(color: Colors.teal),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.teal),),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vocabulary Quiz'),
          backgroundColor: Colors.teal[300],
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/reading.gif', 
                height: 200,
              ),
              const SizedBox(height: 30),
              const Text(
                'Loading your quiz...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vocabulary Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = questions[currentQuestionIndex];
    final options = question['options'] as List<String>;
    final answerIndex = question['answerIndex'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Quiz'),
        backgroundColor: Colors.teal[300],
      ),
      body:Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/back.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        
        
       Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Text(
                question['question'] as String,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ...List.generate(options.length, (index) {
                Color optionColor = Colors.grey.shade200;

                if (answered) {
                  if (index == answerIndex) {
                    optionColor = Colors.green.shade300;
                  } else if (index == selectedOptionIndex) {
                    optionColor = Colors.red.shade300;
                  }
                }

                return GestureDetector(
                  onTap: () => _selectOption(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: optionColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      options[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  ElevatedButton(
                    onPressed: answered ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Next'),
                  )
                ],
              )
            ],
          ),
        ),],
      ),
    );
  }
}
