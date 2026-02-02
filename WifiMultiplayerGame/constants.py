# Constants
import pygame

# Network
PORT = 5555
HEADER_SIZE = 64
FORMAT = 'utf-8'

# Screen
SCREEN_WIDTH = 1024 # Made wider for 6 players + items
SCREEN_HEIGHT = 768
FPS = 60

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
RED = (200, 50, 50)
GREEN = (50, 200, 50)
BLUE = (50, 50, 200)
GRAY = (100, 100, 100)
DARK_GRAY = (40, 40, 40)
YELLOW = (255, 255, 0)
CYAN = (0, 255, 255)
MAGENTA = (255, 0, 255)
BROWN = (139, 69, 19)

# Models / Colors
MODELS = {
    0: {"name": "Red Guy", "color": RED},
    1: {"name": "Blue Guy", "color": BLUE},
    2: {"name": "Green Guy", "color": GREEN},
    3: {"name": "Yellow Guy", "color": YELLOW},
    4: {"name": "Cyan Guy", "color": CYAN},
    5: {"name": "Magenta Guy", "color": MAGENTA}
}

# Game

# Settings
MAX_PLAYERS = 6
MAX_HP = 10
MAX_ITEMS = 8

SHELL_LIVE = "LIVE"
SHELL_BLANK = "BLANK"

# Items
ITEM_BEER = "BEER"
ITEM_GLASS = "GLASS"
ITEM_CIGS = "CIGS"
ITEM_CUFFS = "CUFFS"
ITEM_SAW = "SAW"

ITEMS_LIST = [ITEM_BEER, ITEM_GLASS, ITEM_CIGS, ITEM_CUFFS, ITEM_SAW]
