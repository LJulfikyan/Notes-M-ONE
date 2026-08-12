enum NoteColor {
  magenta('magenta'),
  pink('pink'),
  green('green'),
  yellow('yellow'),
  cyan('cyan'),
  purple('purple');

  const NoteColor(this.storageValue);

  final String storageValue;

  static NoteColor fromStorage(String value) {
    return NoteColor.values.byName(value);
  }
}
