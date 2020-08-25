import json
import log
from clickgen import build_cursor_theme

from config import configs, sizes, delay, temp_folder
from helper import init_build, pack_it


def build(config) -> None:

    build_cursor_theme(
        config['name'],
        image_dir=config['bitmaps_dir'],
        cursor_sizes=sizes,
        out_path=config['temp_folder'],
        hotspots=hotspots,
        archive=False,
        delay=delay)

    pack_it(config)


if __name__ == "__main__":
    init_build()

    # read hotspots file
    with open('./hotspots.json', 'r') as hotspot_file:
        hotspots = json.loads(hotspot_file.read())

    # building themes
    for config in configs:
        print('🌈 Building %s Theme ...' % config['name'])
        build(config)
