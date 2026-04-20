import 'dart:convert';

/// Normalize a Git path spec for UI display.
///
/// Git may wrap paths in double quotes and encode non-ASCII bytes using
/// backslash-octal escapes, for example:
/// `"docs/dev/prepare/\344\270\255\346\226\207.md"`.
String normalizeGitPathSpec(String rawSpec) {
  var spec = rawSpec.trim();
  if (spec.isEmpty) return spec;

  if (spec.startsWith('"') && spec.endsWith('"') && spec.length >= 2) {
    spec = decodeGitQuotedPath(spec.substring(1, spec.length - 1));
  }

  if (spec.startsWith('a/') || spec.startsWith('b/')) {
    return spec.substring(2);
  }
  return spec;
}

String decodeGitQuotedPath(String value) {
  final bytes = <int>[];
  var index = 0;

  while (index < value.length) {
    final char = value[index];
    if (char != '\\') {
      bytes.addAll(utf8.encode(char));
      index++;
      continue;
    }

    if (index + 1 >= value.length) {
      bytes.add('\\'.codeUnitAt(0));
      break;
    }

    final next = value[index + 1];
    final end = index + 4 <= value.length ? index + 4 : value.length;
    final octalMatch = RegExp(
      r'^[0-7]{1,3}',
    ).firstMatch(value.substring(index + 1, end));
    if (octalMatch case final match?) {
      bytes.add(int.parse(match.group(0)!, radix: 8));
      index += 1 + match.group(0)!.length;
      continue;
    }

    switch (next) {
      case 'n':
        bytes.add('\n'.codeUnitAt(0));
        break;
      case 'r':
        bytes.add('\r'.codeUnitAt(0));
        break;
      case 't':
        bytes.add('\t'.codeUnitAt(0));
        break;
      case '"':
        bytes.add('"'.codeUnitAt(0));
        break;
      case '\\':
        bytes.add('\\'.codeUnitAt(0));
        break;
      default:
        bytes.addAll(utf8.encode(next));
        break;
    }
    index += 2;
  }

  return utf8.decode(bytes, allowMalformed: true);
}
