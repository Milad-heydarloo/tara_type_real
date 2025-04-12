import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart';
import 'dart:math';

void main() {
  runApp(const TaraVoiceApp());
}

class TaraVoiceApp extends StatelessWidget {
  const TaraVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      theme: _buildTaraTheme(),
      home: const VoiceToTextScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTaraTheme() {
    return ThemeData(
      fontFamily: 'vazir',
      primaryColor: const Color(0xFF8E24AA),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8E24AA),
        secondary: Color(0xFFFFC107),
        surface: Color(0xFF37474F),
        background: Color(0xFF263238),
        onBackground: Color(0xFFCFD8DC),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF7B1FA2),
        elevation: 4,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'vazir',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          foregroundColor: const Color(0xFF263238),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'vazir',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'vazir',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'vazir',
          color: Colors.white,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'vazir',
          color: Color(0xFFCFD8DC),
          fontSize: 16,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF37474F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA68C8), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA68C8), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(
          fontFamily: 'vazir',
          color: Colors.grey[400],
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'vazir',
          color: Color(0xFFBA68C8),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF37474F),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}

class VoiceToTextScreen extends StatelessWidget {
  const VoiceToTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoiceController());
    final theme = Theme.of(context);

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        color: isMobile ? Colors.transparent : Colors.white, // پس‌زمینه سفید برای صفحات بزرگ


        child: Stack(
          children: [

            // بک‌گراند اصلی
            if (isMobile)
          Container(
      decoration: BoxDecoration(
      image: DecorationImage(
      image: AssetImage('images/tt.png'),
      fit: BoxFit.fill,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.darken,
      ),
    ),
    ),
    ),

    // برای صفحات بزرگ - لوگو در مرکز با سایز اصلی
    if (!isMobile)
    Center(
    child: Container(
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage('images/ff.png'),
    fit: BoxFit.none, // سایز اصلی بدون تغییر

    ),
    ),
    width: 200, // سایز دلخواه برای لوگو
    height: 500,
    ),
    ),


            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTaraHeader(theme,context),
                  const SizedBox(height: 24),
                  Obx(
                        () => ElevatedButton.icon(
                      onPressed: controller.toggleListening,
                      icon: Icon(
                        controller.state.isListening ? Icons.mic_off : Icons.mic,
                        size: 28,
                        color: const Color(0xFF263238),
                      ),
                      label: Text(
                        controller.state.isListening ? 'توقف ضبط صوت' : 'شروع ضبط صوت',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: controller.state.isListening
                            ? const Color(0xFFFBC02D)
                            : const Color(0xFFFFEB3B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                        () => controller.state.isListening
                        ? LinearProgressIndicator(
                      value: controller.state.soundLevel / 100,
                      backgroundColor: Colors.grey[700],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBA68C8)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    )
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                        () => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFBA68C8),
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(minHeight: 120),
                      child: Text(
                        controller.state.recognizedText.isEmpty
                            ? 'متن تشخیص داده شده اینجا نمایش داده می‌شود...'
                            : controller.state.recognizedText,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 17,
                          color: controller.state.recognizedText.isEmpty
                              ? Colors.grey[400]
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                              () => ElevatedButton(
                            onPressed: controller.state.recognizedText.isEmpty
                                ? null
                                : controller.addToTextField,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFFFFEB3B),
                              foregroundColor: const Color(0xFF263238),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'افزودن به متن',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                              () => ElevatedButton(
                            onPressed: controller.state.currentHistoryIndex > 0
                                ? controller.undo
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'عقب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                              () => ElevatedButton(
                            onPressed: controller.state.currentHistoryIndex <
                                controller.state.textHistory.length - 1
                                ? controller.redo
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFFBA68C8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'جلو',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'خروجی اصلی متن:',
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.textController,
                    maxLines: 15,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'متن نهایی اینجا نمایش داده می‌شود...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      hintTextDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'تاریخچه متن:',
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    return Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: const Color(0xFF9C27B0),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        controller: controller.scrollController,
                        itemCount: controller.state.textHistory.length,
                        itemBuilder: (context, index) {
                          final isActive = controller.state.currentHistoryIndex == index;
                          return MouseRegion(
                            onEnter: (_) => controller.updateCurrentHistoryIndex(index),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  controller.updateCurrentHistoryIndex(index);
                                  controller.updateTextFromHistory();
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF9C27B0).withOpacity(0.3)
                                        : Colors.transparent,
                                    border: isActive
                                        ? Border.all(
                                      color: const Color(0xFFBA68C8),
                                      width: 1.5,
                                    )
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    controller.state.textHistory[index],
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                      isActive ? FontWeight.bold : FontWeight.normal,
                                      color: isActive ? Colors.white : Colors.white70,
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
            // لوگوی گرد در گوشه صفحه

          ],
        ),
      ),
    );

  }

  Widget _buildTaraHeader(ThemeData theme, BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // محتوای اصلی کارت
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30), // فضای برای لوگو
                const Center(
                  child: Text(
                    'برنامه اختصاصی صدای قلم تارا',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'مترجم، نویسنده',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.purple[100],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.favorite,
                        color: Colors.pink,
                        size: 30),
                    onPressed: () => _showHelpDialog(context),
                    tooltip: 'راهنما',
                  ),
                ),
              ],
            ),

            // لوگوی گرد در داخل کارت - سمت راست بالا
            Positioned(
              top: -2, // کمی خارج از کارت برای افکت زیبا
              right: -2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final controller = Get.find<VoiceController>();
                    controller.incrementLogoClick();
                    if (controller.logoClicks.value == 2) {
                      _showSecretMessage(context, controller);
                      controller.resetLogoClick();
                    }
                  },
                  splashColor: Colors.purple.withOpacity(0.3),
                  highlightColor: Colors.purple.withOpacity(0.1),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF263238),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'images/ff.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, color: Colors.purple[300]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showHelpDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'راهنمای استفاده',
      titleStyle: const TextStyle(color: Color(0xFFFFC107)),
      content: const Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          '1. دکمه میکروفون را فشار دهید\n'
              '2. صحبت کنید\n'
              '3. از دکمه "افزودن به متن" استفاده کنید\n'
              '4. با دکمه‌های عقب و جلو در تاریخچه حرکت کنید',
          style: TextStyle(fontSize: 16),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107)),
        child: const Text('متوجه شدم'),
      ),
    );
  }

  List<Map<String, dynamic>> _getTimeBasedMessages() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // صبح (5 صبح تا 12 ظهر)
      return [
        {
          "text": "صبح بخیر تارای عزیزم! روزت پرانرژی باشه ☀️",
          "emoji": "🌞",
          "color": Colors.amber
        },
        {
          "text": "صدای قشنگ تو بهترین شروع برای این صبح زیباست",
          "emoji": "🌅",
          "color": Colors.orange
        }
      ];
    }
    else if (hour >= 12 && hour < 17) {
      // بعدازظهر (12 ظهر تا 5 بعدازظهر)
      return [
        {
          "text": "وقت نوشتنه تارا جان! ایده‌هات رو با من درمیان بذار",
          "emoji": "✍️",
          "color": Colors.blue
        },
        {
          "text": "عصرت پر از خلاقیت و انرژی باشه",
          "emoji": "🌤️",
          "color": Colors.lightBlue
        }
      ];
    }
    else if (hour >= 17 && hour < 21) {
      // عصر (5 بعدازظهر تا 9 شب)
      return [
        {
          "text": "عصر بخیر عزیزم! خستگی رو از تن بیرون کن و بنویس",
          "emoji": "🌇",
          "color": Colors.purple
        },
        {
          "text": "صدای گرم تو بهترین همراه برای این عصر",
          "emoji": "🎶",
          "color": Colors.deepPurple
        }
      ];
    }
    else {
      // شب (9 شب تا 5 صبح)
      return [
        {
          "text": "شب بخیر ستاره من! یادت نره استراحت کن",
          "emoji": "🌙",
          "color": Colors.indigo
        },
        {
          "text": "می‌دونم دست‌هات خسته‌ست، فردا دوباره می‌نویسیم",
          "emoji": "💤",
          "color": Colors.blueGrey
        },
        {
          "text": "خواب‌های قشنگ ببینی عزیزم",
          "emoji": "✨",
          "color": Colors.deepPurple
        }
      ];
    }
  }

  void _showSecretMessage(BuildContext context, VoiceController controller) {
    final messages = _getTimeBasedMessages();
    final random = Random();
    final message = messages[random.nextInt(messages.length)];

    Get.defaultDialog(
      title: 'برای تارا 💌',
      titleStyle: TextStyle(
        fontSize: 20,
        color: message["color"] as Color,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          Text(
            message["text"] as String,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message["emoji"] as String,
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: message["color"] as Color,
          foregroundColor: Colors.white,
        ),
        child: const Text('مرسی!'),
      ),
    );
  }
}

class VoiceController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final _state = Rx<AppState>(AppState());
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final logoClicks = 0.obs;

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
      debugPrint('خطا در مقداردهی اولیه: $e');
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
            onResult: (result) => _updateState(recognizedText: result.recognizedWords),
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

  void incrementLogoClick() => logoClicks.value++;
  void resetLogoClick() => logoClicks.value = 0;
  void updateCurrentHistoryIndex(int index) => _updateState(currentHistoryIndex: index);
  void updateTextFromHistory() => _updateTextFromHistory();

  @override
  void onClose() {
    _speech.stop();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

class AppState {
  bool isListening;
  String recognizedText;
  double soundLevel;
  List<String> textHistory;
  int currentHistoryIndex;

  AppState({
    this.isListening = false,
    this.recognizedText = '',
    this.soundLevel = 0.0,
    this.textHistory = const [],
    this.currentHistoryIndex = -1,
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

class HistoryItem {
  final String text;
  final int id;

  HistoryItem({required this.text, required this.id});
}
