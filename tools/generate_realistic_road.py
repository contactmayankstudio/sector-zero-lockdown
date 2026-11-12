import numpy as np
from PIL import Image, ImageFilter, ImageDraw
import os

width, height = 1024, 1024
np.random.seed(42)

# Base asphalt tone: dark moody asphalt matching Dead Target
base_gray = np.random.normal(loc=55, scale=10, size=(height, width)).clip(25, 95).astype(np.uint8)

# Multiple octaves of noise for realistic aggregate
fine_noise = np.random.normal(loc=0, scale=6, size=(height, width)).astype(np.int16)
med_noise = np.repeat(np.repeat(np.random.normal(loc=0, scale=10, size=(height//2, width//2)), 2, axis=0), 2, axis=1).astype(np.int16)
coarse_noise = np.repeat(np.repeat(np.random.normal(loc=0, scale=12, size=(height//4, width//4)), 4, axis=0), 4, axis=1).astype(np.int16)

asphalt = np.clip(base_gray.astype(np.int16) + fine_noise + med_noise + coarse_noise, 25, 110).astype(np.uint8)

img_rgb = np.zeros((height, width, 3), dtype=np.float32)
# Slight cool industrial slate blue-gray tone
img_rgb[:, :, 0] = np.clip(asphalt.astype(np.float32) - 2.0, 0, 255)
img_rgb[:, :, 1] = np.clip(asphalt.astype(np.float32) + 1.0, 0, 255)
img_rgb[:, :, 2] = np.clip(asphalt.astype(np.float32) + 6.0, 0, 255)

# Tire tracks (darker vertical bands where car/truck wheels drive: x ~ 280-380, x ~ 640-740)
tire_left = np.exp(-((np.arange(width) - 330) ** 2) / (2 * 50**2))
tire_right = np.exp(-((np.arange(width) - 690) ** 2) / (2 * 50**2))
tire_bands = (tire_left + tire_right).reshape(1, width, 1)
img_rgb = img_rgb * (1.0 - tire_bands * 0.22)

# Natural organic oil stain map (blurred)
stain_layer = np.zeros((height, width), dtype=np.float32)
for _ in range(20):
    cx = np.random.randint(250, 780)
    cy = np.random.randint(50, 974)
    rx = np.random.randint(25, 75)
    ry = np.random.randint(30, 110)
    y_coords, x_coords = np.ogrid[:height, :width]
    dist_sq = ((x_coords - cx)**2 / rx**2 + (y_coords - cy)**2 / ry**2)
    stain_patch = np.clip(1.0 - dist_sq, 0.0, 1.0)
    stain_layer = np.maximum(stain_layer, stain_patch * np.random.uniform(0.25, 0.55))

# Smooth the stains with Gaussian filter
stain_img = Image.fromarray((stain_layer * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(radius=8))
smooth_stains = np.array(stain_img).astype(np.float32) / 255.0

img_rgb = img_rgb * (1.0 - smooth_stains[:, :, np.newaxis] * 0.40)
img_rgb = np.clip(img_rgb, 0, 255).astype(np.uint8)

pil_img = Image.fromarray(img_rgb)
draw = ImageDraw.Draw(pil_img)

stripe_yellow = (230, 170, 35)

# Double yellow boundary lines on left and right borders (authentic Dead Target road markings)
for y in range(0, height, 4):
    wobble_l = int(np.sin(y * 0.03) * 1.5)
    wobble_r = int(np.cos(y * 0.03) * 1.5)
    # Left double lines
    draw.rectangle([115 + wobble_l, y, 126 + wobble_l, y + 4], fill=stripe_yellow)
    draw.rectangle([134 + wobble_l, y, 145 + wobble_l, y + 4], fill=stripe_yellow)
    # Right double lines
    draw.rectangle([878 + wobble_r, y, 889 + wobble_r, y + 4], fill=stripe_yellow)
    draw.rectangle([897 + wobble_r, y, 908 + wobble_r, y + 4], fill=stripe_yellow)

# Weathering & distress over paint
road_arr = np.array(pil_img).astype(np.float32)
micro_grime = np.random.uniform(0.82, 1.0, size=(height, width, 1))
road_arr = np.clip(road_arr * micro_grime, 0, 255).astype(np.uint8)

diff_path = "/home/am/targetkill/textures/pbr/tex_industrial_asphalt.png"
Image.fromarray(road_arr).save(diff_path)
print("Updated realistic asphalt matching Dead Target reference.")

# Generate matching tangent-space normal map
sobel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], dtype=np.float32)
sobel_y = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]], dtype=np.float32)

gray_float = asphalt.astype(np.float32) / 255.0
gx = np.zeros_like(gray_float)
gy = np.zeros_like(gray_float)

gx[1:-1, 1:-1] = (
    gray_float[:-2, 2:] + 2*gray_float[1:-1, 2:] + gray_float[2:, 2:] -
    gray_float[:-2, :-2] - 2*gray_float[1:-1, :-2] - gray_float[2:, :-2]
)
gy[1:-1, 1:-1] = (
    gray_float[2:, :-2] + 2*gray_float[2:, 1:-1] + gray_float[2:, 2:] -
    gray_float[:-2, :-2] - 2*gray_float[:-2, 1:-1] - gray_float[:-2, 2:]
)

strength = 2.5
nx = -gx * strength
ny = -gy * strength
nz = np.ones_like(nx)
norm = np.sqrt(nx**2 + ny**2 + nz**2)
nx, ny, nz = nx/norm, ny/norm, nz/norm

normal_rgb = np.zeros((height, width, 3), dtype=np.uint8)
normal_rgb[:, :, 0] = np.clip((nx * 0.5 + 0.5) * 255, 0, 255).astype(np.uint8)
normal_rgb[:, :, 1] = np.clip((ny * 0.5 + 0.5) * 255, 0, 255).astype(np.uint8)
normal_rgb[:, :, 2] = np.clip((nz * 0.5 + 0.5) * 255, 0, 255).astype(np.uint8)

norm_path = "/home/am/targetkill/textures/pbr/tex_asphalt_normal.png"
Image.fromarray(normal_rgb).save(norm_path)
print("Updated asphalt normal map.")
