import 'dart:io';

import 'package:interactive_cli/interactive_cli.dart';
import 'package:collection/collection.dart';
import 'package:tint/tint.dart';

class SelectOption {
  final String name;
  final String description;

  SelectOption({
    required this.name,
    this.description = '',
  });

  String get fullText => '$name  ($description)';
}

class Select extends InteractiveLines<SelectOption> {
  final String prompt;
  final List<SelectOption> options;
  int _selectedIndex;

  SelectOption get selectedOption => options[_selectedIndex];

  String get promptPrefix => ' ? '.yellow();
  String get selector => '❯'.green();
  String get textPrefix => ' › '.gray();
  String get responsePrefix => ' · '.gray();
  String get successPrefix => ' ✔ '.green();

  Select({
    required this.prompt,
    required this.options,
    int defaultOption = 0,
  }) : _selectedIndex = defaultOption;

  @override
  void onInit() {
    context.hideCursor();
  }

  @override
  void onFinish(res) {
    context.showCursor();
    print(
        '$successPrefix${prompt.white().bold()}$responsePrefix${options[_selectedIndex].name.brightCyan()}');
  }

  @override
  List<String> render() {
    return [
      '$promptPrefix${prompt.white().bold()}$textPrefix',
      ...options.mapIndexed(
        (index, option) {
          if (index == _selectedIndex) {
            return '$selector ${option.fullText.brightCyan()}';
          } else {
            return '  ${option.fullText}';
          }
        },
      ),
    ];
  }

  void _up() {
    if (_selectedIndex > 0) {
      _selectedIndex--;
    } else {
      _selectedIndex = options.length - 1;
    }
  }

  void _down() {
    if (_selectedIndex < options.length - 1) {
      _selectedIndex++;
    } else {
      _selectedIndex = 0;
    }
  }

  @override
  void react(Key pressedKey, finish) {
    if (pressedKey.isControl) {
      if (pressedKey.controlChar == ControlCharacter.ctrlC) {
        context.clearRender();
        exit(0);
      } else if (pressedKey.controlChar == ControlCharacter.arrowUp) {
        _up();
      } else if (pressedKey.controlChar == ControlCharacter.arrowDown) {
        _down();
      } else if (pressedKey.controlChar == ControlCharacter.enter) {
        finish(selectedOption);
      }
    }
  }
}
