#!/usr/bin/env python3
"""Subset MiSans weights to the characters used by the app."""
import glob
import subprocess

chars = set()
for path in glob.glob('lib/**/*.dart', recursive=True) + glob.glob(
    'lib/**/*.arb', recursive=True
):
    with open(path, encoding='utf-8') as handle:
        chars.update(handle.read())
chars.update(chr(i) for i in range(32, 127))
chars.update('　、。！？；：“”‘’（）【】《》—…·×÷≤≥→←↑↓↔•…✓✗●○■□▲▼◆◇')
text = ''.join(sorted(c for c in chars if c.isprintable() or c in '\n\t'))
with open('/tmp/onedash_chars.txt', 'w', encoding='utf-8') as handle:
    handle.write(text)

variants = [
    ('MiSans-Regular.ttf', 'MiSans-Subset.ttf'),
    ('MiSans-Medium.ttf', 'MiSans-Medium-Subset.ttf'),
    ('MiSans-Semibold.ttf', 'MiSans-Semibold-Subset.ttf'),
]
for source, output in variants:
    subprocess.run(
        [
            'pyftsubset',
            f'assets/fonts/{source}',
            '--text-file=/tmp/onedash_chars.txt',
            f'--output-file=assets/fonts/{output}',
            '--layout-features=*',
            '--glyph-names',
            '--symbol-cmap',
            '--legacy-cmap',
            '--notdef-glyph',
            '--notdef-outline',
            '--recommended-glyphs',
        ],
        check=True,
    )
    print(f'wrote assets/fonts/{output}')
