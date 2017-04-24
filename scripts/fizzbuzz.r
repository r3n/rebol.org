REBOL [
    title: "FizzBuzz"
    date: 18-Apr-2010
    file: %fizzbuzz.r
    author:  Nick Antonaccio
    purpose: {
        A 92 character version of the classic "FizzBuzz" program. 
        Taken from the tutorial at http://re-bol.com
    }
]

repeat i 100[j:""if i // 3 = 0[j:"fizz"]if i // 5 = 0[j: join j"buzz"]if j =""[j: i]print j]