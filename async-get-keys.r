REBOL [
    title: "Asynchronous Get Keys"
    date: 18-Apr-2010
    file: %async-get-keys.r
    author:  Nick Antonaccio
    purpose: {
        Demonstrates how to check for async keystrokes (including arrow keys) in the REBOL console. 
        Taken from the tutorial at http://re-bol.com
    }
]

print ""
p: open/binary/no-wait console://
q: open/binary/no-wait [scheme: 'console]
count: 0

forever [
    count: count + 1
    if not none? wait/all [q :00:00.01] [
        wait q
        qq: to string! copy q
        probe qq
        print ["^/count incremented to" count "while waiting^/"]
    ]
]