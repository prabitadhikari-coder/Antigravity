export class UIController {
    constructor() {
        this.playerSlotsEl = document.getElementById('player-slots');
        this.opponentSlotsEl = document.getElementById('opponent-slots');
        this.opponentQueueEl = document.getElementById('opponent-queue');
        this.playerHandEl = document.getElementById('player-hand');
        this.scaleEl = document.getElementById('scale-indicator');
        this.statusEl = document.getElementById('game-status');

        // Cache for clicked card implementation
        this.selectedCardIndex = -1;
        this.onSlotClick = null; // Callback
    }

    setPhase(phase) {
        if (!this.statusEl) return;
        let text = "";
        switch (phase) {
            case 'draw': text = "Draw a Card to Start Turn"; break;
            case 'play': text = "Play Cards & Ring Bell"; break;
            case 'combat': text = "Combat Phase..."; break;
            case 'opponent': text = "Opponent's Turn"; break;
        }
        this.statusEl.textContent = text;
    }

    render(board) {
        this.renderRow(this.playerSlotsEl, board.playerSlots, true);
        this.renderRow(this.opponentSlotsEl, board.opponentSlots, false);
        this.renderRow(this.opponentQueueEl, board.opponentQueue, false, true);
        // Hand rendering would be separate or passed in
    }

    renderRow(container, slots, isPlayer, isQueue = false) {
        container.innerHTML = '';
        slots.forEach((card, index) => {
            const slotEl = document.createElement('div');
            slotEl.className = 'card-slot';
            slotEl.dataset.index = index;
            slotEl.dataset.isPlayer = isPlayer;

            if (card) {
                const cardEl = this.createCardElement(card);
                // Queue cards are often face down or semi-visible, but we'll show them for now
                if (isQueue) cardEl.style.opacity = '0.7';
                slotEl.appendChild(cardEl);
            }

            // Click handling for placement
            slotEl.onclick = () => {
                if (this.onSlotClick) this.onSlotClick(index, isPlayer);
            };

            container.appendChild(slotEl);
        });
    }

    createCardElement(card) {
        const el = document.createElement('div');
        el.className = `card ${card.rarity || 'common'}`;

        // Note: card.rarity comes from data. If Card class didn't copy it, we might check that too.
        // Let's ensure Card class logic expects this property or we access it from data.
        // The Card constructor in Card.js copies properties? Let's check Card.js too.

        const sigilsHtml = card.sigils.map(s => `<span class="sigil-icon" title="${s}">${s[0].toUpperCase()}</span>`).join('');

        el.innerHTML = `
            <div class="card-cost">${card.cost}</div>
            <div class="card-image-area">
                <!-- <img src="${card.image}" alt="${card.name}"> -->
                <span>${card.name}</span>
                <div class="card-sigils">${sigilsHtml}</div>
            </div>
            <div class="card-stats">
                <span class="stat-attack">${card.baseAttack}</span>
                <span class="stat-health">${card.currentHealth}</span>
            </div>
        `;
        return el;
    }

    renderHand(hand, onCardSelect) {
        this.playerHandEl.innerHTML = '';
        hand.forEach((card, index) => {
            const cardEl = this.createCardElement(card);
            cardEl.onclick = () => {
                // Visual selection feedback
                this.clearSelection();
                cardEl.style.transform = "translateY(-30px)";
                cardEl.style.borderColor = "yellow";
                console.log(`[UI] Card clicked: index ${index}`);
                if (onCardSelect) {
                    onCardSelect(index);
                } else {
                    console.error("[UI] onCardSelect callback is missing!");
                }
            };
            this.playerHandEl.appendChild(cardEl);
        });
    }

    highlightSelection(index) {
        this.clearSelection();
        const cardEl = this.playerHandEl.children[index];
        if (cardEl) {
            cardEl.style.transform = "translateY(-30px)";
            cardEl.style.borderColor = "yellow";
        }
    }

    clearSelection() {
        Array.from(this.playerHandEl.children).forEach(el => {
            el.style.transform = "";
            el.style.borderColor = "black";
        });
    }

    updateScale(value) {
        this.scaleEl.textContent = `Scale: ${value}`;
        this.scaleEl.style.color = value > 0 ? '#aaf' : (value < 0 ? '#faa' : '#fff');
    }

    async animateAttack(slotIndex, isPlayerSource) {
        const container = isPlayerSource ? this.playerSlotsEl : this.opponentSlotsEl;
        const slot = container.children[slotIndex];
        if (!slot) return;

        const card = slot.firstElementChild;
        if (!card) return;

        // Simple animation
        card.style.transform = isPlayerSource ? "translateY(-50px)" : "translateY(50px)";
        await new Promise(r => setTimeout(r, 200));
        card.style.transform = "";
    }
}
