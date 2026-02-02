import pygame
import threading
import sys
import subprocess
import os
import socket
import pickle
import time
import tkinter as tk
from tkinter import messagebox

# Internal Imports (Assuming in same dir)
from constants import *
from network import Server, Network
from player import Player
from game_state import GameState

# --- ASSET HANDLING ---
assets = {}

def load_assets():
    def load(name, filename):
        try:
            path = f"assets/{filename}"
            if os.path.exists(path):
                img = pygame.image.load(path)
                return pygame.transform.scale(img, (64, 64)) 
            else:
                return None
        except: return None

    try:
        bg = pygame.image.load("assets/table_background.png")
        assets["table"] = pygame.transform.scale(bg, (SCREEN_WIDTH, SCREEN_HEIGHT))
    except: assets["table"] = None

    try:
        gun = pygame.image.load("assets/shotgun_topdown.png")
        assets["gun"] = pygame.transform.scale(gun, (400, 100))
    except: assets["gun"] = None

    try:
        s_live = pygame.image.load("assets/shell_live.png")
        assets["shell_live"] = pygame.transform.scale(s_live, (30, 60))
    except: assets["shell_live"] = None
    try:
        s_blank = pygame.image.load("assets/shell_blank.png")
        assets["shell_blank"] = pygame.transform.scale(s_blank, (30, 60))
    except: assets["shell_blank"] = None

    item_map = {
        ITEM_BEER: "item_beer.png",
        ITEM_GLASS: "item_glass.png",
        ITEM_CUFFS: "item_cuffs.png",
        ITEM_SAW: "item_saw.png",
        ITEM_CIGS: "item_cigs.png"
    }
    for k, v in item_map.items():
        assets[k] = load(k, v)


# --- PYGAME UTIL ---
win = None
font = None

def draw_text(text, x, y, color=WHITE, center=False, small=False):
    if not win: return
    f = pygame.font.SysFont("comicsans", 20 if small else 30)
    img = f.render(str(text), 1, color)
    if center:
        rect = img.get_rect(center=(x, y))
        win.blit(img, rect)
    else:
        win.blit(img, (x, y))

def draw_players(players, my_id, turn_idx):
    slots = [
        (150, 50), (SCREEN_WIDTH//2 - 75, 50), (SCREEN_WIDTH-300, 50),
        (150, SCREEN_HEIGHT-150), (SCREEN_WIDTH//2 - 75, SCREEN_HEIGHT-150), (SCREEN_WIDTH-300, SCREEN_HEIGHT-150)
    ]
    
    for i, p in enumerate(players):
        if i >= len(slots): break
        x, y = slots[i]
        
        model_data = MODELS.get(p["model_id"], MODELS[0])
        color = model_data["color"]
        
        # Turn Highlight
        if turn_idx < len(players) and players[turn_idx]["id"] == p["id"]:
             pygame.draw.rect(win, YELLOW, (x-5, y-5, 160, 110), 3)

        # Player Box
        pygame.draw.rect(win, color, (x, y, 150, 100))
        if not p["alive"]:
            pygame.draw.line(win, BLACK, (x, y), (x+150, y+100), 5)
            pygame.draw.line(win, BLACK, (x+150, y), (x, y+100), 5)
        
        # Info
        name_txt = f"{p['name']} (ID:{p['id']})"
        if p["id"] == my_id: name_txt += " [YOU]"
        draw_text(name_txt, x, y - 25, BLACK, small=True)
        draw_text(f"HP: {p['hp']}", x + 5, y + 5, BLACK, small=True)

        # Inventory
        if p["inventory"]:
            ix = x + 5
            iy = y + 50
            for item_name in p["inventory"]:
                icon = assets.get(item_name)
                if icon:
                    win.blit(pygame.transform.scale(icon, (32, 32)), (ix, iy))
                else:
                    draw_text(item_name[0], ix+10, iy, BLACK, small=True)
                ix += 35
                
        # Status
        status = ""
        if p["is_cuffed"]: status += "CUFFED "
        if p["saw_active"]: status += "SAW "
        if status:
            draw_text(status, x+5, y+85, RED, small=True)


# --- GAME LOOP ---
def run_game_client(host_ip, name, model_id):
    global win, font
    pygame.init() # Init here inside the process
    win = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption(f"Buckshot Multiplayer - {name}")
    font = pygame.font.SysFont("comicsans", 30)
    
    load_assets()

    n = Network(host_ip, name, model_id)
    if n.p_id is None:
        print("Failed to connect")
        return 

    run = True
    clock = pygame.time.Clock()

    state = None
    private_msg = ""
    private_timer = 0
    show_help = False
    
    while run:
        clock.tick(FPS)
        try:
            state = n.send("get_state")
            if state is None: raise Exception("Disconnected")
            if state and "private_info" in state:
                p_info = state["private_info"]
                if p_info["type"] == "GLASS_RESULT":
                     private_msg = f"GLASS REVEALS: {p_info['shell']}"
                     private_timer = 120 
        except Exception as e:
             print(f"Connection Lost: {e}")
             break

        # Draw BG
        if assets.get("table"):
            win.blit(assets["table"], (0,0))
        else:
            win.fill(GRAY)
            pygame.draw.rect(win, BROWN, (200, 200, SCREEN_WIDTH-400, SCREEN_HEIGHT-400))
        
        # Back Button
        pygame.draw.rect(win, RED, (10, 10, 80, 30))
        draw_text("BACK", 50, 25, WHITE, True, True)
        
        # Session Info
        info_txt = f"Connected to: {host_ip}"
        if n.p_id == 0: info_txt += " (HOST)"
        else: info_txt += " (CLIENT)"
        draw_text(info_txt, SCREEN_WIDTH - 150, 20, WHITE, True, small=True)

        if not state:
            draw_text("Waiting for server...", SCREEN_WIDTH//2, SCREEN_HEIGHT//2, center=True)
        else:
            # Gun
            if assets.get("gun"):
                win.blit(assets["gun"], (SCREEN_WIDTH//2 - 200, SCREEN_HEIGHT//2 - 50))
            else:
                pygame.draw.rect(win, BLACK, (SCREEN_WIDTH//2 - 50, SCREEN_HEIGHT//2 - 20, 100, 40))
                draw_text("GUN", SCREEN_WIDTH//2, SCREEN_HEIGHT//2, WHITE, True, True)

            draw_text(f"Shells: {state['shells_count']}", SCREEN_WIDTH//2, SCREEN_HEIGHT//2 + 60, WHITE, True)
            draw_players(state["players"], n.p_id, state["current_turn_index"])
            
            # Log
            log_y = SCREEN_HEIGHT - 30
            for l in reversed(state["log"]):
                draw_text(l, 10, log_y, WHITE, small=True)
                log_y -= 25
                if log_y < SCREEN_HEIGHT - 150: break

            # Private Info
            if private_timer > 0:
                draw_text(private_msg, SCREEN_WIDTH//2, SCREEN_HEIGHT//2 - 100, CYAN, True)
                private_timer -= 1

            # Input
            players = state["players"]
            my_p_data = next((p for p in players if p["id"] == n.p_id), None)
            cmd = None
            if state["round_active"] and players[state['current_turn_index']]['id'] == n.p_id:
                draw_text("YOUR TURN!", SCREEN_WIDTH//2, 50, RED, True)
                
                # Instructions
                tips = "[S] Self | [0-5] Shoot ID | Items: [B]eer [G]lass [H]eal [K]Saw"
                draw_text(tips, SCREEN_WIDTH//2, 80, BLACK, True, small=True)
                
                keys = pygame.key.get_pressed()
                if keys[pygame.K_s]: cmd = {"action": "SHOOT", "target_id": n.p_id}
                else:
                    for i in range(6):
                       if keys[pygame.K_0 + i]:
                             tid = i - 1
                             if tid == -1: tid = 9 
                             else: cmd = {"action": "SHOOT", "target_id": i}
                if my_p_data:
                    inv = my_p_data["inventory"]
                    if keys[pygame.K_b] and ITEM_BEER in inv: cmd = {"action": "USE_ITEM", "item_id": ITEM_BEER}
                    if keys[pygame.K_g] and ITEM_GLASS in inv: cmd = {"action": "USE_ITEM", "item_id": ITEM_GLASS}
                    if keys[pygame.K_h] and ITEM_CIGS in inv: cmd = {"action": "USE_ITEM", "item_id": ITEM_CIGS}
                    if keys[pygame.K_k] and ITEM_SAW in inv: cmd = {"action": "USE_ITEM", "item_id": ITEM_SAW}

            if not state["round_active"] and n.p_id == 0:
                draw_text("Press [SPACE] to Start Game", SCREEN_WIDTH//2, 550, BLUE, True)
                if pygame.key.get_pressed()[pygame.K_SPACE]: cmd = {"action": "START_GAME"}

            if cmd:
                state = n.send(cmd)
                pygame.time.delay(200)

        # Draw Help Overlay
        if show_help:
            draw_help_overlay()
        else:
            draw_text("Hold [TAB] for Controls/Info", SCREEN_WIDTH//2, SCREEN_HEIGHT - 20, WHITE, True, small=True)

        pygame.display.update()
        for event in pygame.event.get():
            if event.type == pygame.QUIT: run = False
            if event.type == pygame.MOUSEBUTTONDOWN:
                x, y = pygame.mouse.get_pos()
                if 10 <= x <= 90 and 10 <= y <= 40: run = False
            
            # Toggle Help
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_TAB: show_help = not show_help

    pygame.quit()
    # Relaunch Launcher
    main_exe = sys.executable
    script = sys.argv[0]
    if getattr(sys, 'frozen', False):
        subprocess.Popen([main_exe])
    else:
        subprocess.Popen([main_exe, script])
    sys.exit()

def draw_help_overlay():
    # Semi-transparent bg
    s = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
    s.set_alpha(200)
    s.fill((0,0,0))
    win.blit(s, (0,0))
    
    cx = SCREEN_WIDTH // 2
    cy = 100
    
    draw_text("CONTROLS & ITEMS", cx, 50, GREEN, True)
    
    # Controls
    lines = [
        "--- CONTROLS ---",
        "[S] : Shoot Yourself (Risk/Reward)",
        "[0-5] : Shoot Player ID (Target)",
        "[TAB] : Toggle this menu",
        "",
        "--- ITEMS ---",
        "[B]eer : Rack (Skip) current shell",
        "[G]lass : Peek inside chamber (See if Live/Blank)",
        "[C]igarettes (Heal) : Restore 1 HP",
        "Saw [K]nife : Double Damage for next shot",
        "Hand[C]uffs : Skip opponent's next turn"
    ]
    
    for line in lines:
        col = WHITE
        if "---" in line: col = YELLOW
        draw_text(line, cx, cy, col, True, small=True)
        cy += 35


# --- LAUNCHER UI ---
class Launcher:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Buckshot Multiplayer")
        self.root.geometry("500x600")
        self.root.configure(bg="#1a1a1a")
        
        self.selected_model = 0
        self.name_var = tk.StringVar(value="Player")
        self.ip_var = tk.StringVar(value="localhost")
        self.status_var = tk.StringVar(value="")
        
        self.setup_ui()

    def setup_ui(self):
        bg = "#1a1a1a"
        fg = "#ffffff"
        
        tk.Label(self.root, text="BUCKSHOT LAN", font=("Segoe UI", 24, "bold"), fg="#ff4444", bg=bg).pack(pady=30)
        
        frame = tk.Frame(self.root, bg=bg)
        frame.pack(pady=10)
        
        tk.Label(frame, text="NAME", fg="#aaa", bg=bg, anchor="w").pack(fill="x")
        tk.Entry(frame, textvariable=self.name_var, font=("Segoe UI", 12)).pack(fill="x", pady=(0, 20))
        
        tk.Label(frame, text="AVATAR", fg="#aaa", bg=bg, anchor="w").pack(fill="x")
        model_frame = tk.Frame(frame, bg=bg)
        model_frame.pack(pady=5)
        
        self.model_btns = []
        for i in range(6):
            c = MODELS[i]["color"]
            hex_c = '#%02x%02x%02x' % c
            f = tk.Frame(model_frame, bg=bg, padx=2, pady=2)
            f.pack(side="left", padx=5)
            b = tk.Button(f, bg=hex_c, width=4, height=2, command=lambda x=i: self.select_model(x), relief="flat")
            b.pack()
            self.model_btns.append(f)
        self.select_model(0)

        tk.Label(frame, text="HOST IP (JOIN)", fg="#aaa", bg=bg, anchor="w").pack(fill="x", pady=(20,0))
        tk.Entry(frame, textvariable=self.ip_var, font=("Segoe UI", 12)).pack(fill="x")

        tk.Label(self.root, textvariable=self.status_var, fg="#f00", bg=bg).pack(pady=5)

        tk.Button(self.root, text="HOST GAME", bg="#4CAF50", fg="white", font=("Segoe UI", 12, "bold"), command=self.host_game, relief="flat").pack(fill="x", padx=50, pady=10)
        tk.Button(self.root, text="JOIN GAME", bg="#2196F3", fg="white", font=("Segoe UI", 12, "bold"), command=self.join_game, relief="flat").pack(fill="x", padx=50, pady=5)

    def select_model(self, idx):
        self.selected_model = idx
        for i, f in enumerate(self.model_btns):
            f.config(bg="white" if i==idx else "#1a1a1a")

    def run_process(self, args):
        # Spawn new process
        main_exe = sys.executable
        if getattr(sys, 'frozen', False):
            cmd = [main_exe] + args
        else:
            cmd = [main_exe, sys.argv[0]] + args
        
        subprocess.Popen(cmd)

    def host_game(self):
        name = self.name_var.get()
        if not name: return
        
        self.root.destroy()
        # Spawn Server
        self.run_process(["--server"])
        
        # Wait for server to initialize
        time.sleep(1.0)
        
        # Spawn Client (Self) -> Connects to localhost by default
        self.run_process(["--client", "--connect", "localhost", "--name", name, "--model", str(self.selected_model)])
        sys.exit()

    def join_game(self):
        name = self.name_var.get()
        ip = self.ip_var.get()
        if not name or not ip: return
        
        self.root.destroy()
        self.run_process(["--client", "--connect", ip, "--name", name, "--model", str(self.selected_model)])
        sys.exit()

    def run(self):
        self.root.mainloop()


# --- ENTRY POINT ---
if __name__ == "__main__":
    if "--server" in sys.argv:
        # Run Server Mode
        s = Server()
        s.run() # Blocking
    elif "--client" in sys.argv:
        # Run Client Mode
        # Parse args manually strictly
        ip = "localhost"
        name = "Player"
        model = 0
        try:
            if "--connect" in sys.argv:
                idx = sys.argv.index("--connect") + 1
                if idx < len(sys.argv): ip = sys.argv[idx]
            if "--name" in sys.argv:
                idx = sys.argv.index("--name") + 1
                if idx < len(sys.argv): name = sys.argv[idx]
            if "--model" in sys.argv:
                idx = sys.argv.index("--model") + 1
                if idx < len(sys.argv): model = int(sys.argv[idx])
        except: pass
        
        run_game_client(ip, name, model)
    else:
        # Run Launcher
        app = Launcher()
        app.run()
