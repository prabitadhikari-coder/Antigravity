import { Board } from './engine/Board.js';
import { GameLoop } from './engine/GameLoop.js';
import { Opponent } from './ai/Opponent.js';
import { UIController } from './ui/UIController.js';
import { Card } from './engine/Card.js';
import { gameState } from './engine/GameState.js';
import { CARD_DATA, BOSS_RARE_CARDS } from './data/Cards.js';
import { ShopUI } from './ui/ShopUI.js';

// Elements
const screens = {
    home: document.getElementById('home-screen'),
    shop: document.getElementById('shop-screen'),
    deck: document.getElementById('deck-screen'),
    game: document.getElementById('game-container')
};

const modal = document.getElementById('post-game-modal');
const currencyDisplay = document.getElementById('currency-display');
const shopUI = new ShopUI();

// Navigation Functions
function showScreen(screenName) {
    Object.values(screens).forEach(el => el.classList.add('hidden'));
    screens[screenName].classList.remove('hidden');

    // Updates
    currencyDisplay.textContent = gameState.currency;
    document.getElementById('home-btn').style.display = screenName === 'home' ? 'none' : 'block';

    if (screenName === 'shop') shopUI.render();
    if (screenName === 'deck') renderDeckScreen();
}

function renderDeckScreen() {
    const grid = document.getElementById('deck-grid');
    grid.innerHTML = '';
    const deck = gameState.getDeckObjects();
    deck.forEach(data => {
        const el = shopUI.createVisualCard(data);
        grid.appendChild(el);
    });
}

// Game State Vars
let gameLoop = null;
let playerDrawDeck = [];
let playerSquirrelDeck = 0;
let playerHand = [];

// Event Listeners - Navigation
document.getElementById('start-battle-btn').onclick = () => startBattle();
document.getElementById('open-shop-btn').onclick = () => showScreen('shop');
document.getElementById('open-deck-btn').onclick = () => showScreen('deck');
document.getElementById('exit-btn').onclick = () => { alert("Cannot exit browser window via JS :)"); };
document.getElementById('home-btn').onclick = () => showScreen('home');
document.getElementById('shop-back-btn').onclick = () => showScreen('home');
document.getElementById('deck-back-btn').onclick = () => showScreen('home');

// Helper for Status Logging
function logStatus(msg, isError = false) {
    const el = document.getElementById('game-status');
    if (el) {
        el.textContent = msg;
        el.style.color = isError ? '#ff4444' : '#ffcc00';
    }
    console.log(`[STATUS] ${msg}`);
}

// Draw Piles
const mainPile = document.getElementById('main-deck-pile');
const squirrelPile = document.getElementById('squirrel-pile');

if (mainPile) mainPile.onclick = () => tryDrawCard('main');
if (squirrelPile) squirrelPile.onclick = () => tryDrawCard('squirrel');

function tryDrawCard(pile) {
    try {
        if (!gameLoop) {
            logStatus("Error: Game Loop not initialized!", true);
            return;
        }

        if (gameLoop.phase !== 'draw') {
            logStatus(`Cannot draw now! Phase: ${gameLoop.phase}`, true);
            return;
        }

        let newCard = null;
        if (pile === 'squirrel') {
            if (playerSquirrelDeck > 0) {
                playerSquirrelDeck--;
                const squirrelData = {
                    id: 'squirrel', name: 'Squirrel', cost: 0, attack: 0, health: 1,
                    sigils: ['sacrificial'], image: 'assets/squirrel.png', rarity: 'common'
                };
                newCard = new Card(squirrelData);
                document.getElementById('squirrel-count-display').textContent = playerSquirrelDeck;
            } else {
                logStatus("No Squirrels left!", true);
                return;
            }
        } else {
            // Main Deck
            if (playerDrawDeck.length > 0) {
                const data = playerDrawDeck.pop();
                if (!data) {
                    logStatus("Error: Drawn card data is null!", true);
                    return;
                }
                newCard = new Card(data);
                document.getElementById('deck-count-display').textContent = playerDrawDeck.length;
            } else {
                logStatus("Deck Empty!", true);
                return;
            }
        }

        if (newCard) {
            playerHand.push(newCard);

            // Log for debugging
            logStatus(`Drawn ${newCard.name}. Hand size: ${playerHand.length}`);

            // Re-render
            if (gameLoop.ui) {
                gameLoop.ui.renderHand(playerHand, gameLoop.handleHandSelect);
            } else {
                throw new Error("UI Controller missing in GameLoop");
            }

            // Advance Phase
            gameLoop.startPlayPhase();
        }
    } catch (e) {
        console.error(e);
        logStatus("Draw Error: " + e.message, true);
    }
}

// Handler defined globally for re-use or we attach it to window/gameLoop?
// Better to keep it inside startBattle closure but we need access from draw.
// Refactoring: `handleHandSelect` needs to be accessible.

let handleHandSelect = null; // Hoist this

// Post Game Listeners
document.getElementById('continue-btn').onclick = () => {
    modal.classList.add('hidden');
    startBattle(); // New Battle
};
document.getElementById('return-home-btn').onclick = () => {
    modal.classList.add('hidden');
    showScreen('home');
};

// Battle Logic
function startBattle() {
    try {
        logStatus("Initializing Battle...");

        // 1. Setup Decks
        const deckObjects = gameState.getDeckObjects();
        // Shuffle logic (Fisher-Yates)
        for (let i = deckObjects.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [deckObjects[i], deckObjects[j]] = [deckObjects[j], deckObjects[i]];
        }

        playerDrawDeck = deckObjects;
        playerSquirrelDeck = gameState.squirrelDeck || 10;
        playerHand = [];

        if (playerDrawDeck.length < 1) {
            throw new Error("Your deck is empty! Go to Shop.");
        }

        // Initial Draw (Automatic) - Hand Size 3 + 1 Squirrel
        for (let i = 0; i < 3; i++) {
            if (playerDrawDeck.length) playerHand.push(new Card(playerDrawDeck.pop()));
        }
        playerHand.push(new Card({
            id: 'squirrel', name: 'Squirrel', cost: 0, attack: 0, health: 1,
            sigils: ['sacrificial'], image: 'assets/squirrel.png', rarity: 'common'
        }));
        playerSquirrelDeck--;

        // Update Counts
        document.getElementById('deck-count-display').textContent = playerDrawDeck.length;
        document.getElementById('squirrel-count-display').textContent = playerSquirrelDeck;

        // 2. Setup Engine
        const board = new Board();
        const ui = new UIController();

        // Boss Logic: Every 10th battle (9 wins prior)
        const isBoss = gameState.battlesWon > 0 && (gameState.battlesWon % 9 === 0);

        if (isBoss) {
            alert("BOSS BATTLE INITIATED!");
        } else {
            console.log(`Battle ${gameState.battlesWon + 1} started.`);
        }

        const opponent = new Opponent(isBoss);

        // Init GameLoop BEFORE setupGameData because setupGameData attaches to it
        gameLoop = new GameLoop(board, ui, opponent);

        setupGameData(ui, board);
        ui.render(board); // Render empty slots initially

        // Define Game Over Callback
        gameLoop.onGameOver = (playerWon, scaleValue) => {
            const messageEl = document.getElementById('post-game-message');
            const titleEl = document.getElementById('post-game-title');

            if (playerWon) {
                titleEl.textContent = "Victory!";
                titleEl.style.color = "#4f4";
                gameState.addCurrency(scaleValue);
                gameState.battlesWon++;

                messageEl.textContent = `You Won! Earned ${scaleValue} Teeth. Total Wins: ${gameState.battlesWon}`;

                if (isBoss) {
                    messageEl.textContent += " BOSS DEFEATED!";

                    // 30% Chance for Reserved Boss Card
                    if (Math.random() < 0.30) {
                        const rareId = BOSS_RARE_CARDS[Math.floor(Math.random() * BOSS_RARE_CARDS.length)];
                        gameState.addCard(rareId);
                        const rareCard = CARD_DATA.find(c => c.id === rareId);
                        messageEl.textContent += ` RARE DROP: ${rareCard ? rareCard.name : rareId}!`;
                        messageEl.style.color = "#FFD700"; // Gold color for excitement
                    } else {
                        messageEl.textContent += " (No rare drop this time)";
                    }
                }
            } else {
                titleEl.textContent = "Defeat...";
                titleEl.style.color = "#f44";
                const lossParams = Math.floor(Math.random() * 4) + 1;
                gameState.removeCurrency(lossParams);
                messageEl.textContent = `You Lost. Dropped ${lossParams} Teeth.`;
            }

            currencyDisplay.textContent = gameState.currency;
            modal.classList.remove('hidden');
        };

        // 3. Start Game
        gameLoop.start();

        // 4. Show Screen ONLY on success
        showScreen('game');

    } catch (e) {
        console.error(e);
        alert("Failed to start battle: " + e.message);
        showScreen('home'); // Ensure return to safety
    }
}

function setupGameData(ui, board) {
    let selectedHandIndex = null;
    let pendingCost = 0;

    // Attach handler to gameLoop so it persists correctly
    gameLoop.handleHandSelect = (index) => {
        selectedHandIndex = index;
        const card = playerHand[index];
        if (!card) return;

        pendingCost = card.cost;
        logStatus(`Selected ${card.name}. Needs ${pendingCost} sacrifices.`);
        ui.highlightSelection(index);
    };

    // Initial Hand Render
    ui.renderHand(playerHand, gameLoop.handleHandSelect);

    ui.onSlotClick = (slotIndex, isPlayer) => {
        if (gameLoop && gameLoop.phase !== 'play') {
            logStatus(`Wait! It's ${gameLoop.phase} phase.`, true);
            return;
        }
        if (!isPlayer) return;

        // 1. Sacrificing
        if (pendingCost > 0) {
            const clickedCard = board.playerSlots[slotIndex];
            if (clickedCard) {
                const isWorthy = clickedCard.hasSigil('worthy_sacrifice');
                const bloodValue = isWorthy ? 3 : 1;

                logStatus(`Sacrificed ${clickedCard.name} for ${bloodValue} blood.`);
                board.removeCard(slotIndex, true);
                pendingCost -= bloodValue;
                ui.render(board);

                if (pendingCost <= 0) {
                    pendingCost = 0;
                    logStatus("Blood cost met! Place your card.");
                }
                return;
            } else {
                logStatus("Click a creature to sacrifice!", true);
                return; // STOP EXECUTION HERE
            }
        }

        // 2. Playing
        if (pendingCost === 0 && selectedHandIndex !== null) {
            const cardToPlay = playerHand[selectedHandIndex];
            if (!cardToPlay) return;

            if (board.playerSlots[slotIndex] === null) {
                if (board.placeCard(cardToPlay, slotIndex, true)) {
                    playerHand.splice(selectedHandIndex, 1);
                    selectedHandIndex = null;
                    ui.clearSelection();
                    // Re-render hand with the SAME handler from gameLoop
                    ui.renderHand(playerHand, gameLoop.handleHandSelect);
                    ui.render(board);
                    logStatus(`Played ${cardToPlay.name}!`);
                }
            } else {
                logStatus("Slot occupied!", true);
            }
        } else if (selectedHandIndex === null) {
            logStatus("Select a card from hand first.");
        }
    };

    document.getElementById('end-turn-btn').onclick = () => {
        if (gameLoop) gameLoop.endPlayerTurn();
    };
}

// Initial Render
showScreen('home');
