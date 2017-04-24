REBOL [
   Title: "Basic RC4 algorithm"
   Date: 29-Apr-2004
   File: %rc4.r
   Author: "Arthur Beltrao (Brasil)"
   Email: "arthurbeltrao@yahoo.com.br"
   Purpose: {Provides encryption and decryption using the basic RC4 algorithm}
   Note: {You can evaluate the En/Decrypt performance using the elapsed function}
   Library: [
      level: 'advanced
      platform: 'all
      type: [function module]
      domain: [encryption]
      tested-under: [view 1.2.10.3.1 on [W2K] by "Arthur Beltrao"]
      license: 'PD
      support: none
   ]
]


rc4_state: make object! [
   x: 0
   y: 0
   m: []
]


rc4_setup: func [
   {Initializes the rc4_state object used in En/Decrypt function.}
   key [binary! string!] "Crypt key"
   /local i j k a
][
   rc4_state/x: 0
   rc4_state/y: 0
   rc4_state/m: copy []

   for i 0 255 1 [ append rc4_state/m i ]

   j: 0
   k: 0

   for i 0 255 1 [
      a: pick rc4_state/m i + 1
      j: (j + a + pick key (k + 1)) and 255
      poke rc4_state/m (i + 1) pick rc4_state/m (j + 1)
      poke rc4_state/m (j + 1) a
      k: k + 1
      if k >= length? key [ k: 0 ]
   ]
]


rc4_crypt: func [
   {En/Decrypts the data, using the pre-initialized rc4_state object.^/^- The rc4_state must be initialized first by the rc4_setup function.}
   data [binary! string!] "Data to En/Decrypt"
   /local i x y a b new_data
][
   x: rc4_state/x
   y: rc4_state/y
   new_data: copy #{}

   i: 0
   while [ i < length? data ] [
      x: x + 1 and 255
      a: pick rc4_state/m x + 1
      y: y + a and 255
      b: pick rc4_state/m y + 1
      poke rc4_state/m x + 1 b
      poke rc4_state/m y + 1 a

      append new_data to-char (pick data i + 1) xor (pick rc4_state/m a + b and 255 + 1)
      
      i: i + 1
   ]
   
   rc4_state/x: x
   rc4_state/y: y
   return new_data
]


rc4: func [
   {Provides encryption and decryption using the basic RC4 algorithm.}
   key [binary! string!] "En/Decrypt key"
   data [binary! string!] "Data to En/Decrypt"
][
   rc4_setup key
   return rc4_crypt data
]


elapsed: func [
   {Returns the elapsed time since the begining of an operation. Ex: elapsed [ rc4 read %rc4.r "testing" ]}
   body [block!] "Operation to calculate the elapsed time"
   /local stime
][
   stime: now/precise
   do body
   return difference now/precise stime
]
