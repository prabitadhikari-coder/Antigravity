import { getSigil } from './Sigils.js';

export class Card {
    constructor(data) {
        this.id = data.id;
        this.name = data.name;
        this.cost = data.cost;
        this.baseAttack = data.attack;
        this.baseHealth = data.health;
        this.currentHealth = data.health;
        this.sigils = data.sigils || [];
        this.image = data.image;
        this.rarity = data.rarity || 'common';
        this.price = data.price || 0;

        // State
        this.isAlive = true;
    }

    hasSigil(sigilId) {
        return this.sigils.includes(sigilId);
    }

    triggerSigil(hookName, ...args) {
        this.sigils.forEach(sigilId => {
            const sigilDef = getSigil(sigilId);
            if (sigilDef && typeof sigilDef[hookName] === 'function') {
                sigilDef[hookName](...args);
            }
        });
    }

    takeDamage(amount) {
        this.currentHealth -= amount;
        if (this.currentHealth <= 0) {
            this.currentHealth = 0;
            this.die();
        }
    }

    die() {
        this.isAlive = false;
        console.log(`${this.name} died!`);
        this.triggerSigil('onDeath', this);
    }

    getAttack() {
        return this.baseAttack; // + buffs later
    }
}
