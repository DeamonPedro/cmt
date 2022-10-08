import 'package:cmt/components/input.dart';
import 'package:cmt/components/select.dart';
import 'package:cmt/utils.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as path;

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

Future<void> main(List<String> arguments) async {
  final isGitRepo = await GitDir.isGitDir(path.current);
  if (!isGitRepo) {
    errorMessage('This is not a git directory');
  }
  final git = await GitDir.fromExisting(path.current);
  final commits = await git.commits();
  final commitMessageRegex = RegExp(
    r'(refactor|feat|fix|docs|style|test|chore)((?:\(([^())\r\n]*)\)|\()?):(.*)?',
  );

  final scopes = commits.values
      .where((commit) => commitMessageRegex.hasMatch(commit.message))
      .map((commit) {
    final match = commitMessageRegex.firstMatch(commit.message);
    return match!.group(3)!;
  }).toList();

  final commitType = Select(
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
