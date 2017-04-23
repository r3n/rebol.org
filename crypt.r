REBOL [
    Title: "File Encryption and Decryption Utility"
    Date: 29-Jun-2001/12:00-7:00
    Version: 1.0.4
    File: %crypt.r
    Author: "Carl Sassenrath"
    Purpose: {An example utility that encrypts and decrypts files using a highly secure form of encryption (the Blowfish algorithm with 128 bits). Requires REBOL/View/Pro or REBOL/Command to run.
}
    Email: carl@rebol.com
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

if not system/user-license/id [
    alert "REBOL/View/Pro or REBOL/Command required to run this script."
    quit
]

request-key: has [pass] [
    pass: request-text/title "Enter a pass-phrase:"
    if pass [checksum/secure pass]
]

crypt: func [
    "Encrypts or decrypts with compression. Returns result."
    data [any-string!] "Data to encrypt or decrypt"
    akey [binary!] "The encryption key"
    /decrypt "Decrypt the data"
    /binary "Produce binary decryption result."
    /local port
][
    port: open [
        scheme: 'crypt
        direction: pick [encrypt decrypt] not decrypt
        key: akey
        padding: true
    ]
    if not decrypt [data: compress data]
    insert port data
    update port
    data: copy port
    close port
    if decrypt [
        data: decompress data
        if not binary [data: to-string data]
    ]
    data
]

if none? op: request ["Select action:" "Encrypt" "Decrypt" "Cancel"][quit]
action: pick ["Encrypt" "Decrypt"] op
if none? files: request-file/title join "Select Files to " action action [quit]
if none? key: request-key [quit]

foreach file files [
    data: read/binary file
    data: either op [crypt data key][crypt/decrypt/binary data key] 
    write/binary file data
]

alert join "File has been " pick ["encrypted." "decrypted."] op
                                                            