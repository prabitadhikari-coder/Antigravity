import pygame
from tetris.settings import *

class UI:
    def __init__(self, screen):
        self.screen = screen
        self.font = pygame.font.SysFont('Arial', 24, bold=True)
        self.big_font = pygame.font.SysFont('Arial', 48, bold=True)

    def draw_score(self, score):
        score_surface = self.font.render(f"Score: {score}", True, WHITE)
        self.screen.blit(score_surface, (20, 20))

    def draw_next_piece(self, piece):
        # Draw "Next" label
        label = self.font.render("Next:", True, WHITE)
        self.screen.blit(label, (320, 20))
        
        # Draw the piece itself
        # Just use a small offset like (320, 60) for preview
        start_x = 330
        start_y = 60
        
        if piece:
            # piece.shape contains the current rotation's coordinates
            for sx, sy in piece.shape:
                rect = pygame.Rect(start_x + sx * TILE_SIZE, start_y + sy * TILE_SIZE, TILE_SIZE, TILE_SIZE)
                pygame.draw.rect(self.screen, piece.color, rect.inflate(-2, -2))

    def draw_game_over(self, score):
        # Semi-transparent background
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
        overlay.set_alpha(200)
        overlay.fill(BLACK)
        self.screen.blit(overlay, (0, 0))
        
        # Game Over Text
        go_surf = self.big_font.render("GAME OVER", True, RED)
        go_rect = go_surf.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 - 50))
        self.screen.blit(go_surf, go_rect)
        
        # Final Score
        score_surf = self.font.render(f"Final Score: {score}", True, WHITE)
        score_rect = score_surf.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 + 10))
        self.screen.blit(score_surf, score_rect)
        
        # Restart Prompt
        restart_surf = self.font.render("Press R to Restart", True, YELLOW)
        restart_rect = restart_surf.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 + 60))
        self.screen.blit(restart_surf, restart_rect)
