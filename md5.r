REBOL [
	Title:   "MD5 Message-Digest Algorithm"
	Author:  "Marco Antoniazzi"
	file: %md5.r
	Rights:  "derived from the RSA Data Security, Inc. MD5 Message-Digest Algorithm"
	email: [luce80 AT libero DOT it]
	date: 16-12-2012
	version: 2.0.1
	Purpose: {Returns a MD5 "message digest" of an input string as a binary!}
	History: [
		0.0.1 [11-11-2012 "Start"]
		1.0.0 [24-11-2012 "Works"]
		1.0.1 [03-12-2012 "Revised leftrotate"]
		2.0.0 [15-12-2012 "Added incremental behaviour and hmac-md5"]
		2.0.1 [16-12-2012 "Fixed to-uint32 and length calc"]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [encryption]
		tested-under: [View 2.7.8.3.1]
		support: none
		License: "http://en.wikipedia.org/wiki/Wikipedia:Text_of_Creative_Commons_Attribution-ShareAlike_3.0_Unported_License"
	]
	Notes: {
		taken from: http://en.wikipedia.org/wiki/MD5
		using symbols found in RFC 1321
		Not fast but compact
		
		NO WARRANTIES. USE AT YOUR OWN RISK.
		
		Bugs: length of message must be < 2^63 bytes
	}
]

ctx-md5: context [
	; convenience functions
	int-to-bin: func [num [integer!]][reverse debase/base to-hex num 16] ; reversed
	to-uint32: func [num [decimal!]][while [num < 0] [num: num + 4294967296] while [num > 2147483647] [num: num - 4294967296] to integer! num]

	;leftrotate function definition ;(x << c) or (x >> (32 - c))
	leftrotate: func [x [integer!] c [integer!] /local a b] [
		(shift/left x c) or shift/logical x (32 - c)
	]

	;Note: All variables are unsigned 32 bit and wrap modulo 2^32 when calculating

	;s specifies the per-round shift amounts
	s:	[7 12 17 22 7 12 17 22 7 12 17 22 7 12 17 22
		 5  9 14 20 5  9 14 20 5  9 14 20 5  9 14 20
		 4 11 16 23 4 11 16 23 4 11 16 23 4 11 16 23
		 6 10 15 21 6 10 15 21 6 10 15 21 6 10 15 21]

	T: copy []
	;Use binary integer part of the sines of integers (Radians) as constants:
	for i 1 64 1 [
		sin: abs (sine/radians i) * 4294967296
		sin: to-decimal head clear find form sin "." ; integer part
		append T to-uint32 sin
	]

	set 'md5 func [[catch]
		{Returns a "message digest" of the input string as binary!}
		message [any-string!] "input string"
		/with md5-context [block!] "initial context"
		/local
		final-length
		AA BB CC DD
		i j X-j byte
		A B C D F X
		temp n pad?
		][

		message: to-binary message

		final-length: round/ceiling/to (length? message) + 1 + 8 64 ; At least 1 byte for padding single 1 bit and 8 bytes for message length (in bits)
		temp: length? message
		pad?: true

		either none? md5-context [
			md5-context: copy [0  0 0 0 0]
		][
			if 5 <> length? md5-context [throw make error! "md5-context length must be 5"]
			if md5-context/1 = 0 [
				if 0 <> mod temp 64 [throw make error! "message length must be a multiple of 64 bytes"]
				final-length: temp
				pad?: false
			]
		]

		either md5-context/1 = 0 [
			temp: 8.0 * temp ; length in bits of message
			md5-context/2: 1732584193
			md5-context/3: -271733879
			md5-context/4: -1732584194
			md5-context/5: 271733878
		][
			temp: 8 * temp + md5-context/1
		]
		i: to-integer temp / 4294967296 ; high 32 bits
		j: to-integer temp - (i * 4294967296) ; low 32 bits
		md5-context/1: temp

		if pad? [

		;Step 1. Append Padding Bits
			;Pre-processing: adding a single 1 bit and padding with zeros until message length in bit is multiple of 512
			insert tail message #{80} ; padding single 1 bit
			insert/dup tail message #{00} final-length - (length? message) - 8

		;Step 2. Append Length
			temp: join int-to-bin j int-to-bin i
			; put length mod (2 pow 64) to message
			message: head insert tail message temp
		]

		;Step 3. Initialize MD Buffer
			;Initialize variables:
			A: md5-context/2
			B: md5-context/3
			C: md5-context/4
			D: md5-context/5

		;Step 4. Process Message in 16-Word Blocks
			;Process the message in successive 512-bit chunks:
			;for each 512-bit chunk of message
			for byte 1 final-length 64 [
				;break chunk into sixteen 32-bit words X[j] 0 <= j <= 15
					X-j: at message byte
				;Initialize hash value for this chunk:
					AA: A
					BB: B
					CC: C
					DD: D
				;Main loop:
					for i 0 63 1 [
						case [
							all [0 <= i i <= 15] [
								F: (B and C) or ((complement B) and D)
								j: i
							]
							all [16 <= i i <= 31] [
								F: (B and D) or (C and (complement D))
								j: mod (5 * i + 1) 16
							]
							all [32 <= i i <= 47] [
								F: B xor C xor D
								j: mod (3 * i + 5) 16
							]
							all [48 <= i i <= 63] [
								F: C xor (B or (complement D))
								j: mod (7 * i) 16
							]
						]

						X: to-integer reverse copy/part at X-j (j * 4 + 1) 4
						temp: D
						D: C
						C: B
						;B: B + leftrotate (A + F + X + T/(i + 1))  s/(i + 1)
						n: to-uint32 0.0 + A + F + X + T/(i + 1)
						B: to-uint32 0.0 + B + leftrotate n s/(i + 1)
						A: temp
					]

	     			;Add this chunk's hash to result so far:
				    A: to-uint32 0.0 + A + AA
				    B: to-uint32 0.0 + B + BB
				    C: to-uint32 0.0 + C + CC
				    D: to-uint32 0.0 + D + DD
			]

			md5-context/2: A
			md5-context/3: B
			md5-context/4: C
			md5-context/5: D

		;Step 5. Output ;
			rejoin [int-to-bin A int-to-bin B int-to-bin C int-to-bin D]
	]
	
	{ Krawczyk, et. al. RFC 2104
	** Function: hmac_md5
	}

	set 'hmac-md5 func [
		text [any-string!] { data stream }
		key [any-string!] { authentication key }
		/local
		k_ipad
		k_opad
		i
		][
		k_ipad: copy #{} { inner padding - key XORd with ipad}
		k_opad: copy #{} { outer padding - key XORd with opad}

		; if key is longer than 64 bytes reset it to key=MD5 key
		if (length? key) > 64 [key: md5 key]

		{
			* the HMAC_MD5 transform looks like:
			*
			* MD5(K XOR opad, MD5(K XOR ipad, text)) 
			*
			* where K is an n byte key
			* ipad is the byte 54 repeated 64 times
			* opad is the byte 92 repeated 64 times
			* and text is the data being protected
		}

		; XOR key with ipad and opad values 
		for i 1 64 1 [
			insert tail k_ipad to-char (any [key/:i 0]) xor 54
			insert tail k_opad to-char (any [key/:i 0]) xor 92
		]

		md5 join k_opad md5 join k_ipad text
	]
]

;comment [
do [
probe md5 ""
probe md5 "a"
probe md5 "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
md5-ctx: [0  0 0 0 0] ; initialize md5 context
md5/with "1234567890123456789012345678901234567890123456789012345678901234" md5-ctx
probe md5/with "5678901234567890" md5-ctx
probe hmac-md5 "what do ya want for nothing?" "Jefe"
halt
]
