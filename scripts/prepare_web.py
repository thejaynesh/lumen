"""Set canonical metadata consistently, including after a preview build."""
import argparse
from pathlib import Path
from urllib.parse import urlparse
import re


def prepare(root, origin, preview=False):
    origin = origin.rstrip('/')
    parsed = urlparse(origin)
    if (parsed.scheme != 'https' or not parsed.hostname or parsed.username or
            parsed.password or parsed.path or parsed.query or parsed.fragment or
            not re.fullmatch(r'[A-Za-z0-9.-]+', parsed.hostname) or
            any(char.isspace() for char in origin)):
        raise ValueError('--site-url must be an HTTPS origin without credentials, path or query.')
    path = root / 'index.html'
    text = path.read_text(encoding='utf-8')
    current = re.search(r'<link rel="canonical" href="(https://[^"<>]+)/">', text)
    if not current:
        raise ValueError('Missing canonical origin in web/index.html.')
    text = text.replace(current.group(1), origin)
    text = re.sub(r'\s*<meta name="robots" content="noindex, nofollow">', '', text)
    if preview:
        text = text.replace('<head>', '<head>\n  <meta name="robots" content="noindex, nofollow">')
    path.write_text(text, encoding='utf-8')
    robots = 'User-agent: *\nDisallow: /\n' if preview else (
        'User-agent: *\nAllow: /\nDisallow: /admin\nDisallow: /login\n'
        'Disallow: /access-denied\nDisallow: /modes\nDisallow: /*?job=\n'
        f'Disallow: /*?jobId=\nSitemap: {origin}/sitemap.xml\n')
    (root / 'robots.txt').write_text(robots, encoding='utf-8')
    (root / 'sitemap.xml').write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
        f'  <url><loc>{origin}/</loc></url>\n</urlset>\n', encoding='utf-8')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site-url', default='https://lumen-f2e07.web.app')
    parser.add_argument('--preview', action='store_true')
    args = parser.parse_args()
    try:
        prepare(Path(__file__).resolve().parents[1] / 'web', args.site_url, args.preview)
    except ValueError as error:
        parser.error(str(error))
