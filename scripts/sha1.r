REBOL [
	Title:   "SHA1 Message-Digest Algorithm"
	Author:  "Marco Antoniazzi"
	file: %sha1.r
	email: [luce80 AT libero DOT it]
	date: 16-12-2012
	version: 1.0.0
	Purpose: {Returns a sha1 "message digest" of an input string as a binary!}
	History: [
		1.0.0 [16-12-2012 "Started and finished"]
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
		taken from: FIPS 180-1
		taken from: http://en.wikipedia.org/wiki/sha-1
		Not fast but compact
		
		NO WARRANTIES. USE AT YOUR OWN RISK.
		
		Bugs: length of message must be < 2^63 bytes
	}
]

ctx-sha1: context [
	; convenience functions
	int-to-bin: func [num [integer!]][debase/base to-hex num 16] ; big-endian
	to-uint32: func [num [decimal!]][while [num < 0] [num: num + 4294967296] while [num > 2147483647] [num: num - 4294967296] to integer! num]

	;leftrotate function definition ;(x << c) or (x >> (32 - c))
	leftrotate: func [x [integer!] c [integer!] /local a b] [
		(shift/left x c) or shift/logical x (32 - c)
	]

	;Note 1: All variables are unsigned 32 bits and wrap modulo 2^32 when calculating
	;Note 2: All constants in this code are in big endian. 
	;        Within each word, the most significant byte is stored in the leftmost byte position

	set 'sha1 func [[catch]
		{Returns a SHA1 "message digest" of the input string as binary!}
		message [any-string!] "input string"
		/with sha1-context [block!] "initial context"
		/local
		final-length
		a b c d e
		i j w-t w
		h0 h1 h2 h3 h4 f byte
		temp pad?
		][

		message: to-binary message

		final-length: round/ceiling/to (length? message) + 1 + 8 64 ; At least 1 byte for padding single 1 bit and 8 bytes for message length (in bits)
		temp: length? message
		pad?: true

		either none? sha1-context [
			sha1-context: copy [0  0 0 0 0 0]
		][
			if 6 <> length? sha1-context [throw make error! "sha1-context length must be 6"]
			if sha1-context/1 = 0 [
				if 0 <> mod temp 64 [throw make error! "message length must be a multiple of 64 bytes"]
				final-length: temp
				pad?: false
			]
		]

		either sha1-context/1 = 0 [
			temp: 8.0 * temp ; length in bits of message
			sha1-context/2: 1732584193
			sha1-context/3: -271733879
			sha1-context/4: -1732584194
			sha1-context/5: 271733878
			sha1-context/6: -1009589776
		][
			temp: 8 * temp + sha1-context/1
		]
		i: to-integer temp / 4294967296 ; high 32 bits
		j: to-integer temp - (i * 4294967296) ; low 32 bits
		sha1-context/1: temp

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
			message: head insert tail message join int-to-bin i int-to-bin j
		]

		;Step 3. Initialize main Buffer
			;Initialize variables:
			h0: sha1-context/2
			h1: sha1-context/3
			h2: sha1-context/4
			h3: sha1-context/5
			h4: sha1-context/6

		;Step 4. Process Message in 16-Word Blocks
			w: array 80
			;Process the message in successive 512-bit chunks:
			;break message into 512-bit chunks
			for byte 1 final-length 64 [
				;break chunk into sixteen 32-bit big-endian words w[i], 0 <= i <= 15
					w-t: at message byte
				;Extend the sixteen 32-bit words into eighty 32-bit words:
					for i 1 80 1 [
						either i <= 16 [
							w/(i): to-integer copy/part at w-t (i * 4 - 3) 4
						][
							w/(i): leftrotate (w/(i - 3) xor w/(i - 8) xor w/(i - 14) xor w/(i - 16)) 1
						]
					]
				;Initialize hash value for this chunk:
					a: h0
					b: h1
					c: h2
					d: h3
					e: h4
				;Main loop:
					for i 0 79 1 [
						case [
							all [0 <= i i <= 19] [
								f: (b and c) or ((complement b) and d)
								k: 1518500249
							]
							all [20 <= i i <= 39] [
								f: b xor c xor d
								k: 1859775393
							]
							all [40 <= i i <= 59] [
								f: (b and c) or (b and d) or (c and d) 
								k: -1894007588
							]
							all [60 <= i i <= 79] [
								f: b xor c xor d
								k: -899497514
							]
						]

						temp: to-uint32 0.0 + (leftrotate a 5) + f + e + k + w/(i + 1)
						e: d
						d: c
						c: leftrotate b 30
						b: a
						a: temp
					]

				;Add this chunk's hash to result so far:
					h0: to-uint32 0.0 + h0 + a
					h1: to-uint32 0.0 + h1 + b 
					h2: to-uint32 0.0 + h2 + c
					h3: to-uint32 0.0 + h3 + d
					h4: to-uint32 0.0 + h4 + e
			]

			sha1-context/2: h0
			sha1-context/3: h1
			sha1-context/4: h2
			sha1-context/5: h3
			sha1-context/6: h4

		;Step 5. Output ;
			;Produce the final hash value (big-endian):
			rejoin [int-to-bin h0 int-to-bin h1 int-to-bin h2 int-to-bin h3 int-to-bin h4]
	]
	
]

;comment [
do [
	probe sha1 ""
	probe sha1 "abc"
	probe sha1 "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
	probe sha1 "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	sha1-ctx: [0  0 0 0 0 0] ; initialize sha1 context
	sha1/with "1234567890123456789012345678901234567890123456789012345678901234" sha1-ctx
	probe sha1/with "5678901234567890" sha1-ctx
	halt
]
