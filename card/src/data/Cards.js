export const CARD_DATA = [
    {
        id: 'wolf',
        name: 'Wolf',
        cost: 2, // 2 Blood
        attack: 3,
        health: 2,
        sigils: [],
        image: 'assets/wolf.png', // Placeholder path
        rarity: 'common',
        price: 5
    },
    {
        id: 'stoat',
        name: 'Stoat',
        cost: 1,
        attack: 1,
        health: 3,
        sigils: [],
        image: 'assets/stoat.png',
        rarity: 'common',
        price: 3
    },
    // Squirrel removed from shop pool. Handled separately.
    {
        id: 'bullfrog',
        name: 'Bullfrog',
        cost: 1,
        attack: 1,
        health: 2,
        sigils: ['blocking'], // Blocks flying
        image: 'assets/bullfrog.png',
        rarity: 'common',
        price: 3
    },
    {
        id: 'elk',
        name: 'Elk',
        cost: 2,
        attack: 2,
        health: 4,
        sigils: ['moving'], // Not implemented yet, moving would require logic
        image: 'assets/elk.png',
        rarity: 'common',
        price: 6
    },
    {
        id: 'mantis',
        name: 'Mantis',
        cost: 1,
        attack: 1,
        health: 1,
        sigils: ['bifurcated_strike'], // Hits Left/Right
        image: 'assets/mantis.png',
        rarity: 'rare',
        price: 8
    },
    {
        id: 'ant',
        name: 'Worker Ant',
        cost: 1,
        attack: 1, // Logic needs to check other ants
        health: 2,
        sigils: ['ant_power'],
        image: 'assets/ant.png',
        rarity: 'common',
        price: 4
    },
    {
        id: 'adder',
        name: 'Adder',
        cost: 2,
        attack: 1,
        health: 1,
        sigils: ['touch_of_death'],
        image: 'assets/adder.png',
        rarity: 'rare',
        price: 8
    },
    {
        id: 'sparrow',
        name: 'Sparrow',
        cost: 1,
        attack: 1,
        health: 2,
        sigils: ['airborne'],
        image: 'assets/sparrow.png',
        rarity: 'common',
        price: 4
    },
    {
        id: 'porcupine',
        name: 'Porcupine',
        cost: 1,
        attack: 1,
        health: 2,
        sigils: ['sharp_quills'],
        image: 'assets/porcupine.png',
        rarity: 'rare',
        price: 7
    },
    {
        id: 'grizzly',
        name: 'Grizzly',
        cost: 3,
        attack: 4,
        health: 6,
        sigils: [],
        image: 'assets/bear.png',
        rarity: 'rare',
        price: 12
    },
    {
        id: 'urayuli',
        name: 'Urayuli',
        cost: 4,
        attack: 7,
        health: 7,
        sigils: [],
        image: 'assets/urayuli.png',
        rarity: 'legendary',
        price: 25
    },
    {
        id: 'mantis_god',
        name: 'Mantis God',
        cost: 1,
        attack: 1,
        health: 1,
        sigils: ['trifurcated_strike'],
        image: 'assets/mantis_god.png',
        rarity: 'legendary',
        price: 30
    },
    {
        id: 'amalgam',
        name: 'Amalgam',
        cost: 2,
        attack: 3,
        health: 3,
        sigils: [],
        image: 'assets/amalgam.png',
        rarity: 'rare',
        price: 15
    },
    {
        id: 'mole_man',
        name: 'Mole Man',
        cost: 1,
        attack: 0,
        health: 6,
        sigils: ['blocking', 'burrower'], // Burrower prevents direct attacks (concept)
        image: 'assets/mole_man.png',
        rarity: 'rare',
        price: 10
    }
];

export const BOSS_RARE_CARDS = ['urayuli', 'mantis_god', 'amalgam', 'mole_man'];
