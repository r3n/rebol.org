REBOL [
    Author: "Christian Blanvillain"
    Name: 'CompteEstBon
    Title: "Le Compte est Bon."
    File: %ceb.r
    Date: 1-May-2008
    Version: 1.0
    Purpose: "Algorithm to solve french countdown game."
    Library: [
        level: 'intermediate
        platform: 'all
        type: [game fun]
        domain: [math game]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

target: 952
list: [ 3 6 25 50 75 100 ]

kronos: make time! now/time
op: [+ - * /]
ad: func[x y][x + y]
sb: func[x y][x - y]
ml: func[x y][if error? try [return x * y][0]]
dv: func[x y][either (x // y) = 0 [x / y][0]]
calculs: func[x y][make block! [(ad x y) (sb x y) (ml x y) (dv x y)]]
nwlist: func[list j i res][sort append head remove at head remove at copy list j i res]
hash: make hash! 1

ceb: function[list size][ol][
  if (not select hash mold list) [
    hash: append append hash mold list true
    for i 1 (size - 1) 1 [ 
      for j (i + 1) size 1 [ 
        ol: reduce calculs list/:j list/:i
        for k 1 4 1 [ 
          if any [(ol/:k = target) all [(ol/:k <> 0) (size > 1) (s: ceb (nwlist list j i ol/:k) (size - 1))]] [
            return rejoin [list/:j op/:k list/:i "=" ol/:k newline s]
  ] ] ] ] ] 
  return false
] 

print rejoin ["^(1B)[J" ceb list length? list newline (now/time - kronos) " sec."]

