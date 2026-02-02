import random
from constants import *
from player import Player

class GameState:
    def __init__(self):
        self.players = [] 
        self.shells = [] 
        self.current_turn_index = 0
        self.game_started = False
        self.round_active = False
        self.log = [] 

    def add_player(self, id, addr):
        # 1. Check if player with same IP exists and is disconnected
        # addr is (ip, port), we just check ip
        client_ip = addr[0]
        for p in self.players:
            # Assuming p.addr is stored as (ip, port)
            if p.addr[0] == client_ip and not p.is_connected:
                p.is_connected = True
                p.addr = addr # Update port
                self.log.append(f"{p.name} Reconnected.")
                return p

        # 2. Add New Player if space
        if len(self.players) < MAX_PLAYERS and not self.game_started:
            new_player = Player(id, addr, name=f"Player {id}")
            self.players.append(new_player)
            return new_player
        return None

    def update_player_info(self, id, name, model_id):
        p = self.get_player(id)
        if p:
            p.name = name
            p.model_id = model_id

    def get_player(self, id):
        for p in self.players:
            if p.id == id:
                return p
        return None

    def start_game(self):
        if len(self.players) >= 2:
            self.game_started = True
            self.start_round()
            return True
        return False

    def start_round(self):
        # Generate shells
        count = random.randint(3, 8)
        lives = random.randint(1, count - 1)
        blanks = count - lives
        
        self.shells = [SHELL_LIVE] * lives + [SHELL_BLANK] * blanks
        random.shuffle(self.shells)
        
        self.log.append(f"Round Start! {lives} Live, {blanks} Blank.")
        
        # Give Items (New Round always refreshes)
        self.distribute_items()
        
        # Reset Turn Cycle Tracking
        self.acted_in_cycle = set()
        
        self.round_active = True
        self.validate_turn()

    def distribute_items(self):
        # 1 to 4 items given randomly to ALL players (same count for everyone)
        import random
        items_to_give = random.randint(1, 4)
        
        for p in self.players:
            if p.alive:
                # Add 'items_to_give' random items, respecting MAX_ITEMS
                for _ in range(items_to_give):
                    if len(p.inventory) < MAX_ITEMS:
                        p.inventory.append(random.choice(ITEMS_LIST))

    def next_turn(self):
        # Reset current player's temporary statuses (Saw)
        curr = self.players[self.current_turn_index]
        if curr: curr.saw_active = False
        
        self.current_turn_index = (self.current_turn_index + 1) % len(self.players)
        self.validate_turn()

    def process_shot(self, actor_id, target_id, is_self_shot):
        if not self.shells:
            self.start_round()
            return

        shell = self.shells.pop(0)
        actor = self.get_player(actor_id)
        target = self.get_player(target_id)
        
        if not actor or not target: return

        # Track that this player acted (Turn Cycle)
        if not hasattr(self, 'acted_in_cycle'): self.acted_in_cycle = set()
        self.acted_in_cycle.add(actor_id)

        is_live = (shell == SHELL_LIVE)
        
        dmg = 1
        if actor.saw_active:
            dmg = 2
            actor.saw_active = False # Consumed

        log_msg = f"{actor.name} shoots "
        log_msg += "themselves" if is_self_shot else f"{target.name}"
        log_msg += "! It was " + ("LIVE!" if is_live else "BLANK.")
        self.log.append(log_msg)

        if is_live:
            target.take_damage(dmg)
            self.next_turn()
        else:
            if is_self_shot:
                pass # Go again
            else:
                self.next_turn()

        self.check_win_condition()
        
        # Check Turn Cycle Complete (Mid-round Item Refresh)
        alive_ids = {p.id for p in self.players if p.alive and p.is_connected}
        # Filter acted set to only include currently alive/connected (in case someone died)
        valid_acted = self.acted_in_cycle.intersection(alive_ids)
        
        if valid_acted == alive_ids and self.game_started and self.round_active:
             self.log.append("All players acted: New Items Distributed!")
             self.distribute_items()
             self.acted_in_cycle = set()

        if not self.shells and self.round_active:
             self.start_round()

    def process_item(self, actor_id, item_name, target_id=None):
        actor = self.get_player(actor_id)
        if not actor or item_name not in actor.inventory: return None

        # Remove item
        actor.inventory.remove(item_name)
        self.log.append(f"{actor.name} used {item_name}!")
        
        result = None

        if item_name == ITEM_BEER:
            if self.shells:
                s = self.shells.pop(0)
                self.log.append(f"Beer racked a {s} shell.")
            else:
                 self.start_round() # Empty?
        
        elif item_name == ITEM_CIGS:
            actor.heal(1)
        
        elif item_name == ITEM_SAW:
            actor.saw_active = True
        
        elif item_name == ITEM_CUFFS:
            if target_id is not None:
                t = self.get_player(target_id)
                if t and t.id != actor_id:
                    t.is_cuffed = True
        
        elif item_name == ITEM_GLASS:
            if self.shells:
                result = {"type": "GLASS_RESULT", "shell": self.shells[0]}
        
        return result

    def check_win_condition(self):
        alive_players = [p for p in self.players if p.alive]
        
        # If everyone died (Draw)
        if len(alive_players) == 0 and self.game_started and len(self.players) > 0:
             self.log.append("EVERYONE DIED. GAME OVER.")
             self.round_active = False
             self.log.append("Restarting in 3 seconds...")
             self.reset_game_state()
             self.start_round()
             return

        # If 1 player remains (Winner)
        if len(alive_players) == 1 and self.game_started and len(self.players) > 1:
            winner = alive_players[0]
            self.log.append(f"{winner.name} WINS THE ROUND!")
            
            self.round_active = False
            self.log.append("Starting New Round...")
            
            # Revive everyone for the next round
            self.reset_game_state()
            self.start_round()

    def reset_game_state(self):
        for p in self.players:
            if p.is_connected: 
                if not p.alive:
                    p.alive = True
                    p.hp = MAX_HP # Revive dead to Full
                else:
                    # Survivors keep their HP (Persistent)
                    pass
                
                # Everyone keeps inventory (Persistent)
                # Reset Status Effects
                p.is_cuffed = False
                p.saw_active = False
                
        self.current_turn_index = 0

    def to_dict(self):
        return {
            "players": [p.to_dict() for p in self.players],
            "shells_count": len(self.shells),
            "current_turn_index": self.current_turn_index,
            "round_active": self.round_active,
            "log": self.log[-5:] 
        }
