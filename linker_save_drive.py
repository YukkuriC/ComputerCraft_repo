import os, subprocess, sys

MC_ROOT = r'C:/Minecraft/.minecraft/versions'
PACK_NAME = sys.argv[1] if len(sys.argv) > 1 else 'foo'
while 1:
    TARGET_PACK = os.path.join(MC_ROOT, PACK_NAME)
    if os.path.isdir(TARGET_PACK):
        break
    PACK_NAME = input('pack name: ').strip()

SAVE_NAME = sys.argv[2] if len(sys.argv) > 2 else 'foo'
while 1:
    TARGET_SAVE = os.path.join(TARGET_PACK, 'saves', SAVE_NAME, 'computercraft')
    if os.path.isdir(TARGET_SAVE):
        break
    SAVE_NAME = input('save name: ').strip()

DRIVE_NAME = sys.argv[3] if len(sys.argv) > 3 else 'foo'
while 1:
    TARGET_DRIVE = os.path.join(TARGET_SAVE, DRIVE_NAME)
    if os.path.isdir(TARGET_DRIVE):
        break
    DRIVE_NAME = input('drive name: ').strip()


SRC_ROOT = os.path.join(os.path.dirname(__file__), 'remote')

subprocess.run(
    [
        'cmd',
        '/c',
        'mklink',
        '/J',
        os.path.abspath(os.path.join(TARGET_DRIVE, 'remote')),
        os.path.abspath(SRC_ROOT),
    ],
    shell=True,
)
