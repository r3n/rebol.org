REBOL [
    Title: "Tower of REBOL"
    Date: 17-Nov-1998
    File: %tower.r
    Purpose: "REBOL can speak to many audiences."
    Comment: {
        Words can mean different things
        for different speakers.
    }
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'Demo 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

use [block-of-words ways-to-speak plain-words] [

    block-of-words: [
        Hello friend newline
        This is a block of words newline
        This block can be spoken differently for different people newline
    ]

    ;; Create a block of strings with the normal way to say it:

    plain-words: copy []
    foreach word block-of-words [
        insert tail plain-words (
            either word = 'newline [
                :newline
            ] [
                 mold word
            ])
    ]

    ;; This block contains different ways to speak.
    ;; The way to say different words can be defined here, and 
    ;; that way can be any REBOL expression.

    ways-to-speak: [

        Hill-billy [
            Hello:  "Howdy" 
            friend: "city slicker"
            this:   "this here"
          a:      "uh"
          of:     "uh"
          for:    "fer"
            block:  "blawk"
            words:  "werdz"
            can:    "kin"
            spoken: "sed"
            differently: "differnt"
            different: "differnt"
            people: "folks"
        ]
        
        Sales-speak [
            Hello:  "Greetings" 
            friend: "valued customer," 
            block: reform [pick ["priceless" 
                               "lucrative" 
                   ] random 2 "unit"
                ] 
            words:  "lexical commodities" 
            can:    "is pro-actively enabled to" 
            spoken: "tapped into" 
            differently: reform ["accordingly" newline]
            for:    "to suit the desires of"
            different: "various demographic" 
            people: "target audiences"
        ]
        
        Angry [
            Hello:  "Hey" 
            friend: "bub"
            block:  "bleepin' block" 
            words:  "blankin' words"
            spoken: reform ["thrown on the screen" newline]
            differently: "any old way"
            different: "any given"
            people: "whomever"
        ]        

        Bombastic [
            Hello:  "Salutations and accolades" 
            friend: "esteemed user,"
            block: reform [pick ["most miraculous" 
                               "most amazing" 
                               "hardly befitting"
                         ] random 3 block
                   ]
            words: reform ["lowley" words]
            set [differently different] ["alternate ways" "various"]
            people: reform [newline "personages"]
        ]            
    ]

    example: [

        set block-of-words plain-words
        print ["Plain way to say it:"]
        print block-of-words 

        forskip ways-to-speak 2 [

                do second ways-to-speak
                
                print ["Now we'll say it in" first ways-to-speak ":"]
                print block-of-words

                set block-of-words plain-words ; (default words to use)
        ]
        "done"
    ]
]

do example
