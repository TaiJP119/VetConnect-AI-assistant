import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class WasteSortScreen extends StatefulWidget {
  const WasteSortScreen({super.key});

  @override
  State<WasteSortScreen> createState() => _WasteSortScreenState();
}

class _WasteSortScreenState extends State<WasteSortScreen> {
  int maxPeople = 1; // 1 people
  int maxTimeCooking = 15; // 10 minutes
  final textController = TextEditingController();
  XFile? image;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI assist',
            style: GoogleFonts.notoSans(color: Colors.white, fontSize: 18.0)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 56, 228, 128),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  imagePickerMethod();
                },
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: image != null
                      ? Image.file(File(image!.path))
                      : Image.asset('assets/images/pick_image.png'),
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    var recipe = await generateWasteSortbyAI(
                        maxPeople, maxTimeCooking, textController.text, image);
                    openButtomBar(recipe);
                  } catch (e) {
                    log(e.toString());

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something went wrong')));
                  }

                  setState(() {
                    isLoading = false;
                  });
                },
                style: ElevatedButton.styleFrom(fixedSize: const Size(400, 40)),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Generate by AI'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Show loading
  void showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  // Hide loading
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  // Method to pick image from gallery
  Future<void> imagePickerMethod() async {
    final picker = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picker != null) {
      setState(() {
        image = picker;
      });
    }
  }

  // Method to open bottom bar
  void openButtomBar(var recipe) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(recipe.toString()),
            ),
          );
        });
  }

  // Method to generate waste sort by Gemini
  Future<List<String>> generateWasteSortbyAI(int people, int maxTimeCooking,
      String? intoleranceOrLimits, XFile? picture) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyDbYz3Wb6hOxA3Z0XtjiG0XVJ6PTPU-v98',
    );

    final prompt = _generatePrompt(people, maxTimeCooking, intoleranceOrLimits);
    final image = await picture!.readAsBytes();
    final mimetype = picture.mimeType ?? 'image/jpeg';

    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart(mimetype, image)])
    ]);

    // return response.skipWhile((response) => response.text != null).map((event) => event.text!);
    log(response.text!);
    return [response.text!];
  }

  // Method to generate prompt
  String _generatePrompt(
      int people, int maxTimeCooking, String? intoleranceOrLimits) {
    String prompt =
        '''Give me the answer in point form and what should i do in short.
  ''';

    if (intoleranceOrLimits != null) {
      prompt += 'Based on the image: $intoleranceOrLimits';
    }

    return prompt;
  }
}
