REBOL [
    Title: "Web Site Checker"
    Date: 11-June-2004  ;16-May-2001
    Version: 1.1.1
    File: %site-check.r
    Author: "Carl Sassenrath"
    Purpose: {Scan a web site looking for missing pages, remote links, email links, etc. Helps you clean up sites.}
    Email: carl@rebol.com
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: [web file-handling markup parse] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

; 1.1.1 - Fixes problem when top-level relative paths are used ( /index.html /about.html etc)

;--Config:
base-url: http://www.rebol.com
threshold: 8000   ; used to filter out huge pages
exclude-urls: [   ; URL patterns for pages to exclude
    http://www.rebol.com/library
    http://www.rebol.com/docs/core23
    http://www.rebol.com/dictionary
    http://www.rebol.com/users.html
    http://www.rebol.com/docs/dictionary
]

;--Lists:
base-str: form base-url
scanned-urls: []
missing-urls: []
remote-urls: []
local-urls: []
secure-urls: []
email-urls: []
ftp-urls: []
ref-urls: []  ; pairs of: url and referrer

;--Functions:
html?: func [url /local t] [
    all [
        t: find/last/tail url "."
        t: to-string t
        any [t = "htm" t = "html"]
    ]
]

add-url: func [urlset url from /local t] [
    clear find url "#"
    if all [
        not find url "?"
        html? url
    ][
        append urlset url
        repend ref-urls [url form from] ; second is string
    ]
]

scan-page: func [url /local tag page new path] [
    print ["Scanning:" url length? local-urls length? missing-urls]
    append scanned-urls url
    foreach u exclude-urls [if find/match url u [print "(excluded)" exit]]
    path: either html? url [first split-path url][url]
    if error? try [page: load/markup url][append missing-urls url exit]
    if (length? page) > threshold [exit] ; big page, skip it.
    foreach tag page [
        if all [
            tag? tag
            tag: parse tag "="
            tag: select tag "HREF"
        ][
            new: to-url tag
            parse/all tag [
                "#" |
                base-str  (add-url local-urls new url) |
                "/"       (add-url local-urls base-url/:new url) |  ;1.1.1
                "http:"   (append remote-urls new) |
                "https:"  (append secure-urls new) |
                "ftp:"    (append ftp-urls new) |
                "mailto:" (append email-urls new) |
                none      (add-url local-urls path/:new url)
            ]
        ]
    ]
    remote-urls: unique remote-urls
    local-urls:  unique local-urls
    secure-urls: unique secure-urls
    email-urls:  unique email-urls
    ftp-urls:    unique ftp-urls
]

;--Main code:
scan-page base-url

while [pick urls: exclude local-urls scanned-urls 1][
    scan-page pick urls 1
]

out: reform ["Site Summary for" base-url "on" now newline]

sort scanned-urls
repend out "^/Scanned Pages:^/"
foreach url scanned-urls [repend out [url newline]]

sort remote-urls
repend out "^/Remote Links:^/"
foreach url remote-urls [repend out [url newline]]

sort email-urls
repend out "^/Email Links:^/"
foreach url email-urls [repend out [url newline]]

repend out "^/References:^/"
foreach [url url2] ref-urls [repend out [url2 " -> " url newline]]

repend out "^/Missing Pages:^/"
foreach url missing-urls [
    n: ref-urls
    repend out ["Missing URL:" url newline]
    while [n: find n url] [
        repend out [tab "Ref from:" n/2 newline]
        n: next n
    ]
]

write %site-summary.txt out
browse %site-summary.txt
