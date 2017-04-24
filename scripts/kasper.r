REBOL [
    Title: "The Kasper Program"
    File: %kasper.r
    Date: 21-May-2001
    Updated: 13-Jun-2008
    Version: 1.0
    Purpose: "Please Ingri (my sister, the dog owner)"
    Library: [
      level: 'beginner
      plugin: [size: 280x273]
      domain: [gui]
      license: none
      Platform: [all plugin]
      Tested-under: none
      Type: [demo]
      Support: none
    ]
]


emails: [
{Ingri,

Hey, this Kasper dog of yours really WAS wonderful, wasn't he!!}
{Ingri,
Hey, that dog was so cool! You were a lucky dog owner, that's
for sure!}
"Ingri, I love your dog!"
{Kasper ---
What a wonderful name for a dog!}
{Your dog was so cool. Been lookin' all over the web
for his fan club, but I couldn't find it. Pity.}
{Kasper
Is your name Kasper? Why isn't it Caspar?
(Just wondering).}
"Kasper is cool. Was he an ACD, by any chance?"
{Honourable dog owner,
I'm thinking of starting a Kasper Fan Club.
Cool, eh?}
{I have a dog too, but his name isn't Kasper.
Thought maybe you'd like to know.}
{Hello,
I saw Kasper on http://www.rebol.org/,
and I must say, he really was a beautiful dog.}
"Kasper was a nice dog. Nice dog. Bet he was a blue healer!"
]

dialog: layout [
    backdrop effect [gradient 1x1 0.0.0 0.0.180]
    h2 "Attention:" red
    text yellow bold 250x60 {
        Kasper probably was the most wonderful dog in the world.
        If you disagree, stop using this program.
    }
    button "OK" [hide-popup]
]

view layout [
    size 280x273
    ;backtile http://www.oops-as.no/royg/kasper.jpg  <-- wesite long gone
    backdrop effect [gradient 1x1 0.200.0 0.0.0]
    at 0x0
    title red center 280 "The Kasper Program"
    at 50x50
    text black bold "Kasper probably was the most wonderful dog in the world"
    at 0x100
    banner center 280 "Kasper"
    banner center 280 "1993 - 2008"
    banner center 280 "R.I.P."
    across
    at 5x240
    button 195 "Please share your condolences" [
        ;random/seed now
        ;send/header ingris@email.here pick emails random (length? emails) make object! [X-kasper: "Kasper" from: to: date: none]
        emailer/to/subject ingri@imprint.no "Kasper"
    ]
    button 70 "Disagree" [inform dialog]

]

quit

;halt ;; to terminate script if DOne from webpage
