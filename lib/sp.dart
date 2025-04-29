import 'dart:io';

class SP {

  static void write(String filename, String text) {
    if (!File(filename).existsSync()) {
      File(filename).createSync();
    }
    var raf = File(filename).openSync(mode: FileMode.write);
    raf.writeStringSync(text);
    raf.flushSync();
    raf.closeSync();
  }

  static String read(String filename) {
    if (!File(filename).existsSync()) {
      return "";
    }
    var text = File(filename).readAsStringSync();
    return text;
  }

}