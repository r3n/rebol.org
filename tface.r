REBOL [
    Title: "TFACE: Scrolling text face"
    Author: "Steven White with help from Carl"
    File: %tface.r
    Date: 3-Nov-2011
    Purpose: {This is a module that can be included in a larger program
    with the command 'do %tface.r' and it will provide a function      
    (TFACE-SHOW-TEXT <text-string-parameter>' that will display a passed
    text string in a scrolling window.  This code was copied from the REBOL
    cookbook and annotated so that the copier could understand it.}
    library: [
        level: 'intermediate
        platform: 'all
        type: [tutorial tool]
        domain: [gui vid]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This module was modified from a scroller demo that was modified from      ]
;; [ an example in the REBOL cookbook.                                         ]
;; [                                                                           ]
;; [ This module provides a function that accepts a big text string and        ]
;; [ displays it in a scrolling face.  It is like a "printing" module that     ]
;; [ "prints" to the screen in a way that can be scrolled.  The formatting     ]
;; [ of the text string is up to the caller.                                   ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is a scroller demo from the REBOL cookbook, with annotations to      ]
;; [ describe some of the obscure points.                                      ]
;; [                                                                           ]
;; [The key understanding is that T1 it an interface object, and its text value] 
;; [can be envisioned as a rectangle of pixels, with the text "displayed" on   ]
;; [it.                                                                        ]
;; [                                                                           ]
;; [Only a part shows through the window. The para/scroll/y value shows the    ]
;; [starting point from which text is displayed. This value starts at zero when] 
;; [the text is displayed at the top, and "increases" in a negative direction  ]
;; [because the text area can be envisioned as a grid with the top left corner ]
;; [being 0x0--thus "down" the text would be in a negative y direction like    ]
;; [the coordinates in algebra. The display window also is a rectangle of      ]
;; [pixels, and displaying in it starts at 0x0.                                ]
;; [                                                                           ]
;; [The size/y value is the vertical size of the text window. The user-data    ] 
;; [value is the vertical size of the text. The (user-data minus size/y)       ]
;; [expression is evaluated first. The result of that calculation represents   ]
;; [a point in the text value somewhere back from the maximum value, that is,  ]
;; [back from the end. That point, back from the end, is back by a distance    ]
;; [equal to the size of the display window. In other words, it is the point   ]
;; [in the text value where, if the text is displayed from that point forward, ]
;; [you will hit the end of the text when you hit the end of the window. In    ]
;; [other words, it is the point where you start to display text when you are  ]
;; [displaying the last page.                                                  ] 
;; [                                                                           ]
;; [The para/scroll/y value is going to vary from zero (the top of the text)   ]
;; [to the result of the above calculation (the last page), as you operate     ]
;; [the scroller. That is why the (user-data minus size/y) result is           ]
;; [multiplied by the data value of the scroller (which is a fraction in       ]
;; [the range of zero to one). Somewhere in that range of zero through         ]
;; [(user-data minus size/y) is where we want to start displaying a window     ]
;; [of text.                                                                   ]
;; [                                                                           ]
;; [The reason for the max function is that it could happen that the text      ]
;; [is SMALLER than the window. In that case, (user-data minus size/y) will    ]
;; [be negative (and will be negated later giving a positive value), and we    ]
;; [don't want that. Instead, we want to display from the top all the time,    ]
;; [and thus want para/scroll/y to be zero.                                    ]
;; [                                                                           ]
;; [We negate the para/scroll/y value because we are going "down" the          ] 
;; [text in a negative y direction.                                            ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ In the functions below, TXT and BAR are internal names to refer to        ]
;; [ the text area and the scroller that get passed to the functions.          ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is the viewing screen with a text area and a scroller to scroll      ]
;; [ through the text area.                                                    ]
;; [---------------------------------------------------------------------------]

TFACE-OUT: center-face layout [
        ;; "across" means that interface objects will be side-by-side,
        ;; and the "return" command will go down.
        across

        h3 "Program Output" 
        return
        
        ;; This makes the scroller tight up next to the text box.
        space 0

        ;; a text box and a scroller right next to it.
        T1: text 700x600 wrap green black font-name font-fixed 
        S1: scroller 16x600 [TFACE-SCROLL T1 S1]
        return

        ;; Go down 5 pixels
        pad 0x5 
        
        ;; Set inter-object spacing to 5 pixels.
        space 5

        ;; Make our operating and debugging buttons.
        button "Close" [TFACE-CLOSE T1 S1]
    ]

;; [---------------------------------------------------------------------------]
;; [ This function is called every time the scroller is moved.                 ]
;; [ In general, it modifies the properties that indicate where the text       ]
;; [ should be displayed from, and the redisplays the text.                    ]
;; [ But how does it do that?                                                  ]
;; [ The para/scroll/y attribute is a number that shows the position in        ]
;; [ in the text that is at the top of the display area.  It varies from       ]
;; [ zero, when the text is shown from the beginning, to some maximum          ]
;; [ value when the and of the text is in the window.                          ]
;; [ What is that maximum value?  It is size of the text minus the size        ]
;; [ of the the display area.  In other words, it is a point back from the     ]
;; [ end equal to the size of the box.  If the text is displayed from that     ]
;; [ point, when you run out of text you will run out of box.                  ]
;; [ The para/scroll/y value becomes a negative value, with an increasing      ]
;; [ absolute value, as we move down through the text.                         ]
;; [ The "data" attribute of the scroller varies from zero, when the           ]
;; [ scroller is at the top, to 1 when the scroller is at the bottom.          ]
;; [ This fractional value is applied to the maximum possible size of          ]
;; [ para/scroll/y to set it to a point from which text will be displayed.     ]
;; [ The "max" function is used to account for the situation where the         ]
;; [ text is smaller than the size of the box.  In that case, the              ]
;; [ calculation of (text size) minus (box size) will be negative, and         ]
;; [ negating that will be positive, which is a value we don't want to         ]
;; [ see for para/scroll/y because it is in the "wrong direction" so to        ]
;; [ speak.                                                                    ]
;; [---------------------------------------------------------------------------] 

TFACE-SCROLL: func [TXT BAR][
        TXT/para/scroll/y: negate BAR/data *
            (max 0 TXT/user-data - TXT/size/y)
        show TXT
    ]

;; [---------------------------------------------------------------------------]
;; [ This is the function used by the caller.  It loads the text area          ]
;; [ with the contents of a passed text wtring, so that we have something      ]
;; [ to scroll through.  Then is displays a window containing the text.        ]
;; [---------------------------------------------------------------------------]
TFACE-SHOW-TEXT: func [TFACE-TEXT-IN][
       
            ;; Load the text area of the screen with the text passed from 
            ;; the caller.                                        
            T1/text: TFACE-TEXT-IN  

            ;; Set para/scroll/y so we display from the top of the text.
            T1/para/scroll/y: 0

            ;; Set the initial scroller position to the top.
            S1/data: 0

            ;; This must be done whenever you load up a test area.
            T1/line-list: none

            ;; Store the "y" size of the text in the user-data attribute.
            T1/user-data: second size-text T1

            ;; Set the size of the thing you grab in the scroller.
            ;; It is the size of the text area divided by the size of the
            ;; text in that area.  In other words, if the size of the
            ;; text in the area gets bigger, the little grabby thing
            ;; has to get smaller. 
            S1/redrag T1/size/y / T1/user-data

            ;; Display the window.
            view TFACE-OUT
    ]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Close"button.                              ]
;; [ Parameters are passed in case of some future need, but at this time       ]
;; [ all the procedure does is close the window.                               ]
;; [---------------------------------------------------------------------------]

TFACE-CLOSE: func [TXT BAR] [
    unview
]

;; [---------------------------------------------------------------------------]
;; [ End of module.                                                            ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ To use this module, remove or comment-out the code from here to the       ]
;; [ the end.  The code below is present just so that if you execute           ]
;; [ this module, it will produce a result so you can see what it does.        ]
;; [ Normally, this would not be a stand-alone program, but would be           ]
;; [ a re-usable function that one would call from a larger program.           ]
;; [---------------------------------------------------------------------------]

DEMO-TEXT: 
#{
789CD55AFF6FDBB612FF5D7F05216078C9603B091EBA07643F0C6D96ED05489A
2276D10D453050166DB395453D928AE3FDF5EFEEF845946CB7E9900C9880A28E
441E8F779F3BDEE7A4D9D5ECFA329BCEB5AA2A592F99158F962DF85C64D9F4FD
CDCDEBBBDFB3D94A1AB656655B09D668F5204B6118671BBE6556B1529AA6829F
7043D6A5DA30B57042EC8A5B36E77556086648BE28278C5D5906E25A23166DC5
164AC344782A443D2EB81125D3A251DA4EB2ECE7DB8BF737976F67AF6757B76F
B35F945E833CEE641BAB49595C62AB5AD0A5B6893293CCAD6257827D5205A904
3FE71C74D0386EE1A459DC9997256B1A037B935A9419EC0E944DB7FEA935362C
60D8069796962D85353897FB3DA2286708D8C2AFC292502F41D6B034A8ABD18C
4BCDD730D2AECEB3AC54ECBB93EB938BDB377FDC5DBEB9BDFEC34D3027163D31
D159F661259C7EB26EDAB87F504E0B5E6E47B4B57429BB6A4DB505D1B35F5E5F
5C8EA7FFBDFD309E5DFE3673F3C76E3E3C8519DE6D64CB8D0431BC6904D7EEF7
8A3F08D85B7E5129237256B4D6AA9AC666F43C6FEB07293639AD1DF73DBDB8BB
7A37CB682FEC63C6E09A495B897396933EE76C0FE0F2EC3ECB7EFC917D1C3FDF
754F027B6EDC70FA291712C0B6D06A1D5D07D028C55A794BEC0CA3CB0BE43513
8F7CDD905369EF6EAF73A53E17F06FC29E7A7981CF77EDD97212B48BB69E5BE9
5DC8F87C2E1A8BF70BB9EC4516AFCB81C0887C00FD00EF04D210D995FC4C8869
408E85A7790749583111E846981CE3112DE8B280934DB9C5E70FD6CF1F085917
BE283D15E8A33CDD06669A262CE0C2FF29AEB97F7E1CBE24B2A5D9C130217617
9723CA38E0DD5A598E3830689C9E9B0508926872B516C1A4AA30F3560390147A
EC89E07E2164A3FF3F8B2D6BEB52686301A8DED18497D919E293238CACD0084C
50FE9398DB11415A02D8091F0FBC6AC53D23891E63023299019340BC7334A886
59BC5E566485463E8ACA78F34594E53E2844993388A9A0A2B44F8FFF27EDF9B9
A44581B775852776C33584CA4A6DD07A5AB5CB559AC729D460083F71D83AD93A
B3C519A213088ED0148F041107BFCD4ACE57CE50E09E68AA8903AD1785F3C0DA
96FD29B48229A2F65E89464EE732EE0E54AB1AE7D05CD69036A070803C4299A3
164B00361C5AA5440762AAF32A1662CEA1ECE8BCC761223BE0FCA59665E26CD5
B04A2C201D295D43880581B8E1D3C7D3F1188F5B4083DAD479277FA3DAAA44E1
7DC5B6896A942CA311294929A501D1DC0A5756544B5168EE7C114A2D7F62F3CA
2817FB3DA8266E0EA8454BF9C9BED49136313D6CE1AB807DC16836F24F11B1E5
ABB607017082844D0F7B993D0527B8538F4B6E390974B8799A1837FFA813B096
35B8D0A972DC53513C365A1804074A15281FBC03458184F4E3E4C0F3B6B24E3E
1D5AD5BCAD28BF62390B4F05A4CD2890FB20F19543978F28E7420840A62DF8FC
7397C4D7FC51AEDBB51B35728B48F06B00626FB0A829C460082D33623B8F47B8
11BA5B60160064007AE60910C5FF5AB059389713D3F5113861573553701F8A45
402D282463D9EDB61833E2CE56699B3021F16C2FD0BDBE611778E46FB806D59D
402AFAA94095366CAB0F132C9871D49E0189F651C32F6EC3F904A551D0A4B4A7
BF18A49420308937145471600F0D5F8ABF703478643F4BD8A5C83E94DF61EF4B
458A2BB8A3B7CE1994A08F423A4C6C7D1C057AC4A4E100B560A11E442F268E7A
06391E61CA45EBA9466808AD44435F172A57B8CD1CEEC1DC5B927C307CBD02D2
EC6C790DF7655361515F382134DDEDDB2B1C2BA9237782518A5D68EE52B6AC7B
0269BF907B693699088C00E7C8F1844D63344B5F6F0F06FA23B7AFE1C14DD1C6
51DA4644BEEBE098402DB2F04EA0E7E3CF5192BCE02180873858171B023EE375
5C251477120F603C53574851BD4D63C4270261C2F4E6F5F5F5E51D8EA98741EF
93B481FC73D0DA945C58573B74E7F7119EA6F438DC053001B201304BF9E09CD0
2823693001EBD89DC09B24C396AAFE97F56E046D502D6381CA8F52EF861C1373
37065E20FA56AE41FF281017A02A8426F7A31A4481AA88B92781E085BCFC2158
CB25D63D7927546860024CA42E0725555527D09788746A1C2AAEBE09F0FF1CC6
77E5E01C82030E7251A9CD88CD7E9B11CADEBCBE23EB1101AAE118AFF95A10CD
D362E1BA5FBD3D0FEA6187A3240952B02C0562CA607FCEE7F8B8FEE49F68C440
9BA94694628340F3FD074790071649E835665DFA3D3062479FE2D4BF94725FC2
88AE0978FB7E76CEE602713126660CB945B5D637E8F08295730E9B33C0A6D682
D721EF0EB8B489E9CFC8528C8BED18FF1FA562028C722D6CAB217EE76ABD8E89
7309B90DA27A1267B845B3F8F7EADF2C7FE77BA4B7AD6D5A9BB3F8D0898C7FA6
CBBAAE17FF2CCC00C472B9B2D80AAAA933AD3A3F15EAB153C334B8C9D3ACB793
386E88044D42834420FD71DAECECDCCDFACFE9E9E30FA7A76CA379039C12F155
54548EABDA8E3132DDAF0510B5B2DBC914E6C765CE7E20111F7D27F7E2EEF6FA
1AFB1CD3B3FBA14952BD7F753666AF7CEF223E6B78098CEF15DB6BC0A9F0EE1E
3B5793497C2918240DEDF5AAB7EE0D589F618FDB5573A199588AA25D2EF12FD7
434EA4F8A672E831FB8D5E5CDF4E2FD37DBE6C32488B0D6A149640F504D4BE78
CEF6C1448DD5076A460EAE2E452F450DBBAF884AF836B227141AED62DD9F145B
251054EB09D1A09A0902CD2AB412FA046914E34C8BD89FED28EE9ECB0B7C0361
BF822AB154821ABAA5EB7AFFB46FCA97AF68C3E191CEADD5125C2B5CFD5CB7EB
229C265DFFC8D54969551D04A68CD1F3DDA4F933E4A33EDB5E21BBD468DBAE63
1F0462F933724C2D659CA84BDD555885008CD600D311257AEC8106F23DDC72E4
B14E201F105069C21E42E5F9351B7EF0DBA4EDF628FF4FA1B9BED30D71456BA4
E97D8161E01E43EDE5EDA131D16F18240291431FEC0D602605C95F27F48940DF
A188FC59B7A0586BE33BC448F393076E9D27E33096966A4D6F4062A9E89B29BE
21CE7C2331BC53886F7A0AA32A44B11F0E54752328FE5D7A1D1EFC87DD9C6898
23E1C893101932CF14C503E0EE084CF352DA1E05179D75D3F68C2A14E4DDF54E
FDE6F3A1E7BBE0EBD81400D645CCD93B3F401482D8C8A2EAD03014B8C3468C20
3207BFF8818671283092AEF1D086B07CDE4BDBAD2F4FF91C58A26B197990DAD6
351EBA1C3BD0306683350F456F7D08E03DFED8F74827306D77C0F423F7520A84
1DFB903DC282C2DDE8714940E6287DFB1604BA87E19D77981278E68825AD0A9F
9810A01DC954438146D07BB481730205936902CB375AC1CA9159E59018777984
6904FF86179F5FB89EBF0466F14538954FE7841BA8348033015FBAEF2A60B873
D2B3C87920AD30EE84FA04DF67A9AE47D8A938A5795D2B614C7FFB5642572DE1
890B0FFE866AC6539B181D141ABEE1155F83C29152295E761583E33B43A0C4B7
2073A854A9910D80E6910E52B4D2DBD611C182E029DC8703787EDAD530A5760C
CA274FF756B74ECE0BD335B270552EEBD047EDE5D817E04A83EF252252E836DE
195FBDEDF0D28302E8720DF61C98B34BED915DC601DE8694FC86A2BEED8DF5AE
36B3B3135CE39CF5548741C385A662D82F02376EC4FEEE53FA0A65B8DC206E4E
F7AEE4BE6181A4852F65C29914CBC0C0CC54D3973E3DA3D8DB27D4513EFC36A7
A08CE74A32ACDDA97A408423F1431A673C2D1F2A5EC95A8C2B69C0583508D8D5
DB2A7F6CE4DB7CB706F359B20BFF78AEEFAC14C700BF838A04D23C4A1B9398D9
D94183F596A478C2AD013B2EC2E2B1493E14D17D08B5A337C1B394F869484C0E
C9A01D40C6BD727BB08E5C3C5D8A700AD00754855C2E8576C76925AD85620277
474AE1874A03212B4E0D2DEC4AF9137BC286780146A4F9128DEEDF2F9EF41CB0
63EB9FC30B9DAE62EF0DC136118B8D94BF93916A611A808A09D1E189B2A3CD5F
490E5EE03B084D48C5421BEA0DFABC036EC02A063D454C67D15AFCCAA316A21C
212B67E11339E2C03D81A10B0D74762E4A9CE5A824906754EE69BC2711F8AC36
CC920EC2F0A8F7DD2EF7D91A7E7196FD1FAC687A5C02290000
}

TFACE-SHOW-TEXT decompress DEMO-TEXT
