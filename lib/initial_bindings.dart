
import 'package:get/get.dart';
import 'package:tara_type_real/message_queue.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() async {


    Get.lazyPut<MessageQueue>(() => MessageQueue("https://manager-admin.liara.run"));


  }
}