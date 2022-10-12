import 'dart:io';

import 'package:cmt/models/select_option.dart';
import 'package:interactive_cli/interactive_cli.dart';
import 'package:collection/collection.dart';
import 'package:tint/tint.dart';

class SearchableSelector extends InteractiveLines<SelectOption> {
  final String prompt;
  final List<SelectOption> options;
  int _selectedIndex;
  String _input = '';
  int _cursorIndex = 0;

  List<SelectOption> enableOptions(String search) =>
      options.where((option) => option.name.startsWith(search)).toList();

  SelectOption get selectedOption => enableOptions(_input)[_selectedIndex];

  String get promptPrefix => ' ? '.yellow();
  String get selector => '❯'.green();
  String get textPrefix => ' › '.gray();
  String get responsePrefix => ' · '.gray();
  String get successPrefix => ' ✔ '.green();

  SearchableSelector({
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
    List<String> lines = [];
    final question = '$promptPrefix${prompt.white().bold()}$textPrefix';
    final questionLength = question.strip().length;
    final tabulation = ' ' * questionLength;
    context.setCursorPosition(
      column: questionLength + _cursorIndex,
      row: 0,
    );
    return [
      '$question$_input',
      ...enableOptions(_input).mapIndexed(
        (index, option) {
          if (index == _selectedIndex) {
            return tabulation + option.fullText.onGray().white();
          } else {
            return tabulation + option.fullText.gray();
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

  void setChar(String char) {
    final newInput = _input.substring(0, _cursorIndex) +
        char +
        _input.substring(_cursorIndex, _input.length);
    if (enableOptions(newInput).isNotEmpty) {
      if (!enableOptions(newInput).contains(selectedOption)) {
        _selectedIndex = 0;
      }
      _input = newInput;
      _cursorIndex++;
    }
  }

  void _backspace() {
    if (_cursorIndex > 0) {
      _input = _input.substring(0, _cursorIndex - 1) +
          _input.substring(_cursorIndex, _input.length);
      _cursorIndex--;
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
      } else if (pressedKey.controlChar == ControlCharacter.backspace) {
        _backspace();
      } else if (pressedKey.controlChar == ControlCharacter.arrowRight) {
        if (_cursorIndex < _input.length) {
          _cursorIndex++;
        }
      } else if (pressedKey.controlChar == ControlCharacter.arrowLeft) {
        if (_cursorIndex > 0) {
          _cursorIndex--;
        }
      } else if (pressedKey.controlChar == ControlCharacter.home) {
        _cursorIndex = 0;
      } else if (pressedKey.controlChar == ControlCharacter.end) {
        _cursorIndex = _input.length;
      } else if (pressedKey.controlChar == ControlCharacter.enter) {
        finish(selectedOption);
      }
    } else {
      setChar(pressedKey.char);
    }
  }
}
