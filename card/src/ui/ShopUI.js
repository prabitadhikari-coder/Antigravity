import { CARD_DATA } from '../data/Cards.js';
import { gameState } from '../engine/GameState.js';

export class ShopUI {
    constructor(uiController) {
        this.ui = uiController; // To reuse card creation logic potentially
        this.container = document.getElementById('shop-screen');
        this.buyArea = document.getElementById('shop-cards');
        this.sellArea = document.getElementById('sell-cards');
    }

    render() {
        // Render Buyable Cards (All Cards)
        this.buyArea.innerHTML = '';
        CARD_DATA.forEach(data => {
            const wrapper = document.createElement('div');
            wrapper.className = 'shop-card-wrapper';

            // Hacky: Reuse UIController logic or manually create card?
            // Let's call a static helper or just replicate for now to avoid tight coupling issues if UIController expects game instances
            const cardEl = this.createVisualCard(data);

            const buyBtn = document.createElement('button');
            buyBtn.className = 'buy-btn';
            buyBtn.textContent = `Buy (${data.price})`;
            buyBtn.onclick = () => this.buyCard(data);

            wrapper.appendChild(cardEl);
            wrapper.appendChild(buyBtn);
            this.buyArea.appendChild(wrapper);
        });

        // Render Sellable Cards (Inventory)
        this.sellArea.innerHTML = '';
        const deck = gameState.getDeckObjects();
        deck.forEach(data => {
            const wrapper = document.createElement('div');
            wrapper.className = 'shop-card-wrapper';

            const cardEl = this.createVisualCard(data);

            const sellPrice = Math.floor(data.price / 2);
            const sellBtn = document.createElement('button');
            sellBtn.className = 'sell-btn';
            sellBtn.textContent = `Sell (${sellPrice})`;
            sellBtn.onclick = () => this.sellCard(data);

            wrapper.appendChild(cardEl);
            wrapper.appendChild(sellBtn);
            this.sellArea.appendChild(wrapper);
        });
    }

    createVisualCard(data) {
        // Simplified visual card creation
        const el = document.createElement('div');
        el.className = `card ${data.rarity || 'common'}`;
        const sigilsHtml = (data.sigils || []).map(s => `<span class="sigil-icon" title="${s}">${s[0].toUpperCase()}</span>`).join('');

        el.innerHTML = `
            <div class="card-cost">${data.cost}</div>
            <div class="card-image-area">
                <span>${data.name}</span>
                <div class="card-sigils">${sigilsHtml}</div>
            </div>
            <div class="card-stats">
                <span class="stat-attack">${data.attack}</span>
                <span class="stat-health">${data.health}</span>
            </div>
        `;
        return el;
    }

    buyCard(data) {
        if (gameState.removeCurrency(data.price)) {
            gameState.addCard(data.id);
            alert(`Bought ${data.name}!`);
            this.updateCurrencyDisplay();
            this.render(); // Refresh sell list
        } else {
            alert("Not enough Teeth!");
        }
    }

    sellCard(data) {
        // Removing cards from deck by object reference is tricky if we don't have unique instance IDs in inventory.
        // GameState uses array of strings (ids).
        // We just remove the FIRST matching ID.
        if (gameState.removeCard(data.id)) {
            const sellPrice = Math.floor(data.price / 2);
            gameState.addCurrency(sellPrice);
            this.updateCurrencyDisplay();
            this.render();
        }
    }

    updateCurrencyDisplay() {
        document.getElementById('currency-display').textContent = gameState.currency;
    }
}
