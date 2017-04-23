REBOL [
    title: "Little 3D Game"
    date: 29-Nov-2009
    file: %3d-game.r
    author:  Nick Antonaccio
    purpose: {
        Try to click the bouncing REBOLs as many times as possible in 30 seconds.
        The speed increases with each click!  The 3D logic and calculations in this
        script were  taken directly from Gregory Pecheret's "ebuc-cube" script, at:
 
        http://www.rebol.net/demos/download.html
 
        This script can also be found in the tutorial at http://re-bol.com
    }
]

beep-sound: load to-binary decompress 64#{
eJwBUQKu/VJJRkZJAgAAV0FWRWZtdCAQAAAAAQABABErAAARKwAAAQAIAGRhdGEl
AgAA0d3f1cGadFQ+T2Z9jn1lSjM8T2uNsM/j7Midc05PWGh4eXVrXE5DQEZumsTn
4M2yk3hiVU9fcX+GcFU8KkNmj7rR3+HYroJbPUpfdoqAbldBP0ZWbpW62OvRrohk
WlleaHB2dW9bRzo1WYWy3OHbyrKObVNCVGp/jXpgRC48Vnievtfm6MCUaUVLWW1/
fXNkUkdCRlN7ps3r3cSkgm1fWFhmdH2AaVA6LElwnMja4dzNpHtXPUxje45/aVA5
PUtif6TG3uvMpHtXU1lkcnd2cGVURT0+ZJC84+HUvaGCZ1NIWm6AinVaQCtAX4Wu
yt3k37aJYEBKXXOHf3FdSEJET2KJsdPr1reUcGJbW2FsdXl2YUs5MFF7qdPe3tO+
mHNUP1Bnfo59ZEkyPFFukbTR5OvGm3BMTVlpent1aVpMQ0FJcZ3I6uHMsJB2YlZR
YXJ/hW5UOypEaJK90+Dg1qyBWjxKYHeLgG1WPz9HWXKYvNnr0KyFYVhZX2pydnVu
Wkc7N1yHtN3h2sivjGxTRFZrgI15X0MtPVh7osHZ5ua+kmdES1tvgn5zY1BGQ0hW
fqjO69vBoX9rXllaaHV9fmhPOi1Lcp/K2+DayaF4Vj1NY3uNfmhONjxLZIKnyODr
yqJ4VFFYZHN3dm5iUUM9QGaTv+Th0rqdf2VTSltvgIl0WT4rQGCIssze5N60iF8/
Sl10h39vW0ZBRFFljLPU69W1kG1gWlxiYHkWb1ECAAA=
}
alert {
   Try to click the bouncing REBOLs as many times as possible in
   30 seconds.  The speed increases with each click!
}
do game: [
   speaker: open sound://
   g: 12 i: 5 h: i * g j: negate h  x: y: z: w: sc: 0  v2: v1: 1  o: now
   img1: to-image layout [backcolor brown box red center logo.gif]
   img2: to-image layout [backcolor aqua box yellow center logo.gif]
   img3: to-image layout [backcolor green box tan center logo.gif]
   cube: [[h h j][h h h][h j j][h j h][j h j][j h h][j j j][j j h]]
   view center-face layout/tight [
      f: box white 550x550 rate 15 feel [engage: func [f a e] [
         if a = 'time [
            b: copy []  x: x + 3  y: y + 3  ; z: z + 3
            repeat n 8 [
               if w > 500 [v1: 0]   if w < 50 [v1: 1]
               either v1 = 1 [w: w + 1] [w: w - 1]
               if j > (g * i * 1.4) [v2: 0]   if j < 1 [v2: 1]
               either v2 = 1 [h: h - 1] [h: h + 1]  j: negate h
               p: reduce pick cube n 
               zx: p/1 * cosine z - (p/2 * sine z) - p/1
               zy: p/1 * sine z + (p/2 * cosine z) - p/2
               yx: (p/1 + zx * cosine y) - (p/3 * sine y) - p/1 - zx
               yz: (p/1 + zx * sine y) + (p/3 * cosine y) - p/3
               xy: (p/2 + zy * cosine x) - (p/3 + yz * sine x) - p/2 - zy
               append b as-pair (p/1 + yx + zx + w) (p/2 + zy + xy + w)
            ]
            f/effect: [draw [
               image img1 b/6 b/2 b/4 b/8
               image img2 b/6 b/5 b/1 b/2
               image img3 b/1 b/5 b/7 b/3 
            ]]
            show f
            if now/time - o/time > :00:20 [
               close speaker
               either true = request [
                  join "Time's Up! Final Score: " sc "Again" "Quit"
               ] [do game] [quit]
            ]
         ]
         if a = 'down [
            xblock: copy [] yblock: copy []
            repeat n 8 [
                append xblock first pick b n
                append yblock second pick b n
            ]
            if all [
                e/offset/1 >= first minimum-of xblock
                e/offset/1 <= first maximum-of xblock
                e/offset/2 >= first minimum-of yblock
                e/offset/2 <= first maximum-of yblock
            ][
               insert speaker beep-sound wait speaker
               sc: sc + 1
               t1/text: join "Score: " sc 
               show t1
               if (modulo sc 3) = 0 [f/rate: f/rate + 1]
               show f
            ]
         ]
      ]]
      at 200x0 t1: text brown "Click the bouncing REBOLs!"
   ]
]
