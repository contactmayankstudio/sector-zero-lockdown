import os
import urllib.request
import sys

TEXTURES = [
    # Ground: Real Mud / Soil ("mitti")
    ("textures/pbr/ground/brown_mud_diff_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/brown_mud/brown_mud_diff_1k.jpg"),
    ("textures/pbr/ground/brown_mud_nor_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/brown_mud/brown_mud_nor_gl_1k.jpg"),
    ("textures/pbr/ground/brown_mud_arm_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/brown_mud/brown_mud_arm_1k.jpg"),

    # Ground: Real Grass / Earth ("khash darti")
    ("textures/pbr/ground/aerial_grass_rock_diff_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/aerial_grass_rock/aerial_grass_rock_diff_1k.jpg"),
    ("textures/pbr/ground/aerial_grass_rock_nor_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/aerial_grass_rock/aerial_grass_rock_nor_gl_1k.jpg"),
    ("textures/pbr/ground/aerial_grass_rock_arm_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/aerial_grass_rock/aerial_grass_rock_arm_1k.jpg"),

    # Walls: High-Graphics Concrete Block Bunker Wall ("deewar real higt grafix")
    ("textures/pbr/walls/concrete_block_diff_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/concrete_block_wall_02/concrete_block_wall_02_diff_1k.jpg"),
    ("textures/pbr/walls/concrete_block_nor_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/concrete_block_wall_02/concrete_block_wall_02_nor_gl_1k.jpg"),
    ("textures/pbr/walls/concrete_block_arm_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/concrete_block_wall_02/concrete_block_wall_02_arm_1k.jpg"),

    # Walls: High-Graphics Apocalyptic Broken Brick Wall
    ("textures/pbr/walls/broken_brick_diff_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/broken_brick_wall/broken_brick_wall_diff_1k.jpg"),
    ("textures/pbr/walls/broken_brick_nor_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/broken_brick_wall/broken_brick_wall_nor_gl_1k.jpg"),
    ("textures/pbr/walls/broken_brick_arm_1k.jpg", "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/broken_brick_wall/broken_brick_wall_arm_1k.jpg")
]

def download_file(target_path, url):
    if os.path.exists(target_path) and os.path.getsize(target_path) > 10000:
        print(f"Already exists: {target_path} ({os.path.getsize(target_path)} bytes)")
        return True
    
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    print(f"Downloading: {url} -> {target_path}")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)'})
    try:
        with urllib.request.urlopen(req, timeout=25) as response, open(target_path, 'wb') as out_file:
            data = response.read()
            out_file.write(data)
            print(f"✓ Saved {target_path} ({len(data)} bytes)")
        return True
    except Exception as e:
        print(f"✗ Failed to download {url}: {e}")
        return False

if __name__ == "__main__":
    success = 0
    for path, url in TEXTURES:
        if download_file(path, url):
            success += 1
    print(f"\nFinished: {success}/{len(TEXTURES)} textures downloaded successfully.")
