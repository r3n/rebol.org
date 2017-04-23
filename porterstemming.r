REBOL [
    file: %porterstemming.r
    date: 18-Nov-2007
    title: "Porter Stemming Algorithm"
    version: 1.0.1
    organization: "Digital Bear Consulting"
    url: http://www.digital-bear.com
    author: "Dale K. Brearcliffe"
    email: %daleb@digital-bear.com
    copyright:  "Copyright (c) 2007, 2009 Dale K. Brearcliffe"
    license: {Copyright (c) 2007, 2009 Dale K. Brearcliffe. All rights reserved.
              Redistribution and use in source and binary forms, with or without
              modification, are permitted provided that the following conditions
              are met:
              
              Redistributions of source code must retain the above copyright 
              notice, this list of conditions and the following disclaimer.
              
              Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in 
              the documentation and/or other materials provided with the 
              distribution.
              
              Neither the name of Digital Bear Consulting nor the names of its 
              contributors may be used to endorse or promote products derived 
              from this software without specific prior written permission.
              
              THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
              CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
              INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
              MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
              DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
              BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
              EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
              TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
              DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
              ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
              TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
              THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
              SUCH DAMAGE.}
    purpose: {Applies the Porter Stemming algorithm as presented in:
              Porter, 1980, An algorithm for suffix stripping, Program,
              Vol. 14, no. 3, pp 130-137.}
    remarks: {This program is based on the modified version of Porter's stemming
              algorithm posted at: http://tartarus.org/~martin/PorterStemmer/
              The program was tested with the sample test vocabulary found at
              the above web site. In testing it created the same output results
              as the sample output.
              Note that this program will force all text to lower case and
              return results as lower case.}
    usage: {do %porterstemming.r
            stemmedWord: porterStem word
           }
    library: [
        level: 'intermediate
        platform: 'all
        type: [function tool]
        domain: [text text-processing]
        tested-under: [view 2.7.6.3.1 "Windows XP"]
        support: none
        license: BSD
        see-also: http://tartarus.org/~martin/PorterStemmer/
    ]
]

porterStem: function [
 "Stems Words"
 word
][
][

word: lowercase word

;Check for minimum length
if (length? word) < 3 [return word]

;Set variables
vowels: "aeiou"
vowel: charset join vowels {y}
consonant: charset ["bcdfghjklmnpqrstvwxYz"]
consonant1: charset ["bcdfghjklmnpqrstvz"]
cvc: [1 consonant 1 vowel 1 consonant]
V: [some vowel]
C: [some consonant]
C1: [some consonant1]
VC: [V C]
ruleM: [(m: 0) any C VC (m: m + 1) VC (m: m + 1) VC (m: m + 1) VC (m: m + 1) any V]
listStep1a: [{sses} {ss} {ies} {i} {ss} {ss} {s} {}]
listStep1b: [{at} {ate} {bl} {ble} {iz} {ize} {bb} {b} {cc} {c} {dd} {d} {ff} {f} {gg} {g} {hh} {h} {jj} {j} {kk} {k} {ll} {ll} {mm} {m} {nn} {n} {pp} {p} {qq} {q} {rr} {r} {ss} {ss} {tt} {t} {vv} {v} {ww} {w} {xx} {x} {zz} {zz}]
listStep2: [{ational} {ate} {tional} {tion} {enci} {ence} {anci} {ance} {izer} {ize} {logi} {log} {bli} {ble} {alli} {al} {entli} {ent} {eli} {e} {ousli} {ous} {ization} {ize} {ation} {ate} {ator} {ate} {alism} {al} {iveness} {ive} {fulness} {ful} {ousness} {ous} {aliti} {al} {iviti} {ive} {biliti} {ble}]
listStep3: [{icate} {ic} {ative} {} {alize} {al} {iciti} {ic} {ical} {ic} {ful} {} {ness} {}]
listStep4: [{al} {} {ance} {} {ence} {} {er} {} {ic} {} {able} {} {ible} {} {ant} {} {ement} {} {ment} {} {ent} {} {ion} {} {ou} {} {ism} {} {ate} {} {iti} {} {ous} {} {ive} {} {ize} {}]

;partOfWord - Given a word and a suffix of interest, the function splits the word,
;returning a block containing the stem, the suffix and a boolean that is set to
;true if the suffix was found in the word.

partOfWord: function [
 "Creates parts of word breakdown. Returns a block with stem, suffix & pointer."
 arg1 [string!]
 arg2 [string!]
][
 l1
 l2
 matched
 returnvalue
 stem
 suffix
][
matched: false
l1: length? arg1
l2: length? arg2
stem: copy {}
suffix: copy {}
if l2 < l1 [
 suffix: rightString arg1 l2
 stem: leftString arg1 (l1 - l2)
 if suffix == arg2 [matched: true]
]
returnValue: copy []
append returnValue stem
append returnValue suffix
append returnValue matched
return returnValue
]

hasVowel?: function [
 "Returns true if the passed string contains a vowel."
 arg1 [string!]
][
 returnValue
 t
][
 t: intersect arg1 (join vowels {y})
 returnValue: false
 if t <> "" [returnValue: true]
 return returnValue
]

leftString: function [
   "Returns the left most arg2 characters of string arg1."
   arg1 [string!]
   arg2 [number!]
   ][
   l
   ][
   l: length? arg1
   if (l <= arg2) [return arg1]
   if (arg2 = 0) [return {}]
   if (arg2 < 0) [arg2: 0 - arg2]
   return copy/part arg1 arg2
]

rightString: function [
   "Returns the right most arg2 characters of string arg1."
   arg1 [string!]
   arg2 [number!]
   ][
   l
   lt
   ][
   l: length? arg1
   if (l <= arg2) [return arg1]
   if arg2 = 0 [return {}]
   either arg2 > 0 [
     lt: 0 - arg2
   ][
     lt: arg2
   ]
   return skip tail arg1 lt
]
 
;Fix the problem with the status of 'y' by changing the lower case 'y' to 
;uppercase in those cases where 'y' should be treated as a consonant

foreach letter vowels [
 replace word join letter {y} join letter {Y}
]
if (leftString word 1) == {y} [replace word {y} {Y}]

;Step 1a removes plurality
;Rule: SSES -> SS                  caresses  ->  caress
;Rule: IES  -> I                   ponies    ->  poni
;                                  ties      ->  ti
;Rule: SS   -> SS                  caress    ->  caress
;Rule: S    ->                     cats      ->  cat

forskip listStep1a 2 [
 partOfWordResults: partOfWord word first listStep1a
 stem: first partOfWordResults
 ptr: third partOfWordResults
 if ptr [
  word: join stem second listStep1a
  break
 ]
]
listStep1a: head listStep1a

;Step 1b removes past participles
;Rule: (m>0) EED -> EE              feed      ->  feed
;                                   agreed    ->  agree

step1bDone: false
step1b1: false
partOfWordResults: partOfWord word {eed}
stem: first partOfWordResults
ptr: third partOfWordResults
if ptr [
 step1bDone: true
 parse stem ruleM
 if m > 0 [
  word: join stem {ee}
 ]
]

;Rule: (*v*) ED  ->                 plastered ->  plaster
;                                   bled      ->  bled

if not step1bDone [
 partOfWordResults: partOfWord word {ed}
 stem: first partOfWordResults
 ptr: third partOfWordResults
 if ptr [
 	step1bDone: true
  if hasVowel? stem [
   word: stem
 	 step1b1: true
  ]
 ]
]

;Rule: (*v*) ING ->                  motoring  ->  motor
;                                    sing      ->  sing

if not step1bDone [
 partOfWordResults: partOfWord word {ing}
 stem: first partOfWordResults
 ptr: third partOfWordResults
 if ptr [
  if hasVowel? stem [
   word: stem
 	 step1b1: true
  ]
 ]
]

;If the second or third of the rules in Step 1b is successful, the following
;is done:
;
;    AT -> ATE                       conflat(ed)  ->  conflate
;    BL -> BLE                       troubl(ed)   ->  trouble
;    IZ -> IZE                       siz(ed)      ->  size
;    (*d and not (*L or *S or *Z))
;       -> single letter
;                                    hopp(ing)    ->  hop
;                                    tann(ed)     ->  tan
;                                    fall(ing)    ->  fall
;                                    hiss(ing)    ->  hiss
;                                    fizz(ed)     ->  fizz

if step1b1 [
 forskip listStep1b 2 [
  partOfWordResults: partOfWord word first listStep1b
  stem: first partOfWordResults
  ptr: third partOfWordResults
  if ptr [
   word: join stem second listStep1b
   step1b1: false
   break
  ]
 ] 
 listStep1b: head listStep1b
]

;Rule: (m=1 and *o) -> E  fail(ing)    ->  fail
;                         fil(ing)     ->  file

if step1b1 [
 parse word ruleM
 if m == 1 [
  letter: rightString word 1
	if parse letter C1 [
	 if parse (rightString word 3) cvc [
	  word: join word {e}]
	 ]
 ]
]

;Step 1c
;Rule: (*v*) Y -> I           happy        ->  happi
;                             sky          ->  sky

partOfWordResults: partOfWord word {y}
stem: first partOfWordResults
ptr: third partOfWordResults
if ptr [
 if hasVowel? stem [word: join stem {i}]
]
partOfWordResults: partOfWord word {Y}
stem: first partOfWordResults
ptr: third partOfWordResults
if ptr [
 if hasVowel? stem [word: join stem {i}]
]

;Step 2
;Rule: (m>0) ATIONAL ->  ATE           relational     ->  relate
;Rule: (m>0) TIONAL  ->  TION          conditional    ->  condition
;                                      rational       ->  rational
;Rule: (m>0) ENCI    ->  ENCE          valenci        ->  valence
;Rule: (m>0) ANCI    ->  ANCE          hesitanci      ->  hesitance
;Rule: (m>0) IZER    ->  IZE           digitizer      ->  digitize
;Rule: (m>0) LOGI    ->  LOG - New Rule added 
;Rule: (m>0) ABLI    ->  ABLE          conformabli    ->  conformable
;Rule: (m>0) BLI     ->  BLE - Replaces rule: (m>0) ABLI -> ABLE 
;Rule: (m>0) ALLI    ->  AL            radicalli      ->  radical
;Rule: (m>0) ENTLI   ->  ENT           differentli    ->  different
;Rule: (m>0) ELI     ->  E             vileli        - >  vile
;Rule: (m>0) OUSLI   ->  OUS           analogousli    ->  analogous
;Rule: (m>0) IZATION ->  IZE           vietnamization ->  vietnamize
;Rule: (m>0) ATION   ->  ATE           predication    ->  predicate
;Rule: (m>0) ATOR    ->  ATE           operator       ->  operate
;Rule: (m>0) ALISM   ->  AL            feudalism      ->  feudal
;Rule: (m>0) IVENESS ->  IVE           decisiveness   ->  decisive
;Rule: (m>0) FULNESS ->  FUL           hopefulness    ->  hopeful
;Rule: (m>0) OUSNESS ->  OUS           callousness    ->  callous
;Rule: (m>0) ALITI   ->  AL            formaliti      ->  formal
;Rule: (m>0) IVITI   ->  IVE           sensitiviti    ->  sensitive
;Rule: (m>0) BILITI  ->  BLE           sensibiliti    ->  sensible

forskip listStep2 2 [
 partOfWordResults: partOfWord word first listStep2
 stem: first partOfWordResults
 ptr: third partOfWordResults
 if ptr [
  parse stem ruleM
	if m > 0 [
   word: join stem second listStep2
	]
  break
 ]
] 
listStep2: head listStep2

;Step 3
;Rule: (m>0) ICATE ->  IC              triplicate     ->  triplic
;Rule: (m>0) ATIVE ->                  formative      ->  form
;Rule: (m>0) ALIZE ->  AL              formalize      ->  formal
;Rule: (m>0) ICITI ->  IC              electriciti    ->  electric
;Rule: (m>0) ICAL  ->  IC              electrical     ->  electric
;Rule: (m>0) FUL   ->                  hopeful        ->  hope
;Rule: (m>0) NESS  ->                  goodness       ->  good

forskip listStep3 2 [
 partOfWordResults: partOfWord word first listStep3
 stem: first partOfWordResults
 ptr: third partOfWordResults
 if ptr [
  parse stem ruleM
	if m > 0 [
   word: join stem second listStep3
	]
  break
 ]
] 
listStep3: head listStep3

;Step 4
;Rule: (m>1) AL    ->                  revival        ->  reviv
;Rule: (m>1) ANCE  ->                  allowance      ->  allow
;Rule: (m>1) ENCE  ->                  inference      ->  infer
;Rule: (m>1) ER    ->                  airliner       ->  airlin
;Rule: (m>1) IC    ->                  gyroscopic     ->  gyroscop
;Rule: (m>1) ABLE  ->                  adjustable     ->  adjust
;Rule: (m>1) IBLE  ->                  defensible     ->  defens
;Rule: (m>1) ANT   ->                  irritant       ->  irrit
;Rule: (m>1) EMENT ->                  replacement    ->  replac
;Rule: (m>1) MENT  ->                  adjustment     ->  adjust
;Rule: (m>1) ENT   ->                  dependent      ->  depend
;Rule: (m>1 and (*S or *T)) ION ->     adoption       ->  adopt
;Rule: (m>1) OU    ->                  homologou      ->  homolog
;Rule: (m>1) ISM   ->                  communism      ->  commun
;Rule: (m>1) ATE   ->                  activate       ->  activ
;Rule: (m>1) ITI   ->                  angulariti     ->  angular
;Rule: (m>1) OUS   ->                  homologous     ->  homolog
;Rule: (m>1) IVE   ->                  effective      ->  effect
;Rule: (m>1) IZE   ->                  bowdlerize     ->  bowdler

forskip listStep4 2 [
 partOfWordResults: partOfWord word first listStep4
 stem: first partOfWordResults
 ptr: third partOfWordResults
 if ptr [
  parse stem ruleM
	if m > 1 [
   either (first listStep4) == {ion} [
    if ((rightString stem 1) == {s}) or ((rightString stem 1) == {t}) [
		 word: join stem second listStep4
		]
	 ][
    word: join stem second listStep4
	 ]	
	]
	break
 ]
] 
listStep4: head listStep4

;Step 5a
;Rule: (m>1) E     ->                  probate        ->  probat
;                                      rate           ->  rate
;Rule: (m=1 and not *o) E ->           cease          ->  ceas

partOfWordResults: partOfWord word {e}
stem: first partOfWordResults
ptr: third partOfWordResults
if ptr [
 parse stem ruleM
 either m > 1 [
  word: stem
 ][
  if m == 1 [
   letter: rightString stem 1
	 if ((not parse letter C1) or (not parse (rightString stem 3) cvc)) [
	   word: stem
	 ]  
  ]
 ]
] 

;Step 5b
;Rule: (m > 1 and *d and *L) -> single letter
;                                      controll       ->  control
;                                      roll           ->  roll

partOfWordResults: partOfWord word {l}
stem: first partOfWordResults
ptr: third partOfWordResults
if ptr [
 parse stem ruleM
 if m > 1 [
  if (rightString stem 1) == {l} [word: stem]
 ]
]

return lowercase word
]

