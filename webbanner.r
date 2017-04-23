REBOL [
    Title: "Web Banner"
    Date: 20-Jul-1999
    File: %webbanner.r
    Author: "Andrew Grossman"
    Usage: { 
        make-banner or make-banner/ad with an ad number to show a
        specific ad.
    }
    Purpose: {Generate HTML code that displays a banner and links to its destination.}
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: [web markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

random/seed now

banner-db: [
    http://www.news.com  %/images/newscom.gif
        "News.com: News you can use"
    http://www.wired.com %/images/wirednews.gif
        "Wired News"
    http://slashdot.org  %/images/slashdot.gif 
        "Slashdot: News for nerds.  Stuff that matters."
]

make-banner: func [/ad adnumber /local url img alt] [
    set [url img alt] skip banner-db either ad [ 
        adnumber - 1 * 3
    ][
        random (length? banner-db) / 3
    ]   
    rejoin [{<a href="} url {"><IMG SRC="} img {" ALT="} alt {"></a>}]
]

examples: [
    print [make-banner newline
           make-banner/ad 3]
]
do examples
