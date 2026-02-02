import socket
import pickle
import threading
from constants import *
from game_state import GameState

class Server:
    def __init__(self):
        self.host = '0.0.0.0' # Bind to all interfaces
        self.local_ip = self.get_local_ip() # For display
        self.port = PORT
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        
        # Allow reusing address to prevent "Address already in use" errors on quick restarts
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        
        self.game = GameState()
        self.clients = []
        try:
            self.socket.bind((self.host, self.port))
            self.socket.listen(MAX_PLAYERS)
            print(f"Server started. Share this IP: {self.local_ip}")
        except socket.error as e:
            print(f"Server Bind Error: {e}")
            raise e


    def get_local_ip(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return "localhost"

    def run(self):
        player_id = 0
        while True:
            conn, addr = self.socket.accept()
            print(f"Connected to: {addr}")
            
            # Create player in game state OR reconnect
            # We pass 'player_id' as a candidate ID for new players
            new_player = self.game.add_player(player_id, addr)
            
            if new_player:
                # Use the ACTUAL ID of the player (in case of reconnect)
                actual_id = new_player.id
                
                # Start thread for client
                thread = threading.Thread(target=self.handle_client, args=(conn, actual_id))
                thread.start()
                
                # Only increment candidate ID if it was actually used for a NEW player
                if actual_id == player_id:
                    player_id += 1
            else:
                print(f"Lobby Full. Rejecting: {addr}")
                conn.close()

    def handle_client(self, conn, p_id):
        # Send initial confirmation (player ID)
        conn.send(pickle.dumps(p_id))
        
        while True:
            try:
                data = pickle.loads(conn.recv(2048*4))
                if not data:
                    break
                
                # Check for commands
                if isinstance(data, dict):
                    if data.get("action") == "INTRO":
                        # New Player Intro
                        name = data.get("name", "Unknown")
                        model = data.get("model_id", 0)
                        self.game.update_player_info(p_id, name, model)
                    elif data.get("action") == "START_GAME":
                        self.game.start_game()
                    elif data.get("action") == "SHOOT":
                        target_id = data.get("target_id")
                        self.game.process_shot(p_id, target_id, is_self_shot=(target_id == p_id))
                    elif data.get("action") == "USE_ITEM":
                        item = data.get("item_id")
                        target_id = data.get("target_id") # For Cuffs
                        res = self.game.process_item(p_id, item, target_id)
                        if res:
                             # Send private result back (Glass)
                             # We can inject it into the next state update or send special packet
                             # For simplicity, let's send a special packet immediately
                             conn.send(pickle.dumps(res))
                             # But wait, the client is blocking on send() returns state
                             # So we probably shouldn't break the req-rep cycle.
                             # Actually `handle_client` sends `self.game.to_dict()` at the end.
                             # If we send `res` now, connection might get desynced if client expects 1 reply.
                             # Better approach: Include `private_info` in the state dict just for this user?
                             # Or just return `res` INSTEAD of state dict for this turn?
                             # Let's Modify `conn.sendall(pickle.dumps(self.game.to_dict()))` line.
                             pass 
                        
                # Always reply with latest state (or custom result if Glass)
                # Hack for Glass: If result exists, we wrap state?
                # Simpler: The client knows it asked for GLASS.
                state = self.game.to_dict()
                if 'res' in locals() and res:
                    state["private_info"] = res
                
                conn.sendall(pickle.dumps(state))
            except Exception as e:
                print(f"Error handling client {p_id}: {e}")
                break
        
        print(f"Lost connection to player {p_id}")
        self.game.disconnect_player(p_id)
        conn.close()

class Network:
    def __init__(self, host_ip, name, model_id):
        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server = host_ip
        self.port = PORT
        self.addr = (self.server, self.port)
        self.name = name
        self.model_id = model_id
        self.p_id = self.connect()

    def connect(self):
        try:
            self.client.connect(self.addr)
            # Receive initial player ID
            pid = pickle.loads(self.client.recv(2048*4))
            # Send Intro Data Immediately
            self.client.send(pickle.dumps({
                "action": "INTRO",
                "name": self.name,
                "model_id": self.model_id
            }))
            # Receive intial state response (ignore for now, wait for game loop)
            self.client.recv(2048*4)
            return pid
        except socket.error as e:
            print(f"Connection error: {e}")
            return None

    def send(self, data):
        try:
            self.client.send(pickle.dumps(data))
            # Receive updated state
            return pickle.loads(self.client.recv(2048*4))
        except socket.error as e:
            print(f"Network Error: {e}")
            return None
        except EOFError:
             print("Server closed connection")
             return None
