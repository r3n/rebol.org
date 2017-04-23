REBOL [
	Title: "Similarity Metrics"
	File: %simetrics.r
	Date: 19-Feb-2006 
	Purpose: "Toolkit of string distance metrics."
	Version: 0.5.0
	Library: [
		Level: 'intermediate
		Platform: 'all
		Type: [function module tool]
		Domain: [ai math parse scientific text text-processing]
		tested-under: [
			core 2.5.6.3.1 on [WXP] "fvz"
		]
        Support: none
        License: 'bsd
        See-also: none
	]
	Author: "Francois Vanzeveren (fvz)"
	History: [
		0.5.0 [19-Feb-2006 {
			Improved interface for 'accumulate-statistics and 'get-similarity: 
				the corpus statistics are returned to the client and must be passed back
				to 'get-similarity for token-base metrics.
			} "fvz"]
		0.4.1 [19-Feb-2006 {
			- BUG FIX: recursive calls to get-similarity/jaro(-winkler) must be done with 'case and 'strict refinements.
			- Performance improvement: Jaccard metric accepts pre-tokenized source string.
		} "fvz"]
		0.4.0 [18-Feb-2006 {
			- NEW METRIC: Hybrid Jaccard - Jaro
			- NEW METRIC: Hybrid Jaccard - Jaro-Winkler} "fvz"]
		0.3.2 [18-Feb-2006 {
			- Some code improvement for 'sm-multiply 'sm-divide and 'sm-max (thanks to Marco)
			- NEW TOKENIZER: 'tokenize-text
		} "fvz"]
		0.3.1 [18-Feb-2006 {
			- Interface change for hybrid token-based metrics
			- BUG FIX: remove folders in the corpus} "fvz"]
		0.3.0 [17-Feb-2006 {
			NEW METRIC: Term Frequency-Inverse Document Frequency
			NEW METRIC: Term Frequency-Inverse Document Frequency with Jaro (slow!)
			NEW METRIC: Term Frequency-Inverse Document Frequency with Jaro-Winkler (slow!)
		} "fvz"]
		0.2.1 [12-Feb-2006 "BUG FIX: in simetrics/ctx-jaro/get-prefix-length. Thanks to Sunanda from Rebol.org" "fvz"]
		0.2.0 [11-Feb-2006 {
			- NEW METRIC: Jaccard Similarity
			- /case refinement: matching is case sensitive
			- /strict refinement: matching is non-english characters sensitive
		} "fvz"]
		0.1.1 [11-Feb-2006 {
			- The script is now compatible with older versions of rebol (i.e. < 2.6.x)
			- BUG FIX Levenshtein: the subtitution's cost was not properly computed from the deletion and insertion's costs
			- Levenshtein: result normalized
			- NEW METRIC: Jaro and Jaro-Winkler metrics
			- New interface: 'get-similarity is the unique entry point to all metrics
		} "fvz"]
		0.1.0 [10-Feb-2006 "Levenshtein distance implemented" "fvz"]
		0.0.1 [9-Feb-2006 "Created this file" "fvz"]
	]
]

simetrics: context [
	set 'accumulate-statistics function [
		"Accumulates and returns the statistics on the corpus of documents."
		corpus [file! block! hash!] "Path to where the collection of documents (the corpus) is stored, or the corpus itself!"
		tokenize [function!] "Splits a string into tokens."
	] [
		corpus-path
		document-frequency ; maps each word to the number of documents in which it appears
		; maps each document d of the corpus D to the number of times each
		; token/word w appears in d and the weight of w in d
		; The structure is:
		; [
		;	d1 [
		;		w1 [frequency weight]
		;		w2 [frequency weight]
		;		...
		;	]
		;	d2 [
		;		w1 [frequency weight]
		;		w2 [frequency weight]
		;		...
		;	]
		;	...
		; ]
		term-stats
		d-stats
		tokens prev-token
		pointer count corpus-size
		w w-stats w-count w-weight 
		err
	] [
		corpus-path: none
		if file? corpus [
			corpus-path: corpus
			corpus: read corpus-path
			forall corpus [
				either dir? join corpus-path first corpus
					[corpus: back remove corpus ]
					[insert corpus: next corpus none]
			]
			corpus: head corpus
		]
		
		document-frequency: make hash! []
		term-stats: make hash! []
		d-stats: make hash! []
		; The following loop count the frequencies of each token:
		;  * the number of documents in which a token w appears (document-frequency)
		;  * within each document, the frequency of token w (term-stats)
		foreach [doc-name doc] corpus [
			tokens: sort tokenize either doc [copy doc] [read join corpus-path doc-name]
			prev-token: none
			forall tokens [
				either not all [prev-token equal? prev-token first tokens] [
					; increment document frequency counts
					pointer: find document-frequency first tokens
					either pointer [
						count: add 1 first next pointer
						change next pointer count
					] [
						repend document-frequency [first tokens 1]
					]
					if prev-token [append d-stats compose/deep [(prev-token) [(w-count) 0]]]
					w-count: 1
				] [
					w-count: add w-count 1
				]
				prev-token: first tokens
			]
			repend term-stats [doc-name d-stats]
			d-stats: make hash! []
		]
		corpus: head corpus
		
		; The following computes the weight of each token w in each document of the corpus (term-stats)
		corpus-size: divide length? corpus 2
	
		forskip term-stats 2 [
			tokens: second term-stats
			forskip tokens 2 [
				w: first tokens
				w-stats: second tokens
				w-count: first w-stats
				w-weight: multiply 	w-count
						  			log-10 divide corpus-size
						  							select document-frequency w
				change next w-stats w-weight
			]
		]
		term-stats: head term-stats
		return reduce [document-frequency term-stats]
	]
	
	set 'get-similarity function [
		{Measures the similarity of two strings.}
		s [string! block!] "Source string or token multiset. Token multiset is ONLY for Jaccard metric!"
		/jaro 
			{Measures the similarity of two strings based on the 
			number and the order of common characters between them.}
			t-jaro [string!] "Target string"
		/jaro-winkler
			{Variant of the Jaro metric adjusting the weighting for common prefixes.}
			t-jaro-winkler [string!] "Target string"
		/levenshtein
			{Measures the distance (i.e. similarity) between two strings. 
			The distance is the number of edit operations (deletions, 
			insertions, substitutions) required to transform the source 
			string into the target string.}
			t-levenshtein [string!] "Target string"
		/levenstein {See /levenshtein.}
			t-levenstein [string!] "Target string"
		/del-cost dc [number!] "Deletion's cost. ONLY with /levenshtein refinement."
		/ins-cost ic [number!] "Insertion's cost. ONLY with /levenshtein refinement."
		/sub-cost sc [number!] "Substitution's cost. ONLY with /levenshtein refinement."
		/case "Characters are case-sensitive."
		/strict "Matching is non-english characters sensitive."
		
		; Token-Based Metrics
		/jaccard
			{Token based distance function. The Jaccard similarity between 
			word sets S and T is simply |S intersect T| / |S union T|}
			t-jaccard [string!] "Target string"
			tokenize-jaccard [function!] "Splits a string into tokens."
		/tfidf	"Term Frequency-Inverse Document Frequency Metric"
			corpus-stats [block!] "Corpus statistics as build and returned by 'accumulate-statistics."
			tokenize-tfidf [function!] "Splits a string into tokens."
		; Hybrid token-based metrics
		/jaro-hybrid "Hybrid token-based and Jaro-Winkler metric. ONLY with token-based metric."
		/jaro-winkler-hybrid "Hybrid token-based and Jaro-Winkler metric. ONLY with token-based metric."
	] [t tokenize] [
		t: any [t-jaro t-jaro-winkler t-levenshtein t-levenstein t-jaccard]
		tokenize: any [:tokenize-jaccard :tokenize-tfidf]
		; TOKEN-BASED METRICS
		if jaccard [
			use [s-bag t-bag current-score max-score score] [
				s-bag: unique either block? s [s] [tokenize s]
				t-bag: unique tokenize t
				either any [jaro-hybrid jaro-winkler-hybrid] [
					score: 0
					forall s-bag [
						current-score: max-score: 0
						forall t-bag [
							if jaro-hybrid 			[current-score: get-similarity/jaro/case/strict 		first s-bag first t-bag]
							if jaro-winkler-hybrid  [current-score: get-similarity/jaro-winkler/case/strict first s-bag first t-bag]
							max-score: max current-score max-score
						]
						t-bag: head t-bag
						score: add score max-score
					]
					s-bag: head s-bag
					t-bag: head t-bag 
					return divide score max length? s-bag length? t-bag
				] [
					return divide
							length? intersect s-bag t-bag
							length? union s-bag t-bag
				]
			]
		]
		if tfidf [
			use [document-frequency term-stats retval q-tok f-score score 
				tokens j-score w-stats q-tok-scores w-scores d-frequency
			] [
				document-frequency: first corpus-stats
				term-stats: second corpus-stats
				retval: make hash! []
				q-tok: sort unique tokenize s
				q-tok-scores: make hash! []
				if any [jaro-hybrid jaro-winkler-hybrid] [
					d-frequency: document-frequency
					forall q-tok [
						w-scores: make hash! []
						forskip d-frequency 2 [
							if jaro-hybrid 		[j-score: get-similarity/jaro/case/strict first q-tok first d-frequency]
							if jaro-winkler-hybrid [j-score: get-similarity/jaro-winkler/case/strict first q-tok first d-frequency]
							if greater-or-equal? j-score 0.9 [repend w-scores [first d-frequency j-score]]
						]
						repend q-tok-scores [first q-tok w-scores]
						d-frequency: head d-frequency
					]
				]
				f-score: select reduce [
					any [jaro-hybrid jaro-winkler-hybrid] [
						w-scores: select q-tok-scores first q-tok
						forskip w-scores 2 [
							if w-stats: select tokens first w-scores [
								j-score: second w-scores
								score: add score multiply j-score second w-stats
							]
						]
					]
					true [
						w-stats: select tokens first q-tok
						score: add score either w-stats [second w-stats] [0]
					]
				] true
				
				forskip term-stats 2 [
					score: 0
					tokens: second term-stats
					forall q-tok [
						do f-score
					]
					repend retval [score first term-stats]
					q-tok: head q-tok
				]
				term-stats: head term-stats
				return sort/skip/reverse retval 2
			]
		]
		
		; NON TOKEN-BASED METRICS
		trim s: copy any [s ""]
		trim t: copy any [t ""]
		if not case [
			lowercase s
			lowercase t
		]
		if not strict [
			parse/all s [
				any [
					mark: alpha-ext (change mark select/case alpha-map first mark)
					| skip
				]
			]
			parse/all t [
				any [
					mark: alpha-ext (change mark select/case alpha-map first mark)
					| skip
				]
			]
		]
		if jaro [
			use [half-len s-common t-common transpositions] [
				; get half the length of the string rounded up - (this is the distance used for acceptable transpositions)
				half-len: to-integer divide min length? s length? t 2
				; get common characters
				s-common: ctx-jaro/get-common-characters s t half-len
				t-common: ctx-jaro/get-common-characters t s half-len
				
				; Check for empty and/or different size common strings
				if any [
					not-equal? length? s-common length? t-common
					empty? s-common empty? t-common
				] [return 0]
				
				; Get the number of transpositions
				; A transposition for s-common, t-common is a position i 
				; such that s-common[i] <> t-common[i]
				transpositions: 0
				for i 1 length? s-common 1 [
					if not-equal? s-common/:i t-common/:i [transpositions: add transpositions 1]
				]
				transpositions: divide transpositions 2
				return divide 
							add add 
									divide length? s-common length? s
									divide length? t-common length? t
								divide 
									subtract length? s-common transpositions
									length? s-common
							3
			]
		]
		if jaro-winkler [
			use [dist prefix-length] [
				dist: get-similarity/jaro/case/strict s t
				; This extension modifies the weights of poorly matching pairs s, t which share a common prefix
				prefix-length: ctx-jaro/get-prefix-length s t
				return add  dist
							multiply multiply prefix-length ctx-jaro/PREFIXADUSTMENTSCALE 
									 subtract 1 dist
			]
		]
		if any [levenshtein levenstein] [
			use [dist max-len] [
				; 0.1.1
				either any [ins-cost del-cost sub-cost] [
					sc: any [sc sm-multiply sm-max dc ic 2 2]
					dc: any [dc ic sm-divide sc 2]
					ic: any [ic dc]
				] [
					sc: dc: ic: 1
				]
				dist: ctx-levenshtein/get-distance
							back tail s 
							back tail t 
							array reduce [length? t length? s]
							dc ic sc
				; get the max possible levenstein distance score for string
				max-len: max length? s length? t
				if zero? max-len [return 1] ; as both strings identically zero length
				; return actual / possible levenstein distance to get 0-1 range
				subtract 1 divide dist max-len
			]
		]
	]
	sm-divide: func [
		"Returns the first value divided by the second."
		value1 [number! pair! char! money! time! tuple! none!]
		value2 [number! pair! char! money! time! tuple! none!]
	] [
		all [
			value1 value2
			divide value1 value2
		]
	]
	sm-multiply: func [
		"Returns the first value multiplied by the second."
		value1 [number! pair! char! money! time! tuple! none!]
		value2 [number! pair! char! money! time! tuple! none!]
	] [
		all [
			value1 value2
			multiply value1 value2
		]
	]
	sm-max: func [
		"Returns the greater of the two values."
		value1 [number! pair! char! money! date! time! tuple! series! none!]
		value2 [number! pair! char! money! date! time! tuple! series! none!]
	] [
		all [
			value1: any [value1 value2]
			value2: any [value2 value1]
			max value1 value2
		]
	]
	alpha-map: make block! reduce [	
		make char! 131	make char! 102	; ƒ to f
		make char! 138	make char! 83	; Š to S
		make char! 142	make char! 90	; Ž to Z
		make char! 154	make char! 115	; š to s
		make char! 158	make char! 122	; ž to z
		make char! 159	make char! 89	; Ÿ to Y
		make char! 192	make char! 65	; À to A
		make char! 193	make char! 65	; Á to A
		make char! 194	make char! 65	; Â to A
		make char! 195	make char! 65	; Ã to A
		make char! 196	make char! 65	; Ä to A
		make char! 197	make char! 65	; Å to A
		make char! 199	make char! 67	; Ç to C
		make char! 200	make char! 69	; È to E
		make char! 201	make char! 69	; É to E
		make char! 202	make char! 69	; Ê to E
		make char! 203	make char! 69	; Ë to E
		make char! 204	make char! 73	; Ì to I
		make char! 205	make char! 73	; Í to I
		make char! 206	make char! 73	; Î to I
		make char! 207	make char! 73	; Ï to I
		make char! 208	make char! 68	; Ð to D
		make char! 209	make char! 78	; Ñ to N
		make char! 210	make char! 79	; Ò to O
		make char! 211	make char! 79	; Ó to O
		make char! 212	make char! 79	; Ô to O
		make char! 213	make char! 79	; Õ to O
		make char! 214	make char! 79	; Ö to O
		make char! 217	make char! 85	; Ù to U
		make char! 218	make char! 85	; Ú to U
		make char! 219	make char! 85	; Û to U
		make char! 220	make char! 85	; Ü to U
		make char! 221	make char! 89	; Ý to Y
		make char! 224	make char! 97	; à to a
		make char! 225	make char! 97	; á to a
		make char! 226	make char! 97	; â to a
		make char! 227	make char! 97	; ã to a
		make char! 228	make char! 97	; ä to a
		make char! 229	make char! 97	; å to a
		make char! 231	make char! 99	; ç to c
		make char! 232	make char! 101	; è to e
		make char! 233	make char! 101	; é to e
		make char! 234	make char! 101	; ê to e
		make char! 235	make char! 101	; ë to e
		make char! 236	make char! 105	; ì to i
		make char! 237	make char! 105	; í to i
		make char! 238	make char! 105	; î to i
		make char! 239	make char! 105	; ï to i
		make char! 241	make char! 110	; ñ to n
		make char! 242	make char! 111	; ò to o
		make char! 243	make char! 111	; ó to o
		make char! 244	make char! 111	; ô to o
		make char! 245	make char! 111	; õ to o
		make char! 246	make char! 111	; ö to o
		make char! 249	make char! 117	; ù to u
		make char! 250	make char! 117	; ú to u
		make char! 251	make char! 117	; û to u
		make char! 252	make char! 117	; ü to u
		make char! 253	make char! 121	; ý to y
		make char! 255	make char! 121	; ÿ to y
	]
	alpha-ext: make block! []
	forskip alpha-map 2 [
		append alpha-ext first alpha-map
	]
	alpha-map: head alpha-map ; for compatibility with Rebol/Core < 2.6.x
	
	; Charsets
	digit: charset [#"0" - #"9"]
	alpha-ext: charset alpha-ext
	alpha: charset [#"A" - #"Z" #"a" - #"z"]
	alphanum: union alpha digit
	space: charset reduce [#" " newline crlf tab]
	
	ctx-jaro: context [
		;maximum prefix length to use.
		MINPREFIXTESTLENGTH: 6
		
		;prefix adjustment scale.
		PREFIXADUSTMENTSCALE: 0.1
		
		get-common-characters: func [
			{Returns a string of characters from string1 within string2 if they 
			are of a given distance seperation from the position in string1}
			string1 [string!]
			string2 [string!]
			distance-sep [integer!]
			/local return-commons pos str
		] [
			; create a return string of characters
			return-commons: copy ""
			; create a copy of string2 for processing
			string2: copy string2
			; iterate over string1
			forall string1 [
				if found? str: find/part 
							at string2 add 1 pos: subtract index? string1 distance-sep
							first string1
							subtract 
								add multiply distance-sep 2 min pos 0
								1 
				[
					; append character found
					append return-commons first string1
					; alter copied string2 for processing
					change/part str to-char 0 1
				]
				string2: head string2
			]
			return-commons
		]
		get-prefix-length: func [
			"Returns the prefix length found of common characters at the begining of the strings."
			string1 [string!]
			string2 [string!]
			/local n
		] [
			n: first minimum-of reduce [MINPREFIXTESTLENGTH length? string1 length? string2]
			for i 1 n 1 [
				; check the prefix is the same so far
				if not-equal? string1/:i string2/:i [
					; not the same so return as far as got
					return subtract i 1
				]
			]
			; 0.2.1
			return n ; first n characters are the same
		]
	]
	ctx-levenshtein: context [
		get-distance: function [
			s [string!] "Source string"
			t [string!] "Target string"
			m [block!]
			dc [number!] "Deletion's cost"
			ic [number!] "Insertion's cost"
			sc [number!] "Substitution's cost"
		] [
			letter-copy letter-substitute 
			letter-insert letter-delete
			i j 
		] [
			if empty? head s [return length? head t]
			if empty? head t [return length? head s]
; 0.1.1
;			if m/(index? t)/(index? s) [return m/(index? t)/(index? s)]
			j: index? t
			i: index? s
			if m/:j/:i [return m/:j/:i]	
			letter-copy: letter-substitute: letter-insert: letter-delete: 1E+99
			; Copy t[j] to s[i]
			if equal? first s first t [
				letter-copy: do select reduce [
					all [head? s head? t] [0]
					true [get-distance back s back t m dc ic sc]
				] true
			]
			; Substitute t[j] for s[i]
			letter-substitute: add sc do select reduce [
					all [head? s head? t] [0]
					head? s [subtract index? t 1]
					head? t [subtract index? s 1]
					true [get-distance back s back t m dc ic sc]
				] true
			; Insert the letter t[j]
			letter-insert: add ic do select reduce [
				head? t [index? s]
				true [get-distance s back t m dc ic sc]
			] true
			; Delete the letter s[i]
			letter-delete: add dc do select reduce [
				head? s [index? t]
				true [get-distance back s t m dc ic sc]
			] true
; 0.1.1
;			m/(index? t)/(index? s): first minimum-of reduce [letter-copy letter-substitute letter-insert letter-delete]
			poke m/:j i first minimum-of reduce [letter-copy letter-substitute letter-insert letter-delete]
			m/:j/:i
		]
	]
]

; Sample tokenizers
tokenize-rebol-script: func [
	"Converts a string to a token multiset (where each token is a word)."
	str [string!]
	/local rebol-punctuation tokens t-alpha t-digit char mark
			space alpha-ext alpha digit
] [
	space: 		simetrics/space
	alpha-ext: 	simetrics/alpha-ext
	alpha:		simetrics/alpha
	digit:		simetrics/digit
	rebol-punctuation: charset "-!?~"
	
	tokens: make block! []
	t-alpha: copy ""
	t-digit: copy ""
	parse/all str [
		any [ "64#{" thru "}" |
			copy char rebol-punctuation (
				if not empty? t-alpha [append t-alpha char]	
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
			) |
			copy char space (
				if not empty? t-alpha [
					append tokens t-alpha
					t-alpha: copy ""
				]
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
			) |
			copy char alpha-ext (
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
				lowercase char
				char: select/case simetrics/alpha-map first char
				append t-alpha char
			) | 
			copy char alpha (
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
				lowercase char
				append t-alpha char
			) | 
			copy char digit (
				either not empty? t-alpha [
					append t-alpha char
				] [
					append t-digit char
				]
			) | 
			mark: (
				if not empty? t-alpha [
					append tokens t-alpha
					t-alpha: copy ""
				]
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
			) skip
		]
	]
	return tokens
]

tokenize-rebol-script-query: func [
	"Converts a string to a token multiset (where each token is a word)."
	str [string!]
	/local tokens
] [
	tokens: tokenize-rebol-script str
	
	return tokens
]

tokenize-text: func [
	str [string!]
	/local rebol-punctuation tokens t-alpha t-digit char mark
			space alpha-ext alpha digit
] [
	space: 		simetrics/space
	alpha-ext: 	simetrics/alpha-ext
	alpha:		simetrics/alpha
	digit:		simetrics/digit
	
	tokens: make block! []
	t-alpha: copy ""
	t-digit: copy ""
	parse/all str [
		any [
			copy char space (
				if not empty? t-alpha [
					append tokens t-alpha
					t-alpha: copy ""
				]
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
			) |
			copy char alpha-ext (
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
				lowercase char
				char: select/case simetrics/alpha-map first char
				append t-alpha char
			) | 
			copy char alpha (
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
				lowercase char
				append t-alpha char
			) | 
			copy char digit (
				either not empty? t-alpha [
					append t-alpha char
				] [
					append t-digit char
				]
			) | 
			mark: (
				if not empty? t-alpha [
					append tokens t-alpha
					t-alpha: copy ""
				]
				if not empty? t-digit [
					append tokens t-digit
					t-digit: copy ""
				]
			) skip
		]
	]
	return tokens
]
