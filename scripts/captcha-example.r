REBOL [
    title: "Captcha Example"
    date: 8-Apr-2010
    file: %captcha-example.r
    author:  Nick Antonaccio
    purpose: {

        A minimal example demonstrating how to use the captcha library by SOFTINNOV:
        http://softinnov.org/rebol/captcha.shtml

        NOTE:  the first part of this script CAN be used to create catchpa images
        in a non-graphic environment.  You can, for example, run the first 6 lines
        of this script on your web server - just be sure to use REBOL/command 
        (available for free in the REBOL SDK Beta at http://www.rebol.net/builds/#section-1 
        rebcmd or rebcmd.exe - demo license available in the MAC download).

    }
]

write/binary %Caliban.caf read/binary http://re-bol.com/Caliban.caf
do http://re-bol.com/captcha.r

captcha/set-fonts-path %./
captcha/level: 4
write/binary %captcha.png captcha/generate
write %captcha.txt captcha/text

view center-face layout [
    image (load %captcha.png)
    text "Enter the captcha text:"
    f1: field [
        either f1/text = (read %captcha.txt) [alert "Correct"] [alert "Incorrect"]
    ] 
]
