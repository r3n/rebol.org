REBOL [
    title: "Convert Decimal to Binary"
    date: 2-aug-2014
    file: %convert-decimal-to-binary.r
    author:  Nick Antonaccio
    purpose: {
        A quick example demonstrating the technique at
        https://www.youtube.com/watch?v=XdZqk8BXPwg
    }
]
x: to-integer ask "Decimal Number:  " 
y: ""
until [
    insert head y either odd? x [1][0] 
    x: x / 2
    x <= 1
]
alert y