import random
from tetris.settings import *

class Tetromino:
    def __init__(self, x, y):
        self.x = x # Grid x
        self.y = y # Grid y
        self.type = random.choice(list(SHAPES.keys()))
        self.color = SHAPES_COLORS[self.type]
        self.rotation = 0 # 0, 1, 2, 3
        # Start with base shape
        self.shape = SHAPES[self.type]

    def rotate(self):
        if self.type == 'O':
            return # O doesn't rotate

        # Classical rotation (x, y) -> (-y, x) for 90 degrees clockwise
        # But this depends on coordinate system.
        # Screen: x right, y down.
        # (1, 0) -> (0, 1) ? 
        # (1, 0) is Right. (0, 1) is Down. Right -> Down is 90 CW.
        # (0, 1) -> (-1, 0). Down -> Left. 90 CW.
        # (-1, 0) -> (0, -1). Left -> Up. 90 CW.
        # (0, -1) -> (1, 0). Up -> Right. 90 CW.
        # So yes, new_x = -old_y, new_y = old_x
        
        new_shape = []
        for sx, sy in self.shape:
            new_shape.append((-sy, sx))
        self.shape = new_shape
        self.rotation = (self.rotation + 1) % 4

    def undo_rotate(self):
         # Rotate counter-clockwise: (x, y) -> (y, -x)
        if self.type == 'O':
            return
            
        new_shape = []
        for sx, sy in self.shape:
            new_shape.append((sy, -sx))
        self.shape = new_shape
        self.rotation = (self.rotation - 1) % 4

    def get_positions(self):
        # Returns absolute grid positions
        positions = []
        for sx, sy in self.shape:
            positions.append((self.x + sx, self.y + sy))
        return positions
