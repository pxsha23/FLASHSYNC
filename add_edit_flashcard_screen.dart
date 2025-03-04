import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flashcard.dart';

class AddEditFlashcardScreen extends StatefulWidget {
  final String userId;
  final Flashcard? flashcard;

  const AddEditFlashcardScreen({super.key, required this.userId, this.flashcard});

  @override
  _AddEditFlashcardScreenState createState() => _AddEditFlashcardScreenState();
}

class _AddEditFlashcardScreenState extends State<AddEditFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = false;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    if (widget.flashcard != null) {
      _questionController.text = widget.flashcard!.question;
      _answerController.text = widget.flashcard!.answer;
    }
  }

  void _saveFlashcard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final flashcardData = {
          'question': _questionController.text.trim(),
          'answer': _answerController.text.trim(),
          'createdAt': DateTime.now(),
        };

        if (widget.flashcard == null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('flashcards')
              .add(flashcardData);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('flashcards')
              .doc(widget.flashcard!.id)
              .update(flashcardData);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving flashcard. Please try again.'),
            backgroundColor: Color.fromARGB(255, 4, 4, 4),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.flashcard == null ? 'Create Flashcard' : 'Edit Flashcard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Preview Card
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _showAnswer
                              ? _answerController.text.isEmpty ? 'Answer Preview' : _answerController.text
                              : _questionController.text.isEmpty ? 'Question Preview' : _questionController.text,
                          style: TextStyle(
                            fontSize: 18,
                            color: _questionController.text.isEmpty && !_showAnswer ||
                                _answerController.text.isEmpty && _showAnswer
                                ? Colors.grey
                                : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // Flip Button
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAnswer = !_showAnswer;
                      });
                    },
                    icon: Icon(Icons.flip),
                    label: Text(_showAnswer ? 'Show Question' : 'Show Answer'),
                  ),
                  SizedBox(height: 32),
                  // Question Field
                  TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: 'Question',
                      prefixIcon: Icon(Icons.help_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) => value!.trim().isEmpty ? 'Please enter a question' : null,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 24),
                  // Answer Field
                  TextFormField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      labelText: 'Answer',
                      prefixIcon: Icon(Icons.check_circle_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) => value!.trim().isEmpty ? 'Please enter an answer' : null,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 32),
                  // Save Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveFlashcard,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text(
                          'Save Flashcard',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );*/



     return Scaffold(
      backgroundColor:  const Color.fromARGB(255, 249, 206, 236),
      appBar: AppBar(
        //upper scaffold color
        backgroundColor:const Color.fromARGB(255, 202, 198, 236),
        elevation: 0,
        title: Text(
          widget.flashcard == null ? 'Create Flashcard' : 'Edit Flashcard',
          style: const TextStyle(
            fontStyle: FontStyle.italic,  // Italic text
            //letterSpacing: 1.5,  // Adjust spacing between letters
            fontWeight: FontWeight.bold,
            color:  Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Preview Card with enhanced design
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.indigo.shade50,const Color.fromARGB(255, 254, 173, 217)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 242, 226, 226).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(255, 167, 150, 163),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _showAnswer
                              ? _answerController.text.isEmpty ? 'Answer Preview' : _answerController.text
                              : _questionController.text.isEmpty ? 'Question Preview' : _questionController.text,
                          style: TextStyle(
                            fontSize: 20,
                            color: _questionController.text.isEmpty && !_showAnswer ||
                                    _answerController.text.isEmpty && _showAnswer
                                ? const Color.fromARGB(255, 210, 106, 162)
                                : const Color.fromARGB(255, 192, 21, 112),
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic, 
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  
                  // Flip Button with enhanced design
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAnswer = !_showAnswer;
                        });
                      },
                      icon: const Icon(Icons.flip, color: Color.fromARGB(255, 229, 30, 163)),
                      label: Text(
                        _showAnswer ? 'Show Question' : 'Show Answer',
                        style: const TextStyle(color: Color.fromARGB(255, 209, 41, 145)),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Question Field with enhanced design
                  TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: 'Question',
                      labelStyle: const TextStyle(color: Color.fromARGB(255, 203, 107, 169)),
                      prefixIcon: const Icon(Icons.help_outline, color: Color.fromARGB(255, 245, 66, 176)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 249, 144, 226)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 249, 144, 209)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 229, 30, 159)),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) => value!.trim().isEmpty ? 'Please enter a question' : null,
                    onChanged: (value) => setState(() {}),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Answer Field with enhanced design
                  TextFormField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      labelText: 'Answer',
                      labelStyle: const TextStyle(color: Color.fromARGB(255, 203, 107, 169)),
                      prefixIcon: const Icon(Icons.check_circle_outline, color: Color.fromARGB(255, 245, 66, 176)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 249, 144, 226)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 249, 144, 209)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 229, 30, 159)),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) => value!.trim().isEmpty ? 'Please enter an answer' : null,
                    onChanged: (value) => setState(() {}),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button with enhanced design
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveFlashcard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 198, 236),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor:const Color.fromARGB(255, 225, 98, 168),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 12),
                                Text(
                                  'Save Flashcard',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic, 
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
