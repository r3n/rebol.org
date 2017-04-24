REBOL [
    title: "Binary File Transfer"
    date: 4-Dec-2009
    file: %binary-file-transfer.r
    author:  Nick Antonaccio
    purpose: {
        Demonstrates how to transfer binary files between 2 computers
        connected by a TCP port.  This is a shortened version of the script 
        explained at http://www.rebol.net/cookbook/recipes/0058.html .

        There are 2 separate programs here - one to run as server, and another
        to run as client.  The script is configured to demonstrate on a single machine.
        To run it on two separate computers, change the IP address in the client
        script.
    }
]


    ; server/receiver - run first:

    if error? try [port: first wait open/binary/no-wait tcp://:8] [quit]
    mark: find file: copy wait port #""
    length: to-integer to-string copy/part file mark
    while [length > length? remove/part file next mark] [append file port]

    view layout [image load file]



    ; client/sender - run after server (change IP address if using on 2 pcs):

    save/png %image.png to-image layout [box blue "I traveled through ports!"]

    port: open/binary/no-wait tcp://127.0.0.1:8  ; adjust this IP address
    insert file: read/binary %image.png join l: length? file #""
    insert port file