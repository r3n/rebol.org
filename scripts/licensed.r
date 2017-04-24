REBOL [
    Title: "Check for REBOL Pro Features"
    Date: 18-May-2001
    Version: 1.0.0
    File: %licensed.r
    Author: "Carl Sassenrath"
    Purpose: {An example of how to detect View/Pro and Command special features.}
    Email: carl@rebol.com
    library: [
        level: 'beginner 
        platform: none 
        type: [tool] 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

alert either system/user-license/id [
    "You have REBOL/View/Pro or REBOL/Command."
][
    "You do not have REBOL/View/Pro nor REBOL/Command."
]
