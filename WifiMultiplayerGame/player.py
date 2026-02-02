MAX_HP = 5

class Player:
    def __init__(self, id, addr, name="Player"):
        self.id = id
        self.addr = addr
        self.name = name
        self.hp = MAX_HP
        self.inventory = []
        self.alive = True
        self.is_connected = True
        self.model_id = 0
        
        # Status Effects
        self.is_cuffed = False
        self.saw_active = False

    def take_damage(self, amount=1):
        self.hp -= amount
        if self.hp <= 0:
            self.hp = 0
            self.alive = False

    def heal(self, amount=1):
        if self.alive and self.hp < self.max_hp:
            self.hp += amount

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "model_id": self.model_id,
            "hp": self.hp,
            "alive": self.alive,
            "is_connected": self.is_connected,
            "inventory": self.inventory,
            "is_cuffed": self.is_cuffed,
            "saw_active": self.saw_active,
        }
