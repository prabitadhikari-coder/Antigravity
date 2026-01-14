import zipfile
import os

zips = ["FINAL_RobloxDungeonGame.zip", "UPDATED_RobloxDungeonBackend.zip"]

for z_name in zips:
    if os.path.exists(z_name):
        print(f"--- Contents of {z_name} ---")
        with zipfile.ZipFile(z_name, 'r') as z:
            for f in z.namelist():
                print(f)
        print("\n")
    else:
        print(f"File {z_name} not found.")
