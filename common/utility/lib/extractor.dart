import 'dart:io';

class Extractor {
  static void extractClasses() {
    final outputFile = File('generated/all_classes.txt');
    final buffer = StringBuffer();

    buffer.writeln('// Сгенерированный файл со всеми классами');
    buffer.writeln('');

// Ищем папку password_manager в родительских директориях
    final currentDir = Directory.current;
    final rootDir = findPasswordManagerDir(currentDir);

    if (rootDir == null) {
      print('Папка password_manager не найдена!');
      print('Текущая директория: ${currentDir.path}');
      return;
    }

    print('Найдена папка: ${rootDir.path}');
    generateClassCode(rootDir, buffer);

// Создаем директорию generated если её нет
    final generatedDir = Directory('generated/');
    if (!generatedDir.existsSync()) {
      generatedDir.createSync(recursive: true);
    }

    outputFile.writeAsStringSync(buffer.toString());
    print('Код сохранен в ${outputFile.path}');
  }

  static Directory? findPasswordManagerDir(Directory currentDir) {
// Проверяем текущую директорию
    final passwordManagerDir = Directory('${currentDir.path}/password_manager');
    if (passwordManagerDir.existsSync()) {
      return passwordManagerDir;
    }

// Проверяем родительские директории
    Directory? parent = currentDir.parent;
    while (parent != null && parent.path != parent.parent.path) {
      final candidateDir = Directory('${parent.path}/password_manager');
      if (candidateDir.existsSync()) {
        return candidateDir;
      }
      parent = parent.parent;
    }

    return null;
  }

  static void generateClassCode(Directory rootDir, StringBuffer buffer) {
// Список директорий, которые нас интересуют
    final targetDirectories = ['common/utility/lib', 'password_manager_frontend/lib', 'password_manager_server/bin'];

    for (final dirName in targetDirectories) {
      final targetDir = Directory('${rootDir.path}/$dirName');

      if (!targetDir.existsSync()) {
        print('Директория $dirName не найдена, пропускаем...');
        continue;
      }

      print('Обрабатывается директория: ${targetDir.path}');
      buffer.writeln('// ========== ДИРЕКТОРИЯ: $dirName ==========');
      buffer.writeln('');

// Рекурсивно обходим все файлы в этой директории
      final entities = targetDir.listSync(recursive: true);

      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          try {
            final relativePath = entity.path.replaceAll('\\\\', '/lib');
            final content = entity.readAsStringSync();

// Пропускаем пустые файлы
            if (content.trim().isEmpty) continue;

            buffer.writeln('// ===== $relativePath =====');
            buffer.writeln(content);
            buffer.writeln('');
          } catch (e) {
            print('Ошибка при чтении файла ${entity.path}: $e');
          }
        }
      }

      buffer.writeln('// ========== КОНЕЦ ДИРЕКТОРИИ: $dirName ==========');
      buffer.writeln('');
    }
  }
}

void main() {
  print('Запуск экстрактора классов...');
  Extractor.extractClasses();
}