import os
import struct
import urllib.request
import zlib

TARGET_DIR = "/home/am/.local/share/godot/export_templates/4.3.stable"
os.makedirs(TARGET_DIR, exist_ok=True)

url = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz"

# Resolve redirect
req = urllib.request.Request(url, method='HEAD')
with urllib.request.urlopen(req) as resp:
    final_url = resp.geturl()
    cl = int(resp.headers.get('Content-Length'))

print(f"Total archive size: {cl} bytes ({cl / (1024*1024):.1f} MB)")

# 1. Fetch EOCD (End of Central Directory)
req = urllib.request.Request(final_url, headers={'Range': f'bytes={cl-65536}-{cl-1}'})
with urllib.request.urlopen(req) as resp:
    tail = resp.read()

eocd_pos = tail.rfind(b'PK\x05\x06')
eocd = tail[eocd_pos:eocd_pos+22]
sig, disk, disk_cd, total_cd_disk, total_cd, cd_size, cd_offset = struct.unpack('<IHHHHII', eocd[:20])

# 2. Fetch Central Directory (only 3.5 KB)
req = urllib.request.Request(final_url, headers={'Range': f'bytes={cd_offset}-{cd_offset+cd_size-1}'})
with urllib.request.urlopen(req) as resp:
    cd_data = resp.read()

pos = 0
entries = []
for _ in range(total_cd):
    if cd_data[pos:pos+4] != b'PK\x01\x02':
        break
    (ver_made, ver_need, flags, method, mod_time, mod_date, crc,
     comp_size, uncomp_size, name_len, extra_len, comment_len,
     disk_start, int_attr, ext_attr, local_header_offset) = struct.unpack('<HHHHHHIIIHHHHHII', cd_data[pos+4:pos+46])
    
    pos += 46
    filename = cd_data[pos:pos+name_len].decode('utf-8', errors='ignore')
    pos += name_len + extra_len + comment_len
    
    entries.append({
        'filename': filename,
        'method': method,
        'comp_size': comp_size,
        'uncomp_size': uncomp_size,
        'offset': local_header_offset,
        'crc': crc
    })

print(f"Found {len(entries)} entries in central directory.")

# Target files needed for Android export
targets = ["android_debug.apk", "android_release.apk", "android_source.zip", "version.txt"]

for entry in entries:
    base_name = os.path.basename(entry['filename'])
    if base_name in targets or entry['filename'] in targets or entry['filename'].endswith(tuple(targets)):
        target_dest = os.path.join(TARGET_DIR, base_name)
        if os.path.exists(target_dest) and os.path.getsize(target_dest) == entry['uncomp_size']:
            print(f"Already exists: {base_name}")
            continue
            
        print(f"Downloading {base_name} ({entry['comp_size'] / (1024*1024):.2f} MB)...")
        # Read local header to get exact data offset
        lh_range = f"bytes={entry['offset']}-{entry['offset']+100}"
        req = urllib.request.Request(final_url, headers={'Range': lh_range})
        with urllib.request.urlopen(req) as resp:
            lh_data = resp.read()
            
        lh_name_len, lh_extra_len = struct.unpack('<HH', lh_data[26:30])
        data_start = entry['offset'] + 30 + lh_name_len + lh_extra_len
        data_end = data_start + entry['comp_size'] - 1
        
        # Stream download file data
        req = urllib.request.Request(final_url, headers={'Range': f'bytes={data_start}-{data_end}'})
        with urllib.request.urlopen(req) as resp:
            compressed_data = resp.read()
            
        if entry['method'] == 0: # Stored
            file_data = compressed_data
        elif entry['method'] == 8: # Deflated
            decompressor = zlib.decompressobj(-15)
            file_data = decompressor.decompress(compressed_data)
        else:
            print(f"Unknown compression method {entry['method']} for {base_name}")
            continue
            
        with open(target_dest, 'wb') as f:
            f.write(file_data)
        print(f"Successfully saved {target_dest} ({len(file_data)} bytes)!")

print("All Android export templates downloaded and ready!")
