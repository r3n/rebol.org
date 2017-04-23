REBOL [
    Title: "En-/decryption Functions"
    Date: 20-Jul-1999
    File: %encrypt.r
    Author: "Bohdan Lechnowsky"
    Usage: {
        Put the command:

        do %encrypt.r

        near the beginning of your %user.r file.  Once
        it has been run, do the following:

        >> write/binary %pass.r encrypt "password-here"

        Whenever you need to assign that particular 
        password, do the following (this example shows 
        setting the default proxy password):

        system/schemes/default/proxy/pass: decrypt read %pass.r
    }
    Purpose: "A basic encryption scheme."
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

hash: func [
    "Returns a hash value for a string"
    string [string!] value [integer!]
][
    (checksum string) // value
]

encrypt: func [
    "Encrypts a string"
    string [string!]
    /local shift-val codeword
][
    codeword: "mycode" ;-- change as needed
    shift-val: hash codeword 8
    if zero? shift-val [shift-val: 5]
    string: shift enbase/base compress string 2 shift-val
    to-string load append insert head string "2#{" "}"
]

decrypt: func [
    "Decrypts an encrypted string"
    string [string!]
    /local shift-val codeword
][
    codeword: "mycode" ;-- change as needed
    shift-val: hash codeword 8
    if zero? shift-val [shift-val: 5]
    string: shift/right enbase/base string 2 shift-val
    to-string decompress load append insert head string "2#{" "}"
]

shift: func [
    "Takes a base-2 binary string and shifts bits"
    data [string!] places [integer!] /left /right
    /local first-bits last-bits
][
    if any [places < 1 places >= length? data] [
        print "ERROR: Shift places exceeds length of binary data or is invalid"
        return none
    ]
    either right [
        last-bits: copy/part tail data (places * -1)
        remove/part tail data (places * -1)
        data: head insert head data last-bits
    ][
        first-bits: copy/part data places
        remove/part data places
        append data first-bits
    ]
    return data
]
