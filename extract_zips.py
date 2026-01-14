import zipfile
import os

target_dir = 'RobloxRPG'
os.makedirs(target_dir, exist_ok=True)
zips = ["FINAL_RobloxDungeonGame.zip", "UPDATED_RobloxDungeonBackend.zip"]

for z_name in zips:
    print(f"Extracting {z_name}...")
    with zipfile.ZipFile(z_name, 'r') as z:
        z.extractall(target_dir)
print("Extraction complete.")
