import { CARD_DATA } from '../data/Cards.js';
import { Card } from '../engine/Card.js';

export class Opponent {
    constructor() {
        // AI Definitions
    }

    async playTurn(board, gameLoop) {
        // 1. Queue Management: Move queued cards to slots if empty
        this.resolveQueue(board);

        // 2. Play New Cards into Queue (The "Smart" part)
        // Simple strategy: Try to oppose strong player cards, or hit open slots

        // Simulate thinking
        await new Promise(r => setTimeout(r, 1000));

        // Get available moves (Empty Queue Slots)
        const emptyQueueIndices = board.opponentQueue.map((c, i) => c === null ? i : null).filter(i => i !== null);

        if (emptyQueueIndices.length > 0) {
            // Pick a random card from "Deck" (just random data for now)
            const randomCardData = CARD_DATA[Math.floor(Math.random() * CARD_DATA.length)];
            const newCard = new Card(randomCardData);

            // Heuristic: Where is the best spot?
            // - If player has a high attack unit, maybe block it?
            // - If player has start open, hit it?

            let bestSlot = -1;
            let bestScore = -999;

            for (let slot of emptyQueueIndices) {
                let score = 0;
                const opposingCard = board.playerSlots[slot];

                const hasAirborne = newCard.hasSigil('airborne');
                const hasTouchOfDeath = newCard.hasSigil('touch_of_death');

                if (opposingCard) {
                    const opposesBlocksFlying = opposingCard.hasSigil('blocking');

                    if (hasAirborne && !opposesBlocksFlying) {
                        // We fly over!
                        score += newCard.attack * 2.5;
                    } else {
                        // Direct fight
                        if (hasTouchOfDeath) score += 15; // Very strong against any card
                        if (newCard.health > opposingCard.attack) score += 5; // We survive
                        if (newCard.attack >= opposingCard.health || hasTouchOfDeath) score += 10; // We kill it
                    }
                } else {
                    // Open slot - Direct Damage!
                    score += newCard.attack * 2;
                }

                if (score > bestScore) {
                    bestScore = score;
                    bestSlot = slot;
                }
            }

            if (bestSlot !== -1) {
                console.log(`AI plays ${newCard.name} at slot ${bestSlot}`);
                board.opponentQueue[bestSlot] = newCard;
                gameLoop.ui.render(board);
            }
        }
    }

    resolveQueue(board) {
        for (let i = 0; i < 4; i++) {
            if (board.opponentSlots[i] === null && board.opponentQueue[i] !== null) {
                // Move from queue to board
                board.opponentSlots[i] = board.opponentQueue[i];
                board.opponentQueue[i] = null;
            }
        }
    }
}
