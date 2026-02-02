export class GameLoop {
    constructor(board, uiController, opponent) {
        this.board = board;
        this.ui = uiController;
        this.opponent = opponent;

        this.turn = 0;
        this.scale = 0;

        // Phases: 'draw', 'play', 'combat', 'opponent'
        this.phase = 'start';

        this.isPlayerTurn = false;

        // Callbacks
        this.onGameOver = null;
    }

    start() {
        console.log("Game Started");
        this.turn = 1;
        this.startDrawPhase();
    }

    startDrawPhase() {
        this.phase = 'draw';
        this.isPlayerTurn = true;
        this.ui.setPhase('draw'); // Update UI prompt
        console.log("Draw Phase Started. Pick a pile.");
    }

    startPlayPhase() {
        this.phase = 'play';
        this.ui.setPhase('play');
        console.log("Play Phase Started.");
    }

    async endPlayerTurn() {
        if (this.phase !== 'play') {
            console.log("Cannot end turn yet.");
            return;
        }

        this.isPlayerTurn = false;
        this.ui.setPhase('combat');

        console.log("Player Turn Ended. Combat Phase...");
        await this.resolveCombat(true); // Player attacks

        console.log("Opponent Turn...");
        this.phase = 'opponent';
        await this.opponent.playTurn(this.board, this);

        console.log("Opponent Combat Phase...");
        await this.resolveCombat(false); // Opponent attacks

        // Next Turn
        this.turn++;
        console.log(`Turn ${this.turn} Started`);
        this.startDrawPhase();
    }

    async resolveCombat(isPlayerAttacking) {
        const attackers = isPlayerAttacking ? this.board.playerSlots : this.board.opponentSlots;

        for (let i = 0; i < 4; i++) {
            const card = attackers[i];
            if (card && card.isAlive) {
                await this.performAttack(card, i, isPlayerAttacking);
            }
        }
    }

    async performAttack(attacker, slotIndex, isPlayerAttacking) {
        let damage = attacker.getAttack();
        if (damage <= 0) return;

        // Check Sigils
        const isFlying = attacker.hasSigil('airborne');
        const isBifurcated = attacker.hasSigil('bifurcated_strike');

        // Bifurcated Strike Logic (Simplified: Hits Left/Right slots, ignores center)
        // If not bifurcated, hits center.

        let targets = [];
        if (isBifurcated) {
            // TODO: Implement proper slot mapping (i-1, i+1) and bounds checking
            // For now, simpler fallback or just treat as direct damage for prototype
            // Let's implement basics:
            if (slotIndex > 0) targets.push({ idx: slotIndex - 1, isDirect: false });
            if (slotIndex < 3) targets.push({ idx: slotIndex + 1, isDirect: false });
        } else {
            targets.push({ idx: slotIndex, isDirect: false });
        }

        for (let t of targets) {
            let targetCard = this.board.getOpposingCard(t.idx, isPlayerAttacking);

            // Flying check
            if (isFlying && targetCard && !targetCard.hasSigil('blocking')) {
                targetCard = null; // Fly over
            }

            // Animation
            await this.ui.animateAttack(slotIndex, isPlayerAttacking); // Re-use animation logic

            if (targetCard) {
                targetCard.takeDamage(damage);
                attacker.triggerSigil('onDamageDealt', attacker, targetCard, damage);
                targetCard.triggerSigil('onDamageTaken', targetCard, attacker, damage);

                if (!targetCard.isAlive) {
                    this.board.removeCard(t.idx, !isPlayerAttacking);
                }
            } else {
                this.modifyScale(isPlayerAttacking ? damage : -damage);
            }
        }

        this.ui.render(this.board);
        await new Promise(r => setTimeout(r, 200));
    }

    modifyScale(amount) {
        this.scale += amount;
        this.ui.updateScale(this.scale);

        // Boss Logic Hook
        if (this.opponent.isBoss) {
            this.checkBossLives();
        } else {
            if (Math.abs(this.scale) >= 5) {
                this.handleGameOver(this.scale > 0);
            }
        }
    }

    checkBossLives() {
        if (this.scale >= 5) {
            // Boss loses a life
            const isDefeated = this.opponent.loseLife();
            if (isDefeated) {
                this.handleGameOver(true);
            } else {
                // Reset scale for next phase
                this.scale = 0;
                this.ui.updateScale(0);
                alert("Boss enters Phase 2!"); // Temporary feedback
                // Clear opponent board logic usually happens here or in loseLife
            }
        } else if (this.scale <= -5) {
            this.handleGameOver(false);
        }
    }

    handleGameOver(playerWon) {
        if (this.onGameOver) {
            this.onGameOver(playerWon, Math.abs(this.scale));
        }
    }
}
