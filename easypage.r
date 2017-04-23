REBOL [
    Title: "Easy REBOL GUI Page"
    Date: 23-May-2000
    Version: 1.0.1
    File: %easypage.r
    Author: "Larry Palmiter"
    Purpose: {Shows how to create a simple page with paragraphs,
buttons, and entry fields on a colorful backdrop.
}
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

pic: load-thru/binary http://www.rebol.com/view/bay.jpg

view layout [
    size 512x480
    backtile pic effect [reflect 1x0 fit blur gradcol 1x1 100.0.0 0.0.100]
    title white "Easy REBOL Page"
    indent 30
    guide
    h2 white "Simple Example"
    text white {
        This is a short, simple, easy to read example of a 
        REBOL/View screen. It uses a pleasant JPG image as a
        backdrop to make it more interesting and easy to
        read. The image is reflected, scaled, blurred and
        colorized to make it more interesting.
    }
    text white {
        On top of the background there is a title and a
        subtitle.  They use a predefined style that makes
        them a certain size and color, but you can change
        them into whatever style you prefer with the STYLIZE
        function.
    }
    h2 white "Mail A Message"
    text white {
        Here is a field for sending a short email message. It
        assumes that your REBOL email address has been set in
        your USER.R file.  If not, it will be ignored.
    }
    result: area "It works!" 400x100
    across
    button "Send" [
        if system/user/email [send carl@rebol.com result/text quit]
    ]
    button "Quit" [quit]
]