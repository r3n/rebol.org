rebol [
   Library: [
        level: 'intermediate
        platform: 'all
        type: tool
        domain: [math]
        tested-under: none
        support: none
        license: none
        see-also: none
        ]
	History: [
                [1.0 22-mar-2007 "First version"]
		]
	Title:		"Bignumbers.r"
        File:   %bignumbers.r
	Owner:		"Alban Gabillon"
	Version:		1.0
	Date:		22-Mar-2007
    Purpose: {
    This script allows you to apply the four classical operations (add, subtract divide, multiply) on very big positive integers. 
    Size of the integers is only limited by the size of a rebol string since numbers are represented as strings.
    When using this script, keep in mind that the operations manipulate "string numbers" in reverse order (see example at the end of the script)}]

add: func [
{add two big numbers written in reverse order -
output is also  written in reverse order}
n1 [string!]
n2 [string!]
/local mem plus n result][
mem: 0
result: copy ""
if (length? n1) < (length? n2) [n: n1 n1: n2 n2: n]
while [not tail? n2][
	plus: to-string ((to-integer to-string n1/1) + (to-integer to-string n2/1) + mem)
	either (length? plus) = 1 [mem: 0 result: insert result plus/1][mem: 1 result: insert result plus/2]
	n1: next n1
	n2: next n2]
while [all[mem = 1 not tail? n1]][
	plus: to-string ((to-integer to-string n1/1) + mem)
	either (length? plus) = 1 [mem: 0 result: insert result plus/1][mem: 1 result: insert result plus/2]
	n1: next n1]
either mem = 1 [insert result #"1"][insert result copy n1]
result: head result]

multiply: func [
{multiply two big numbers written in reverse order -
output is also  written in reverse order}
n1 [string!]
n2 [string!]
/local count i longueur result temp n][
if (length? n1) < (length? n2) [n: n1 n1: n2 n2: n]
longueur: length? n2
result: copy "0"
for count 1 longueur 1 [
	temp: copy "0"
	for i 1 (to-integer to-string n2/:count) 1 [
		temp: add temp n1]
	insert/dup temp #"0" (count - 1)
	result: add result temp]
result]

greater: func [
{compare two bignumbers written in reverse order -
return none if they are equal}
n1 [string!]
n2 [string!]][
either (length? n1) <> (length? n2) [(length? n1) > (length? n2)][
	either equal? n1 n2 [none][
		n1: back tail n1
		n2: back tail n2
		while [n1/1 = n2/1][n1: back n1 n2: back n2]
		n1/1 > n2/1]
	]
]

sub: func [
{substract the smallest big number from the largest one - 
both numbers are written in reverse order -
output is also written in reverse order}
n1 [string!]
n2 [string!]
/local mem minus n result][
mem: 0
result: copy ""
if greater n2 n1 [n: n1 n1: n2 n2: n]
while [not tail? n2][
	minus: to-string (((to-integer to-string n1/1) - mem) + (10 - (to-integer to-string n2/1)))
	either (length? minus) = 1 [mem: 1 result: insert result minus/1][mem: 0 result: insert result minus/2]
	n1: next n1
	n2: next n2]
while [all[mem = 1 not tail? n1]][
	minus: to-string ((to-integer to-string n1/1) + (10 - mem))
	either (length? minus) = 1 [mem: 1 result: insert result minus/1][mem: 0 result: insert result minus/2]
	n1: next n1]
insert result copy n1
result: back tail result
while [all [result/1 = #"0" not head? result]][result: back result]
clear next result
result: head result]

divide: func [
{divide two big numbers written in reverse order - 
output is a block of two numbers [quotient remainder] also written in reverse order}
n1 [string!]
n2 [string!]
/local count i  result temp quotient diff][
if greater n2 n1 [return reduce ["0" n1]]
if equal? n1 n2 [return reduce ["1" "0"]]
diff: (length? n1) - (length? n2)
insert/dup n2 #"0" diff
if greater n2 n1 [remove n2 diff: diff - 1]
quotient: copy ""
for i 1 diff 1 [
	temp: copy n2
	count: 0
	until [switch greater n1 temp reduce [
		none [
			insert quotient to-string (count + 1) 
			insert/dup quotient #"0" (diff - i + 1) 
			return reduce [quotient "0"]]
		false [
			insert quotient to-string count 
			n1: sub n1 (sub temp n2)
			remove n2
			true]
		true [
			count: count + 1
			temp: add temp n2
			false]
			]
		]
	]
temp: copy n2
count: 0
until [switch greater n1 temp reduce [
	none [
		insert quotient to-string (count + 1)
		return reduce [quotient "0"]]
	true [count: count + 1
		temp: add temp n2
		false]
	false [insert quotient to-string count
		n1: sub n1 (sub temp n2)
		return reduce [quotient n1]]
		]
	]
]


p: {102639592829741105772054196573991675900716567808038066803341933521790711307779}
q: {106603488380168454820927220360012878679207958575989291522270608237193062808643}
rsa-155: {10941738641570527421809707322040357612003732945449205990913842131476349984288934784717997257891267332497625752899781833797076537244027146743531593354333897}

probe p
print "*"
probe q
print "="
reverse p reverse q
probe reverse multiply p q
print ""
print ""
probe rsa-155
print "/"
probe reverse p
reverse p
print "="
reverse rsa-155
r: divide rsa-155 p
probe reduce [reverse r/1 reverse r/2]
ask "Press Enter to quit"
