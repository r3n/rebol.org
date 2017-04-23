REBOL [
    title: "Playing Card Images"
    date: 13-Jan-2010
    file: %playing-cards.r
    author:  Nick Antonaccio
    purpose: {
        A data block of playing card images.  Use the following code to view:

        do %playing-cards.r
        gui: [size 670x510 backdrop 0.150.0 across ]
        foreach [card label num color pos] cards [
        append gui compose [
            at (pos) image load to-binary decompress (card)
        ]
        view layout gui

        Taken from the tutorial at http://re-bol.com
    }
]

cards:  [
    64#{
    eJzt1z0WwiAMAODoc1Wu0OfkOVycvIOncOZoHTwQk2sMBAehL8mzqTqYFlH6Pegj
    2J/j+b6FElcqByonKhcqK9iU9kjHbzsurxHLDjFylTf6Mo4j1bkFyw6IXOUtN9HH
    vu2qi/UwoBZpCKpBcDDBxyTwMZCChyEBquH8iSanK2iGh5NMyp3AfPMccb4x5QIM
    ufAxkECfQwB9Dn0MHQ1q3t3WfB3xb75joGvqTUmjaEiEVrUG8rJqGpufqd4jPmGQ
    iXg+1FHeUDSmOUzt2SxonHI6FX/zW6bP4luGL/iiSf0fajFTb4iymVjlyxnLPGth
    M/VBaLapD2aK6S6AvZm44vSmDCcbVFJqNk5rnh/sPYwSJmN5J7K8Wz0AAI/VC/YN
    AAA=
    } "ace of clubs" 1 "black" 20x20
    64#{
    eJztl7FRxTAMhgVHC14hR8UcNFTswBTUGS0FA6miNbKd49nSn0g5KC1Hzy/yF1vy
    +SLl9f37kap8ir6Ivol+iN7RQ7WvMv711HSUtV60rq0rTf5s2yZ9seR6Uc6tK62Y
    5OdZT2XkflmyJ7wkl8n0d4ZrDOeMuJxcJnOA8f2pw67PkBkt5c4wNdpxIsPUaDuf
    UeyaQbErBu7h6A9kKJWmbXoWojEyw+xHL92e8RkCexhhxB/uI0OM3HNnIyZ4fjpL
    i/J8D48YxbuMjCb/zB+cw8vMvuJkJjOZyUzmCsP0L0x74Z8yDLKsw7Dl7Tww67WE
    eHsG5M89sf6uxGY1xejcfYnhPp8fMJ1EapKj2macG+4hqq4sk9lnks+wKhqRP6D6
    tEzkrIYKZHYZijA2WsOAaIE/joSYyDdR5NvqB5uyj432DQAA
    } "2 of clubs" 2 "black" 100x20
    64#{
    eJztlzF2wyAMhpW+ri1X8OuUc3TJ1Dv0FJ19NA89kKasREDei4V+R4obv3QImNiR
    P7AEQsDn1/GNavqRspdykPItZUevVT7K+9/3VnQa60Xj2G4ly8M0TXIvklwvyrnd
    Si4i+fnomzLpZRiyl3hILpPp74yok+7BcGKXyeTrIw25DNd+N4ySEGRqTaWOZaq1
    NzLI9o6Bfaj1gXZRKrmX9a0QqZYsc3a9dKnjM/VxBSP68NwyxMh/nsmICfrPTNKs
    vN6HS0zHu4y8TQGfD/hzhDl/8ck8hOF+5rixBUq0P0OmnxeI6efXlkwkbkTiT6wP
    jTYbMncaU5SezP9i2Iz0KqYF/KsMg9niMNAP+3agH7YF8VIHxha1ni/EFrVWL8SE
    CMPz9Xzb2AJ2RYYBuyvLZHaZfDOD9WFdE44pqGm/5SBtLLx9dmoHEo+x1q5i3BRi
    ImeiyNnqBBVpT9z2DQAA
    } "3 of clubs" 3 "black" 180x20
    64#{
    eJztlz1WwzAMgAWPFXyFPCbOwcLEHTgFc46WgQNpYhWSVce/WCp0tB3Xrvw1kiyn
    cl7fvx8hlk9uL9zeuH1wu4OHKN95/utJW132eMG+ayeVB8dxcC8SihcQaSdVRPzx
    3N6qK/fbRlbBLZgMwf8ZDA4GPExwMOCwhwGTYYtKphxHY0UVVEzUffJxomMA8hcE
    /UG7Pn9loFnDgT0tA0FqwqV2/qJuqFNtoTkPCvmFhzamYwaqmHoYliNme0LQ6Xpv
    QEDKfpEEk8S9MI+p6pyvYc/0xcOQmG7vQ9dzYTMXjYtZzGIWs5hrGISbMPqHP2Ww
    yLUmM8rv3X36c0u2JybEYa7MfqWcN8i5NTPO3VcxmsjmDBXyZM/wTGKcbfDU8Nsa
    nszorJV1Ad2AweSOFdPGxzamCOTZhzaD812YYmoznmfHYbNZXIznncjzbvUDyCYa
    mfYNAAA=
    } "4 of clubs" 4 "black" 260x20
    64#{
    eJztlzF2wyAMhtW+rg1X8OvUc3Tp1Dv0FJ19NA85kKauVEIGDFKAuM5rhwgTiPwF
    fsBG5O3j+xmCfVF+pfxO+ZPyAzwF/0z3zyfJpc3hgnmWghNVlmWhkj0+XOC9FJzY
    RR8vdVPKHqfJ9wwn12U8/J4hOe4IhhQfwuAePds6grgqPwJsG3AWA5C/IMgPoNK8
    m6k0W3qCLzPgOEWckxovygOVut30nCsb/8rDOk0dJjiuYsiPmPU4J7cLhmro87i8
    Yyk8vM6aSp/tOdSMthHGs/SBZ7XSuZNZe7wzf8OAcmkGofbUTHySW0x6Iy4z+c26
    PVPtGDZT7jw2MzSHWKu5IXPQmlp2Z/4Xo1dxFyMbfpNB/UJdZqz4rtoxzi1JTwiI
    ZqzM44oxz4i5JWPH7qsYCWRtxm/8UY95JmmfbeJoGnOYzljWWSsxfC47gPEr09IT
    meaa6l2pNGGaiGju2CgzpqfLdG2I6Sqm6VR/05Sd4Acse9Xu9g0AAA==
    } "5 of clubs" 5 "black" 340x20
    64#{
    eJztlj1WwzAMgAWPFXyFPCbOwcLEHTgFc46WgQNpYjWS5dS/SHo07WOoHDep/MWS
    bVnO6/v3IyT5pPpC9Y3qB9U7eEj6ldq/nqS2sqYL1lVuXOhh2za6syamC2KUGxdW
    0c9z39Ug98sSLcElmEyE8xnkdpMBhy0CTAZNhmyZDPRM/Ywgqs5WGkPpIMwYgPIH
    QV44jOl8nvnTzTMELjvOZRgvSkCdzFaWy0OlzzzkaTIYaGLDw5AesfgTgjS3MQYB
    YxlXDOwKD89YU7Gpz+HIjOJhIrvuiNXOzz8y2eKNuTIz24NDP5Pc0uln8dwx833R
    MvP9dRnGkzc8+cc3h7N8eCnmoDX9XW7M/2Lq9TuDkYSvMlhvJYtR4rD0o8ShHIhG
    btnPPC235BNYzQkeRg6yq+SWfTTaXt571XJC+i47kFH9yYy6pvU7MxFGRcSWIfan
    SzPPGhM9jMMfmzFHdYo4XX4AibGWIfYNAAA=
    }  "6 of clubs" 6 "black" 420x20
    64#{
    eJztlzF2wyAMQNW+ri1X8OvUc2Tp1Dv0FJ19NA85kKauVAJiQMigpHamCBOI+AaB
    QDyfvn5fIcgP5Q/Kn5S/KT/BS9DP1H5+i7mWOTwwz7HgRJVlWahkjQ8PeB8LTqyi
    n3fZVSPP0+RHgpMbMh7+z5A5bhfG45BBN7bHwngQTFlHUBkEKPjUIBiA/AchvcAG
    HcCo9tQMOE4XnFMzX4wbah22GDlXCn3iIS3TgAmKqxjSI2Z7nIvNIOaFPs/LOzaF
    p+f6Po1j9tewZVqxMJ5NH+9nuQ9vZNKID+bOjHoGZT9abKn12n4WjH4uakY/X8cw
    lrhhiT+2NVTj4UHMFT6NrbpPc3dSI5na4zpTe1xlhKcOZYTHdab2uM7UK7zBoLRm
    X6a2UbenZlSfxoDfETrl7cJuM519mPvpxJZ4IQ5iy+XO68WWdAN3Y4KFiRfZfWIL
    rD1treHKdGPCXgy6sT2J6d4XWLRpEt7t7jAzA6PBmGlPy03MUEyM5ZvI8m31B3Qa
    a6P2DQAA
    } "7 of clubs" 7 "black" 500x20
    64#{
    eJzVlz12wyAMx9W+rC1X8MuUc3Tp1Dv0FJ19NA85kKasRBIkNRhLcmK7r8KECP8e
    SPD318fX5Q3EfqieqH5S/ab6Agfp7+n8+T3V0no5oO9Tw4X+DMNALfdEOSDG1HDh
    Lvo51kNN7LXromXYBZOJ8DyDkoPOUMjBZCLuxtQxIxQnmzHDeMzsVHOh7GflrMY4
    4inzQuDScn6ZpKfQcO4MZtFVjgxmMDLYEoa9MIonOyVDM4dRXsnh9IK+p2lOfQ2n
    zNQ8TOTQHTqMjuvLZvKMi5iW5mumpbGKaWp1I8YRz7aa34SZ0XydV0Pzk/VZaU/n
    7Y8YT8x27p41dOzFztowterS/H+8ln16njUvU0zyOJNu+CqD4y22GGV97oy2PumB
    aGj+9nTVNM+epVUPg7Cb5hFu73DzGsujqlqV97L1GE886p6irp5irl2YIqE244nZ
    NBfj+SbyfFtdAaNeJZ72DQAA
    } "8 of clubs" 8 "black" 580x20
    64#{
    eJzVljtyxCAMhpVM2oQreFLtOdKkyh1yitQ+moscSFVaViDMUyB2vE4msNgr/I0R
    4kf47ePnGXz5onah9k7tk9oDPPn+lZ5/v3Ary+p/sK58c5X+bNtGd9dj/Q+s5Zur
    rosur/WrmvK4LFYruBiVsXCcQT+HMUMuG5Wx+GcMQvYwGLXPkL8zGFDOHb1dGXxR
    GKMzdZwlf2zBILgqGYlhPRnBiAwG0VWGf5nC+JfdwjjLZP4Eo2RoZJPNiw03PWVN
    ecxxDFumLTOMda6rOixieIAJI97ESJqvGVFjJSNq9SRmwp9zNX8KE2WOYTuY1p+k
    eRZptgGaNQWDO9WLIY2EGDdfy6TA1J3nMFgERvaZbFe7PmPKkp25x1TBIRBjuIef
    s7+4FnEZHaOtO3Iba4NXpKMNVatTmv+Pe3kuR3XLLINwF4YT/pBBQeVdZhCfyIzi
    wweieFamee2nq3DmFoyWx2YYhOl8eFTzGD+H+hqLmWKoVX9RGFQZjN+LfX/2WQ7X
    lMfql99m6rwuMDhW/B33sjKOTYoblytIR+ey9g0AAA==
    } "9 of clubs" 9 "black" 20x40
    64#{
    eJzFl01WhDAMgKPPrfYKPFeew40r7+ApXHM0FnOgrNzWtKG/CTSjDFOmdFK+F0IS
    0vL++fMMsX1Tf6P+Qf2L+gM8xfmZrl9euLdtjj+YZx7CQX+WZaExzPj4A+95CEeY
    otNrr0q0x2nyo4aTGzIe/s+w7bsMArgh4/B+DEJjrcpArZOFnsEYz1Y4jOl9qNjT
    xQIhHJpQGM4npwiZwTXpOiEqGzBR2TVMkFyeKULD0J0dRgugCOHxnIzp+jwI+Z7S
    h5AGpzHZNU14NAarqPlguhMMxdD1NnYMVl7aYqCNVNJ9FROdlhgEleFLgJgDJRhO
    T3DomYVNZp3ZZzCdNUbN+Za5bc7fhClpLgSZ81IY1DHBjH240+7EWGweP7vFh4ZY
    nJwbw1w15bzJh5Z30P4u79cES20x1ajimD/Ww0pvX3s1pq/hieGCX2nyvmew1S6s
    aRi5NklGrnGVPXFBVNfK8lxpdVXW3IYZ5aqFWc04IedpP5X2Q5s5TzsumeZdrsZd
    2YHMwB5mdupYZjbb6YxMc8HgoNgftl5Yvoks31a/90iSufYNAAA=
    } "10 of clubs" 10 "black" 100x40
    64#{
    eJzNVzuO2zAQnQRpZoksr7BIlXOkSZU75BSpfQS2hAtvvRVbg0W2yIGmCrAJEObN
    jLQrUVTWQBZIaMuS6afHNx/N0B8+fX9LNr7geI/jI47POF7RG5s/4Pdv136sx8He
    dDj4SV+4uL+/x1lnmr2pNT/pS6fw8a6n2ozXNzftuSE38VlMo7/HiP7+AphGF+j5
    R5idMMQlZmZjzswp5ZTJpy22Txi9lOQYTjojPUYsD5iYKFG2eY6eJY8YW75R9nF1
    i7tyNEf3GJnlAsN5MqjHlFJs/k7hPcb1PGFiC1XXWmAo6sswQkIB16Go5ic9kw7D
    KDpgXnmWmNmxvhY4FFOigHMfQ8Zjc7uYYHpWGOgRtYwUA2MM0/FgUV1YKrntZhe+
    x7iNaSikPPIzFLOrxd6HOAJsN2wxrpUP/QTHUEka/jrxLPLQP08koXImygwtHSaY
    oHwKsAOYnCkl+GGNgTH0cFZMQ4odz8ykS68wFX441lMoAleJ8fS5YZh6/Kpug0Od
    h9qQh5SouR6zvcdk6KkFtk16wkBPzieiyrMey7EhTy1w5PFMzHHEo3oQ0oQHMetD
    NuIxu2plDlwTnNn7uTI8pzxKVDjDO5tY1HBOrqdW3FBTi31MNZI5WboGpBB4YosD
    TM16qw3wiGzXIiVqcg4UWPXEuOWJlCECQUcNquV4HvHECCLkJp4CkOJywAO18C4e
    TJgdwDPyDx4vKC2kmCYmerAWFkuqS6Ok6w7WEnmoUKuaIet4TgO7EG6E0m1HKcT1
    iAc3Tz6kxsdzHvBYilINVga0vm4xluqIrfIg3VKug7UsRZEYxdINdXzkQzgxIMGU
    B+m28SFVTU44CIkKIk/bDoP8xtMC78IDrmeLoRolJUvRB+SYP0ZbHmHWVJeY9njC
    xAMvoSaO9cjEo1dhxy6U3kmPEo15EGrXk5QIelA+pOMpyGTl0WIIcdn6aej93FAG
    1I0almgQ7bnrmEot6LFwM0pTnGvxjLEyDdtLtYZfKnk1X2J+XU88AV0FTY7q4+Zg
    xnjbgDzrfdoIUYi9wzxirP2oK9COZGqWc6daYcgxzZvuvEWJGx7Zx3hbVZfuY6w9
    W2iC9Xhvlt7JVxjlQevSxLemO+0IVj5UnqvbyXZtqJ0Pp9xoP5YY36GsMLqNkdt5
    X7PF6ByjzMkd+/5Ig77GWCtj65XIDWQHcez1IJN9i4eaYNs1fGxjKm6kMPZ8isk8
    pc9Cs8T9PeQC88fxP2KIXgbz3LgIc8l/okv+W/0GSJQzj/YNAAA=
    } "jack of clubs" 11 "black" 180x40
    64#{
    eJzNVzuS5DYMhV1OUCwvrzDlaM/hZCPfwadwPEdgylKgKyBVMZnAB0K0VZ2Yfg9S
    94hU7fYEGyx71B/2mwfgAQTUf/719XeJ9Q+uz7i+4Pob1y/yW+y/4vt/P+3XuF7j
    T15f9xc+8Obt7Q2v3OnxJ73vL3xwC09/zFSX9evLS3+2/CU/xXT5ARgB4AnGI8In
    mNx/Wsw30pDPmBObe865aOO6YI63LkDtGJsxHnVAF6QDYwk0+axhDpfybqvT1pKa
    YfuUixMGz56r1EaMy7sTZww/3ojJnf70qz9eJAswcAiYTqIHht/wAzBd/EaH8uSP
    76L1rtIdjwJjs893YXdMD6fpM9S6YGiKGBgrKcd2njFaSkRPY8lGDPxxXlVLRNer
    aJl48M80rEVjT2FMQp8859SrFIK9ZBjj9n+fZg1JI4bdJDB20XDXWMuyJcC2TWDs
    2D7xUJuatVWzbSmUKE8YR0CqRWRptS4bAyoyYeBKVoVsurS2CbzD88xTa/FiKE8V
    ZWypQcMBA2mYvdSoY2FNm7GCThhphiy5iZn7UiB5alrrxNNYP6YgIo+nZHXG0Eew
    aMEzdETB6wUDTUFhatIaEYCklCZbbLhJqoEPC0k3rInHnQoCY5Rvg5hy5RFZb1oX
    kDVAEslmHiRiLUYMclqpE0S8xFWrNF2QdEmlETrrDJpeWtLg0WQICq8zT72B3hbQ
    2AYFI8oRo1oLDoItiUXRaLnobcwXgsIhZ+CksKZrL+uIYVB+A09DmqCfqGcwjzzI
    jZAHFmmyqftaR58R1Nr55WFLlFtjHeqNTuL7QlQBD/h0rHk0AMQDfQzSUULRy9lR
    CdEaj6AllIUheXnEyCH+QumAQfkg8yMm7Unk+SJPsQhq9EcsigHlk/AW7nYWUJ54
    WEA16iuxwqqKX3iwqpDMWIWJbe/Ck7QiTVHvstF0nv3hQeGJkAgeaJ6kWR+o3BJO
    MM4fwkMlS0YZzpg46nGOkTXj/GljrfLUGRs2+wHQaA+aJ5+RqsbGyr7CIAtbTZ9y
    ofTROSFrzknRr1jNU61SV2Wba3iHRKANTzxZdM2+RLvc2MnzPusGDM6O64aIkraC
    Tt737TvGgxREnviJ/afmfSo+MGz3RK4d/+50jXMlDNwxMTY48GrXGJmk2SfMAxPj
    J0ulMe5wPB2TasQIS5AYTsL6mHgjDxoAjHEAOryaMTFWs7etQCJi6NWEifEcGBrb
    MfdJPmJQiTCGuxoP/Y47gklDVDoOOd3bh65MuSBpokPHrOv3O5R3DIjgTzj9mJ4T
    5vC5waGVvbxfMXE7hWGBzg0M77Su/uy3ZRwSwDAF/d3RAZMODBK32xrrZ+f5xj3k
    GfPd9RNiRJ5i+j3E72Gerg9hPvKb6CO/rf4HC5MFI/YNAAA=
    } "queen of clubs" 12 "black" 260x40
    64#{
    eJytlz2S2zAMhZFMGg4niyvspMo50qTKHXKK1D4CW46LvQJbjZotciBUmUkT5j1Q
    ki1RXjmbpS3/iJ+fQAAE5C/ffn0UHz9wfMbxFcd3HO/kg58/Yf7nQzvW4+RPOZ3a
    Gx/48Pz8jHeeqf6UWtsbHzyFl09bqW68f3ysR8Me9ZCp8v+MiIm+AeMeOGJMjxl3
    7BFj/6RzIwx6bQ9f4ziOpT1mEb1eF18NsxL54DefUNM1U6OEzJHcVGaFXvtQXSin
    yQo3UDeM/8oWSxemTba3QCEw5udeZMzmC0/20IVrBsMNwGLUzcAH0Y7hnOhk2Q2G
    +qqz8QphO2L89VUMFqK0h+bXjuHSjQFSmw7G6xJ3MjrrtA2sLYx67R/8RA98KEF4
    MXWT5+TcxCLkRGvasFvMIHWC7CYzZgmYTm647jEy5IzrhZDDFKyegdA5ea6mKBZL
    3ssfG84DEzpJERmDp/X2WhWnkfVACmR+Y0jHQCgnSMTYZHIW3TJiMGjEPDZYeeLA
    MrdMDTCoRJhzFt9nPZM0wiBs5xKK/HZ7eh2sHj/lXg6SJOzr2DBAhxdjwXhKsXQ6
    MHpM1IH/sA9DGsc1Q+9z8TAnOq6g1zpwF7IHvg1YWchk5p1/YZhusIc6Zeo68PlG
    BzuU9lyK3I6OUifjPGMZku9k6+3BvLZCFXKxttdXOq0DTuM8JBbUjU5mtXCtgrqa
    B+pYr6MhWUAKlYCQJuvtGREcMEI3Qwf24FfreEWc57VCgpuD20Phrc5T8kuWiLiG
    oVQEeRN3zwVJgXXev2ing9PMKhNkItoG9pHu63BrJc/WMMK6XkeZ5cj5GAuS4szF
    bxhtOpxn+nDxtWOM9tgohtTIyOhMV2wYxNJlkMy+a0YIdUxFSkEmTlvrDKGemVqT
    FxeWmVx2GM9YY5GiK85D3mVAVNY69AgLN5naaiareb7B4CuLLxuBhWv/sExfqrbO
    l5Trtf95aDriIOLUmoteMd42Vp3EewvFF2ZqeHM3WnR6ZulqbLSvYrytHjC+ZZdu
    7a1R9pml6/MmoGf2fGiyZub88TJhjZGXmKV0eEJd1u53IWvG76Wqbpmmb7nlqt+T
    1Uu8qiwxrbHdtU33dhfGdMkfm+7+xla/L8xVkduMhTm+HVV31yFzh44eCU3rOmDc
    h2/AHBhzL3PPf6J7/lv9Bas8HtD2DQAA
    } "king of clubs" 13 "black" 340x40
    64#{
    eJztl7EOAiEMhtG4qq9wcfI5XJx8B5/Cmddg4lVu8IGcTDphCy7ShP7x0MR45Xpc
    uC9taQmBw+m+dlkurHvWI+uZdeFWedzz/+um6Kv4/DjvSyeNP8Zx5F5GUn5cSqWT
    JkP82tWmlCyHIVlyG7Ymk1wHJvZhKPRhAsUeDBPBZEIwGUZCtJjsrskQG2Fnk5mn
    9GAIYDgiu6ZmDhOQw24MEg8yLyg/aWb+hYk2k7c3g5EVbDBlW2ozZVuazIir2lnN
    ZKQy9I6dXjFD+UHyDNULqbuWmfk9hgBGLSrNkFqcmtGL/HMMEg8yLyg/lmAMR0zt
    iDBGTontyTOjNy7FYLWQM6DBULRrgTBQvXrV9Gt1R+5EyN3qAeRtVIj2DQAA
    } "ace of diamonds" 1 "red" 420x40
    64#{
    eJztlzFuwzAMRZUia9orGJlyjiyZeoecorOvoUlX8ZADZQrASaHoFpHIH1BAWqCD
    aNMylGfqm1JA+fh52wWxL/YD+4n9zL4JW+mf+ffL++qtzXKGeV6bcvDNsizclp4s
    Z8h5bcpRuviy16GMvU1T9uw6fbhMDq8zFKPLxBiTy2TqYHw9PFKHZsiQCWQZCd8E
    Moxk5PFARu8uGakY8O4cpg4Ec9jDFKRVbTRLmEa1ZWycZBmlB+ZHM3BttEOVR7w8
    Y6adryeMmnd/reJ515Z+5f81mMEMZjCD+edM8hmKPqNqNQGGVK3W1R0wpKs7YOw2
    wejRtfubIV2IAdPk58/2JD+aq84nerqYsi+rB0uASTUD86znHc2X2VlqRBhvAUl+
    bHjLkMvEHsZmxDAgI0CPY11MzzdRz7fVHVe+QnD2DQAA
    } "2 of diamonds" 2 "red" 500x40
    64#{
    eJztlzFuwzAMRdWia9srGJ1yjiyZeoeeorOvoUlX8dADZQrASaHkRSS/QaKJgaII
    bUWJ8kxRFEnbx8/La+ryze3A7cTti9tTeunjM///87Y2KXM/0zyvXTv4y7Is3LeR
    2s9U69q1ow3xx4dWZeR5mqon5+ndZWq6nck5l3swVMhlavbtYUUuQzkjhsRUmOGF
    SHMs07U7TPfIwIC1s5pREfShYuC6GiKstvZ0NcJqYLPRUyyj7OHfPgNjQ07VLvH8
    jBm5XxuM2Hdsj5k6kDvlLvn1YP48QwFGZ6BbNzBjU9nNr98yu9WNHW2O+Cfk58h+
    hfbdyoP5n0zxGTKBZxkVwCjGSCUCilXFwJhXDM4dcyMGOUj6RozydNS9c20h9VCE
    7BEXbjH9YXKYrFimCmartowMri0ktcPaArTbuQIxJs3BTPYUaR/ewLgSYiLvRJF3
    qyuqXC8m9g0AAA==
    } "3 of diamonds" 3 "red" 580x40
    64#{
    eJztlzFOxTAMQPMR64crVEycg+VP3IFTMPcannyVDhyICamTv5OGNnb9ayPEgBS3
    /qnT913XjuT05fXrnIq8sz6zXljfWE/pvsyPfP/jYVEpYznTOC5DPvhimiYe8wyV
    MxEtQz7yFP88aVc7uRsG8uRzeHQZSr9nZgwwEGEwwEAgHnbkMhxRy2B7F+ujQDDl
    HaSxYwAaR9VQ+cn/IW0oJrtFbQD8lCnhgWVsTJn9diQM3w+68ZQ8eQyIetn5ieTZ
    r9eOMequ47Fl9tehys9t6UxnOtOZzvxvBn1G9KQbzNrbhD9smbVHWj1OM1avVIzZ
    c1U8du+W73XINNuqP9yTVGau26GjeCIM+fmpjJfn6mhDjHqt26pNUDLkLKBcL/SZ
    GXyGIoy3oJv8HDOOhJjIN1Hk2+oKvccYTPYNAAA=
    } "4 of diamonds" 4 "red" 20x60
    64#{
    eJztlztSxDAMQA1DC1whQ8U5tqHiDpyCOtdQ5auk2ANtxYwr4Q/xWrJiadhQLLNK
    HK+cN7IseW3n8P716LJ8xvIay1ssH7HcuYfcPsf3x6dSqMz5dvNcqnTFH8uyxDq1
    YL4dYqnSlZri44Wb6uR+mlCT0/SsMuguZwDA78Eghl2Y8Bt/fPu2KJAeDROAdCIy
    ySxXgPoc3TsbWhXGADSGVoX5LDIhmatMsl47I8qZya2rIaLodjxq/uQ4aQwdlxif
    XCtx5oyUL85IeUfLXKXj2hC/y//rxvwLJhiYdlZvMAFAZQA6Q5wJ7WJwAUMWDJkp
    CwYMGYud3Xy2xMcUZ0u+THnv5cZcH+N1JnSTqmfq5CT2fMvUPVLa4zgj7ZWMEfdc
    5o+8d9NxDZkyhL8+k5h9rkevEeNRjc/KjOKMPyfFUb4qY8n7pmTGq4xCmBmbPyqj
    9WRkLN9Elm+rb8X3AoD2DQAA
    } "5 of diamonds" 5 "red" 100x60
    64#{
    eJztl7FSwzAMQF2uK/ALOSYmPoKFiX/gK5jzG578Kxn6QUzceRKyVV8rxZbEteW4
    XpW4jpwXy5YlN3l9/74PVT6xPGN5w/KBZRO2tX3G+7sHKlzmeoZ5pqoceLEsC9al
    BeoZAKgqR2nCnyfZ1Urupgks+ZoeTQbC6UyOycFEhy3syGSyyaAtk4mCybwHYoSt
    Mk0QmmDqNEFogqmmQWicwQePOmoaH3Of4X4ujQdjTGtMZq2kRcEM+0lgjQcvbIav
    Rdc/hbX8LJjuekmmt+7giB8+r5Gks+TXjfm/TDd+BNOLQ8F041kw3bzgzCC/fs1c
    et+4xJg9/nH52bNernUfyo25TibZTI420yJXibHcMkCJ1cZoMd8YNXcO/8DjHMxx
    1brO07Tv/A/2ltzehpTx0BMGU97LLP8Qo+4te0bdWxqj7S18IB0hRkXIliGF0S0d
    +VlnwMM4xmMznm+iF8e31Q9Nm/Jv9g0AAA==
    } "6 of diamonds" 6 "red" 180x60
    64#{
    eJztlzF2wyAMQGlf16ZX8MuUc3TplDvkFJ19DSau4qEHytT3mKiAEBAIpLhOXofK
    JgT5W8hCyM/vx+9XFeQT2gHaB7QTtCf1EvQzXP/axYZlDqea59j5A/4sywK917hw
    Kudi5w+vgp99baqR52lynJynN5Zx6veM1VpvwhjHMkDwPksYmKxkLL5IMtqgSQzB
    wGOWZtJIlwxEojB0HZWMj1Y2lEe3Ml6ZJ0OjxFikjSNdMV07hvfHCnz21pj4VPlD
    xrnOMWq9aoZcd+wPLei5emI22V//zN9lyPypGLJuYKZTN5ygbjhBTbiVuXfduIfP
    kviI4ixZL9G6kyjN4ClJBrtOMzgEJINDuZ7BS0syOCnW29nMZ0l8RHHurBdWkutu
    G+Mtk5wc5Ji9vu3RnChXEzPK+cQM905+A/f3oNWNtt2n5mL8EbVF4o+YYWqLTrdm
    pKktNt4xrC0XZlhbLDLQSogPk2RCRnOThdxot8IahhURI/kmknxb/QDHNOZR9g0A
    AA==
    } "7 of diamonds" 7 "red" 260x60
    64#{
    eJztlz12wyAMgGlf17RX8OvUc2Tp1Dv0FJ19DSZfxUMP1CnvMakCosYSMlJ+nKly
    CAZ/FkII2d5/HHahyBeWNyzvWD6xPISn0j/i9e/nWriM5RfGsVb5wJN5nrHOPVB+
    AaBW+chd+PcqVTXyOAxgyc/wYjIQrmdSjCYTY5xMBtLdGGlz4lerHmEztpajTMpY
    RS2IlmCKWhAtzuCNC0XU4vboDJ9X7jwNxlrElBv/FPGWqWcCyx48sRnuZ9U/mbX8
    LBh1vSSjrTs4YpXPa0Ud88+KWVkahk9PZ7ibVIa7+3KGL7/K8MC5XM/NbPb4x+Xn
    /nolrRKMFoeCUeNZMOq+4MzK/jqbcecN6tXzhgiK83LLFvPy+NC1Fp41dcWGqk5l
    /nPC1czWOYF3JolkJjXKW4aMVJ9NlUk02U4cEtOLZ2K6++L0BF7fXyk2ve0enI7K
    N30nIXuiaU+9w2Dye5nln8p088aR6eYNUttZdy06uSzGugvT7qiG8dhsiovxfBN5
    vq1+ATh8w+n2DQAA
    } "8 of diamonds" 8 "red" 340x60
    64#{
    eJzdlztSxDAMQANDC1whQ8U5aKi4A6egzjVc+SopOBAVM6qEP3ESfWx5w+4ygxLH
    K+dFliXFO3l5+74fknyE9hzaa2jvod0Md2l8Cvc/H3KjMqVzmKbcxSP8mOc59HEE
    0zkg5i4ecShcnrgpIbfjiJZ8jY8mg8PvGXDOZJxz3mQQ/owBcjdr3Oeg7S34hdmv
    PYUCmZYuG5PMItPSZWXCgztDRaNx1hkkTBzcJiNaYdKDqyGqmXa87Q90+eyt+ETW
    ijNj1HxxRss7dtQqXVdN/FneryOMui7GaPFhjBpnxqj5okwl7yczl67nS/i8RgSI
    RpkS2bVIUTLsppovNomed8X14wwNpcrQJBy3Y/kDhGnVfJmqVfO0Yww10K556pbO
    SO1/1LzUTttbevaorr2uKudkvM0Ar1+FKdFqrAuc3AWQxacwrTgXppmv7R+4nndw
    YlTWhl+MX6GeoctnZ/ucY2rUMyyTbQivZ5A7DvJ6dnLXRl7PLs9Vl2szYtOWDA2M
    zpjSxfR8E/V8W/0A+lG2V/YNAAA=
    } "9 of diamonds" 9 "red" 420x60
    64#{
    eJzVlztSxDAMQANDyecKma04Bw0Vd+AU1LmGKl8lBQfaihlVRnbirPWJrR1YdnDW
    m8h+UWRJdpyXt6+HIZcPqs9UX6m+U70Z7nL7RP2fj0vlZcq/YZqWUzroYp5nOqeW
    mH9DjMspHamJ/g5SlSq34xh75Tg+dZk4/JwBiNBhECB0mYDXY5B3mwyEmsmSZGic
    tZosSQagVrRIgqEbK0WrJHxoMiIWqfH0MCYVJt+4KeJSV0+IPXvoos8kbdo/WEuJ
    Nfy8kuVRYMRLoUbc+SOFPZbpYlw7DPPPaXTAE0kxPAg209ODzB40mc2xsEmSwRKg
    whoM76yt0nHnj7QZbjpjLp3Ppj1aOosx57tkUOSW5Wdr/VGMsY4pZrf8c8YzdocP
    PbFwxPS38ucqOd+Yg5657FkTXGuLZ41yrXWGC0yGO+9MPXUTajWJQegzRbf5bloY
    LDda7zjBoIlyBqx3LrennasIqlXnRliVXz6faT+Vt1Ute2jHtW6rmkyE2J7vhUEQ
    sY2aaa0/G9NYxzZmt/w5ozJYMygni2Ka3X7G803U/7a6H78BawWaX/YNAAA=
    } "10 of diamonds" 10 "red" 500x60
    64#{
    eJzNlzGu1EAMhg2iiUYwV3ii4hw0VNyBU1DvEaYdrVCu4Daa5hVc4lVcwRVShFD4
    bU+yySS7byWeBJPNy77Jny8e27GzHz//fEs2vmL/gP0T9i/YX9Ebmz/h/Pd3vm/H
    yT50OvlBN3x5fHzEUWcm+9A0+UE3ncKf9y1qN14/PEzPDXmIz2om+nvNmPsX0Uz5
    Dnv+keZKGOJaU2nSjX3WTx6jT2dsK02vl/Su6dN0pBmzgZSep3GeznmtyerSqcs2
    HCPRHL1ofuf8bWW8rySuD3F6wtU/9Epczq4RvqXhi6a/aEYzYwpEQtDwrNGVzBo3
    tQ8UsZkmmuYJ8JYT7ZxqSDW2ksaelSbgnnbpDY0UxGvLcf+EKDRrqAxbe9zPFOra
    2dzZrMviJSWIc4o9w8PWPxZ3qefAKXHnZ4+PFO5h8hiI9aYybDRd9GzsctK9hCOO
    GRkieWZYmu446tiIaJFLhFI84FAhuNazR6hD5HYcSiVa1E1CCTlELSdjNlAiwSDF
    YLScFBgRSslvppi04wSEkCX5UEyHWzacgmWxDDYcwzI1HKRfIVlhwp6DVOCqqRgk
    fsspHKtGMYFCl3b2cITmYk0JncSWQzPHMMk81vpHrZbZmjPM6XfxQn65RhcUzsZp
    /Zz18SO1ZqBrnDFoiBST4YNwzFEzNODDubOAHXAmzCZ1b+akobrGOeOcYjT66p8j
    zllBwAzqB/j5kANQUEwSJAFf5cAo0+i3odG4PeQY1XCbz5HgHzZMh7AywolEaDgE
    P4cFoxykU8MRYl6sgcYyruXoghZMksBxZ4/IxRq1B0kQdvbIGpNQ6vEwtf4ht8af
    wPpA7p53w5A/yynQPlfJSkBaakKI6q1d/THMXFvgLI4HdUyLxlyjUNHiUR2z/ua1
    DpXoSj0MJXDOqiOf7vYcLbmdwKGpWP/yjtdwULsVj0Cwt/KLpldOPcfoJfIrsLfy
    RWNtg91Ib5JqsbXyRaPtpyvaZsU52sW8Vc0ab2Pw2cyJqvGWN2u8HbKEeF3jHNaF
    XjS1BW/sodqssXZ9/OZW3qzLfAaNWNRbjrVD15CvHUvc2nPx86TV4oYmVk19DWv8
    A48u/dRNzXpq4+dR/6vRn8Yen1Gv2MQLc1Uj9X2tT97KjzTdmOurn996nRvQXH2H
    XGlujv9Ro45+Cc1z4y7NPb+J7vlt9QeRdPNP9g0AAA==
    } "jack of diamonds" 11 "red" 580x60
    64#{
    eJzNlztuXDkQRWuMSQjCri0IE806nDjyHmYVjrUEpoQw4BYqNZgo8CYceQuMBujA
    oO8tvu5pVttuBQ5MqX/vHV3Wn6237/97Lb4+4PE3Hu/w+AePP+RPv/6I+5/erMe+
    Hv1XHh/XC3/w5vn5Ga+8Mv1X5lwv/OElPP0VpW7Wq4eHeW+NB73LTPkFTK3tHnOq
    td5l2vxtmR+kQa+Z/9WGqeqouWPpDdP8XbaBVbP0bjMyp7oYUZlLh8xVDHVFnVvJ
    mLp0FJevcqHza63/ugyuDE3SnXHxC/MZql/IFKqlYtmZdstgqwKDdJS89qInZ4bG
    wbxhqciQ5RgZbnZmHKktSypzcLPD5s8QDzpZqjNKg+C7exLsORhEEQbdxOeKwTUZ
    VQy52HX8E0yuxbM2U+Femz0rzmQyXJ8JoZbo18oXXc8KewqwMkN8Vt7BKLaYgqdR
    9SiZvX4QZjAiyIMwUpHhOzCIcu98VqkamJFNWYR03IfKQGJ3Bltkgkwo9FjLQouu
    GGSadccKG7IAWJZ2xlikk7Eh4CQd2Bg4MmkT7/mCTN4ZFaNrRF2EZWZ+7YrB36OM
    xWz6XgBRtTnoIKg0IftQlYxIWwp7UdzN7Jy2A0iCUNAZbJthBRBWNy1iKegoAy1W
    2HxMxgnmxL1gTRfa6TrWCvaKfg2moyt1aPIJBS3Br7msaOw9aVlbKRwyuw53y4lG
    ZDDUMYlx9qBYlYtO1qAjlLFiT7Us+nTKEnT8Rho59Y/sV+pY1HGZ1nIi0T9CJ8t3
    dHI6Db8h9amYy9zEEO7AVvedA8Floo4V6Kj7zhhTZsa8W7notNLNrdkY/2u3B/2B
    +HBmcMDuNY8YN4YWQWSc0a03MaQRQ3xy4y2qBLUWmCQmTdwKKBS0R/ZS2HQK9ur+
    rQC1Jmwhz8/GQIglRm9gORjcD/FhAcrqcnaW8VwRiX6hm89NzBHEjrToV9ZLF8tg
    Aw3NFnKxOn2NBEUh07GdSS7j1UgSU4ajZs97KgvwK/CPXvToe/WNJh+AOFpp0553
    zD4OShwSDIEdd0LvVPrMHuUIsrlW6EGeW527dRymZNrGNJ+9GKLCcwlHDxk/bS8M
    P+E+hBINRm+Q8aP8wvD4wejFWB+8MiqZdZSfGf+kHG2IEQd15RxcR96Z8eOQI1zK
    GDwnv8MsHexlPEMO5jiCd3smopeYbTBI53GUB7/QMzAIx7+7HnVWfNh7xcus0PXd
    HjxVZzih6LuP98icFgOD1E83Mnt8PKJuc+YJ6hU2Q5wv8emdedVj4m758q9lfgy6
    YwOJ9zvthsmHjuqleCLzo++Q18xP12/IMIZ3mOOL6s+Zu+tFzEv+J3rJ/1bfAGnk
    dy/2DQAA
    } "queen of diamonds" 12 "red" 20x80
    64#{
    eJytl0tuFDEQhgvExjJQV4hYcQ42rLgDp2A9R/DWGqG+greRF2TBJbLKFWqFNFKQ
    +atsd7e7h3QQ8aRnJu4v9a5y59OXX+/I1jdcH3F9xvUV1yt6Y/sn3P/5vl7jOtkP
    nU71Q1/4cnd3h0/dKfZDpdQPfekW3j5sRe3W65ubcrTkhg+ZQv/PxHiJ0wswJeJ1
    xFymYwbajpnLP8n5Sxp4bY++S7aV8MpNOq/9Iv3ijSBPPmFrUuYyLYxjSRCkRMRi
    sxXMOoZgMotXotoBW6drTHGV0ML6HeP3amZZ/GIYobcFG1LKPTQ+jAxPkxjDzIXW
    zLRm4BvbEiFYrAuMmt4ZVscqU8pjMSRODHkPoz2dQVyaHDN98GtmpNuj7MCILfz2
    SJ3ZyEGcK8Pr+KzscUyzKmIpPc5rv5xGrqvSMLZ8reMzM7ahYM37Os4rOaKVoguh
    vM5YIkS1UYvDwJRmsu6K/cWOkbmGLYjK08DoPY20T5XyZLrH2kC2cF8yVXHJ5tmo
    i3AzM4pdEOWIskdB8sYvTjI3lQshUfQUeFurRL71l3MhMaUYA++YXj/Q44KHOkAD
    UyC9tz55SMqZrM9WjGC7NoY2LIwmhTa6og+ezaRExgByI+PCrU9JNIQ+KQM/cxoZ
    iMmw2rsYVEgi5MbnvV8EZWjngG+QANEj43y4hRbumUj4Fp3fMapCICcGGMQQc05b
    Xc5HNUiNNpOjy2MMXXRUGSsMr1k7346+646ZUhlLbQ6bGOKPAmGQWYDQkO7sek0u
    9RMi7PSabtiMWHqXzqMuj4JAXpPJqabvmQQxlYEgxNLKddTlM2n0NZ2kjCQPMZv6
    QbbVZI/CVmWSsjPRQ5wVgg4mK1gog5gNE3ytG251JgliZBNnhRK6oRcs6pVHRgtc
    yxwp4DaBd36xQtYxrhqUM+2YQgHSKYW4nHDyY2QweLSrSJ3RtscAED/Wjw4eqbHV
    OKGzs86RTX/p+NLCUMiGTNnlvfrSa7IdYm7jl41LO7zaoC47pg62NjD7oN4w0uYt
    TF+G+YYpdWiLbV1hJmNs+NvkvSJHb/bD2s6C+WxZmHs7XOthJMT9GMNhNTN2k+uh
    Jm8XVX7FXOoBXJkWB1Xld3Lmw7ozOq5ptKcd1o8LY2N28KvJEZLOcJmmTXzqQSyW
    rVr0A1NWjNVJO4V2tdrjY2NFp/faL3sM6nGuxBmddpWxfOk4BIHntiHO9ljW8i71
    ic26WfO/MKBad/r65GcnQi+ZysQnniF7vqby9FLmAHmunOlIUPPrgLEYvgBzYMxz
    mef8T/Sc/63+AJ3HlmT2DQAA
    } "king of diamonds" 13 "red" 100x80
    64#{
    eJzt1zEOwiAUBmA0ruoVGifP4eLkHTyFM9dg4iodPJCTCRM+3utiX8NPkNaY+FrE
    4BdoQSg9XZ5bw3GjdKR0pnSltDIbLrf0+30n6T0sn8ZaydJBX/q+pzyVRD5NjJKl
    IxXRx2FclYp110UUj24PTTQNjG9jgmtjXPAtDAkHjXPQEHEeGW4uawJVQo19bIZY
    yDgP750uGl5z6uelTCwYr1QR7h+qBpoQFxuLv5nPeGx46QIm/fOAkSUnb2TJyRqe
    CS5vmIwqqjDS1KixLxvVixP3FdC9D8tt1kzF3/yeCQVGTV5tgpq82ujJq0zQk3dG
    46GR5zwwMNqZqZlZY4aNGTBowGTcYR/KhjNvZOPawOinUZ3RT75KA6LIlLwTlbxb
    vQADV0S89g0AAA==
    } "ace of hearts" 1 "red" 180x80
    64#{
    eJztlztSxDAMQA2zLewVMlScg4aKO3AK6lxDla+SYg9ExYwqIdsDG30YaXaXzkoU
    Z5wX2bKVkfLy9vVQunywPrO+sr6z3pVD71/5+elxqJS1n2VdR9MOvtm2jdvWQ/0s
    RKNpR+viy5M2ZeR+WSiSz+UYMlSuZxAgZACghgxhgonnwyMl5uwwyG8CSEOaYUcQ
    +ghnQ4rBwfwaArK+t+cgGOu7YZw1vITp4vgFe78uZVAOBdXbd2GGV51fMMx+BYdV
    Z0/lTvgMAoUM1d19JlYzMe/GjzFEN/kGJzOZyUxmMv/EYIJRqdFjUKVhj9E51lgt
    R1T5HI1Vy+jM7TAIZnqNqaIoMiVAn3PVmRgMI+RG9cZftY0sMK5gWl0WMVUyZhX7
    vku/0PNr36Vr0R/G7rRlokDsDIYMZBgbVYbJxHwoKSbzT5T5t/oGyDsmgPYNAAA=
    } "2 of hearts" 2 "red" 260x80
    64#{
    eJztl0FOxDAMRQNiC3OFihXnYMOKO3AK1r2GV7lKFxyIFZJXxkmESOxfHDEjRkjj
    NpPKfeM6qe2kj88ft6nKq7YHbU/aXrRdpZuqX/X+211ro6z1TOvaunLoxbZt2heN
    1DOJtK4cRaU/99aUk+tlkUjel0PISDqeIaJ8CoYzh4xQ7I8aChkm8gyrj0X/9SjE
    qJLLWDp3LMONoYihgfFjdwyYQ8ugcVlGgD/SkHw0w+OjKKP3PpjRWdc/OKafwWYV
    vNPemz2GSUJGcnc9FasoNpx3eSJW5SQ5eGHOy+SYYYoZm12AYZvJgPFpGuUpZE5U
    E2bqz18zbhaDOg8Zs15ABsmF+X8MTzAueT3DLnk9Y/PJWU0HNjGOaotlUG0xDKwt
    bX3uzKDaUtf53syZawvbzQNgxk3IDlM3kz8zYhhcW76ZvdrC424G1paZ+JEAafGc
    Q4YiQyBWf8uEMsXMfBPNfFt9Aow0CNT2DQAA
    } "3 of hearts" 3 "red" 340x80
    64#{
    eJztlzGSwyAMRUlm22yu4Em150iTKnfYU6T2NVRxFRd7oK0yo0orYACB8aCdOB2y
    CfnKQ8aYjOTr/Xky3h7cvrjduH1zO5gP75/595/P0Eqb/WnmOXTu4C/LsnDvPORP
    QxQ6dzgXf1zqUCs7ThP17Hc6dxkyrzNoFQxoGKtgQDEfDtRleEaJcVd2gQvBlwLB
    sGCPLUXJYHBDJYr18SMkA2oGYB/Gm7wvkPeVxf8YlNGTgPJZyJFR8HrLdSbMYZKo
    noUbm8JEsWIwh4lixZAIE4Wf1g77kBT7mZB2+Q8OZjCDGcxg3sSggpE5aYNBgC6T
    cmQRzkoGY65t5LgV08iVNdPKuZmxIZU3cneesw2pvFUDRCaP3KHe6NU2GKuzFxkC
    RR0Fm7Vfuc7QqiErplmLZoYU+8f2Gc0+JA2DCkYx566pGM07kebd6g9PV+vB9g0A
    AA==
    } "4 of hearts" 4 "red" 420x80
    64#{
    eJztlztuwzAMQN2iYz9XMDr1HF069Q49RWZfg5OukqEH6lSAE0tJsUWKsqm0BoIC
    oS0rpJ8ZWpZM+vX9+2FIcuD2wu2N2we3m+Eu2Sc+//mYm5Yp7cM05S5u/ON4PHIf
    LZT2gSh3cYsmPjzXrozcjiN58jU+uQwNf2cAIOzBEOEuDJ4dD7ICUCvJsDB8RXKs
    FcVgNkOlgIw5mkAy0M/ImFcYjAeHofq+QN5XUc5jUHpfFAjqWcgrZ4XHm9HCYHGz
    KMmffKbCzawYBoubWTEMCTez0jNX1TivSQzLY5B2WYNX5qIMdjByxq4wCOAyAMZR
    zSCAcVQzahG3GVQvjN8zAI0/uywTPAYzQ1tMzBLojGFTrsz/Y+wKt4xd4YZprHDD
    LHNTuQuSWVZ4I8cZppEra6aVcwsTcipv5O4Sc8ipvFUDzEy5cod64/TiWatt8FQM
    bTHJq8fEuqyXQcmgYlLdulJDaqZdi6qYtyQzm0iO2ZFepi8el3Gli+n5JvK/re7H
    H4xdySf2DQAA
    } "5 of hearts" 5 "red" 500x80
    64#{
    eJztlz1OxTAMgAtiBa5QMXEOFibuwCmYew1PuUoHDsSE5Ck4DmntJI2NeOJHem7z
    8px+dZrEdtqHp/frieWFyj2VRyrPVC6mK25f6PrrTS5aFj6nZclVOujPuq5Up5bI
    5xRjrtKRmujnrjbVyOU8R0ve5luTidP3GYTgYMDRFxkyGTQZ6stkQDFpBOkBtQKq
    L7qDDWtFMZiboVIaBiQDfkY+8wGj5vmAYZHjAjmuXfkag9L6pkBQayHvLArNN6E7
    g7uZTWF7ck2FmaI0DO5mitIwUZgpCjj8x+XPjriIGE8Sg2fml5ggL4Qu0/HDhun4
    c8304qJmevFVMf041cyJcoIn//w0g5LBljnI8/Uc9vYLzQzkzPw/Bh2MjOEDBgFM
    ZoskZS5IBot3D3LLxgxyS2FGuSXvz0Zu4X3+D+UW/HwZGjFs1WLSe5mXGeQWZozc
    kplxbgEwnCwzQyT3ZQivqc14/Dl6GMfz2Iznm8jzbfUBqcKs2fYNAAA=
    } "6 of hearts" 6 "red" 580x80
    64#{
    eJztlztSxDAMhgNDC1whQ8U5aKi4A6egzjX+yldJwYGomFFlZHviyLYSmd2dLAVK
    vI7sb+WXLCcvb9/3Q5QPTs+cXjm9c7oZ7mL5xPWfDymVMsV7mKaUhYsf5nnmPJT4
    eA/epyxcoYh/nmpTjdyOo7fka3w0GT+czwBwF2E8mQwTZn96GG5MMMSdAxqlYHgE
    FAZRKZKhVIxaCR2SDCSD4xlfjQtyXKvyO4ak9azAFesu/7koPN+MrgytZrIS7ck1
    FWYWpWFoNbMoDeOFmUXp8VUK3TJ9zNkM+YvswX/mSoyTFU5lFD9sGMWfa0bbFzWj
    7a+K0fdpyVwoJvTEn6MZkgy1zFacr+ZQPS8KZkdahjoY6SEbDAEmAzSGaoakU2ww
    xYLrDBWLcDoDKI0dzVDBOJURRZQYXzPFCvEzKXOYbRdVTjJ5hXZiS2Z2YsvCELZj
    SzqfjdgSz/m/FFtwBYawHVviSyn2Y0tkjNhCedZ1ifPTRIGTGFiNSV89kzGli+n5
    Jur5tvoBfRyUSfYNAAA=
    } "7 of hearts" 7 "red" 20x100
    64#{
    eJzNlztSxDAMhgNDC1whs9Weg4aKO3AK6lxDla+SggNtxYwqI9s4keKHtEMIq8Tx
    SvlW8eOPk7y8fT0O0T6onKm8Unmncjc8xPhE5z+fUpE2xX2YplSFjX7M80x1iPi4
    D96nKmwhRIfTNlVh9+PoNbuMzyrjh98zCKAyAOBUxuNhjGwzUuNCQDqyzeRhCEhH
    XAtTGDZOwQBnwM7w9jQY0a8GE433C3i/Vuc6Bnn2xQEn5p3/Mzs03oSuDK5pFifm
    43PK0mSnYHBNk52C8SxNdixatWjeh2ZpDPpd7sHrmbrmJVPXvGAami8YTYdHMn+s
    eclUNb9laprfMjXNF0xF8wVT03zBtOy/GMdPuCpj6bthDC1zYZhTizZ20uGt3V8h
    jNBfEyxri2mN6tieDBoYrq0GgwAqs8ywSOc4g3nUO5pfmI7mM9PTfHo+K5qPz/kb
    0jz+vAz1mJhVY8J7mZXpaD4yiuYhvw51NG/ST7zWQQwooje2WTUTY/kmsnxbfQMa
    WW519g0AAA==
    } "8 of hearts" 8 "red" 100x100
    64#{
    eJzNlztSwzAQQA1DC1zBQ8U5aKi4A6eg9hFot9JVXHAgKma2EivJknb1W2XIJCiW
    nVVeNvo82/HL28/94ssH1Weqr1Tfqd4sd759o8+/HkKVZfPbsm3h4F70Zt93OroW
    67fF2nBwL9dEu6cyVVVu19Vq5Xt9VBm7/J1BAJUBAKMyFq/EIHXODUIGss8UoWuQ
    AfCxY2iGIvAxZ4AzIfCJFQbL32owdobh/bGh1TSC0xjk2VMARqw7/2YMaL4JzQzm
    NCnw+fiasjQxqBjMaWJQMZalicGMqzPO+0XVGLRnOQdPZ9rOS6btvGA6zleM5uEl
    mawwWt354zQfOY/HDhpzGDVP+2xu6TymbNnc0vnUK3YCFM4jpG7ZFuM0Tww/AQp/
    QI76uowJMxiYdp+PsZvR2I+588J35lBMf2ctRF/bayp06LghBq152GdmnL80g5zB
    mpm5tkxdowblnAxOMIW+LQaZTj0mrbBIZziDcdYb97iKadwrS2bkfLg/K877+/w/
    ch5zdwYMTPhMiVQGjeY8xov3wHmIf4cGzvv/raNyaaa8ZjcY/NSdV8sUM/NMNPNs
    9QvETVBI9g0AAA==
    } "9 of hearts" 9 "red" 180x100
    64#{
    eJzFlztSxDAMQANDC1xhh4pz0FBxB05BnWuo0lW24EBUzKgS/uSj3yYClsVZryPl
    xbEs2UqeXj5vh1beSn0s9bnU11KvhpumH8v197tedRnbbxjH3tSjnByPx9JWDbff
    wNybelRV+XuwXblyfTjwXvk43O8yPPyeAWDYYQgAdxmk/2IIsFqhBcMAQLVCC5qh
    rgYteAYkA2lGzWHMaF+cYFqRdoG0axW+x5DsfRHKkFH4ot/ZjMFJqKcg/UWLsb2F
    uT/p095NY5D7aBxDMA+2ego4YhgFwzgPEm38rMwySLcuLMP11DCknFAVvM+wZ9g8
    KmTId+NjfpodsQB8zNMEkvc7wRzznVsXAAdxSCfjMBOr52L+OOY1w/JOLZiYDwUT
    86FgYj4UTMyHwhlywZ8xKC9gyGRsT8xhxhcJn2Zi40xxeMm1s6q313KfuNN7QmZv
    Se1Rcoa16id7JimDBEMJRm79EDysMCTuO8UsOvS5aWIWa4Mc55ggV1qmOYh0zl0Z
    7KkcfO5ex4w9lYuJUcKFY768T02ht8XMxm4ynGdIMuSZ+B3SMOG7qGE2ysUZt+o8
    Q3bROWbzcp7JfBNlvq2+AMWyKIX2DQAA
    } "10 of hearts" 10 "red" 260x100
    64#{
    eJzNlz2OHDcQhcuCE6Ih8woLRz6HEkW6g0/heI/AlBAWvAJTg8kGvsRGe4WKBBDW
    ovwe2d3TTc5qB7AAiTM9P93fvC4W64fz4dOX99LGXzj+wPERx584fpFf2/l7XP/n
    t36cx317yv19f+MDHx4fH/HOM9aeYtbf+OApvPw+Sk3j3d2dvTX0zr/JmPx/psb0
    XRiLN9jzg5hXlsEfmU3N1VhrSjFF309HPHYmPthLTJo6UwN/rmemxvj8FKM6q2bJ
    IKPZHJh4YfA58ZDYh7elMXT0gYmN2a3tjB1s3hhFvGQM0+JFXmHUr0y2lHx9eLnY
    89SZZwW0YHBOYGKEQRvz0pAHw72sM9m8993GgfE70+w5Mfa0mbwyfV48+7wzlYyp
    wI4DU48+NHo0YeI405nNz+nA4Cdmu804L775+bDu+Ekig+T9F0jJjALPtdsZCb7a
    qtOcWLyNa+FawIhvNYDIMjMaKFCwCCZRcpErOhqEU1mKIDrCsuz2nHUUOiU7IrnV
    oZHhu9cl8/JSSnFVJsbDWnHKyxxSqTTqIMLFRRUSmQjWYNRRcwEQfy+uIRYnHbHa
    II6OjLGqKqlBlNmQPDBeXYPgg9CRpa3H8V6quUHOu44U+ODE0MmlQRKCazf6nGVg
    oEMnmwUHw6CSXRlsbjqAIoSQ8oFuhNCkw0WCRsCTnyg06XCllRFee5xAaNZRvDrM
    PQo/FXHzvDJOI3UQiwrfQFY+X9EpWHuNQRkk+KruBuaKzeO9bGT8Mtg86xjz+zT3
    SYexMfpw1tGwnNdi1rHlb2kL39a0IqxnHaQmgvAQG7MOEnMZYgw6/szkHmHHWIWR
    Z6aIG2I+iNpgz4q01ImE4MfzvdyG9BQkhKwcGHoX+b6lcmx7mIFBtp9LAjLOj4yp
    q0Rwr4IyRnMnHZZUXGaPC6xiqFjBZqaUpbXBUIROlisMixhLHRO9xck1ZmFdRiXX
    nqAox1d0MFiWW/OphrJ+YdJmT+7NhCWVncFf7sW24VhYpTecptM7zM6w/Tj2xt64
    4D3bOtXGtDbm2BvX5iZfZe14O9Pa4ZHhzXqT3pl1e4D82plTB94ZLJ/uzFebGbR5
    n9A2V5tVbdsR7DZzuwBG87rTkNUcyp9jlfZ0xl5h+rz2jc3ExLgxrl8K+47p4MPN
    zwh8hD5ydd15XfycKufEKhXbdq2msO7gzkz74rDnIxNrv3ZYU6POa3vIA/PN8TMy
    LXS/A/PWuIm55T/RLf+t/gNy5vcz9g0AAA==
    } "jack of hearts" 11 "red" 340x100
    64#{
    eJzNlzGO5DYQRcuGE6Js8wqDjTbwKZxstHfwKRzPEZgSwkBXYCowmAl8iY3mChUt
    0DAG9P9FqbtF9Wxv4GDVrelu6emzWFWs4vz5+etv4sffOD/i/ITzL5w/yS9+/RH3
    //m9n/vj0d/y+Ng/+MKXl5cXfPJK87e01j/44iX8+TBKHY6fHx7avcMe4l2myf/A
    5DzfY04557vM3H5Y5p0wxGtmU7NaF4lmtl7eM/mpvcFfWsDgkBsMnPX6Bf5S6jSx
    fj1e+zDi+8zTqGMtalzlL7Egk52pWWCMqaw6rd1gkl8KZbPnyOiSYIxJKPE83Y35
    0plXzfAKXmFy5vT0drH5zZGnZpDh82GSLn/K88jA485oLpsJZ6b5YHMzzvw9ht7K
    lImYuWwMn3y9xGuVkT4ZXWj03s+eui5jpXHyndn5GSd/QcZqbABDZ+joK+ZEBPFU
    WKJSOtPmts8flylSRYo8axz93DyS+BVVpFbRWA6MVQ7BkU6FWfo8MfKDTqBD/K5i
    rBpLpe2DDmyEh010QVJHyBQZmKgF0TaDXVrTqUIG5J7BU7VkSFm3GZNTkT0DC7WG
    5FnKm1Cj0J5hBAQQFAsDq3TSYDNuGEZLDUyEo+SoA1uT5SkkGkTLoVLK0c8yZZjN
    ZSNAjzpYdkh0Mlh+lgt0VEd7MH0LCwbDpTCVW/YgPXEvOyOhwiZObM8EBAfPg0H+
    hEJm1JGc+soLcLdMZcLE6qATcsbig4gnWEYSStCDTuaMcqrQKVNRDJwGPyugKIrC
    onlStzlk3esgnqg7qouCgVmVk0y6H0vce1JTqUVLnjAWTBx0apCoaYERyDaBqJu4
    08HDGCuhitUSUIToiaNOpWsXzj3rhIGxDOKgI+o2MwWzcpIMz0GHcfR7YBakCuO8
    01GuFVtSc+8tmcXebuiYJc8wMBPCZ8MaZKJDJ3qmcrCE1I037ZGe8QgbElFKG/2M
    UgGIDDyzFquDTuVehCuQaYB4mg7+4U1IVfcT8gmjIcWGdUqD6mKIuHkfZH0ZGF8r
    M3ROlXseSOlUxhqF288+WixeOm3JY41CvdDZq9zyL6ti8+I3MA1FrtsMK3zHNfoQ
    f1FJxRPMq8yuJPcyTSZhNWAIlnF2/x3Dck8mu/N1lUFnuGLYNpxBUFnn2Vh6hzkz
    3n6c6cspsj/1TnVmvI3hh6EbGWv7KpPzhfF2uDL0S1tl8OS7DBvL1oEvzKkzmlcm
    HRhv8/yxrjy2/21HMPq5YQH6NgLz23YWV0zXscVJVLF2ZE4r41lq4Raz+plRxbKz
    UJyZr5nNz77VQDwDyuC28zoz82pPM9+shVLPO7gj07wPQsf3UNe50bd37+whr5lv
    Hj8g4xn3bcZjcY+5e3wX8z3/E/1x93+rXx/+A4IDtCr2DQAA
    } "queen of hearts" 12 "red" 420x100
    64#{
    eJytlz9u3DoQxicPaQjihVcwUuUcaV717pBTpPYR2BILQ1dgK7BxkUuk8hWmCqDC
    YL5vKGlF2hs5SKTVaq397cxw/tKf///xr9jxFdcnXP/h+oLrnby35/f4/tuHdvXH
    vb3k/r7deOLD4+Mj7nxS7SW1thtPPsLbx1HUi+Ofu7t6duhdOGWq/DmT0pKmv8DU
    hPOMWaZzBtrOmeW35NwIQzjaw3ctpfh2bsLDcV327iWvZ00P9TlNNSxTx2hQn4sd
    YUnp6TssCUcf4t3n6ktJOCIMTROvgREwLiUzlUwypi1oZaApt5VA6w3Gg6kBR88s
    D89Xm71IESCQhNf3xjz19mhdGeX5bMgD15WOjJZguvDpFsPl7Ewz6Kma0qedSQmy
    dmYhg8e87zZz3YrDVgqSOixeuG1xjzggRdsvAgWZa5E+OwMXp+YerI4FTDEM0XTw
    M8IUmjJbQF32dNgYNznYUw3CS6LUF4wkmipVaTg0r5HrGZHYbCGiSarjNwOTY4Qh
    BcEI6sA7pMLAZIkzZJQc8BFigsPyQscg7M5H3Ev2XuByjaqXPOjyzuWqyFbJVKUR
    67j0jJ8l4hEYqIpUBSelnil4AhNYYzBHNQWs3/X2zFEcHQ1BDj93UVOU3h7PisBy
    NEJZDMBclLm3xzsIIiSFy4c2kUtJgy4rrbQ1Ayy0xDIPNpsgaSVjvoDDysDMaRci
    DoJ9mUfGN0GVeW3KX5FDQTNzei2VV+Q4CmLSILu4JjGbh3hFLBouCRaxahQ+9HIi
    BME1Ck95YdtDF8lu0JX5Q0beeeYR4zbG1BdrPy07sITEB3HwT74YRIMjqxYrH+Ne
    XGktV0JCCoqbEwSNjPjWlh1SjMrgnheMyVnW/i4s7sE/JsfqzqJq4Z19zzizOegW
    1NgE9cylMAhIV0syJQRBQ66iHJiiYslaCbmxdlgxymRPdKKyScioi4WCYsDvWWKo
    L0YwjzFFq0B9JSYAfu9jdKN/2MWi9aHcsmN2zRfHeEW2AchDklKOXqC+Xxf7CFU5
    Fqcwj1we6xTzC+ZUq0INGGXQHIeYss85ilE2u8CnzOyRYU9EE2RrhcloYWwSI4NM
    Z+dYGzDlphfMwnKwCW39l7P3ykyNYZ1rMFswFDgcrvZwbITapkjrpBxSbcpsDBtF
    S66JDJ6oGS7X3mtjLKxTzaytNqTcwR4bh6HaKJ52Zh2eK9MG+Tplrwx8rbcYjm7O
    cCTPkcGY36d+2wMYg7DvNnO7ELbdgw1UswfbmH6m9IzVT65SbzBWXhz2zNTenm1X
    pCQvyEQthznYmG135W2zlYvtwnfGtmVh3aXptm1rqXxllmn9w1puO1FjHZN+sYfc
    YjrVXx9kTpC3ypnOBK3rOmHMh3+BOTHmrcxb/id6y/9WPwHf55TR9g0AAA==
    } "king of hearts" 13 "red" 500x100
    64#{
    eJy9lztSxDAMhgVDC7pChopz0FBxB05BnaOl4ECqaI0eTtavWGYwcWLHE3/zS7Zs
    bfb1/fsRtHxyfeH6xvWD6x086PuVx7+erOZl1RvW1R5ycWfbNn7Km6A3hGAPueQV
    N8+lVFXulyV4hRZ0mQATGJzDEMxhgHAGwwS4jMWvy0i40GPMXI8hEYG/M7vFixga
    YMCPF/nrHAbWWeLlrc8shveYF9MwbX0O7j8YnS04OrbN+wxVMr9mzEpskoG0G0+c
    1hS69WxGIOlk71bMbogg3GyWDJImceLLuhXDA6JvZqTFw1jC6DAeDdAZo6aow+jE
    udj024wqHM0ZY57I45xJ7xN/RIjdwbhQjTU0GyS39lvrLO9pv9tMdEh1bAIVQzEC
    5k/iTsYgJPPC1t5QY+JH9L21x0xoX+5EptjPMkY6K4Lmfo5CiIVMfnaiUCGTM4dH
    mUxxBlWglCmYKJTLlGfZtjsV6jkTI56f+CqPZNFsM+Zz6DKh8qaRW0/yT7lGlTRa
    vk+FQsVQmUirbNxgqjLG5PnxhCFHZui3R8apj1z8+6Wpvf/FNcToV6Jja1osIJAf
    L/TjNcJM+eYYjftle2PkP9HIf6sfYx2h1vYNAAA=
    } "ace of spades" 1 "black" 580x100
    64#{
    eJztlzF2wyAMQNW+rg1X8MuUc3Tp1DvkFJ19NA85kKauqhBNAkggUmcEG5MnPgoS
    epb88fXzDtK+uZ+4f3I/c3+BN5GvPH85pF62VW5Y1zTEi39s28ZjlJDcQJSGeEUR
    P461KtVel4W8hktwGYL9DIoNfYa3HFyGcIDx9yPT7p5NBpUizZQStGwXj9wXkGW7
    eCRjDNsRIFdk+lCiIXQZTCHTs2KI+Qu98BCDA4zhZ55HzBgrxhACUrbnRozlkuTR
    /nk1mHqByxBb4MZzI8YeZ67cZCYzmclMZpx50jta3vd9BnWS9RjUC7QeM+tBkT/L
    XHllsMyfRc69aS7rC7sGyCqnf9UJBrOnbqmLovqvFGOdTGQoP1OtJpV2OWOeV6o3
    m1aQFWNYI8nP/fAZKn5l2o3VyvYGoz2iGMMjxn6cNsSMfBONfFv9Aj95nK32DQAA
    } "2 of spades" 2 "black" 20x120
    64#{
    eJztl01SwzAMhQXTLfgKGVY9BxtW3IFTsM7RsuBAWnVrFBkYWX6OXJqZdlEnrjvK
    F/lPfnZe309PpOlT8lHym+QPyQ90UPssz7+eS67TrDfNcynWS/4syyLlasl6U86l
    WK/VJD8v3lWTHqcpR4mnFDKZLmekOWkPhhOHTKa4PeIoZFjHvWG4qgozlYUay5/3
    gNERMQzoOxNZR3AMNRqSfaWpi0vIbPRijPkJvXQWwwMMtfMlz5kNg/uVOJs2d2LM
    WsqIbs9Xh/EvhEyWHgzEcxyrQ8wvd2euwLBfOaFuIIuPZ8T4ddFhzl+n/2T20hav
    Y5Dh1k2kq5jZZ76y2y86TJvuzG0xO2m06v02gyI4YGCsej8wVqnaP7G2cL1/Ym2x
    W3VPE8xKuAVtYXdwQtriD05IW/RcZh1BbbFMT1uq2IDz5cYeagvw3tYVIGW+BuI5
    cuTH8AImTEPMyDfRyLfVN3+MWqT2DQAA
    } "3 of spades" 3 "black" 100x120
    64#{
    eJztlztyxDAIQEkmbcIVPKn2HGlS5Q45RWofzcUeiGpbBSHZQp9Z2PGWwma9yG8k
    LBiDv35u7yDyx3ph/Wb9ZX2BNxlf+f71I2ktq5ywrukSD/6zbRtf40iQE0JIl3jE
    If75bKfq5HVZgiW0oMkEOM8QOhjwMOhgwOEPAybDHmmmwjEvBRUjz1AbHQN6zmw0
    +0MS88ZomDhtZ0C1h7I0tEbNpFzBgfEQQznpesNmyMHouPMwomKyUcedDaTiczbE
    8/Px6piBeJgARGYeVs9+htm5yUxmMpOZjJ950jta3vf3GVKV02RGvUTLDGpc8QdS
    VRzVyp2hXFxHNXdnRK0egNrhB/sEzTyjb6Hi9LE7evMPZtxrlbWOvkFtszIKczZe
    JTf6XrQw4X76SNzRZshIw5BTx2TIwTh8NsXFeL6JPN9W/6HQFrv2DQAA
    } "4 of spades" 4 "black" 180x120
    64#{
    eJztlzF2wyAMQNW+ri1X8OvUc3Tp1Dv0FJ19NA89kKauqhAQg4QtkjhD34tsTIQ/
    IFsKyO+fv88g8s3ljcsHly8uD/Ak7TPf/3lJpZVZTpjnVMWDfyzLwnVsITmBKFXx
    iE18edVDGXmcJvIEp+AyBNczbE44gmGLD2HwEnsaPCkgl/UGQjNJl4F6zKxAazOK
    z5WiGACwSmszShxoBSWeQtXzNFCjnMVgDjqr+AwOMPF+xYRQMVnRz0UBV5uzon3a
    8ZdM6vjLMB0ZYQhwIJ7rZ7+GKdyd+ccMAriM38J/BiQ9kmI4fBFBNxqmWYduyWCz
    qFzOUGcqw6Adxr5VO8yt/EVplfQYK3fmGOagNVrW+32mF3mbTC+X0EwvJznZA2lX
    7O2VhcG8ufb23MJI8XIA1M1n5gk1c0DeUm3lJkeq3mHpu5F4hbiBl77Va66Uldnz
    F+VMcddfhenlosrmbRHGjVUnUMeZMXtcxptpkBn5Jhr5tvoDMlDOXvYNAAA=
    } "5 of spades" 5 "black" 260x120
    64#{
    eJztl0FywjAMRVWm2+IrZLriHN10xR04BescLYseSKtuXVk2YMtCMiUzDDMocYyc
    R+xE8o/ztf/9ALYjlR2VbyoHKm/wzu0znf/Z5tLazDvMc67SRj+WZaE6tUTeIcZc
    pS010eFTXqqzzTRFz3AKLhPBZjCddxlwGQZcBl2G+nIZGGFkXw0eVAahGYjKQH3N
    4ggGOebCEWMGgN5pnzNyHmjOhcm5EhTnJgZL0vWOz+AAU+dYCnComOK0905OwMuY
    iyPjrsSLO3Xi1TGKjTAR0M/n5t7vYU7ci3lKRtMNyWj60zL6vGiYK/NLMv+e77cy
    a2nUkB7quioYVZ8Fs1K8ovre6Zhr9mLWYVbSaNZ7m8E6LT3GyLEzY+VYTm9bE7C8
    XE1NSMWbyyibH6sJmBcfpiaUf5iawGs3RxMKY2rCiTHjVRhLEwCcRMyMieS+HPOX
    0NVztpk4wgyMx2dGvolGvq3+ALZph/D2DQAA
    }  "6 of spades" 6 "black" 340x120
    64#{
    eJztlztSxDAMhgVDC7pChopz0FBxB05BnaOl2AOpojXyI4llyY/dBGhQ4s1K/mLH
    tvxn8vr+9QjBPrm8cHnj8sHlDh5CfOb6y1Ms0uZwwjzHiz/4z7IsfPURF05wLl78
    4UP881w2pex+mlzPaMIu4+AwQ3EMxxl0XcYTpzCEBSNwNBmCvAEwGcjbXB0QTJyL
    0pGMX2LtCIZCHihHMDFX0HCuYiglnXb6DA0wvj5jEDMmOSTyhx2k/ZmTE568vV6h
    0856KcawEcYBEXb3Vz72I8zK/TO/ypj7vWAs3ZCMnc+CqeyLkrl5n17LnKUtNR0T
    TEUPJWPrqmROWi+XXhGUOkGbGYzwYpMDaDI8HCIog4oRU/OTDImkuJ1xRleKId2M
    nlXdjGZINWNoq71eMkol4uuD3reM19kYSZVp5OrGtHI1zkhbWyi9XJva4ktPE6gM
    /7G27K/7urbAdm9dW/YHzaa50BZY721oS0qNpras6SOyCG2mZqHbdoqNMtDrbMux
    40zXhpiRb6KRb6tvHjBX8/YNAAA=
    } "7 of spades" 7 "black" 420x120
    64#{
    eJzNlz1WwzAMxwWPFXyFPKaeg4WJO3AK5hwtAwfS1FXYslNsWbFUmpeiRHXl/F4s
    W/98vX2cn4HtK/op+nv0z+gP8MT9czz+/ZK9tZl3mOfcpC3+WZYltqmHeAei3KQt
    dcWfV3mqzh6niSzDKZgMwe0M8hzGTEw5mAzhYUyXc4PnQOaM0JxAHQvqc5ZAMMg1
    F4FgAKAP2nyQdSCDdl5ZK0EJrmKwiK4PbAYdTDpeMSFUTAnkvCjgb84lcNSLBzXq
    1TGKeRgCtHXYzP0WZuWuYRTNS0bTvGQ0zQtG1bxgVM23jK75lvkHmv8Do2le5qxp
    XqzhXvXatjsxnpztuTvW0FOLI7Wxl55d147nGnRdyzvVi1z3qE3zMjvdo/l+P2aw
    XnaLGazhhRmtYS7fWPNYHq5DzSe3tIqy+76ax/VtaKB5uLxWbWue38sMzRdmqPmV
    setFQ82jIZ96rEOYZtI648nZNBfj+SbyfFv9AGTB+m/2DQAA
    } "8 of spades" 8 "black" 500x120
    64#{
    eJzNlz9WwzAMxgWPFXyFPCbOwcLEHTgFc46WoQf6Jlbjv7EtK5ZpC8Wp60r5JbWl
    z8rL6/vXI4X26fqL62+uf7h+Rw/Bv7rzp6fY27aGD61rHPzhfmzb5kbvseFD1sbB
    H97lvp75rbp2vyxWa1iMyli6nEFYw5hxUzYqY3E7psGjwecMqpBkEFs71fdMRiCL
    H+EaZoTThSGi3mjjjKCDzmiYqBUjGD9ikETXGzqDCcafrxhjKiYZYOuyBmXOyZjI
    V/hTJV8dI7QZxhJ0HTZrn2UEre7cPsFmtiIjaZUxolYZI2q1ZQ602jD/QKtnMJJW
    +ZwlrbIYFnkWo2NyOTGVwZl4uYElanyccRMFiDs7pknnbzJoAnweQ6kIpFGMTwgt
    cm2S4pxTFKuJmK891YhdynuRjPOoGsNFOrzW3pnapzP7fapuzNSfqTo2Uw8P2zn1
    94AJ9X7MoA6pxgziszOj+OSNMKo/SA/XYR3zXdMhuPu2ekZ5lB/qGTnMQz3vN6rC
    zPWMriRzPedaq+fLDvVMVtXY3zK8rgsMFMlf4x0kMjPvRDPvVt855Lq+9g0AAA==
    } "9 of spades" 9 "black" 580x120
    64#{
    eJzNlztWxDAMRQ2HFrSFHCrWQUPFHlgFdZaWYhb0KlrjXxJLVmzNwJkZJ05G9p34
    o2c5ef/8eXYpfYf8FvJHyF8hP7inVD6H+tNLzjzN6XTznG/xCD+WZQn3WOLT6bzP
    t3jEonB5lY9q0uM0+VHCREPGu78zue9dBs7RkCHckGE4qQxc/QSnMq5+ZjYkg+Rz
    bkgmulgaYg6RdCAN7ousFVKMsxgU0bXGmIHKgDGxvmKI8qqgykApWbvpCbl+N3zq
    eeOvMp7ir9Si9Be2ySON2WeG+bBhwCYm/AWgEcPGXjdVC8nCrNw5TJ4zIDGkMkhz
    T/DZCSpTmihX0e992L54kS+AvuYFo2ueM3eg+QuYInNpKJpvjUGMahglRjXMYboR
    Y+nzeOyGObT44pra+C89m9aOZQ2a1rIlJphiiyVG7YO+MB6yfo+ZJoYXJsX7PgNW
    qDRVM8re1DDKHrf3x+VdUdsrVwZlc9X2XDb2o717ZeDvSfPIo+xqHrTO7LHm01uZ
    19/ZJNOLURvTiVEbo7yLtsxRujojRa4wkCJvmG61nbF8E1m+rX4BEApi6fYNAAA=
    } "10 of spades" 10 "black" 20x140
    64#{
    eJzNlz+OEzEUxh+IxvKyvsKKinPQUHEHTkGdI7i1UuwV3EbTbEG/V3kVEtIK833P
    9mTsTNiVFgmcTDKZ+fnz+2d78unLj/di7RuOjzg+4/iK4428s+sH3P9+W4+xHewt
    h0P94gsnDw8P+OaVYm8ppX7xxUv4+DBLXbS3d3fluaZ34VmmyOsZ5f2/wBR5gT3/
    iLmShrBlupoml5yLMcVYNJRgmd0wyhMXK+NC8fmSsVNN4kSiQObkQ6hVsjJqtaKp
    ttAYBvrMmIkkm7WVKVub7SbOPFqwTmbPwLTelVEqmF/lnNPQxiia0YB0HZUrDC48
    rn6dbe6mdkarjm59nxkOE+rlsMs8Kaw2nZlRXRkpLT4Dg3gqDFTfxmoMPLzIl1+A
    LOZKi3MoU750QQTJlL34tPLJhOS+1PVgzldlFsnZu3T/BNPg+i7joZNdSlJXlx2m
    F0b1WPZ01ELUGYTlkgEiFkJrytjNjDrInHV4HgcGUZYUoZN6PYOKbmSyw1xA32M6
    8R1hCybIyCyEqHP0x6OnZPDzWIKwUCfl03LKJ5qT8zSWXxapOqCOMbME/DiWpxA7
    B7oMt3JAVvLELBQiZS2zk020rV+4RCGpQsitk0lHsq9CraGL00nHQdtqq9cIhJJM
    9phBuUcZfmUKjToZ3vJozVehUQfxpUHwvah68WbRFOcTDeI9xfxE/NDBc6XaMi5m
    PzjGsSdGflL+bDQ98GmKswnl7jwmFw0amYVCMji2yBxnxt7nllLkZGGXKYZMouSe
    UxPKc04zq0FaSknByYmBDjpnqzArfgv1mAsIobOrlWpFS6FRJ3qaeq54TCXMgynO
    nLnSZw50osy14YSzxfUos/ijlHmseSI7bh7jfLfIbRYErnEzw0VCNjpSdhiVDSMV
    mRi1rYGrHFa7pSGzToEJNyUlz1Uz7zK2O+I8co/LFwztC7ou3LaMtx14ZX7d4od3
    2X5wv1iWvgGsixy3jcpwVSQjbYdZmbrQVkZv6h7Xd6qRoT1I0NPK1MsDw03EFuld
    xrZV09GrjG3P1Z7HzvSdfC8+Qa4w9YnBQib9caMONee0x7ky7QllZGqcz4VhMmVj
    c2daPcdSpnzp6hfmQsQEcXEd4Jwv7q60pz6s4anNglkuGPilfOIDk6rQWGMarj9D
    bpg/tv+R6bPytcxz7UXMS/4TveS/1W9aPkPU9g0AAA==
    } "jack of spades" 11 "black" 100x140
    64#{
    eJzNlz1y3DgQhXtdTlAou6+gcrTn2GQj32FP4VhHQNqlgFdAOoVgFeyBELmKibHv
    NTg0CXA1CjYwR9RQmG9e/7JB/fH1+yfx4xvO33H+ifMvnL/JR19/xuf/fO7n+Xj2
    H3l+7m984eL19RXvXGn+I631N764hF9fRqnp+PD01B4d9UkfMk3+B0YAPGCqR/iA
    0fbLMv9RBj0ym1qNJcdQa1XpyyNTqVdyCVWVqcPCxPhyKWCaQKkzhxyqpxQXEbYU
    H246x1qou61kSlBtNfBaodPaT4aqQlvZuB6kM3pktliLgJEqmpzpFjam9oTUGIPB
    mZ2hsYFB8GFRfBlMLfns857YbKltTM7n2HcmWHXGlDq+dsG4E7Iq/RmZWsnY4itX
    DKKtvCuDJXjC4NW/AmyqF9xBivmV5HH9+NzGeoktkpliJkiG/Gz9E0xKjCI5bjrt
    WIt14V8QQ+VBFcQwMmsKC2QYR8k4i+fuxIjFbC2bQSlGFB+choEJ0KlRLQGCRzG7
    TycmyApE8koIOjAVbyOTVWORqKshrx5atCgnJnZfU250KdLtK4YYmhDWtIc2Md7Q
    lrItsIZUi9yWmfGOziiGJYYVb+mCqWYMGdbk9gJ3dGAQF1sDq1UgBKZYHRn2Ukgs
    uYQVDEyNOuJxUUZXUdgslkadiCplyrD3ZIXHppNOKbHsa8EMMrNOYd6OI+xCB8t2
    PGYd7yo9vTyEE8N76fxiYQcGt+DZFjt70tGTzwwiXuvsfyMVZdYJViTULY05IV2z
    jr1gXi4SOJG3nht1xEo09KGw3bLRuzDqrC+ZzJK6DHvlNuoE9lUOtiLqEjjx2uQP
    PJai3qvezzozahm3aMbkaGz9JDIz4SXznoEQrOWt5ybGcysQWmpOjl8wlbNA0WFs
    y4KBeI5LY+AY4DCosFZzlGYtDIxk7UMFhbCFiFg9M4Etk6ETfY6nv9fkO8eRYR19
    XHhbc/eCThv6Odd9WmpzI9ZmBk5gFMCj1frOfWA4pmlrEZ8wGUNRtx14Z3zcUwfL
    yslo+0Z7Z/q2wc+5j7aaVtt3mDvTb0qYCT0dMNXuO9UVQ9ewZbT9fj4y8Kf1zbau
    F0zfVnNutTPononp23O5MxxQ7b6Tn/PD1Cy8z4PFqBPDq41B8BiKcTOmx1pIZ9Q3
    1FTKZuxYr9qZxgcsDZiX+5POyWf1By20Zwuo/H0HbqfYO4MnrLpyF5zr1e4MhGSF
    LTK1TQyv8cRXoYM7SIf+6Y9318eJefP4BRmvzNtMu4f4FvPweBfznv+J3vO/1b/O
    39P79g0AAA==
    } "queen of spades" 12 "black" 180x140
    64#{
    eJytVzuS1DAQbSgSlYrtK2wRcQ4SIu7AKYjnCE5dE3AFpVNKNuBAHREi3mtZXkv2
    4F1AXtuz9pvXrz9qaT59+flefHzD+RHnZ5xfcb6Rd/78gvc/HurZj4v/yeVSbzzw
    4enpCXc+Kf4npdQbDz7C5cNItRtvHx/L2bBHPcUU+XeMiIn+B4xH4Axjeo7xwJ5h
    7FU8d9KgWz28Wl5HI9etX36VxAFI4jf8semAsYkDMP7nL3QbQ/FrmDEA+053ZIfR
    VTlQ9aMu9KtfLsGVeynyKkcYhavFMBZGLZWqw9C6EGM1PACYDLYob8CQbbCl1VYL
    s7q6E4xfX4+BwoYxu4OBPqualUDmSzs9YuAhxGTNV/n1sPXdqKdUW9ryNcTH3JY6
    ka310+XCohDEGMKqHGJUEtWpW+LnA8wEoinBjDJptygHGCFR8oBIihIXzR1mBlGI
    BKSEe4pxXz9CY3iXRMKUJtxm2fHMMMZXOc+44Yg3HXmCC5qzRGBACKK046ExYMAD
    YRhyvfUYjCZaJPoBwh4Tc6qiWfbgy3Tv2mEiZFBQRE1YoRo4GHKPSZYXDAb8I08c
    9CjjQedpK1WeUQ+nMJ8nzkIE+UAPJxK+7GHxjLqe0XefdzGw/WTyMGXzwMMo54WH
    eQdVkJEHmXJb0HWLEV6J9TmFywwcbBFDHhSUDTxBSL/aiqw37XnCVRahVbN3jYEn
    3NzbZ81rj9rkYhZ23bjEkHgGdbTlUZaaCxRimIaGWkImT0o+e5h3DUxzb6vqea4N
    YFBTB3oYuFpjCOCU817PUqGeNmJqG9/qmVjmIYZrzjfOC4Nfw7y4TR6WNF8l3ji/
    FJHvMUrHfH5dc/J61DDyqIXJX80+46vokQfOsKoCW8IiesfDlaDlXVub2WHAhOpB
    c1WfPTS2x4ApedNE3ap599tjADKSsHUqgm1HmLI0XmWHZf5XjMmiWUptz/6lHsN2
    31brdTGA1Q3Glw1tq4hD3FbZYNaFylejZdkpdzD+oerRv8D4snqC8eVZ22rtkkle
    yi4+W4xvRHqeumNo+6Y1hj2m1o+smxF/Xg4wy26GpS5tRmwa6mLdCbBD4kapdjkb
    MfVbrFXfcm3KQeq2zOuw1L2d79yqlGeMtUbDNaGN1GPkD3vIlotGcm8QcwJ5KY+e
    ES1+nWA8hv8BcyLmpZiX/CZ6yW+r3/c0VV/2DQAA
    } "king of spades" 13 "black" 260x140
    64#{
    eJztlzEOAiEQRdHYkKzDFYiV57Cx8g6ewpoj0O5tKCw5BAfYbLayxZmhUpMB+xl4
    y4b9gc3r5nJ7HQ3XAzkjV+SO7MyB9wN+f0LjswJPE0JbaOBLSglX2qk8Ta1toUFb
    +Dh9H/VTe+9rrzbvuplqXO1chQG3WcggYCgzxyVJcAYmK8DnxLXMApEyE9hZgDMZ
    b5WgDGQLAvw/ZUmrQFE/6kf9qB/1o37Uj/pRP+pH/fzlZ6QHGehlRnqikd7qDVAb
    l+X2DQAA
    } "card back side" 0 "none" -200x-200
] 

