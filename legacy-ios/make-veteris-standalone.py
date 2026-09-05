#!/usr/bin/env python3
import plistlib
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
source = Path('/tmp/veteris-deb/Applications/Veteris.app')
out = root / 'legacy-ios/build-armv7/Veteris-3.2-standalone-arm32.ipa'
if not source.is_dir():
    raise SystemExit('Extract the Veteris .deb to /tmp/veteris-deb first')

with tempfile.TemporaryDirectory(prefix='veteris-standalone-') as td:
    payload = Path(td) / 'Payload'
    app = payload / 'Veteris.app'
    payload.mkdir()
    shutil.copytree(source, app)
    plist_path = app / 'Info.plist'
    with plist_path.open('rb') as f:
        info = plistlib.load(f)
    info['CFBundleIdentifier'] = 'com.uberide.veteris.standalone'
    info['CFBundleDisplayName'] = 'Veteris'
    info['CFBundleName'] = 'Veteris'
    with plist_path.open('wb') as f:
        plistlib.dump(info, f, fmt=plistlib.FMT_BINARY, sort_keys=False)
    out.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([str(root / 'legacy-ios/fakesign-ipa.sh'), str(app), str(out)], check=True)
print(out)
