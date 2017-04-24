REBOL [
    Title:   "Menu-System Demo"
    Name:    'Menu-System-Demo
    File:    %menu-system-demo.r
    
    Version: 0.2.0.1                                                            ;-- Auto download %menu-system.r
    Date:    12-Jun-2005 
    
    Author:  "Christian Ensel"
    Email:   christian.ensel@gmx.de
    
    Owner:   "Christian Ensel"
    Rights:  "Copyright (c)2005 Christian Ensel"                                 
   
    Purpose: "Demostration of features of menu-system.r"

    Comments: "Needs %menu-system.r to run."
        
    Library: [
        level:    'beginner
        platform: 'all
        type: [demo]
        code: 'module
        domain: [user-interface vid gui]
        tested-under: [view 1.3.0.3.1 on "WinXP"]
        support: none
        license: none                                                           ;-- Not bothered with licensing stuff yet, but most likely BSD
        see-also: none
    ]
]

unless request/confirm {The Menu System Demo requires %menu-system.r to be downloaded from REBOL.org^/Click YES to continue, NO to abort.} [
    quit
]

demo:   copy/part form system/script/header/version 5
script: load-thru/check http://www.rebol.org/library/scripts/menu-system.r to tuple! demo

do script

icon-1.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAAXNSR0IArs4c6QAA
AARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAA
OpgAABdwnLpRPAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYyLjFiT2tyLwAA
A1pJREFUOE99lN1P23UYxVsuKFEQQrEEmkJDt9HRhJcEFVIoqPECR6lmZkvMLmRN
fF1Ysk3UP4CZGIxyo8ZETbS6xF3MdbhdmL0oUtY1XdkLVpoVMGXCCq2stQrd2o+/
57eAbBJ/yUnO95zznH4vnm+1Wq1Ws9W3trZGPp/XCOQrKChQodPpth6Qos3IZrPc
nD2P/8zznP26ljOfalUIF008yTw4d19JJpMhdOF1zn5ZzMzlJ0klXlNudVSFcNHE
k4xkN5dtFKVWlvjpeBPB0xb+zhwht3qQO6kXySadKoSLJp5kJCsz62UbRb7RPn74
1spk6A1mwr3cCHXzy0UHd2/vUiHnqQkHsRt9XL1ygFFPPeNe179FIyMj7NxRQ3l5
Ic7eetwv1bFntxGDvoiqioc4fNDCO0e2YakpprSkiF09lexXMnv32KirKcJofJTB
wUE0Q0NDlJTo8Hg+Y2BgAIfDQXt7O90OO/a2x+lyVNDXW0VhYSHekycYHh5WM3a7
Hbd7Lwblx/r7+9EEg0HaWh6mo8OG1WrFZDJhs9loaW7AbCrh5x+fIDbXxTZzsao1
NjYqtzCqWZerm1qjjkgkgiYcDvPuW49gNlfQ2WnB6bTR1GRSzmV88J6Z5FwD81fN
HPvEQL2lCOt2A85nrTzTXaMUlnHIXcri4iKa2dlZTn1RQfzWYZbiT3El9Bgz1xtY
mjKSnq4kHalk+ZqBm0EDC5cNzAcM+E7qmfNXk4zv4/w3BhKJBJp4PM6FY2YSy6+S
XrYzH6zmu4/1ZKJGVufu4a8ZI6lINSvT1Zz4SK+UVpH+zcbKrRfwHd9BMplEk0ql
8Hl7if3aRe7PHrKxWjzDeo4eKCXqM3JnvlaFcNHEk0wu00Ms3MnEqAvpUPcodPEr
Lp1WzOzL5Jaaufu7hQ/fLqdVr7kP779ZpnqSkazMhPwedZfUooWFBSZOuZgOtELu
FXLJVnKL9Uydk9sZVAgXTTzJSNanLKTMbhQJuX4tiN/boWxzM6uZ/bD6HPnb7eTj
1ntYaVM18cL+FjUrM/95IiJMTk4yPupWrrydWORp0n/sAw6pEC6aeJKR7JaPdl2M
RqOMn/tceUe7CXhbmPi+ToVw0cSTzP/+jWw2ZVsDgQBjY2MqhIv2YMH6+R/R3qE2
eoGY/AAAAABJRU5ErkJggg==
}

icon-2.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAAXNSR0IArs4c6QAA
AARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAA
OpgAABdwnLpRPAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYyLjFiT2tyLwAA
AwZJREFUOE99VGtIU2EY3vzjH6MoU0JypRhEzBLsn5UW1KLLEMEwJEhDqcwijNIw
0sD0R/TDQCsI8gKaRrF0iqSmw8tc6kxzutxKhxnYlm5OzzbPnr73k5nXPngO7+V5
nvN+53znSKVSqWSj5XK54PV6JQRafn5+HP7+/hsLyGgl3G43Jr+3QtsQj+ZKGRpe
SDkophr1iLNWt8rE6XSi/9M1NJcFwNwXB7v1KpuqgINiqlGPOMRdabZsZJ+ZRnvN
QfSqw7HgzIIo3ITHfhFu2zkOiqlGPeIQlzQ+M24kCAIbW4kvrXLAmw9x7gLG+mMx
3H0Ui7NnOHw59YhD3O76eJCWP2e6jI/Wo61qG0RPLsT5BIiO08hODcGNxGAer8uJ
w7ikGf/WuGREjt3qeFhGT8K7mAFxQcGRdj4QSbFbN82JSxqtOoFPJbHb7WivlsHp
yGBGifB6TnEU3JEhJz1k05y4pGmv3gPykNhsNnyq2g5RfAivqGBgkzE47Mcx8zMa
HqscwmQ4bIZQTA+FYH4sCMKEDIIlDIvuNLRXBYE8JFarFW01O7HouY/fv+JgHDqM
aTMTT+yGYApeB8doMIaadsDSs4u9xcvQvAkCefCJOmv38jG1HyORl5mEksd3UVp4
D09zU/GyMJmjOC+F154XZePRrWRo3sdgzpaIrtp9SxPR/jpVZ2EZOQaPQ4EHV7ag
9nUpDAO9aFLXwWw0cNS9q+W1+ppyZF8KgGtWAYvhCLrqlEvPiF5df3c5etQyiGzP
VqMc+dcjYBr5ir7ez/Atii0/TMhKlsOs28+5pOnXVvw7R1NTU+j6oMSoLhoQ0zE1
HImCzFC8LXvGDAc5KkqK2A1CYRlgh5ZxiNupUoK0yweSgqHBXmhVMew0H4LgTIHo
VELbeADFOYGofBIMfYuc16hn0EZxLmlWfSK+RK/Xo6MulY0cAYvxBBx/ktnObnNQ
TDXqEYe4G360vqLJZEJHyyt0qBKgU0Whqz6Mg2KqUY84//2NrGwajUbodDpoNBoO
iqm21sCX/wXLiv7FJqqnqwAAAABJRU5ErkJggg==
}

icon-3.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAAXNSR0IArs4c6QAA
AARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAA
OpgAABdwnLpRPAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYyLjFiT2tyLwAA
AtBJREFUOE91VF1IU2EY3rzxJlC0JjRqpfRzIynsoiDLCkrpZ4lgFN2UoBRGEAn9
EEQXXhV0XdBFGWh6tXR249+G+2nYpDRzOcOWP6Sbc3N65nbO0/d8Q8ucB57D+77P
8z685zvf9+n1er0u05NIJKBpmo7gk5WVJZGdnZ25gUb/Y+pHLzxdVeh+a0LXC70E
Y9bIZerZYBKPx+Hru4nu19sw8ekEoqEbYqomCcaskaOG2n8N142ikTnY2w5h0FaE
lfhdqMptJKNXsBo+L8GYNXLUUMueNTNppCiKGNuCz73FgPYE6tIljPvK8dV9DKnF
sxJrOTlqqHV3VoG9cp35mhzrRH9LLtTkI6jL1VBjlbhfa8StmgIZb8qpEVr2TH7/
kDaio9tWheDYaWipBqgrFRJ1F7bjcnnOljm17PHYquVUumg0CnurCfFYgzCqgZY8
I9HUaMKDeuOWObXssbfuAT104XAYfS15UNXH0NQKATGZQCx6EpFpM5KhYihTRQiP
7sbcsBHL4wYoP01QgoVIrdbB3mIAPXShUAj9bTuQSj4Ui1iB5ZhY4EiJEO+CEijI
iIURYTZhFH/xGhzvDKCHnMjZvleOqS6VITRihO1lPhKTxowgFxreieRsMZbCNXC1
709PxO9zWs8h+O041Hglkr9MaH6aj6aGHAScRpkTjFkjx5za4GgZXB2W9Brx1/nc
b/DRJkjxzepcCVLTRXh+Lw/mfN0GPGvMlRw11LLH52n+u49mZmbgem/BmNcMqPVQ
w2aoswcw0sPpDBKMWSNHDbVOqwXsXd+QDIa/DMJjPSp2s1jo+HVAuQht8Qi03wfT
iByWNXKjnlKpZc+GI8IkFothaGgIAx21YuR9CPpPIbZwFcAdCcaskaOGWvZsMmKB
JzoQCGCg5xUGrNXwWkvh6iyUYMwaOWq2PP3/Xgnz8/Pw+/3wer1wOBwSjFkjl+k+
+gNGzgdGk6oIXwAAAABJRU5ErkJggg==
}

icon-folder.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAAXNSR0IArs4c6QAA
AARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAA
OpgAABdwnLpRPAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYyLjFiT2tyLwAA
AZxJREFUOE+tlE8oBGEYxneSlJRSUohEpCRxc3VYF1dXt1mbSEppt63VbBv5E0lG
0pYUKakl0m42tWnZlF2cHJw2olwUt+81z7vZmdndpjnM1HP4vt75zfM+7/eNJEmS
y5EHICfkCIS7MrpJqwN0t9VPqc0+utnopUz2md7eP8mO4wIIECGESder3RSLJ2zB
GKRDVA1klKD4YgddhtvoXGmhs/lmigYb6STQwG6NThmEdsTPGonvlVIVuYTrY389
KUqYHjJPBRiDkIn4CJHIBSm53lNWieUuii2000WolU6DTewM+nfGIAQrXn0MKM6p
7Fr7IPb3pqvZWWFqDHiconxWxTmVrn+TY1wXmawij8ergzAdkZZ59AxCXhb6io1y
3e5EJcnyuA5C/wDlW9NAyMtCuegI1+14K8wgjBigq6XOPEjLy0ovh0Nct+2RzCCc
E4AwEQZpeVkpGxnkOlV2mTPCCI2HDefkaK6ODmZraX+mhqeDYJEJ2oETQNzuYfL5
A3pGGB+uAjYRnl2hHu+VXFo4S93e25bxmjj2G/kDJoZaD/c+jjgAAAAASUVORK5C
YII=
}

icon-file.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAAXNSR0IArs4c6QAA
AARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAA
OpgAABdwnLpRPAAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYyLjFiT2tyLwAA
AkZJREFUOE+tlP1PUlEYx+MP7If+jDRKy0qLnNVWc7pyprSsmev6htRgIF7xBTHU
itxNXrqhkATuesVJOCWcNvl0uM6mIbG2nu3Z3Tnnns/9Pt/z3GMymUzn/kuUQMf5
dHYb6/QWVu863aMpuhwrdNmjdA4qdEpBamqf4/FH0DSNk/sMMScn+qbSaDuUxcEh
7OxjgJqHVumRZBKJxClYGSidPTgFOizCroBkC0eg47TZbKeUlYFWM2KHiOm5BJJX
5cX4Cs+cMQKfdPxLu/T273CrbQaLxUIoFPqtqgwUX98lGNFZjGWI6AXkjSLuVIEn
ryMEojner0BT6zRms5lgMFgZFEvncCykmBcQfw4+ikrDwiOvGL90fmZRg5sPJqqD
osktBibjuLUi8z9AF2VuiVz6WcQqTm8uBdfvy9VByrLO4Fgcea1AUJhcgghBBL7o
4gMpfEm41uKqDlI/OPHY7XTZFCa1AjFxbIood2DiK+5QHo/wqN7i+Dso6pdIWi/w
6u5jRt8mkVwqPcNhQ8mogIzHwbUMdY32yqD9VZlv3eeRWtpwyXGiGQxjF9IwI8o5
hgxHwNwwdDZob2+P0OAd+psf4nQuoW4eQd6tlUMGwlBbL1UG+Xw+bj+aZUSYMB7Y
Rp79jnsmi0v8e47JTd54NxkZ22DYo1Nzua8yKJPJ0Ng6ZXRtk3iWeuXGPZmGFjdX
hblXmkaMkmrrJC5e6q3sUT6fR1EU2tvbjZeqZUdHB6qqnt3Z2WzWWCy1frU8CSm7
Rv68Y/5l/AtQNK4vo4Bc1AAAAABJRU5ErkJggg==
}

rebol-logo.img: load 64#{
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
dKdL3epa97rY3UQgAAA7
}

mac-backdrop.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAAAEAAAAECAYAAABP2FU6AAAAG0lEQVR42gXBAQ0A
AAzDoOb+xc4Bh+C2FVzVA4hoCs1lccrMAAAAAElFTkSuQmCC
}

che-logo.img: load 64#{
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
}

shadow-normal.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+g
vaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH1QQUCzYGyPaalQAAAINJ
REFUeNrd0qEOwjAUBdADDIJDIYaZWPjJfSZuAo2bQiybKKZLmqUzRcE1TZO+U3Ef
P59DwUyHCwKGqgBocFou+wLghhptKVDjjGMpkOb6LeAPgCqzJE1SVS4vjJgR1sAj
WZJhAxgj8sS0Bvp4tkvPmcxxeEC/yzy4Lx1vAAFT/Oz9ASj/FhDibXHbAAAAAElF
TkSuQmCC
}

shadow-round.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAALGPC/xh
BQAAAAd0SU1FB9UEFAs2Bsj2mpUAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCB2
Mi4xYk9rci8AAADFSURBVDhPlZLBEYJADEV3xwI4WINXK7EXLp480YZHa7ANarEF
zWMMZrPBCZn5DLD8l78bDrXW4lV+dZfbs2gQvUVH0cusl8bcLLQPgG6ii+gUAv6Y
dekZQoi/o/okOwGkADKF20kmUcjYnUcSMMt3D9FVAUTKFqPsAIwnW968jJTZZlJE
3RcAF1JwOFvlzbr/FUAKICSxIDVqdD28BqApPARTZMS8TsBGJg6Q6ZuEbrajGrvu
EYSfxHYC7rV5YNHH9l1j/AAM0TR5BZM1PAAAAABJRU5ErkJggg==
}

edge-round.img: load 64#{
iVBORw0KGgoAAAANSUhEUgAAABoAAABDCAQAAAAowt16AAACNUlEQVR42u3XQUsb
YRDG8d+72cSoEVtKIKEHPUlvHgqlYA/pud76gdp8kIJfwJv35qAghR68eigBsa3Y
QsG0SpLN9pAYN2ptkoIIdW67vP99ZnaG2X1Cqh87NTVvXBuxVFLXWGv0r0OaAZb9
OZowAONzZBlVqUgiiPSEIZDK9cE37DTXmjF9pIKfNyg91htg3obtmvfLKn75WxTM
ONTkZaxmzGgPklQL2+l4OlDSduBIZIJoieWYDKJrdnIoCJNDpHcbmqomt5ReOo1S
uMWa7qF/heKr/U50nWihpCQ/euQqRM6ZU1+damFBUVVRQTqY7yGUZIbklyPf7duz
jeee+qmsbC5z6pJS27FP9mwij1271j3TU5UfhcJw05w59sGWgiAnyOnZMmPRA1Hm
+Rmlji/2bSkMthuRBJsq5i1ljkYXSi1nPiI6X7/ICdhz6uT6PrWc2JXPIH0sb1tL
63qoZMFznZH3RKLjhZLSKJQOoaKn6GWwRIpVsxauV8qrWrGurast0dPR1fbaispI
b+ILpVhR2TMzwz51sG7VI7Mjlcaj37qynkWVzESsKCsrXp6IXGZg51Q9MO+JVyOz
l9w0sIm8yNKVKQ9/hsLgVr+6+8Xyn0HpNJ/PMF16d/qXYMr0bguaqk+x00mhkq4E
kXrTV3NjQYlvjqhHGuPqFM63UCP3rnkQftRiD+V1bkAWRD5rUl/biNEYGI8bXc1h
3w7VbRCz1tg59yvj+KfmwHT93al1h4YLfgMuDa/Ykl2CzQAAAABJRU5ErkJggg==
}

red-image:      to image! layout/tight [box 96x16 edge [size: 1x1 color: red    effect: 'ibevel] effect reduce ['gradient 1x1 white red   ]]
blue-image:     to image! layout/tight [box 96x16 edge [size: 1x1 color: blue   effect: 'ibevel] effect reduce ['gradient 1x1 white blue  ]] 
green-image:    to image! layout/tight [box 96x16 edge [size: 1x1 color: green  effect: 'ibevel] effect reduce ['gradient 1x1 white green ]] 
yellow-image:   to image! layout/tight [box 96x16 edge [size: 1x1 color: yellow effect: 'ibevel] effect reduce ['gradient 1x1 white yellow]] 


menu-data: [
    file: item "File" 
          menu [
              new:     item <Ctrl-N> "new"  icons [icon-1.img icon-2.img]
              open:    item <Ctrl-O> "open" icons [icon-2.img icon-3.img]
              recent:  item "open recent"   icon icon-3.img disable 
                       menu [
                           item "Fugu"       icon icon-1.img 
                           item "Starimbiss" icon icon-2.img disable 
                           item "Nexte Lied" icon icon-3.img disable 
                           item "So Blau"    icon icon-1.img disable 
                       ]
                       ---
              save:    item <Ctrl-S> "save"    icons [icon-3.img icon-1.img]
              save-as: item <Ctrl-A> "save as" icons [icon-1.img icon-2.img]
                       ---
              close:   item <Ctrl-W> "close"   icons [icon-2.img icon-3.img]
                       ---
              exit:    item <Ctrl-Q> "exit"    icons [icon-3.img icon-1.img] 
          ]
    edit: item "Edit" 
          menu [
              item "undo" icon icon-3.img
              item "redo" icon icon-1.img
              ---
              item "cut" icon icon-2.img
              item "copy" icon icon-3.img
              item "paste" icon icon-1.img
          ]
    more: item "More" 
          menu [
              a: item "Drive A:" icon icon-2.img 
                 menu [
                     item "Files" icon icon-3.img
                     menu [
                         item "A File" icon icon-2.img
                         item "This is a multi-line^/menu-item, which is^/unuasual but fun." 
                     ]
                 ]
              b: item "Drive B:" icon icon-2.img 
                 menu [
                     item "(no such drive)" disable
                 ]
              c: item "Drive C:" icon icon-2.img 
                 menu [
                     item "I368"     icon icon-3.img 
                     item "SUPPORT"  icon icon-3.img 
                     item "VALUEADD" icon icon-3.img
                     item "WINDOWS"  icon icon-3.img
                 ]
              d: item "Drive D:" icon icon-3.img 
                 menu [
                     item "The Very Best of $MYFAVOURITEARTIST" icon icon-1.img 
                     menu [
                         item "Greatest Song Ever" icon icon-2.img
                         item "Another great song" icon icon-3.img
                     ]
                 ]
              e: item "Drive E:" icon icon-2.img 
                 menu [
                     item <1> "This"       icon icon-1.img radio of 'Teamleitung on
                     ---  
                     item <2> "is"      icon icon-2.img radio of 'A on
                     item <3>  "an"     icon icon-3.img radio of 'A
                     ---
                     item <4>  "example" icon icon-1.img check                         ; oh, check and radio in one group aren't possible yet!
                     item <5>  "of"      icon icon-2.img check ;radio                  
                     ---
                     item <6> "radio"   icon icon-2.img radio of 'B  
                     item <7> "and"     icon icon-3.img radio of 'B
                     item <8> "check"   icon icon-1.img radio of 'C
                     item <9> "items"   icon icon-1.img radio of 'C
                     ---
                     item <A> "Hold"       icon icon-2.img check
                     item <B> "SHIFT-Key"  icon icon-3.img check on 
                     item <C> "down"       icon icon-1.img check 
                     item <D> "to"         icon icon-2.img check  
                     item <E> "toggle"     icon icon-3.img check on  
                     item <F> "multiple"   icon icon-1.img check on
                     item <G> "items"      icon icon-2.img check 
                     item <H> "at"         icon icon-3.img check 
                     item <I> "once"       icon icon-1.img check 
                 ]
          ]
    again: item "Even more" menu [
        undo:    item "undo"  <Ctrl-Z> icon icon-1.img
        redo:    item "redo"  <Ctrl-Y> icon icon-2.img
        bar
        cut:     item "cut"   <Ctrl-X> icon icon-3.img
        copy:    item "copy"  <Ctrl-C> icon icon-1.img
        paste:   item "paste" <Ctrl-V> icon icon-2.img
        bar
        red:     item image red-image    <Ctrl-F1> check on  of 'Colors
        green:   item image green-image  <Ctrl-F2> check off of 'Colors
        blue:    item image blue-image   <Ctrl-F3> check on  of 'Colors
        yellow:  item image yellow-image <Ctrl-F4> check off of 'Colors
        bar
        red:     item "red"    <F1> body font [colors: reduce [red    black]] colors [none red   ] radio on of 'Colors edge [color: 0.0.0]
        green:   item "green"  <F2> body font [colors: reduce [green  black]] colors [none green ] radio    of 'Colors edge [color: 0.0.0]
        blue:    item "blue"   <F3> body font [colors: reduce [blue   black]] colors [none blue  ] radio    of 'Colors edge [color: 0.0.0]
        yellow:  item "yellow" <F4> body font [colors: reduce [yellow black]] colors [none yellow] radio    of 'Colors edge [color: 0.0.0]
        bar
        small:   item "small"  body font [size:  9] radio of 'Size 
        normal:  item "normal" body font [size: 11] radio of 'Size on 
        big:     item "big"    body font [size: 14] radio of 'Size 
        huge:    item "huge"   body font [size: 21] radio of 'Size
        bar
        rebol:   item image rebol-logo.img <Ctrl-F> icon icon-1.img
        bar
        che: item <?> "When?" body font [style: 'bold] icon icon-3.img menu [
            month: item "Month" icon icon-2.img menu [
                jan: item radio    "Januar"
                feb: item radio    "Februar"
                mär: item radio    "March"
                apr: item radio on "April" font [color: 0.0.255] action [print [item/body/text ", " item/body/text ", der macht, was er will."]] 
                mai: item radio    "May"
                jun: item radio    "June"
                jul: item radio    "July"
                aug: item radio    "August"
                sep: item radio    "September" menu [.: item "Radio items with sub-menus? What's that?"]
                okt: item radio    "October"
                nov: item radio    "November"
                dez: item radio    "December"
            ]
            week:  item "Week" icon icon-1.img
            day:   item "Day"   icon icon-1.img
            bar
            properties: item "Properties" icon icon-2.img
        ]
        ha:  item "When?"        icon icon-1.img menu [
            month: item "month" icon icon-2.img
            week:  item "week" icon icon-1.img
            day:   item "day"   icon icon-3.img
            bar
            properties: item "Properties" icon icon-2.img
        ]
        ---
        delete:  item "delete"          <Ctrl-D> icon icon-1.img
    ]
    about: item "About" menu [
        author: item "Author" icon icon-1.img 
                menu [
                    logo: item image che-logo.img icon icon-2.img
                ]
                ---
        script: item icon icon-2.img {This is my first attempt^/of implementing a full-fledged^/skinnable REBOL menu-system^/which allows for menus looking^/and behaving pretty much like^/native OS menus.}
                ---
        wish:   item "Hope you'll like it!" icon icon-2.img
    ]
] 

cool-menu: layout-menu/style copy menu-data cool-style: [
    menu style edge [color: none size: 13x33 image: edge-round.img effect: [extend 13x33]]
               color 60.60.60
               effect none
               spacing 0x0
    item style font [name: "Trebuchet MS" size: 16 style: 'bold colors: reduce [white black]]
               edge none 
               colors [none silver]
               effects none
               action [print ["Selected item" item/var]]
]

wierd-menu: layout-menu/style copy menu-data wierd-style: [
    menu style edge    [color: none size: 2x2 effect: [merge alphamul 75 colorize pink]]
               effect  [merge alphamul 75 colorize yellow]
               spacing 2x2
               color   none
    item style font    [name: "Comic Sans MS" size: 12 style: 'bold colors: reduce [reblue yellow] shadow: none]
               effects [
                    [merge alphamul 75 colorize orange]                         ; enabled normal 
                    [merge alphamul 75 colorize violet]                         ; enabled hovered 
                    [merge alphamul 75]                                         ; disabled normal
                    [merge alphamul 75]                                         ; disabled hovered
               ]
               edge    [color: none size: 2x2 effect: 'invert]
               colors  none
] 

winxp-menu: layout-menu/style copy menu-data winxp-style: [
    menu style edge [size: 1x1 color: 178.180.191 effect: none]
               color white
               spacing 2x2 
               effect none
    item style font [name: "Tahoma" size: 11 colors: reduce [black black silver silver]]
               colors [none 187.183.199] 
               effects none
               edge [size: 1x1 colors: reduce [none 178.180.191] effects: []]
               action [print item/body/text]
]

mac-menu: layout-menu/style copy menu-data mac-style: [
    menu style edge [size: 1x1 color: black effect: none]
               image mac-backdrop.img
               effect 'tile color none
               spacing 2x2
    item style font [name: "Haettenschweiler" size: 18 style: none colors: reduce [black white]]
               colors none 
               edge none
               effects [none [merge colorize blue] none [merge colorize silver]]
               action [print ["Item" item/var "chosen."]]
]

rebol-menu: layout-menu copy menu-data                                          ;-- unstyled default

menu-from-dir: func [dir [file!] /local entries menu dirs m] [
    entries: try [sort read dir]
    menu: copy [item style action [drop-file/text: item/body/text show drop-file focus drop-file]]
    dirs: make block! []
    foreach entry entries [
        either #"/" = last entry [
            insert tail dirs compose [item (to string! head remove back tail copy entry)]
            if not empty? m: menu-from-dir dir/:entry [
                insert tail dirs reduce ['icon 'icon-folder.img 'menu (m)]
            ]
        ][
            insert tail dirs compose [item (to string! entry) icon icon-file.img]
        ]
    ]
    if empty? dirs [dirs: [item "(empty)" disable]] 
    append menu dirs
]
dir-data: menu-from-dir dirize system/options/home 

slider-menu: layout-menu/style [
    r: slider <Red>       icon [icon-3.img icon-2.img] check
       menu [
           item "red"    <255> [set-menu slider-menu 'r [slider/data: 255]] colors [none red] 
           item "maroon" <128> [set-menu slider-menu 'r [slider/data: 128]] colors [none maroon]
           item "black"  <000> [set-menu slider-menu 'r [slider/data:   0]] colors [none black] font [colors: reduce [black white]]
       ]
    g: slider <Green>     icon [icon-3.img icon-2.img] check
       menu [
            item "green"  <255> [set-menu slider-menu 'g [slider/data: 255]] colors [none green]
            item "leaf"   <128> [set-menu slider-menu 'g [slider/data: 128]] colors [none leaf]
            item "black"  <000> [set-menu slider-menu 'g [slider/data:   0]] colors [none black] font [colors: reduce [black white]]
       ]
    b: slider <Blue>      icon [icon-3.img icon-2.img] check disable
       menu [
            item "blue"   <255> [set-menu slider-menu 'b [slider/data: 255]] colors [none blue]
            item "navy"   <128> [set-menu slider-menu 'b [slider/data: 128]] colors [none navy]
            item "black"  <000> [set-menu slider-menu 'b [slider/data:   0]] colors [none black] font [colors: reduce [black white]]
       ]
       ---
    w: slider <Greyscale>    icon [icon-3.img icon-2.img] check off
       ---
    h: slider <Hue>          icon [icon-3.img icon-2.img] check on
    s: slider <Saturation>   icon [icon-3.img icon-2.img] check on
    v: slider <Value>        icon [icon-3.img icon-2.img] check on 
       ---
    b: slider <Transparency> icon [icon-3.img icon-2.img] check on
] winxp-style

slider-menu-text: {slider-menu-data: [
    r: slider <Red>       icon [icon-3.img icon-2.img] check
       menu [
           item "red"    <255> [set-menu slider-menu 'r [slider/data: 255]] colors [none red] 
           item "maroon" <128> [set-menu slider-menu 'r [slider/data: 128]] colors [none maroon]
           item "black"  <000> [set-menu slider-menu 'r [slider/data:   0]] colors [none black] font [colors: reduce [black white]]
       ]
    g: slider <Green>     icon [icon-3.img icon-2.img] check
       menu [
            item "green"  <255> [set-menu slider-menu 'g [slider/data: 255]] colors [none green]
            item "leaf"   <128> [set-menu slider-menu 'g [slider/data: 128]] colors [none leaf]
            item "black"  <000> [set-menu slider-menu 'g [slider/data:   0]] colors [none black] font [colors: reduce [black white]]
       ]
    b: slider <Blue>      icon [icon-3.img icon-2.img] check disable
       menu [
            item "blue"   <255> [set-menu slider-menu 'b [slider/data: 255]] colors [none blue]
            item "navy"   <128> [set-menu slider-menu 'b [slider/data: 128]] colors [none navy]
            item "black"  <000> [set-menu slider-menu 'b [slider/data:   0]] colors [none black] font [colors: reduce [black white]]
       ]
       ---
    w: slider <Greyscale>    icon [icon-3.img icon-2.img] check off
       ---
    h: slider <Hue>          icon [icon-3.img icon-2.img] check on
    s: slider <Saturation>   icon [icon-3.img icon-2.img] check on
    v: slider <Value>        icon [icon-3.img icon-2.img] check on 
       ---
    b: slider <Transparency> icon [icon-3.img icon-2.img] check on
] 
slider-menu: layout-menu/style slider-menu-data winxp-style
}

version: rejoin ["Version: " system/script/header/version " " system/script/header/date]

window: center-face layout/size [
    style text text font [name: "Tahoma" size: 11] 
    backcolor white across
    
    at 0x0 sensor 800x600 feel [engage: func [face action event] [if action = 'alt-up [show-menu/offset window menus/context-menu event/offset]]]
    at 600x2 text 190x22 version as-is effect [gradient 1x0 255.255.255 255.128.128]
    at 2x2 app-menu: menu-bar menu menu-data menu-style winxp-style snow 
    at 2x30
    pad 18 text "Above you see the VID-Style MENU-BAR with a WinXP styled menu." gray
    
    across origin 20x60 pad -18
    text "Here are some examples on skinning / styling menus:" underline return
    
    btn "WinXP"           [show-menu/offset window  winxp-menu 0x1 * face/size + face/offset - 1x0]
    btn "Mac"             [show-menu/offset window    mac-menu 0x1 * face/size + face/offset - 1x0]
    btn "REBOL (default)" [show-menu/offset window  rebol-menu 0x1 * face/size + face/offset - 1x0]
    btn "Cool"            [show-menu/offset window   cool-menu 0x1 * face/size + face/offset - 1x0]
    btn "Wierd"           [show-menu/offset window  wierd-menu 0x1 * face/size + face/offset - 1x0]
    btn "Slideshow"       [show-menu/offset window slider-menu 0x1 * face/size + face/offset - 1x0] pad -8
    box 22x22 effect [arrow red rotate 270] pad -14
    text 200x22 "This one is fun!" left middle effect [gradient 1x0 255.0.0 255.255.255] pad -120x2
    btn 100x18 "See the code ..." [view/new/title center-face layout [style text text font [name: "Courier New" size: 11] backdrop white text slider-menu-text as-is] "All in all, not too complicated"]
    return
    text gray {All these menus are created from the same data with different style sheets^/and are bound to the buttons in their action block}
    return
    
    pad -18
    text "Noticed that you can navigate through the menus using the keyboard, too?" underline return
    text as-is gray {Use UP, DOWN, PAGE-UP, PAGE-DOWN, HOME, END an LEFT (ESCAPE, BACKSPACE), RIGHT to navigate, SPACE to toggle checkable or radio items and RETURN or ENTER to select an item.
Hold SHIFT while selecting or toggling to engage multiple items before menu closes.
And since we don't have TMD (rich text support) yet to support selecting items by typing their underlined letter, you instead can select items by typing their first letter. If multiple items start with the same letter, repeatedly entering that jumps between the items.
}   
    return
    
    pad -18
    text "Example of a DROP-MENU VID-style" underline return
    text gray 90 "Select file:" drop-file: drop-menu 320 menu dir-data menu-style winxp-style return
    
    pad -18
    text "Dynamic modification of menus" underline return
    text gray 90 "Item value get:" btn 200 "Query Menu-Bar/About/Wish" [
        use [info] [
            info: layout/tight/offset compose [
                style text text font [name: "Tahoma" size: 11] 
                backcolor white across space 2x2
                image 400x200 ctx-menus/shadow-image effect 'extend
                at 0x0 box white 396x196 black white edge [size: 1x1 color: black 178.180.191 effect: none]
                origin 20x20 below
                text "Querying a menu:" underline
                pad 8
                text ">>  get-menu app-menu 'about/wish 'body/text" gray
                text (join "== " mold get-menu app-menu 'about/wish 'body/text) gray
                at 340x160 btn "okay" [hide-popup/timeout]
            ] 200x200
            info/color:  none
            info/effect: [merge alphamul 128]
            show-popup/window info window 
        ]
    ]
    text gray {get-menu app-menu 3 'body/text}
    return
    text gray 90 "Item value set:" btn 200 "Toggle Menu-Bar/File/Recent" [
        set-menu app-menu 'file/recent [state: not state]    
    ]
    text gray {set-menu app-menu 'file/recent [state: not state]}
    return
    text gray 90 "Item removal:" hide-remove: at remove-btn: btn 200 "Remove Menu-Bar/About/Author" [
        item: remove-menu app-menu 'about/author
        bar:  remove-menu app-menu 'about/1
        show hide-remove hide/show hide-insert show insert-btn 
    ]
    at hide-remove hide-remove: box 200x22 white with [show?: no]
    text gray as-is {item: remove-menu app-menu 'about/author
bar: remove-menu app-menu 'about/1} return

    text gray 90 "Reinserting:" hide-insert: at insert-btn: btn 200 "Insert Menu-Bar/About Author" with [show?: no] [
        insert-menu/head app-menu 'about bar 
        insert-menu/head app-menu 'about item     
        show hide-insert hide/show hide-remove show remove-btn 
    ]
    at hide-insert hide-insert: box 200x22 white 
    text gray as-is {insert-menu/head app-menu 'about bar
insert-menu/head app-menu 'about item} return

    text gray 90 "Fun stuff:"  btn 200 "mess up menus" [
        win:  remove-menu winxp-menu 'about
        reb:  remove-menu rebol-menu 'about
        cool: remove-menu  cool-menu 'about
        wrd:  remove-menu wierd-menu 'about
        mac:  remove-menu   mac-menu 'about
        rnd: random reduce [win reb cool wrd mac]
        insert-menu winxp-menu none rnd/1
        insert-menu rebol-menu none rnd/2
        insert-menu  cool-menu none rnd/3
        insert-menu wierd-menu none rnd/4
        insert-menu   mac-menu none rnd/5   
    ]
    return
    
    text gray 90 "Item creation:" btn 200 "Insert Menu-Bar/About License" [
        insert-menu app-menu 'about layout-menu/style [license: item "License" menu [bsd: item "BSD licensed"]] winxp-style
    ]
    text gray {insert-menu app-menu 'about layout-menu/style [license: item "License" menu [bsd: item "BSD licensed"]] winxp-style}
    at 770x2   btn "X" red font [color: white style: 'bold] [quit]
    at 600x26  text 192 right as-is "close window here " effect [gradient 1x0 255.255.255 128.128.255] black
    at 710x500 image che-logo.img

] 800x600 
window/edge: make face/edge [size: 1x1 color: black style: none]

view/options window [no-title no-border]

unview/all
halt


