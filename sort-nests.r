REBOL [
    Title: "Sorting nested blocks"
    Date: 16-Jun-1999
    File: %sort-nests.r
    Author: "Jeff Kreis"
    Purpose: "Sort a block of blocks on different fields."
    Email: jeff@rebol.com
    library: [
        level: 'intermediate 
        platform: 'all 
        type: [Tool function] 
        domain: [DB x-file] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

fields: [name legs eyes web-site]
creature-db: [
    ["Beetle" 6 2 http://www.beetle.com]
    ["Fly" 6 26 http://www.fly.com]
    ["Aardvark" 4 2 http://www.aardvark.com]
    ["Spaz" 3 14 http://spaz.com]
]

list-it: func ["Column printer" i [integer!]][
    foreach creature creature-db [
        foreach :fields creature [
            foreach item [name legs eyes web-site] [pad get item]
            print ""
        ]
    ]
]

pad: func [arg][prin arg loop absolute (length? form arg) - 10 [prin " "]]

repeat i length? fields [
    sort/compare creature-db func [a b][(pick a i) < pick b i]
    print ["^/;---Soring on field" i newline] 
    list-it i
]          

