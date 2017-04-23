REBOL [
    title: "Insult Generator"
    date: 31-Aug-2012
    file: %insult.r
    author: Nick Antonaccio
    purpose: {
        Teaching some young children to program.  They loved this one.
        Be sure to see the tutorial at http://re-bol.com 
    }
]

rebol []

adjectives: [
    "farty" "smelly" "poopy" "funny looking" "gross" "boring" "stinky"
    "slimy" "stinky" "dumb" "horrible" "rotten" "characterless" "uninteresting"
    "commonplace" "lifeless" "monotonous" "mundane" "spiritless" "stodgy" 
    "tiresome" "trite" "uninteresting" "irritating" "annoying" "beleaguering"
    "harry" "nagging" "pestering" "witless" "brainless" "deficient" "dense" 
    "dim witted" "dopey" "dull" "half-baked" "irrelevant" "laughable"
    "mindless" "naive" "pointless" "senseless" "simpleminded" "slow"
    "thick-headed" "unintelligent" "daft" "backward" "feeble-minded" "subnormal"
    "underdeveloped" "kooky" "bumbling" "clumsy" "incompetent"
]
nouns: [
    "dummy" "fart face" "hobo" "goofball" "grease bag" "fish mouth"
    "poop head" "monkey man" "big lip baffoon" "lackluster louse"
    "stink foot" "butt" "cheeze head" "drag" "baffoon" "drudge"
    "nothing of a person" "slug" "snail" "zero" "annoyance" "bother"
    "bore" "nag" "numbskull" "cheese head" "dolt" "dope" "half-wit"
    "blockhead" "donkey" "dunce" "fool" "nitwit" "simpleton" "twit"
    "bonehead" "dumbbell" "kook" "muttonhead" "nincompoop" "ninny"
    "pinhead" "fart" "creep" "bumbler" "butterfingers" "clod" "oaf"
    "featherbrain" "fool" "foul-up" "fumbler" "goof off" "harebrain"
    "ignoramus" "klutz" "muddler" "mess" 
]
random/seed now
previous-adjectives: copy []
previous-nouns: copy []
loop 100 [
    if (length? previous-adjectives) = (length? adjectives) [
        previous-adjectives: copy []
    ]
    if (length? previous-nouns) = (length? nouns) [
        previous-nouns: copy []
    ]
    until [not (find previous-adjectives x: random (length? adjectives))] []
    until [not (find previous-nouns y: random (length? nouns))] []
    insult: rejoin [
        "You're a "
        pick adjectives x
        " "
        pick nouns y
        "!"
    ]
    print insult
    append previous-adjectives x
    append previous-nouns y
]
halt



[[

; a CGI version to run on your web site:

#! ./rebol276 -cs
REBOL [title: "Insult Generator"]
print "content-type: text/html^/"
print [<HTML><HEAD><TITLE>"Insult Generator"</TITLE></HEAD><BODY>]
adjectives: [
    "farty" "smelly" "poopy" "funny looking" "gross" "boring" "stinky"
    "slimy" "stinky" "dumb" "horrible" "rotten" "characterless" "uninteresting"
    "commonplace" "lifeless" "monotonous" "mundane" "spiritless" "stodgy" 
    "tiresome" "trite" "uninteresting" "irritating" "annoying" "beleaguering"
    "harry" "nagging" "pestering" "witless" "brainless" "deficient" "dense" 
    "dim witted" "dopey" "dull" "half-baked" "irrelevant" "laughable"
    "mindless" "naive" "pointless" "senseless" "simpleminded" "slow"
    "thick-headed" "unintelligent" "daft" "backward" "feeble-minded" "subnormal"
    "underdeveloped" "kooky" "bumbling" "clumsy" "incompetent"
]
nouns: [
    "dummy" "fart face" "hobo" "goofball" "grease bag" "fish mouth"
    "poop head" "monkey man" "big lip baffoon" "lackluster louse"
    "stink foot" "butt" "cheeze head" "drag" "baffoon" "drudge"
    "nothing of a person" "slug" "snail" "zero" "annoyance" "bother"
    "bore" "nag" "numbskull" "cheese head" "dolt" "dope" "half-wit"
    "blockhead" "donkey" "dunce" "fool" "nitwit" "simpleton" "twit"
    "bonehead" "dumbbell" "kook" "muttonhead" "nincompoop" "ninny"
    "pinhead" "fart" "creep" "bumbler" "butterfingers" "clod" "oaf"
    "featherbrain" "fool" "foul-up" "fumbler" "goof off" "harebrain"
    "ignoramus" "klutz" "muddler" "mess" 
]
random/seed now
previous-adjectives: copy []
previous-nouns: copy []
loop 100 [
    if (length? previous-adjectives) = (length? adjectives) [
        previous-adjectives: copy []
    ]
    if (length? previous-nouns) = (length? nouns) [
        previous-nouns: copy []
    ]
    until [not (find previous-adjectives x: random (length? adjectives))] []
    until [not (find previous-nouns y: random (length? nouns))] []
    insult: rejoin [
        "You're a "
        pick adjectives x
        " "
        pick nouns y
        "!<br>"
    ]
    print insult
    append previous-adjectives x
    append previous-nouns y
]
print [</BODY></HTML>] 
quit
]]
