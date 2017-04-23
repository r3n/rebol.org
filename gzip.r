REBOL [
    Title: "gzip"
    Date: 8-Jan-2013
    Version: 1.1.0
    File: %gzip.r
    Author: "Vincent Ecuyer"
    Purpose: "Creates gzip archives, using the rebol compress command."
    Usage: {
        ;REBOL 2:
        my-data: #{........}
        write/binary %test.gz gzip/name my-data %my-file.txt
		
        ;REBOL 3:
        my-data: #{........}
        write %test.gz gzip/name my-data %my-file.txt
    }
    Comment: {
        COMPRESS uses a zlib compatible format - always with
        deflate algorithm, 32k window size, max compression
        and no dictionnary - followed by checksum (4 bytes) and
        uncompressed data length (4 bytes).
		
        For REBOL 2.x, this module uses a precalculated crc table, and
        for REBOL 3.x, it uses the available 'crc32 checksum method.
		
        r3 compress/gzip is bugged (wrong checksum), so it isn't used.
    }
    History: [
        1.0.0 [1-Jan-2004 "First version"]
        1.1.0 [8-Jan-2013 "Now both REBOL 2 and REBOL 3 compatible"]
    ]
    Library: [
        level: 'advanced
        platform: 'all
        type: [module tool]
        domain: [compression file-handling files]
        tested-under: [
            view 1.2.1.3.1  on [WinXP]
            view 2.7.8.2.5 on [Macintosh osx-x86]
            core 2.5.6.2.4 on [Macintosh osx-x86]
            core 2.7.8.3.1 on [WinXP]
            core 2.7.8.2.5 on [Macintosh osx-x86] 
            core 2.100.111.2.5 on [Macintosh osx-x86]
            core 2.101.0.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'public-domain
        see-also: none
    ]
]

ctx-gzip: context [
    crc-long: [
                 0   1996959894  -301047508 -1727442502   124634137  1886057615
        -379345611  -1637575261   249268274  2044508324  -522852066 -1747789432
         162941995   2125561021  -407360249 -1866523247   498536548  1789927666
        -205950648  -2067906082   450548861  1843258603  -187386543 -2083289657
         325883990   1684777152   -43845254 -1973040660   335633487  1661365465
         -99664541  -1928851979   997073096  1281953886  -715111964 -1570279054
        1006888145   1258607687  -770865667 -1526024853   901097722  1119000684
        -608450090  -1396901568   853044451  1172266101  -589951537 -1412350631
         651767980   1373503546  -925412992 -1076862698   565507253  1454621731
        -809855591  -1195530993   671266974  1594198024  -972236366 -1324619484
         795835527   1483230225 -1050600021 -1234817731  1994146192    31158534
       -1731059524   -271249366  1907459465   112637215 -1614814043  -390540237
        2013776290    251722036 -1777751922  -519137256  2137656763   141376813
       -1855689577   -429695999  1802195444   476864866 -2056965928  -228458418
        1812370925    453092731 -2113342271  -183516073  1706088902   314042704
       -1950435094    -54949764  1658658271   366619977 -1932296973   -69972891
        1303535960    984961486 -1547960204  -725929758  1256170817  1037604311
       -1529756563   -740887301  1131014506   879679996 -1385723834  -631195440
        1141124467    855842277 -1442165665  -586318647  1342533948   654459306 
       -1106571248   -921952122  1466479909   544179635 -1184443383  -832445281 
        1591671054    702138776 -1328506846  -942167884  1504918807   783551873 
       -1212326853  -1061524307  -306674912 -1698712650    62317068  1957810842 
        -355121351  -1647151185    81470997  1943803523  -480048366 -1805370492 
         225274430   2053790376  -468791541 -1828061283   167816743  2097651377 
        -267414716  -2029476910   503444072  1762050814  -144550051 -2140837941 
         426522225   1852507879   -19653770 -1982649376   282753626  1742555852 
        -105259153  -1900089351   397917763  1622183637  -690576408 -1580100738 
         953729732   1340076626  -776247311 -1497606297  1068828381  1219638859 
        -670225446  -1358292148   906185462  1090812512  -547295293 -1469587627 
         829329135   1181335161  -882789492 -1134132454   628085408  1382605366 
        -871598187  -1156888829   570562233  1426400815  -977650754 -1296233688 
         733239954   1555261956 -1026031705 -1244606671   752459403  1541320221
       -1687895376   -328994266  1969922972    40735498 -1677130071  -351390145
        1913087877     83908371 -1782625662  -491226604  2075208622   213261112 
       -1831694693   -438977011  2094854071   198958881 -2032938284  -237706686 
        1759359992    534414190 -2118248755  -155638181  1873836001   414664567 
       -2012718362    -15766928  1711684554   285281116 -1889165569  -127750551 
        1634467795    376229701 -1609899400  -686959890  1308918612   956543938 
       -1486412191   -799009033  1231636301  1047427035 -1362007478  -640263460
        1088359270    936918000 -1447252397  -558129467  1202900863   817233897 
       -1111625188   -893730166  1404277552   615818150 -1160759803  -841546093 
        1423857449    601450431 -1285129682 -1000256840  1567103746   711928724 
       -1274298825  -1022587231  1510334235   755167117
    ]

    right-shift-8: func [
        "Right-shifts the value by 8 bits and returns it."
        value [integer!] "The value to shift"
    ][
        either negative? value [
            -1 xor value and -256 / 256 xor -1 and 16777215
        ][
            -256 and value / 256
        ]
    ]
    
    update-crc: func [
        "Returns the data crc."
        data [any-string!] "Data to checksum"
        crc [integer!] "Initial value"
    ][
        foreach char data [
             crc: (right-shift-8 crc) xor pick crc-long crc and 255 xor char + 1
        ]
    ]

    crc-32: func [
        "Returns a CRC32 checksum."
        data [any-string! binary!] "Data to checksum"
    ] either system/version/2 < 100 [[
        either empty? data [#{00000000}][
            load join "#{" [to-hex -1 xor update-crc data -1 "}"]
        ]
    ]][[
        either empty? data [#{00000000}][
            copy skip to-binary checksum/method to-binary data 'crc32 4
        ]
    ]]

    timestamp: func [
        "Returns the gzip timestamp."
        value [date!] "Date to encode."
    ][
        copy/part head reverse do join "#{" [
            next mold to-hex (value - 01/01/1970) * 86400
            + to-integer value/time - value/zone
            "}"
        ] 4
    ]

    set 'gzip func [
        "Compresses a string series into a gzip encoding."
        data [any-string! binary!] "Data to compress"
        /name "Specifies a filename."
        file [any-string!] "Filename to use in archive."
    ][
        head change skip tail join #{1F8B08} [
            either name [#{08}][#{00}]
            timestamp now
            #{02FF}
            either name [join to-binary file #{00}][#{}]
            next next compress data
        ] -8 head reverse crc-32 data
    ]
]
