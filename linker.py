import os, subprocess, sys

MC_ROOT = r'C:/Minecraft/.minecraft/versions'
PACK_NAME = sys.argv[1] if len(sys.argv) > 1 else 'foo'
while not os.path.isdir(os.path.join(MC_ROOT, PACK_NAME)):
    PACK_NAME = input('pack name: ').strip()

SRC_ROOT = os.path.join(os.path.dirname(__file__), 'remote')

KJS_DATA_ROOT = os.path.join(MC_ROOT, PACK_NAME, 'kubejs/data/computercraft/lua/rom')
os.makedirs(KJS_DATA_ROOT, exist_ok=1)

subprocess.run(
    [
        'cmd',
        '/c',
        'mklink',
        '/J',
        os.path.abspath(os.path.join(KJS_DATA_ROOT, 'remote')),
        os.path.abspath(SRC_ROOT),
    ],
    shell=True,
)
