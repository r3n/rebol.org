REBOL
[
    File: %substring.r
        Date: 3-Febr-2004
        Title: "Simple substring function - returns empty when outside boundery"
        Purpose: "Working around string series"
         Author:  "Hein Hoenjet"
         library: [
                      level: 'beginner
                      platform: 'all 
                      type: [tutorial tool] 
                      domain: [text text-processing]
                      tested-under: none 
                      support: none license: none 
                      see-also: none ]
]

substring: function  [

{ Expression function to get a substring from a string
  Usage: substring "abcdefghijk" 4 9
}
   s [series!] {String} 
   f [number!] {Position from}
   t [number!] {Position until, -1 when end of series}
]  [
]  [ (if t = -1 [ t: length? s])
      return skip (copy/part s t) (f - 1)
]

