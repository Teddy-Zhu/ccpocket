import 'package:ccpocket/utils/git_path_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeGitPathSpec', () {
    test('keeps plain paths unchanged', () {
      expect(
        normalizeGitPathSpec('apps/mobile/lib/main.dart'),
        'apps/mobile/lib/main.dart',
      );
    });

    test('decodes quoted octal-escaped utf8 paths', () {
      expect(
        normalizeGitPathSpec(r'"docs/dev/prepare/\344\270\255\346\226\207.md"'),
        'docs/dev/prepare/中文.md',
      );
    });

    test('removes git a/ and b/ prefixes after decoding', () {
      expect(
        normalizeGitPathSpec(
          r'"b/docs/dev/prepare/\344\270\255\346\226\207.md"',
        ),
        'docs/dev/prepare/中文.md',
      );
    });
  });
}
