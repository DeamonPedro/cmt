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
    ..addFlag('push', abbr: 'p', help: 'Push to remote after commit')
    ..addFlag('help', abbr: 'h', help: 'Show help')
    ..addFlag('version', abbr: 'v', help: 'Show version')
    ..addCommand('f')
    ..addCommand('r')
    ..addCommand('c');
  ArgResults argResults = parser.parse(args);
  final push = argResults['push'] as bool;
  final help = argResults['help'] as bool;
  final version = argResults['version'] as bool;
  final command = argResults.command?.name;
  print(command);

  final isGitRepo = await GitDir.isGitDir(path.current);
  if (!isGitRepo) {
    errorMessage('This is not a git directory');
  }
  final git = await GitDir.fromExisting(path.current, allowSubdirectory: true);
  final commits = await git.commits();
  final commitMessageRegex = RegExp(
    r'(refactor|feat|fix|docs|style|test|chore)((?:\(([^())\r\n]*)\)|\()?):(.*)?',
  );

  final scopes = commits.values
      .where((commit) => commitMessageRegex.hasMatch(commit.message))
      .map((commit) {
        final match = commitMessageRegex.firstMatch(commit.message);
        return match!.group(3)!;
      })
      .toSet()
      .toList();

  final commitType = SearchableSelector(
    prompt: 'Commit type',
    options: commitTypes,
  ).load().name;

  final scope = Input(
    prompt: 'Scope',
    suggestions: scopes,
  ).load();

  final message = Input(
    prompt: 'Commit message',
  ).load();

  git.runCommand(['add', '.']);
  git.runCommand(['commit', '-m', '$commitType($scope): $message']);
}
