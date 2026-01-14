import pygame
from tetris.settings import *
from tetris.tetromino import Tetromino

class Game:
    def __init__(self):
        self.grid = [[None for _ in range(GRID_WIDTH)] for _ in range(GRID_HEIGHT)]
        self.current_piece = Tetromino(GRID_WIDTH // 2, 0)
        self.next_piece = Tetromino(GRID_WIDTH // 2, 0)
        self.game_over = False
        self.score = 0

    def new_piece(self):
        self.current_piece = self.next_piece
        self.next_piece = Tetromino(GRID_WIDTH // 2, 0)
        # Check if new piece collides immediately -> Game Over
        if self.check_collision():
             self.game_over = True

    def check_collision(self, offset_x=0, offset_y=0):
        for px, py in self.current_piece.get_positions():
            nx, ny = px + offset_x, py + offset_y
            
            # Check boundaries
            if nx < 0 or nx >= GRID_WIDTH or ny >= GRID_HEIGHT:
                return True
            
            # Check grid cells (ignore validation if y < 0, meaning above board)
            if ny >= 0:
                if self.grid[ny][nx] is not None:
                    return True
        return False

    def move(self, dx, dy):
        if self.game_over: return
        
        if not self.check_collision(dx, dy):
            self.current_piece.x += dx
            self.current_piece.y += dy
            return True
        return False

    def rotate(self):
        if self.game_over: return
        
        self.current_piece.rotate()
        if self.check_collision():
            # Wall kick logic (simplistic)
            # Try moving left, right, up to fit
            kicks = [(-1, 0), (1, 0), (0, -1), (-2, 0), (2, 0)]
            kicked = False
            for kx, ky in kicks:
                if not self.check_collision(kx, ky):
                    self.current_piece.x += kx
                    self.current_piece.y += ky
                    kicked = True
                    break
            
            if not kicked:
                self.current_piece.undo_rotate()

    def update(self):
        if self.game_over: return
        
        # Gravity handled by main loop timing usually, but logical update here just locks if needed
        pass

    def lock_piece(self):
        for px, py in self.current_piece.get_positions():
            if py < 0:
                self.game_over = True # Block locked above screen
                continue
            self.grid[py][px] = self.current_piece.color
        
        self.clear_lines()
        self.new_piece()

    def clear_lines(self):
        lines_to_clear = 0
        # Iterate from bottom to top
        y = GRID_HEIGHT - 1
        while y >= 0:
            if all(cell is not None for cell in self.grid[y]):
                lines_to_clear += 1
                # Remove this row and insert a new empty one at top
                del self.grid[y]
                self.grid.insert(0, [None for _ in range(GRID_WIDTH)])
                # Don't decrement y, re-check the new row at this index (which was the one above)
            else:
                y -= 1
        
        if lines_to_clear > 0:
            self.score += lines_to_clear * 100 # Simple scoring

    def draw(self, screen):
        # Draw Grid
        for y in range(GRID_HEIGHT):
            for x in range(GRID_WIDTH):
                rect = pygame.Rect(TOP_LEFT_X + x * TILE_SIZE, TOP_LEFT_Y + y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
                pygame.draw.rect(screen, GRID_COLOR, rect, 1) # Border
                
                if self.grid[y][x]:
                    pygame.draw.rect(screen, self.grid[y][x], rect.inflate(-2, -2))

        # Draw Current Piece
        if self.current_piece:
            for px, py in self.current_piece.get_positions():
                if py >= 0:
                    rect = pygame.Rect(TOP_LEFT_X + px * TILE_SIZE, TOP_LEFT_Y + py * TILE_SIZE, TILE_SIZE, TILE_SIZE)
                    pygame.draw.rect(screen, self.current_piece.color, rect.inflate(-2, -2))
        
        # Draw Border
        pygame.draw.rect(screen, BORDER_COLOR, (TOP_LEFT_X - 2, TOP_LEFT_Y - 2, GAME_WIDTH + 4, GAME_HEIGHT + 4), 2)
