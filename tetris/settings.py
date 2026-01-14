import pygame

# Game Settings
SCREEN_WIDTH = 450
SCREEN_HEIGHT = 750
FPS = 60

# Grid Settings
TILE_SIZE = 30
GRID_WIDTH = 10
GRID_HEIGHT = 20
GAME_WIDTH = GRID_WIDTH * TILE_SIZE
GAME_HEIGHT = GRID_HEIGHT * TILE_SIZE

# Offsets to center the grid on screen
TOP_LEFT_X = (SCREEN_WIDTH - GAME_WIDTH) // 2
TOP_LEFT_Y = SCREEN_HEIGHT - GAME_HEIGHT - 20

# Colors
BLACK = (20, 20, 20)
WHITE = (255, 255, 255)
GRAY = (50, 50, 50)
RED = (220, 20, 60)
GREEN = (0, 200, 0)
BLUE = (0, 0, 255)
CYAN = (0, 255, 255)
MAGENTA = (200, 0, 200)
YELLOW = (255, 255, 0)
ORANGE = (255, 165, 0)
PURPLE = (128, 0, 128)
BG_COLOR = (10, 10, 10)
GRID_COLOR = (40, 40, 40)
BORDER_COLOR = (200, 200, 200)

SHAPES_COLORS = {
    'I': CYAN,
    'J': BLUE,
    'L': ORANGE,
    'O': YELLOW,
    'S': GREEN,
    'T': PURPLE,
    'Z': RED
}

# Simplified shape definitions
# 0,0 is the center of rotation
# Shapes are defined as lists of (x, y) offsets
SHAPES = {
    'I': [(0, -1), (0, 0), (0, 1), (0, 2)], # Vertical line (x constant, y varies)
    'J': [(-1, -1), (0, -1), (0, 0), (0, 1)], # Top-left, top-center, center, bot-center
    'L': [(1, -1), (0, -1), (0, 0), (0, 1)],
    'O': [(0, 0), (1, 0), (0, 1), (1, 1)],
    'S': [(0, -1), (0, 0), (1, 0), (1, 1)],
    'T': [(-1, 0), (0, 0), (1, 0), (0, -1)],
    'Z': [(-1, -1), (0, -1), (0, 0), (1, 0)]
    # Wait, these are ONE orientation. The class will handle 90 degree rotation math.
    # I = Vertical: (0, -1) is above center?
    # Grid: y increases DOWN. x increases RIGHT.
    # (0,0) is pivot.
    # I: (0,-1) [above], (0,0) [center], (0,1) [below], (0,2) [below below] -> Vertical. CORRECT.
}
