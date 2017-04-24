REBOL [
    Title: "REBOL Random Password Generator"
    Date: 16-Jun-1999
    File: %rand-pass.r
    Author: "Tyler Booth"
    Purpose: { 
        To use the system password file to generate a random
        set of passwords for every user on the system. 
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

password-file:    %/etc/passwd         ; Master password file
destination-file: %/root/password-list ; Dest. generated passwords

; Set of valid characters for a password
chars: make bitset! [#"a" - #"z" #"A" - #"Z" #"0" - #"9" "!,.$#%&?"]

random/seed now/time
foreach name load password-file [
    user: copy/part name find name ":"
    password: copy ""
    while [not (length? password) = 8][
        a: random #"z"
        if find chars a [insert password a]
    ]
    write/append destination-file reduce [user ":^-" password "^/^/"]
] 
