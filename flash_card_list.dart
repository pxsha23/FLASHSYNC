import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_flashcard_screen.dart';
import '../models/flashcard.dart';
import 'dart:math' show pi;

class FlashcardListScreen extends StatefulWidget {
  final String userId;
  const FlashcardListScreen({super.key, required this.userId});

  @override
  _FlashcardListScreenState createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;
  AnimationController? _animationController;
  Animation<double>? _flipAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    _flipAnimation?.addListener(() {
      setState(() {});
    });
  }

  void _toggleCard() {
    setState(() {
      _showAnswer = !_showAnswer;
      if (_showAnswer) {
        _animationController?.forward();
      } else {
        _animationController?.reverse();
      }
    });
  }

  void _nextCard(int totalCards) {
    setState(() {
      _currentIndex = (_currentIndex + 1) % totalCards;
      _showAnswer = false;
    });
    _animationController?.reset();
  }

  void _previousCard(int totalCards) {
    if (totalCards > 1) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + totalCards) % totalCards;
        _showAnswer = false;
      });
      _animationController?.reset();
    }
  }

  void _validateCurrentIndex(int totalCards) {
    if (totalCards == 0) {
      _currentIndex = 0;
    } else if (_currentIndex >= totalCards) {
      _currentIndex = totalCards - 1;
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
        title: const Text('FLASHSYNC', style: TextStyle(color: Color.fromARGB(255, 180, 37, 144),fontStyle: FontStyle.italic,fontWeight: FontWeight.bold)),
        // const Color.fromARGB(255, 180, 37, 144)
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 246, 209, 233), Color.fromARGB(255, 246, 207, 231)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('flashcards')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final flashcards = snapshot.data!.docs.map((doc) {
              return Flashcard.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>);
            }).toList();

            _validateCurrentIndex(flashcards.length);

            if (flashcards.isEmpty) {
              return const Center(
                child: Text(
                  'No flashcards yet!\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFlippableCard(flashcards[_currentIndex]),
                    ),
                  ),
                ),
                _buildControlBar(flashcards.length),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 136, 219),
        child:  const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddEditFlashcardScreen(userId: widget.userId)),
          );
        },
      ),
    );
  }

  Widget _buildFlippableCard(Flashcard flashcard) {
    final angle = (_flipAnimation?.value ?? 0);
    //ignore: unused_local_variable
    final isBack = angle >= pi / 2;

    return GestureDetector(
      onTap: _toggleCard,
      onLongPress: () => _showEditDeleteOptions(context, flashcard),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: angle),
        duration: const Duration(milliseconds: 20),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value),
            child: value >= pi / 2
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardSide(flashcard, true),
                  )
                : _buildCardSide(flashcard, false),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(Flashcard flashcard, bool isAnswer) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.width * 1.2,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isAnswer
                ? [const Color.fromARGB(255, 255, 255, 255),const Color.fromARGB(255, 255, 255, 255)] //ans card
                : [const Color.fromARGB(255, 214, 217, 236), const Color.fromARGB(255, 254, 173, 217)]  //question card
                // : [const Color.fromARGB(255, 255, 255, 255),const Color.fromARGB(255, 255, 255, 255)], //question card
                //: [Colors.indigo.shade50, const Color.fromARGB(255, 254, 173, 217)]  //answer card
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isAnswer ? 'Answer' : 'Question',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 97, 97, 97),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isAnswer ? flashcard.answer : flashcard.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (!isAnswer)
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Tap to flip \nTap and hold to edit and delete',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(int totalCards) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _previousCard(totalCards),
            color: const Color.fromARGB(255, 120, 118, 119),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:  const Color.fromARGB(255, 120, 118, 119).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentIndex + 1} / $totalCards',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 120, 118, 119),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _nextCard(totalCards),
            color: const Color.fromARGB(255, 120, 118, 119),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(Flashcard flashcard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditFlashcardScreen(
          userId: widget.userId,
          flashcard: flashcard,
        ),
      ),
    );
  }

  void _showEditDeleteOptions(BuildContext context, Flashcard flashcard) {
    const Color primaryBlue =Color.fromARGB(255, 180, 37, 144);
    const Color lightBlue = Color.fromARGB(255, 253, 227, 244);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            top: 24.0,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar at the top
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToEdit(flashcard);
                    },
                    leading: const Icon(Icons.edit, color: primaryBlue),
                    title: const Text(
                      'Edit',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    tileColor: Colors.white,
                    hoverColor: lightBlue,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[200],
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(context, widget.userId, flashcard.id);
                    },
                    leading: const Icon(Icons.delete_outline, color:Color.fromARGB(255, 180, 37, 144)),
                    title: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Color.fromARGB(255, 180, 37, 144),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    tileColor: Colors.white,
                    hoverColor: Colors.red[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String userId, String flashcardId) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color.fromARGB(255, 250, 218, 236), width: 2),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 249, 209, 237),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color.fromARGB(255, 180, 37, 144),
                  size: 40,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Alert!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 223, 118, 195),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Are you sure you want to delete this flashcard? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 137, 133, 135),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color.fromARGB(255, 224, 103, 180)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color.fromARGB(255, 207, 110, 170),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ Color.fromARGB(255, 248, 180, 228),  Color.fromARGB(255, 248, 180, 228)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('flashcards')
                            .doc(flashcardId)
                            .delete();
                        Navigator.pop(context);

                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Color.fromARGB(255, 137, 133, 135),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showDeleteDialog(BuildContext context, String userId, String flashcardId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(
        Icons.delete_rounded,
        color: Color.fromARGB(255, 255, 118, 184),
        size: 32,
      ),
      title: const Text(
        'Delete Flashcard',
        style: TextStyle(
          color: Color.fromARGB(255, 206, 95, 154),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Are you sure you want to delete this flashcard? This action cannot be undone.',
        style: TextStyle(
          color: Color.fromARGB(255, 226, 74, 160),
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color.fromARGB(255, 243, 33, 152), width: 1.5),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color.fromARGB(255, 243, 33, 163),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('flashcards')
                .doc(flashcardId)
                .delete();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 243, 33, 159),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
