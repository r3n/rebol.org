REBOL [
    Title: "REBOL Web Crawler"
    Date: 16-Sep-1999
    File: %webcrawler.r
    Author: "Bohdan Lechnowsky"
    Purpose: {
        To crawl the web starting from any site.  Does not record
        duplicate visits.  Saves all links found in 'newlinks.
    }
    Email: bo@rebol.com
    Comments: {
        Based on my previous script, %rebol-web-miner.r
    }
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

find-links: func [
    "Finds 'href' links and outputs them as a block"
    url [url!] "The site currently being checked"
    html [string!] "The HTML text to parse"
][
    links: make block! 0
    site: tail form url
    while [(copy/part site: back site 1) <> "/"][]
    site: to-url head clear next site

    while [html: find html "href"] [
        link: (trim (copy/part (next (find html "=")) (html: find html ">")))

        if not found? find link "mailto:" [
            link: trim/with link {"}
            if (copy/part form link 7) <> "http://" [
                link: head clean-path join site link
            ]
            append links to-url link
        ]
    ]
    return links
]

urls: [http://www.rebol.com/]

newlinks: make block! 0
sites: make block! 0

while [true] [
    foreach url urls [
        either find sites url [
            print [url "already visited"]
        ][
            print ["    READING" url]
            append newlinks url
            append sites url
            either not error? try [read-url: read url] [
                foreach link find-links url read-url [
                    if none? find newlinks link [
                        append newlinks link
                    ]
                ]
            ][
                print ["    Error reading" url]
            ]
        ]
    ]
    urls: newlinks
] 
