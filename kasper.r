REBOL [
    Title: "The Kasper Program"
    File: %kasper.r
    Date: 21-May-2001
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

Hey, this Kasper dog of yours really IS wonderful, isn't he!!}
{Ingri,
Hey, that dog is so cool! You're a lucky dog owner, that's
for sure!}
"Ingri, I love your dog!"
{Kasper ---
What a wonderful name for a dog!}
{Your dog is so cool. Been lookin' all over the web
for his fan club, but I couldn't find it. Pity.}
{Kasper
Is your name Kasper? Why isn't it Caspar?
(Just wondering).}
"Kasper is cool. Is he an ACD, by any chance?"
{Honourable dog owner,
I'm thinking of starting a Kasper Fan Club.
Cool, eh?}
{I have a dog too, but his name isn't Kasper.
Thought maybe you'd like to know.}
{Hello,
I saw Kasper on http://www.oops-as.no/royg/kasper.jpg,
and I must say, he really is a beautiful dog.}
"Kasper is a nice dog. Nice dog. Bet he's a blue healer!"
]

dialog: layout [
    backdrop effect [gradient 1x1 0.0.0 0.0.180]
    h2 "Attention:" red
    text yellow bold 250x60 {
        Kasper is probably the most wonderful dog in the world.
        If you disagree, stop using this program.
    }
    button "OK" [hide-popup]
]

view layout [
    size 280x273
    backtile http://www.oops-as.no/royg/kasper.jpg
    at 5x0
    title red "The Kasper Program"
    at 150x50
    text black bold "This dog is probably the most wonderful dog in the world"
    across
    at 5x240
    button 195 "Please tell the owner you agree" [
        ;random/seed now
        ;send/header ingris@email.here pick emails random (length? emails) make object! [X-kasper: "Kasper" from: to: date: none]
        emailer/to/subject ingris@email.here "Kasper"
    ]
    button 70 "Disagree" [inform dialog]

]

quit