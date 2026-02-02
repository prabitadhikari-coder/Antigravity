import { Card } from './Card.js';

export class Board {
    constructor() {
        // 4 Lanes. 
        // 0-3 are generic indices.
        this.playerSlots = [null, null, null, null];
        this.opponentSlots = [null, null, null, null];
        this.opponentQueue = [null, null, null, null]; // Intentions for next turn
    }

    placeCard(card, slotIndex, isPlayer = true) {
        const slots = isPlayer ? this.playerSlots : this.opponentSlots;
        if (slotIndex < 0 || slotIndex >= 4) return false;

        if (slots[slotIndex] === null) {
            slots[slotIndex] = card;
            return true;
        }
        return false;
    }

    removeCard(slotIndex, isPlayer = true) {
        const slots = isPlayer ? this.playerSlots : this.opponentSlots;
        if (slots[slotIndex]) {
            slots[slotIndex] = null;
        }
    }

    getOpposingCard(slotIndex, isPlayerAttacking) {
        const targetSlots = isPlayerAttacking ? this.opponentSlots : this.playerSlots;
        return targetSlots[slotIndex];
    }
}
