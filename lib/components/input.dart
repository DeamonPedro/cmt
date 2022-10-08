import 'dart:io';

import 'package:interactive_cli/interactive_cli.dart';
import 'package:tint/tint.dart';
import 'package:collection/collection.dart';

class Input extends InteractiveLines<String> {
  final String prompt;
  final List<String> suggestions;
  int? _selectedSuggestions;
  String _input = '';
  int _cursorIndex = 0;

  Input({
    required this.prompt,
    this.suggestions = const [],
  });

  String get promptPrefix => ' ? '.yellow();
  String get selector => '❯'.green();
  String get textPrefix => ' › '.gray();
  String get responsePrefix => ' · '.gray();
  String get successPrefix => ' ✔ '.green();

  List<String> get _enableSuggestions {
    List<String> list = suggestions;
    if (_input.isNotEmpty) {
      list = suggestions
          .where((suggestion) =>
              suggestion.toLowerCase().startsWith(_input.toLowerCase()) &&
              suggestion != _input)
          .toList();
    }
    if (list.length > 6) {
      return list.sublist(0, 6);
    } else {
      return list;
    }
  }

  @override
  void onFinish(res) {
    print(
        '$successPrefix${prompt.white().bold()}$responsePrefix${res.toString().brightCyan()}');
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

    String input = _input;
    if (_selectedSuggestions != null) {
      input += _enableSuggestions[_selectedSuggestions ?? 0]
          .substring(_input.length)
          .gray();
    }

    lines.add('$question$input');
    if (_enableSuggestions.length > 1) {
      lines.addAll(_enableSuggestions.mapIndexed(
        (index, option) {
          if (index == _selectedSuggestions) {
            return tabulation + option.onGray().white();
          } else {
            return tabulation + option.gray();
          }
        },
      ));
    }
    return lines;
  }

  void _up() {
    if (_selectedSuggestions == null) return;
    if (_selectedSuggestions! > 0) {
      _selectedSuggestions = _selectedSuggestions! - 1;
    } else {
      _selectedSuggestions = _enableSuggestions.length - 1;
    }
  }

  void _down() {
    if (_selectedSuggestions == null) {
      _selectedSuggestions = 0;
    } else if (_selectedSuggestions! < _enableSuggestions.length - 1) {
      _selectedSuggestions = _selectedSuggestions! + 1;
    } else {
      _selectedSuggestions = 0;
    }
  }

  void _backspace() {
    if (_cursorIndex > 0) {
      _input = _input.substring(0, _cursorIndex - 1) +
          _input.substring(_cursorIndex, _input.length);
      _cursorIndex--;
    }
  }

  void setChar(String char) {
    _input = _input.substring(0, _cursorIndex) +
        char +
        _input.substring(_cursorIndex, _input.length);
    _cursorIndex++;
    if (_enableSuggestions.length == 1) {
      _selectedSuggestions = 0;
    } else {
      _selectedSuggestions = null;
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
        if (_selectedSuggestions != null) {
          _input = _enableSuggestions[_selectedSuggestions!];
          _cursorIndex = _input.length;
          _selectedSuggestions = null;
        } else {
          if (_cursorIndex < _input.length) {
            _cursorIndex++;
          }
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
        if (_selectedSuggestions != null && _enableSuggestions.length > 1) {
          _input = _enableSuggestions[_selectedSuggestions!];
        }
        finish(_input);
      }
    } else {
      setChar(pressedKey.char);
    }
  }
}
