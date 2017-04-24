Rebol [
    Title: "Monty Hall Challenge"
    Date: 20-Jul-2003
    File: %oneliner-monty-hall.r
    Purpose: {Simulates swapping doors after Monty shows a goat. Result is percentage wins
after 100 runs. (MHC: a well-known and often debated probability puzzle involving three
doors, two goats, and a car).}
    One-liner-length: 39
    Version: 1.0.0
    Author: {Sunanda (with tweaks from Romano T, Ryan C, Carl R, and Reichart)}
    Library: [
        level: 'beginner
        platform: 'all
        type: [How-to FAQ one-liner]
        domain: [game]
        tested-under: none
        support: none
        license: pd
        see-also: none
    ]
]
w: 100 loop w[w: w - any random[0 0 1]]
