import pygame
import sys
from settings import *
from game import Game
from ui import UI

def main():
    pygame.init()
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption("Tetris Python")
    clock = pygame.time.Clock()
    
    game = Game()
    ui = UI(screen)
    
    # Custom event for moving down automatically (gravity)
    GAME_UPDATE = pygame.USEREVENT
    pygame.time.set_timer(GAME_UPDATE, 500) # 500ms drop speed initial
    
    running = True
    while running:
        # 1. Event Handling
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
                sys.exit()
                
            if event.type == GAME_UPDATE:
                if not game.game_over:
                    moved = game.move(0, 1) # Move down
                    if not moved:
                        game.lock_piece()
            
            if event.type == pygame.KEYDOWN:
                if game.game_over:
                    if event.key == pygame.K_r:
                        game = Game() # Reset game
                else:
                    if event.key == pygame.K_LEFT:
                        game.move(-1, 0)
                    elif event.key == pygame.K_RIGHT:
                        game.move(1, 0)
                    elif event.key == pygame.K_DOWN:
                        game.move(0, 1)
                    elif event.key == pygame.K_UP:
                        game.rotate()
                    elif event.key == pygame.K_SPACE:
                        # Hard drop usually? Or just fast drop. 
                        # Let's do simple hard drop: move down until collision.
                        while game.move(0, 1):
                            pass
                        game.lock_piece()

        # 2. Drawing
        screen.fill(BG_COLOR)
        
        game.draw(screen)
        
        ui.draw_score(game.score)
        ui.draw_next_piece(game.next_piece)
        
        if game.game_over:
            ui.draw_game_over(game.score)
            
        pygame.display.update()
        clock.tick(FPS)

if __name__ == "__main__":
    main()
