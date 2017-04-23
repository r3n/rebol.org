REBOL [ 

 Title: "compress , decompress witch zlib stream" Date: 29-Mar-2015 Version: 1.0.0 File: %zlib.r

]
	


 system/words/&: func [ "Return the memory address of a binary, string or struct as a binary value" b [binary! string! struct!] ][ third make struct! [s [string!]] reduce [either struct? b [third b][b]] ]


address?: function [
    {get the address of a string}
    s 
] [address] [
    s: make struct! [s [string!]] reduce [s]
    address: make struct! [i [integer!]] none
    change third address third s
    address/i
]



zlib: context [ 

  library:  load/library switch system/version/4  [ 3 [%zlib.dll] 4 [%zlib.so]  ]


  Z_FINISH:  4

  Z_OK: 0

  Z_BEST_SPEED: 1   ; 2 razy szybsze
  Z_DEFAULT_COMPRESSION: -1
 	Z_BEST_COMPRESSION:   9

  Z_DEFLATED: 8

  MAX_WBITS: 15 

 MAX_MEM_LEVEL: 9

 Z_DEFAULT_STRATEGY: 0



Z_STREAM_END: 1




  stream: make struct! [
		*next_in  [integer!] ;  /* next input byte */
		avail_in  [integer!] ;  /* number of bytes available at next_in */
		total_in  [integer!]     ;/* total nb of input bytes read so far */
		*next_out [integer!] ; /* next output byte should be put there */
		avail_out [integer!] ; /* remaining free space at next_out */
		total_out [integer!]     ; /* total nb of bytes output so far */
		*msg      [integer!] ;      /* last error message, NULL if no error */
		*state    [integer!] ; /* not visible by applications */
		zalloc    [integer!] ;  /* used to allocate the internal state */
		zfree     [integer!] ;   /* used to free the internal state */
		opaque    [integer!] ;  /* private data object passed to zalloc and zfree */
		data_type [integer!] ;  /* best guess about the data type: binary or text */
		adler     [integer!] ;      /* adler32 value of the uncompressed data */
		reserved  [integer!];   /* reserved for future use */
	] none




version: make routine! [ 
                           return:  [string!]

			] library "zlibVersion"

adress:  address?  version

   
deflateInit: make routine! [
				stream   [struct* [(first z_stream)] ]
				level       [integer!]
                                version [integer!]
				size    [integer!]

				return:      [integer!]

			]  library "deflateInit_"


deflateInit2: make routine! [
				stream   [struct* [(first z_stream)]]
				level       [integer!]
                                method       [integer!]
                                windowBits  [ integer!]
                                memLevel    [integer!]
                                strategy   [integer!]
                                version [integer!]
				size    [integer!]
                                
				return:      [integer!]

			] library "deflateInit2_"




deflateBound: make routine! [
				stream   [struct* [(first z_stream)]] 
                                sourceLen        [integer!]
				
				return:      [integer!]

			] library "deflateBound"





deflate: make routine! [
				stream   [struct* [(first z_stream)]] 
                                flush        [integer!]
				
				return:      [integer!]

			] library "deflate"



deflateEnd: make routine! [
				stream   [struct* [(first z_stream)]] 
				
				return:      [integer!]

			] library "deflateEnd"













inflateInit: make routine! [
				stream   [struct* [(first z_stream)] ]
				version [integer!]
				size    [integer!]

				return:      [integer!]

			]  library "inflateInit_"


inflateInit2: make routine! [
				stream   [struct* [(first z_stream)]]
				windowBits  [ integer!]
                                version [integer!]
				size    [integer!]
                                
				return:      [integer!]

			] library "inflateInit2_"





inflate: make routine! [
				stream   [struct* [(first z_stream)]] 
                                flush        [integer!]
				
				return:      [integer!]

			] library "inflate"



inflateEnd: make routine! [
				stream   [struct* [(first z_stream)]] 
				
				return:      [integer!]

			] library "inflateEnd"
















  tmp: make binary! make bitset! 8 * 10000000 ; 10 mb
  

compress:  func [data  /gzip /deflate  /zlib /local windowbits s length result ][

  windowbits:  either deflate [  -15 ][  15 + any [all [gzip 16] all [zlib 0 ] 0 ] ]


  s: make struct! self/stream none

  s/*next_in:   address? data

  s/avail_in:   length? data


length: length? data

  s/*next_out:    address? tmp 

  s/avail_out:   24 + length



  result: deflateInit2 s Z_DEFAULT_COMPRESSION Z_DEFLATED  windowbits MAX_MEM_LEVEL Z_DEFAULT_STRATEGY adress length? third s


result: self/deflate s  Z_FINISH ; return 


result: deflateEnd s ; return 0


return  as-binary copy/part tmp s/total_out

]


decompress: func [data  /gzip /deflate  /zlib /local windowbits s length result ][


  windowbits:  either deflate [  -15 ][  15 + any [all [gzip 16] all [zlib 0 ] 0 ] ]


  s: make struct! stream none

  s/*next_in:   address? data

  s/avail_in:  length? data
 
   length: 4 * length? data

  s/*next_out:    address? tmp 

  s/avail_out: length

  result: inflateInit2 s windowbits  adress  length? third s

  inflate s  Z_FINISH

  inflateEnd s

return as-string copy/part tmp s/total_out



]



test: func [ /local data tmp ][



data: "Hello word!"


tmp: compress data

print [ "compress zlib - " tmp ]

data: decompress tmp

print [ "decompress zlib - " data ]




tmp: compress/gzip data

print [ "compress zlib - " tmp ]

data: decompress/gzip tmp

print [ "decompress zlib - " data ]



tmp: compress/deflate data

print [ "compress deflate - " tmp ]

data: decompress/deflate tmp

print [ "decompress deflate - " data ]


halt
]
]

zlib/test


