import 'dart:io';

import 'package:cmt/components/input.dart';
import 'package:cmt/components/searchable_selector.dart';
import 'package:cmt/models/select_option.dart';
import 'package:cmt/utils.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

final commitTypes = [
  SelectOption(name: 'refactor', description: 'refactoring production code'),
  SelectOption(name: 'feat', description: 'adding new feature'),
  SelectOption(name: 'fix', description: 'fixing a bug'),
  SelectOption(name: 'docs', description: 'updating documentation'),
  SelectOption(name: 'style', description: 'formatting and style changes'),
  SelectOption(name: 'test', description: 'updating tests'),
  SelectOption(name: 'chore', description: 'tools and configurations changes'),
];

final commitNames = 'refactor|feat|fix|docs|style|test|chore';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', negatable: false, abbr: 'h', help: 'show help')
    ..addFlag('version', negatable: false, abbr: 'v', help: 'show version');
  ArgResults argResults = parser.parse(args);
  final help = argResults['help'] as bool;
  final version = argResults['version'] as bool;
  if (help) {
    stdout.writeln(parser.usage);
    return;
  }
  if (version) {
    stdout.writeln('cmt version 0.2.0');
    return;
  }

  final isGitRepo = await GitDir.isGitDir(path.current);
  if (!isGitRepo) {
    errorMessage('This is not a git directory');
  }
  final git = await GitDir.fromExisting(path.current, allowSubdirectory: true);
  final commits = await git.commits();
  final commitMessageRegex = RegExp(
    r'(?<=(?<=refactor|feat|fix|docs|style|test|chore)\().*(?=\):)(?=.*)',
  );

  List<String> scopes = [];
  for (var commit in commits.values) {
    final match = commitMessageRegex.firstMatch(commit.message);
    if (match != null) {
      scopes.add(match.group(0)!);
    }
  }

  final commitType = SearchableSelector(
    prompt: 'Commit type',
    options: commitTypes,
  ).load().name;

  final scope = Input(
    prompt: 'Scope',
    suggestions: scopes.toSet().toList(),
  ).load();

  final message = Input(
    prompt: 'Commit message',
  ).load();

  if (message.isEmpty) {
    errorMessage('Commit message is required');
  }

  await git.runCommand(['add', '.']);
  if (scope != '') {
    await git.runCommand(['commit', '-m', '$commitType($scope): $message']);
  } else {
    await git.runCommand(['commit', '-m', '$commitType: $message']);
  }
}
