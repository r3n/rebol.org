REBOL [
	Title:   "SHA2 Message-Digest Algorithm"
	Author:  "Marco Antoniazzi"
	file: %sha2.r
	email: [luce80 AT libero DOT it]
	date: 22-03-2013
	version: 1.0.0
	Purpose: {Returns a sha2 "message digest" of an input string as a binary!}
	History: [
		1.0.0 [22-03-2013 "Started and finished"]
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
		taken from: FIPS 180-4
		taken from: http://en.wikipedia.org/wiki/sha-2
		Not fast but compact
		
		NO WARRANTIES. USE AT YOUR OWN RISK.
		
		Bugs: length of message must be < 2^63 bytes
	}
]

ctx-sha2: context [
	; convenience functions
	int-to-bin: func [num [integer!]][debase/base to-hex num 16] ; big-endian
	to-uint32: func [num [decimal!]][while [num < 0] [num: num + 4294967296] while [num > 2147483647] [num: num - 4294967296] to integer! num]

	rightrotate: func [x [integer!] c [integer!]] [
		(shift/logical x c) or shift/left/logical x (32 - c)
	]
	rightshift: func [x [integer!] c [integer!]] [
		shift/logical x c
	]

	;Note 1: All variables are unsigned 32 bits and wrap modulo 2^32 when calculating
	;Note 2: All constants in this code are in big endian. 
	;        Within each word, the most significant byte is stored in the leftmost byte position

	set 'sha2 func [[catch]
		{Returns a SHA2 "message digest" of the input string as binary!}
		message [any-string!] "input string"
		/sha-224 "Returns a SHA-224"
		/sha-256 "Returns a SHA-256 (this is the default)"
		/with sha2-context [block!] "initial context"
		/local
		final-length
		a b c d e f g h
		i j w-t w
		h0 h1 h2 h3 h4 h5 h6 h7
		ch s0 s1 maj byte
		temp pad?
		][

		message: to-binary message

		k: [
			 1116352408  1899447441 -1245643825  -373957723   961987163  1508970993 -1841331548 -1424204075
			 -670586216   310598401   607225278  1426881987  1925078388 -2132889090 -1680079193 -1046744716
			 -459576895  -272742522   264347078   604807628   770255983  1249150122  1555081692  1996064986
			-1740746414 -1473132947 -1341970488 -1084653625  -958395405  -710438585   113926993   338241895
			  666307205   773529912  1294757372  1396182291  1695183700  1986661051 -2117940946 -1838011259
			-1564481375 -1474664885 -1035236496  -949202525  -778901479  -694614492  -200395387   275423344
			  430227734   506948616   659060556   883997877   958139571  1322822218  1537002063  1747873779
			 1955562222  2024104815 -2067236844 -1933114872 -1866530822 -1538233109 -1090935817  -965641998
		]
		
		final-length: round/ceiling/to (length? message) + 1 + 8 64 ; At least 1 byte for padding single 1 bit and 8 bytes for message length (in bits)
		temp: length? message
		pad?: true

		either none? sha2-context [
			sha2-context: copy [0  0 0 0 0 0 0 0 0]
		][
			if 9 <> length? sha2-context [throw make error! "sha2-context length must be 6"]
			if sha2-context/1 = 0 [
				if 0 <> mod temp 64 [throw make error! "message length must be a multiple of 64 bytes"]
				final-length: temp
				pad?: false
			]
		]

		either sha2-context/1 = 0 [
			temp: 8.0 * temp ; length in bits of message
			either sha-224 [
				sha2-context/2: -1056596264
				sha2-context/3: 914150663
				sha2-context/4: 812702999
				sha2-context/5: -150054599
				sha2-context/6: -4191439
				sha2-context/7: 1750603025
				sha2-context/8: 1694076839
				sha2-context/9: -1090891868
			][
				sha2-context/2: 1779033703
				sha2-context/3: -1150833019
				sha2-context/4: 1013904242
				sha2-context/5: -1521486534
				sha2-context/6: 1359893119
				sha2-context/7: -1694144372
				sha2-context/8: 528734635
				sha2-context/9: 1541459225
			]
		][
			temp: 8 * temp + sha2-context/1
		]
		i: to-integer temp / 4294967296 ; high 32 bits
		j: to-integer temp - (i * 4294967296) ; low 32 bits
		sha2-context/1: temp

		if pad? [

		;Step 1. Append Padding Bits
			;Pre-processing:
			;append the bit '1' to the message
			insert tail message #{80} ; padding single 1 bit
			;append 0 = k < 512 bits '0', so that the resulting message length (in bits)
			;   is congruent to 448 (mod 512)
			insert/dup tail message #{00} final-length - (length? message) - 8

		;Step 2. Append Length
			;append length of message (before pre-processing), in bits, as 64-bit big-endian integer
			message: head insert tail message join int-to-bin i int-to-bin j 2
		]

		;Step 3. Initialize main Buffer
			;Initialize variables:
			h0: sha2-context/2
			h1: sha2-context/3
			h2: sha2-context/4
			h3: sha2-context/5
			h4: sha2-context/6
			h5: sha2-context/7
			h6: sha2-context/8
			h7: sha2-context/9

		;Step 4. Process Message in 16-Word Blocks
			w: array 64
			;Process the message in successive 512-bit chunks:
			;break message into 512-bit chunks
			for byte 1 final-length 64 [
				;break chunk into sixteen 32-bit big-endian words w[i], 0 <= i <= 15
					w-t: at message byte
				;Extend the sixteen 32-bit words into eighty 32-bit words:
					for i 1 64 1 [
						either i <= 16 [
							w/(i): to integer! copy/part at w-t (i * 4 - 3) 4
						][
							s0: (rightrotate w/(i - 15) 7) xor (rightrotate w/(i - 15) 18) xor (rightshift w/(i - 15) 3)
							s1: (rightrotate w/(i - 2) 17) xor (rightrotate w/(i - 2) 19) xor (rightshift w/(i - 2) 10)
							w/(i): to-uint32 0.0 + w/(i - 16) + s0 + w/(i - 7) + s1
						]
					]
				;Initialize hash value for this chunk:
					a: h0
					b: h1
					c: h2
					d: h3
					e: h4
					f: h5
					g: h6
					h: h7
				;Main loop:
					for i 1 64 1 [
						S1: (rightrotate e 6) xor (rightrotate e 11) xor (rightrotate e 25)
						ch: (e and f) xor ((complement e) and g)
						temp: 0.0 + h + S1 + ch + k/:i + w/:i
						d: to-uint32 d + temp
						S0: (rightrotate a 2) xor (rightrotate a 13) xor (rightrotate a 22)
						maj: (a and (b xor c)) xor (b and c)
						temp: to-uint32 0.0 + temp + S0 + maj

						h: g
						g: f
						f: e
						e: d
						d: c
						c: b
						b: a
						a: temp
					]

				;Add this chunk's hash to result so far:
					h0: to-uint32 0.0 + h0 + a
					h1: to-uint32 0.0 + h1 + b 
					h2: to-uint32 0.0 + h2 + c
					h3: to-uint32 0.0 + h3 + d
					h4: to-uint32 0.0 + h4 + e
					h5: to-uint32 0.0 + h5 + f
					h6: to-uint32 0.0 + h6 + g
					h7: to-uint32 0.0 + h7 + h
			]

			sha2-context/2: h0
			sha2-context/3: h1
			sha2-context/4: h2
			sha2-context/5: h3
			sha2-context/6: h4
			sha2-context/7: h5
			sha2-context/8: h6
			sha2-context/9: h7

		;Step 5. Output ;
			;Produce the final hash value (big-endian):
			temp: rejoin [int-to-bin h0 int-to-bin h1 int-to-bin h2 int-to-bin h3 int-to-bin h4 int-to-bin h5 int-to-bin h6 either sha-224 [#{}][int-to-bin h7] ]
	]
	
]
	hmac: func [
		hasher [function!] {hashing function}
		text [any-string!] { data stream }
		key [any-string!] { authentication key }
		/local
		k_ipad
		k_opad
		i
		][
		k_ipad: copy #{} { inner padding - key XORd with ipad}
		k_opad: copy #{} { outer padding - key XORd with opad}

		if (length? key) > 64 [key: copy/part hasher key 64]

		; XOR key with ipad and opad values 
		for i 1 64 1 [
			insert tail k_ipad to-char (any [key/:i 0]) xor 54
			insert tail k_opad to-char (any [key/:i 0]) xor 92
		]

		hasher join k_opad hasher join k_ipad text
	]

;comment [
do [
	probe sha2/sha-224 ""
	probe sha2 "abc"
	probe sha2 "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
	probe sha2 "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	sha2-ctx: [0  0 0 0 0 0 0 0 0] ; initialize sha2 context
	sha2/with "1234567890123456789012345678901234567890123456789012345678901234" sha2-ctx
	probe sha2/with "5678901234567890" sha2-ctx
	probe hmac :sha2 #{5361 6D706C65 206D6573 73616765 20666F72 206B6579 6C656E3C 626C6F63 6B6C656E} #{00010203 04050607 08090A0B 0C0D0E0F 10111213 14151617 18191A1B 1C1D1E1F}
	halt
]
