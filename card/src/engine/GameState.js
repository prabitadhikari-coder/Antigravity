import { CARD_DATA } from '../data/Cards.js';

export class GameState {
    constructor() {
        this.currency = 10; // Starting currency "Teeth"
        // Inventory stores card IDs
        this.deck = ['wolf', 'stoat', 'bullfrog', 'elk']; // No squirrels in main deck
        this.squirrelDeck = 10; // Count of squirrels
        this.unlockedCards = [...CARD_DATA.map(c => c.id)]; // All cards unlocked in shop for now
        this.battlesWon = 0; // Track progression
    }

    addCurrency(amount) {
        this.currency += amount;
        console.log(`Currency updated: ${this.currency} (+${amount})`);
    }

    removeCurrency(amount) {
        if (this.currency >= amount) {
            this.currency -= amount;
            console.log(`Currency updated: ${this.currency} (-${amount})`);
            return true;
        }
        return false;
    }

    addCard(cardId) {
        this.deck.push(cardId);
        console.log(`Added ${cardId} to deck.`);
    }

    removeCard(cardId) {
        const index = this.deck.indexOf(cardId);
        if (index > -1) {
            this.deck.splice(index, 1);
            console.log(`Removed ${cardId} from deck.`);
            return true;
        }
        return false;
    }

    getDeckObjects() {
        // Hydrate IDs to full objects
        return this.deck.map(id => CARD_DATA.find(c => c.id === id));
    }
}

export const gameState = new GameState();
