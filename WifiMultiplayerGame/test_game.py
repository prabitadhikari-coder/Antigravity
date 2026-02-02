from game_state import GameState
from player import Player

def test_game_logic():
    print("Initializing GameState...")
    game = GameState()
    
    print("Adding Players...")
    p1 = game.add_player(0, "192.168.1.5")
    p2 = game.add_player(1, "192.168.1.6")
    
    assert len(game.players) == 2
    assert p1.hp == 3
    
    print("Starting Game...")
    game.start_game()
    assert game.game_started == True
    assert game.round_active == True
    assert len(game.shells) > 0
    
    print(f"Shells: {game.shells}")
    
    # Simulate a shot
    current_actor = game.players[game.current_turn_index]
    target = p2 if current_actor.id == p1.id else p1
    
    print(f"Turn: {current_actor.name} shooting {target.name}")
    
    initial_shells = len(game.shells)
    initial_hp = target.hp
    
    game.process_shot(current_actor.id, target.id, is_self_shot=False)
    
    assert len(game.shells) == initial_shells - 1
    
    # Check log
    print("Log:", game.log[-1])
    
    print("Test Passed!")

if __name__ == "__main__":
    test_game_logic()
