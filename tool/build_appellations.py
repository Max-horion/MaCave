#!/usr/bin/env python3
"""Construit assets/appellations.txt : appellations françaises de vins et de
spiritueux (AOC/AOP, IGP, IG), pour reconnaître l'appellation sur une
étiquette (CDC §6.2). Une par ligne, orthographe officielle de l'INAO.

Sources (data.gouv.fr, Licence Ouverte / Etalab, producteur : INAO) :
- « Aires et produits AOC/AOP et IGP » (CSV) : toutes les appellations,
  produits alimentaires compris, sans catégorie ;
- « Délimitation parcellaire des AOC viticoles » : seulement la table des
  attributs (.dbf) de l'archive, lue à distance (téléchargement partiel).

Le premier fichier ne dit pas ce qui est un vin : on garde une appellation si
la délimitation parcellaire la classe en « Vins », si un de ses produits porte
un mot de vin (rouge, blanc, rosé, mousseux…), si son nom prolonge une
appellation viticole (« Chablis premier cru Vaillons »), ou si c'est un
spiritueux (signe européen « IG »). Quelques exceptions sont listées à la
main (EXTRA_WINES, NOT_DRINKS) : relire la sortie « écartés » après une mise
à jour.

Usage : tool/build_appellations.py [--show-excluded]
"""
import csv, io, json, re, struct, sys, unicodedata, urllib.request, zipfile

DATASET_PRODUCTS = 'aires-et-produits-aoc-aop-et-igp'
DATASET_PARCELS = '5aaf6b7ec751df67b0d7a87f'
OUT = 'assets/appellations.txt'

# Appellations viticoles sans aucun mot-clé dans leurs produits.
EXTRA_WINES = {'Blaye', 'Gros Plant du Pays nantais', 'Moulis'}
# Produits non viticoles retenus à tort par les mots-clés.
NOT_DRINKS = {'Ail blanc de Lomagne'}

WINE_WORDS = re.compile(
    r"\b(rouges?|blancs?|rosés?|clairet|claret|mousseux|primeur|effervescent|"
    r"pétillant|crémant|vins?|vendanges tardives|grains nobles|avec sucres|"
    r"liquoreux|moelleux|surmûris|gris|jaune|de paille|doux naturel|tuilé|"
    r"rancio)\b", re.I)


def resources(dataset):
    url = f'https://www.data.gouv.fr/api/1/datasets/{dataset}/'
    return json.load(urllib.request.urlopen(url, timeout=60))['resources']


class RemoteFile(io.RawIOBase):
    """Fichier distant lu par morceaux (en-tête HTTP Range)."""

    def __init__(self, url):
        self.url, self.pos = url, 0
        head = urllib.request.urlopen(
            urllib.request.Request(url, method='HEAD'), timeout=60)
        self.size = int(head.headers['Content-Length'])

    def readable(self): return True
    def seekable(self): return True
    def tell(self): return self.pos

    def seek(self, offset, whence=0):
        base = (0, self.pos, self.size)[whence]
        self.pos = base + offset
        return self.pos

    def readinto(self, buffer):
        if self.pos >= self.size: return 0
        end = min(self.pos + len(buffer), self.size) - 1
        req = urllib.request.Request(
            self.url, headers={'Range': f'bytes={self.pos}-{end}'})
        data = urllib.request.urlopen(req, timeout=120).read()
        buffer[:len(data)] = data
        self.pos += len(data)
        return len(data)


def dbf_rows(data):
    n, header, size = struct.unpack('<IHH', data[4:12])
    fields, offset = [], 32
    while data[offset] != 0x0D:
        d = data[offset:offset + 32]
        fields.append((d[:11].split(b'\0')[0].decode(), d[16]))
        offset += 32
    for i in range(n):
        record = data[header + i * size: header + (i + 1) * size]
        pos, row = 1, {}
        for name, length in fields:
            row[name] = record[pos:pos + length].decode('utf-8', 'replace').strip()
            pos += length
        yield row


def main():
    # Vins de la délimitation parcellaire.
    shp = next(r['url'] for r in resources(DATASET_PARCELS)
               if r['url'].endswith('-shp.zip'))
    archive = zipfile.ZipFile(io.BufferedReader(RemoteFile(shp), 1 << 20))
    dbf = next(n for n in archive.namelist() if n.endswith('.dbf'))
    wines = set()
    for row in dbf_rows(archive.read(dbf)):
        if row['type_prod'] == 'Vins':
            wines.update((row['app'], row['denom']))

    # Toutes les appellations (CSV en Windows-1252).
    products_url = next(r['url'] for r in resources(DATASET_PRODUCTS)
                        if r['format'] == 'csv')
    text = urllib.request.urlopen(products_url, timeout=120).read().decode('cp1252')
    by_area = {}
    for row in csv.DictReader(io.StringIO(text), delimiter=';'):
        key = (row['Aire geographique'].strip(), row['Signe FR'].strip(),
               row['Signe UE'].strip())
        by_area.setdefault(key, []).append(row['Produit'].strip())

    known, spirits, excluded = set(wines), set(), []
    for (area, fr, eu), products in sorted(by_area.items()):
        if (fr in ('LR', 'PNT') or eu == 'STG' or area.startswith('-')
                or area in NOT_DRINKS):
            continue
        if eu == 'IG':
            spirits.add(area)
        elif (area in known or area in EXTRA_WINES or area.startswith('Clos ')
              or any(WINE_WORDS.search(p) for p in products)
              or any(area.startswith(w + ' ') for w in known)):
            wines.add(area)
        else:
            excluded.append(area)

    # « Cognac ou Eau-de-vie de Cognac » : chaque nom compte.
    names = set()
    for entry in wines | spirits:
        for name in re.split(r'\s+ou\s+', entry):
            name = re.sub(r'\s+', ' ', name).strip(' -–')
            if len(name) > 2:
                names.add(name)
    fold = lambda s: unicodedata.normalize('NFKD', s).encode(
        'ascii', 'ignore').decode().lower()
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sorted(names, key=fold)) + '\n')
    print(f'{OUT} : {len(names)} appellations', file=sys.stderr)
    if '--show-excluded' in sys.argv:
        print('\n'.join(excluded), file=sys.stderr)


if __name__ == '__main__':
    main()
