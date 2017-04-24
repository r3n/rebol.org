Rebol [
    title: "Object Namespaces"
    date: 29-june-2008
    file: %object-namespaces.r
    author: Nick Antonaccio
    purpose: {
        A short example to demonstrate how name spaces can be managed in Rebol, using objects.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

var: 1234.56
bank: does [
    print ""
    print rejoin ["Your bank account balance is:  $" var]
    print ""
]

var: "Wabash"
bank: does [
    print ""
    print rejoin [
        "Your favorite place is on the bank of the:  " var]
    print ""
]

print "Your original variable and function have been erased as a result of namespace clashes:"
bank
ask "press [ENTER] to continue... ^/"
print "You can avoid these sorts of problems by using objects:"

show-money: make object! [
    var: 1234.56
    bank: does [
        print ""
        print rejoin ["Your bank account balance is:  $" var]
        print ""
    ]
]

show-place: make object! [
    var: "Wabash"
    bank: does [
        print ""
        print rejoin [
            "Your favorite place is on the bank of the:  " var]
        print ""
    ]
]

show-money/bank 
show-place/bank

ask "press [ENTER] to continue... ^/"

deposit: make show-money [
    view layout [
        button "Deposit $10" [
            var: var + 10
            bank
        ]
    ]
]

travel: make show-place [
    view layout [
        new-favorite: field 300 trim {
            Type a new favorite river here, and press [Enter]} [
            var: value
            bank
        ]
    ]
]