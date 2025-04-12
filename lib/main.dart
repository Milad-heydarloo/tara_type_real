// controllers/voice_controller.dart
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
        fontFamily: 'vazir',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VoiceToTextScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VoiceToTextScreen extends StatelessWidget {
  const VoiceToTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoiceController());

    return Scaffold(
      appBar: AppBar(title: const Text('تبدیل صوت به متن'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voice recording button
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.toggleListening,
                icon: Icon(
                  controller.state.isListening ? Icons.mic_off : Icons.mic,
                  size: 24,
                ),
                label: Text(
                  controller.state.isListening
                      ? 'توقف ضبط صوت'
                      : 'شروع ضبط صوت',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            // Sound level indicator
            Obx(
              () =>
                  controller.state.isListening
                      ? Column(
                        children: [
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: controller.state.soundLevel / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.withOpacity(0.7),
                            ),
                          ),
                        ],
                      )
                      : const SizedBox(),
            ),

            // Recognized text display
            const SizedBox(height: 24),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                constraints: const BoxConstraints(minHeight: 100),
                child: Text(
                  controller.state.recognizedText.isEmpty
                      ? 'متن تشخیص داده شده اینجا نمایش داده می‌شود...'
                      : controller.state.recognizedText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        controller.state.recognizedText.isEmpty
                            ? Colors.grey
                            : Colors.black,
                  ),
                ),
              ),
            ),

            // Action buttons row
            const SizedBox(height: 16),
            Row(
              children: [
                // Add text button
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.state.recognizedText.isEmpty
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
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Undo button
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.state.currentHistoryIndex > 0
                              ? controller.undo
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('عقب', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Redo button
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.state.currentHistoryIndex <
                                  controller.state.textHistory.length - 1
                              ? controller.redo
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('جلو', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text('خروجی اصلی متن : ', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),

            // Main text field
            TextField(
              controller: controller.textController,
              maxLines: 15,
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
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text('تاریخچه متن : ', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.state.textHistory.length,
                  itemBuilder: (context, index) {
                    final isActive =
                        controller.state.currentHistoryIndex == index;
                    return MouseRegion(
                      onEnter:
                          (_) => controller._updateState(
                            currentHistoryIndex: index,
                          ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller._updateState(currentHistoryIndex: index);
                            controller._updateTextFromHistory();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? Colors.blue.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.1),
                              border:
                                  isActive
                                      ? Border.all(color: Colors.blue, width: 2)
                                      : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 4,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              controller.state.textHistory[index],
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isActive
                                        ? Colors.blue.shade800
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class VoiceController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final _state = Rx<AppState>(
    AppState(
      isListening: false,
      recognizedText: '',
      soundLevel: 0.0,
      textHistory: [],
      currentHistoryIndex: -1,
    ),
  );

  final textController = TextEditingController();
  final scrollController = ScrollController();

  AppState get state => _state.value;

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
            _updateState(isListening: false);
          }
        },
        onError: (error) {
          _updateState(isListening: false);
        },
      );
    } catch (e) {
      print('خطا در مقداردهی اولیه: $e');
    }
  }

  void _updateState({
    bool? isListening,
    String? recognizedText,
    double? soundLevel,
    List<String>? textHistory,
    int? currentHistoryIndex,
  }) {
    _state.value = _state.value.copyWith(
      isListening: isListening,
      recognizedText: recognizedText,
      soundLevel: soundLevel,
      textHistory: textHistory,
      currentHistoryIndex: currentHistoryIndex,
    );
  }

  Future<void> toggleListening() async {
    try {
      if (state.isListening) {
        await _speech.stop();
        _updateState(isListening: false);
      } else {
        await _speech.stop();
        await Future.delayed(const Duration(milliseconds: 200));

        final available = await _speech.initialize();
        if (available) {
          _updateState(isListening: true, recognizedText: '');

          _speech.listen(
            onResult:
                (result) =>
                    _updateState(recognizedText: result.recognizedWords),
            localeId: 'fa-IR',
            listenFor: const Duration(minutes: 1),
            cancelOnError: true,
            partialResults: true,
            onSoundLevelChange: (level) {
              _updateState(soundLevel: level ?? 0);
            },
          );
        }
      }
    } catch (e) {
      _updateState(isListening: false);
    }
  }

  void addToTextField() {
    String textToAdd = state.recognizedText;
    if (textToAdd.isNotEmpty && !textToAdd.endsWith(' ')) {
      textToAdd += ' ';
    }

    final newText = textController.text + textToAdd;
    textController.text = newText;
    textController.selection = TextSelection.collapsed(offset: newText.length);

    // Add to history
    List<String> newHistory = List.from(state.textHistory);
    if (state.currentHistoryIndex < newHistory.length - 1) {
      newHistory.removeRange(state.currentHistoryIndex + 1, newHistory.length);
    }
    newHistory.add(newText);

    _updateState(
      textHistory: newHistory,
      currentHistoryIndex: newHistory.length - 1,
    );

    _scrollToCurrent();
  }

  void undo() {
    if (state.currentHistoryIndex > 0) {
      _updateState(currentHistoryIndex: state.currentHistoryIndex - 1);
      _updateTextFromHistory();
      _scrollToCurrent();
    }
  }

  void redo() {
    if (state.currentHistoryIndex < state.textHistory.length - 1) {
      _updateState(currentHistoryIndex: state.currentHistoryIndex + 1);
      _updateTextFromHistory();
      _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          state.currentHistoryIndex * 70.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateTextFromHistory() {
    if (state.currentHistoryIndex >= 0 &&
        state.currentHistoryIndex < state.textHistory.length) {
      textController.text = state.textHistory[state.currentHistoryIndex];
      textController.selection = TextSelection.collapsed(
        offset: state.textHistory[state.currentHistoryIndex].length,
      );
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

// models/history_item.dart

class HistoryItem {
  final String text;
  final int id;

  HistoryItem({required this.text, required this.id});
}

// models/app_state.dart
class AppState {
  bool isListening;
  String recognizedText;
  double soundLevel;
  List<String> textHistory;
  int currentHistoryIndex;

  AppState({
    required this.isListening,
    required this.recognizedText,
    required this.soundLevel,
    required this.textHistory,
    required this.currentHistoryIndex,
  });

  AppState copyWith({
    bool? isListening,
    String? recognizedText,
    double? soundLevel,
    List<String>? textHistory,
    int? currentHistoryIndex,
  }) {
    return AppState(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      soundLevel: soundLevel ?? this.soundLevel,
      textHistory: textHistory ?? this.textHistory,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
    );
  }
}
