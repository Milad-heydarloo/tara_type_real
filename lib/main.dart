import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'تبدیل صوت به متن',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VoiceToTextScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class HistoryItem {
  final String text;
  final int id;

  HistoryItem({
    required this.text,
    required this.id,
  });
}
class VoiceController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  var isListening = false.obs;
  var recognizedText = ''.obs;
  var soundLevel = 0.0.obs;
  var textHistory = <String>[].obs;
  var currentHistoryIndex = (-1).obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            isListening(false);
          }
        },
        onError: (error) {
          isListening(false);
        },
      );
    } catch (e) {
      print('خطا در مقداردهی اولیه: $e');
    }
  }

  Future<void> toggleListening() async {
    try {
      if (isListening.value) {
        await _speech.stop();
        isListening(false);
      } else {
        await _speech.stop();
        await Future.delayed(const Duration(milliseconds: 200));

        final available = await _speech.initialize();
        if (available) {
          isListening(true);
          recognizedText('');

          _speech.listen(
            onResult: (result) => recognizedText(result.recognizedWords),
            localeId: 'fa-IR',
            listenFor: const Duration(minutes: 1),
            cancelOnError: true,
            partialResults: true,
            onSoundLevelChange: (level) {
              soundLevel(level ?? 0);
            },
          );
        }
      }
    } catch (e) {
      isListening(false);
    }
  }

  void addToTextField() {
    String textToAdd = recognizedText.value;
    if (textToAdd.isNotEmpty && !textToAdd.endsWith(' ')) {
      textToAdd += ' ';
    }

    final newText = textController.text + textToAdd;
    textController.text = newText;
    textController.selection = TextSelection.collapsed(offset: newText.length);

    // Add to history
    if (currentHistoryIndex.value < textHistory.length - 1) {
      textHistory.removeRange(currentHistoryIndex.value + 1, textHistory.length);
    }
    textHistory.add(newText);
    currentHistoryIndex(textHistory.length - 1);

    _scrollToCurrent();
  }

  // در کلاس VoiceController، متدهای undo و redo را به این صورت به‌روزرسانی کنید:
  void undo() {
    if (currentHistoryIndex.value > 0) {
      currentHistoryIndex(currentHistoryIndex.value - 1);
      _updateTextFromHistory();
      _scrollToCurrent();
    }
  }

  void redo() {
    if (currentHistoryIndex.value < textHistory.length - 1) {
      currentHistoryIndex(currentHistoryIndex.value + 1);
      _updateTextFromHistory();
      _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          currentHistoryIndex.value * 70.0, // ارتفاع تقریبی هر آیتم
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateTextFromHistory() {
    if (currentHistoryIndex.value >= 0 &&
        currentHistoryIndex.value < textHistory.length) {
      textController.text = textHistory[currentHistoryIndex.value];
      textController.selection = TextSelection.collapsed(
        offset: textHistory[currentHistoryIndex.value].length,
      );
      _scrollToCurrent();
    }
  }



  @override
  void onClose() {
    _speech.stop();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

class VoiceToTextScreen extends StatelessWidget {
  const VoiceToTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoiceController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('تبدیل صوت به متن'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voice recording button
            Obx(() => ElevatedButton.icon(
              onPressed: controller.toggleListening,
              icon: Icon(
                controller.isListening.value ? Icons.mic_off : Icons.mic,
                size: 24,
              ),
              label: Text(
                controller.isListening.value ? 'توقف ضبط صوت' : 'شروع ضبط صوت',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )),

            // Sound level indicator
            Obx(() => controller.isListening.value
                ? Column(
              children: [
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: controller.soundLevel.value / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.withOpacity(0.7),
                  ),
                ),
              ],
            )
                : const SizedBox()),

            // Recognized text display
            const SizedBox(height: 24),
            Obx(() => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              constraints: const BoxConstraints(minHeight: 100),
              child: Text(
                controller.recognizedText.value.isEmpty
                    ? 'متن تشخیص داده شده اینجا نمایش داده می‌شود...'
                    : controller.recognizedText.value,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.recognizedText.value.isEmpty
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            )),

            // Action buttons row
            const SizedBox(height: 16),
            Row(
              children: [
                // Add text button
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.recognizedText.value.isEmpty
                        ? null
                        : controller.addToTextField,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'افزودن به متن',
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
                ),

                const SizedBox(width: 10),

                // Undo button
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.currentHistoryIndex.value > 0
                        ? controller.undo
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'عقب',
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
                ),

                const SizedBox(width: 10),

                // Redo button
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.currentHistoryIndex.value <
                        controller.textHistory.length - 1
                        ? controller.redo
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'جلو',
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
                ),
              ],
            ),

            // Main text field
            const SizedBox(height: 24),
            TextField(
              controller: controller.textController,
              maxLines: 8,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'متن نهایی اینجا نمایش داده می‌شود...',
                hintTextDirection: TextDirection.rtl,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 16),
            ),

            // Text history
            const SizedBox(height: 16),
            // در قسمت لیست تاریخچه، کد را به این صورت تغییر دهید:
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() {
                return ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.textHistory.length,
                  itemBuilder: (context, index) {
                    final isActive = controller.currentHistoryIndex.value == index;
                    return MouseRegion(
                      onEnter: (_) => controller.currentHistoryIndex(index),
                      onExit: (_) => controller.currentHistoryIndex(controller.currentHistoryIndex.value),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.currentHistoryIndex(index);
                            controller._updateTextFromHistory();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              border: isActive
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              controller.textHistory[index],
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? Colors.blue.shade800 : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}