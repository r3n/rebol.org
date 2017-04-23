REBOL [
    title: "Coin Flip"
    date: 27-Nov-2013
    file: %coinflip.r
    author:  Nick Antonaccio
    purpose: {
        A little example for a student.  Click the button to randomly flip the coin image.
        Based on the example video at http://visualruby.net
        Video at http://youtu.be/0zckFPgQ2Co
    }
]
h: load http://re-bol.com/heads.jpg
t: load http://re-bol.com/tails.jpg
random/seed now
view g: layout [
    i: image h
    f: field
    btn "Flip" [
        f/text: first random ["Heads" "Tails"]
        either f/text = "Heads" [i/image: h] [i/image: t] show g
    ]
]