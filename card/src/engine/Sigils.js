export const SIGILS = {
    'touch_of_death': {
        name: "Touch of Death",
        description: "Instantly kills any card it damages.",
        onDamageDealt: (attacker, defender, damage) => {
            if (damage > 0) {
                console.log(`${attacker.name} uses Touch of Death!`);
                defender.die();
            }
        }
    },
    'airborne': {
        name: "Airborne",
        description: "Attacks opponent directly, ignoring blocking cards (unless they block flying).",
        // This logic is usually checked in the combat loop before attacking
        isFlying: true
    },
    'blocking': { // "Mighty Leap"
        name: "Mighty Leap",
        description: "Blocks Airborne units.",
        blocksFlying: true
    },
    'sacrificial': { // "Many Lives" or similar, though basic squirrels are just 0 cost
        name: "Worthy Sacrifice",
        description: "Counts as 3 blood? (Not implemented yet)",
    },
    'sharp_quills': {
        name: "Sharp Quills",
        description: "Deal 1 damage back when attacked.",
        onDamageTaken: (victim, attacker, damage) => {
            if (attacker && attacker.isAlive) {
                console.log(`${victim.name} returns damage with Sharp Quills!`);
                attacker.takeDamage(1);
            }
        }
    },
    'unkillable': {
        name: "Unkillable",
        description: "When this dies, it returns to your hand.",
        onDeath: (card) => {
            console.log(`${card.name} returns to hand!`);
            // Note: This requires access to the playerHand array or a callback.
            // For now, we'll just log it. In a full implementation, we'd fire an event.
            window.dispatchEvent(new CustomEvent('card-died', { detail: card }));
        }
    }
};

export function getSigil(id) {
    return SIGILS[id] || null;
}
