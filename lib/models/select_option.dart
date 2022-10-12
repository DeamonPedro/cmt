class SelectOption {
  final String name;
  final String description;

  SelectOption({
    required this.name,
    this.description = '',
  });

  String get fullText => '$name  ($description)';
}
