from pathlib import Path
import tempfile
import unittest
from prepare_web import prepare


class WebPreparationTests(unittest.TestCase):
    def test_preview_can_return_to_production_and_change_origin(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = Path(__file__).resolve().parents[1] / 'web' / 'index.html'
            (root / 'index.html').write_text(source.read_text(encoding='utf-8'), encoding='utf-8')
            prepare(root, 'https://preview.example.com', True)
            self.assertIn('noindex, nofollow', (root / 'index.html').read_text())
            prepare(root, 'https://portfolio.example.com')
            output = (root / 'index.html').read_text()
            self.assertNotIn('preview.example.com', output)
            self.assertNotIn('noindex, nofollow', output)
            self.assertIn('https://portfolio.example.com/social-preview.png', output)
            self.assertIn('Allow: /', (root / 'robots.txt').read_text())
            first = output
            prepare(root, 'https://portfolio.example.com')
            self.assertEqual(first, (root / 'index.html').read_text())

    def test_untrusted_origin_is_rejected(self):
        for origin in ['http://host.test', 'https://user:secret@host.test', 'https://host.test/path', 'https://bad host.test', 'https://bad"host.test']:
            with self.assertRaises(ValueError):
                prepare(Path('unused'), origin)
