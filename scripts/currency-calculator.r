REBOL [
    title: "Currency Rate Conversion Calculator"
    date: 9-feb-2013
    file: %currency-calculator.r
    author:  "Nick Antonaccio"
    purpose: {

        This example downloads and parses the current (live) US Dollar 
        exchange rates from http://x-rates.com.  The user selects from
        a list of currencies to convert to, then performs and displays the
        conversion from USD to the selected currency.  All of the parsing
        occurs when the "Convert" button is clicked.  The first half of the
        script is the simple Calculator GUI example taken from the first
        part of the tutorial at:

        http://re-bol.com/business_programming.html

    }
]

    view center-face layout [
        origin 0  space 0x0  across
        f: field 200x40 font-size 20
        return
        style btn btn 50x50 [append f/text face/text  show f]
        btn "1"  btn "2"  btn "3"  btn " + "  return
        btn "4"  btn "5"  btn "6"  btn " - "  return
        btn "7"  btn "8"  btn "9"  btn " * "  return
        btn "0"  btn "."  btn " / "   btn "=" [
            attempt [f/text: form do f/text  show f]
        ] return
        btn 200x35 "Convert" [
            x: copy []
            html: read http://www.x-rates.com/table/?from=USD&amount=1.00
            html: find html "<img src='/themes/bootstrap/images/xrates_sm_tm.png'" 
            parse html [
                any [
                    thru {from=USD} copy link to {</a>} (append x link)
                ] to end 
            ]
            rates: copy []
            foreach rate x [
                parse rate [thru {to=} copy c to {'>}]
                parse rate [thru {'>} copy v to end]
                if not error? try [to-integer v] [append rates reduce [c v]]
            ]  
            currency: request-list "Select Currency:" extract rates 2
            rate: to-decimal select rates currency
            attempt [alert rejoin [currency ": " (rate * to-decimal f/text)]]
        ]
    ]
