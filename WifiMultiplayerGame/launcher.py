import subprocess
import sys

if __name__ == "__main__":
    # Redirect legacy launcher.py calls to the new main.py entry point
    print("Redirecting to main.py...")
    cmd = [sys.executable, "main.py"] + sys.argv[1:]
    subprocess.call(cmd)
