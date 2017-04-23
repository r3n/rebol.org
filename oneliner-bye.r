Rebol [
    Title: "VID demo"
    Date: 20-Jul-2003
    File: %oneliner-bye.r
    Purpose: {A red box with "bye" written on it disappears into the distance.}
    One-liner-length: 132
    Version: 1.0.0
    Author: "Anton"
    Library: [
        level: 'intermediate
        platform: none
        type: [How-to FAQ one-liner]
        domain: [vid gui]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
view l: layout [image red "bye" font-size 50 rate 9 feel [engage: func[f a e][if a = 'time[f/text: "" f/image: to-image l show f]]]]
