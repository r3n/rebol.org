Rebol [
    title: "Animated GIF Example"
    date: 29-june-2008
    file: %animated-gif.r
    author:  Nick Antonaccio
    purpose: {
        An example of how to use the 'anim' function.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

make-dir %./frames

write/binary %./frames/frame-1.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zCHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5uWnp5ukHxqjufmZWdnWxS/OsPJcODoPLtKprUcW9TPLXJT
V7LdFZIZuMx/Ll/rrJCkC3NZ1ztd6SpVCG+L363EsXpCTvhmtovzVCWurr7R6jG7
rzZarKFpd8XTS77Z1/Xu7Qn+vunr6+/v725rqv6nm/Oj4Or2Ll7jvDUOa8+e6FX3
3uYjbPz0fN/RKjbeWcU+Z5do2qfN2lWaelnXfbveKwkz7ytLqu0qBK6Xed1cyfhG
TC58xeujhyuF422FXxQeOPybbR1nzbbP18+khtXvu/H95Ns7Gzdv5ZtfaVX64fjZ
crf/d6xPvV7XmJ7PZ1/x/ueXm/nXrOfVZKyZ+DL8nt85zhWzqu8LPosvPyYZEdW8
QrJjvjdj3TOFJuXQFVEVEl0iC9L49pVJJvZcnR7XLn/w+ux64XUpizrvbF0R1PFx
4QvB3s29OxLylB9tW9Cj9+vEol5NLk+5ia7vLB74GvxbETxZRklSqI+HyWNpR7ri
VbkJtreOp05nF1O/EeGW9C01/RqjmVrF3l7PZxnfPStv12qxsjBYAwBolvDW2AQA
AA==
}

write/binary %./frames/frame-10.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJGcFnIAgdVr2kGybtEJDernZmpnfsqp9P48bn5tvr/ZKSuPApY4Koo
Fzvry8OgZb6Sdq1Sog9DZjJlh/l6mLz2ZeDfU3c3SuClwzQm+RWsC6bqOC7JOrwo
Vnv72uht1gfbeK0n6MWtKW/8pbrj2/uI7QU/F9Vmf14XMbfnolxpjWlR3GGbyXZb
a3ZufLY619b5H8+vnNRL8z7K6ciWbnG80B7Y3SZrrZF7bVN+ee6q6uKr9/ZFM8/X
qfnx7s6xYPGrs+7oPXrWzex83qes6svaa+v/n9OrtUp9fX9ve7j/ux8fP3x61rjY
vLZ6b+iNdzsPre/9l5a86itjv21cXGXk5p+Wx+fVM3K9CK15v7MtwZlL74RCAp+b
xsMWkbCMh60SaSsetsmUvXjYrtCm8ahDZVrGo06NPFEBBmsAOJHArHoEAAA=
}

write/binary %./frames/frame-11.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4a8uKBYvd+6Wd
i/54bFp8YjKf9yqTzk2ph6ZqxZ4S4dj87Mw00+J7IjM3Pz/Xa1v674jElecXJrom
yq3NKFbwWC4/PSiE68FB5llMay/1aJkuClobLhqyV2pa9vUp8SeZBLjL1t7czDM7
S9ViukrMlpCNYj2V5YlB03x/7/uzu3RpQqsjL5tdjYFhyIF8yfehWT82Rmz3VxXf
9rvi0+VJs8zdv8lsLYo/NK2b699pqS93r20wLu/lrTbNvbYt3/rcWmv9x5f2prb7
1VZbvHxwrPO1n94u8+IzB/XV+/VsTEpfXl5pn+9Xbf3l6b2J1cHP+6psKhc/43zk
d99Cs/qrXW17eW3Nl7Jfp1aff17zb2/Rjz8/v8uWMf1aGt/IobbiQROP2YsHzQJu
Gg9bRMIyHrZKpK142CZT9uJhu0KbxqMOlWk7Eh0YrAGyBMCKdgQAAA==
}

write/binary %./frames/frame-12.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5uWnp5ukHxqjufmZb79XEWvrlROfnRuvn21F4tXSOOFNptu
JttVBisuzfURtJsrdfXBleWhnHFLZ5VqX18V18lnImW6JmwT/yamD1ofHG9tZbi0
TLV6ytrbOwqeHkrNCtePaiypntX7u+z9rTml7OIxWiZrbhy2kbbm45IsTDrevTDu
GM/PgptrkzWj360qefhi9nLH+b09VUa3Z62zPN+zNkLt7fVt+eK21tHf8w40Jv7S
Oxv148Pxg73y1898t4h4Pnvh9rh5c9S+XjZbH/5+757K7y/22bc716+Lzn168ln4
db/1917kfwvbOH+6/zzLD8ez7p/X9/u1/d+fiEq2+Joe3owHjRxqKx408Zi9eNAs
4KbxsEUkLONhq0SaqACDNQAYMLy/ZgQAAA==
}

write/binary %./frames/frame-2.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5uWnp5ukHxqjufmZWdnW6hqBUwQfnxuvkPltxaJLSsuLOTt
ZWPdIPzSaal3vZUth6nWhZUsq7NsrUqzQ9f47K17qyWmdW1T2txFsreLdW/Pydu6
rXe2mHrsYuf3j86uLn95Z1/Qf6ZnWeUGD2e38V/3WVOh9viYkfzh3Fvmb1Iap+oq
P7OUKH64ocH2tsisGfkvTy7nXi6nG/n11dGZzLv3RQt8On3c19zY7e8stbyDCxtf
h0rLZBZuKjyYFrv6jsLdZ8xr99lGi3wueRLuGN6+zqSq7MW1700y/hHle4o/PhP8
5Xt+397f3z88Pj3ff/++v79/vGdnYbAGAJfEqNM/BAAA
}

write/binary %./frames/frame-3.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blri2cIVNC+GU2Hp6elcEX0tnsbLfPpNs++9mTE57fRcyepfJZxfFgUsdNWU
s51l8ihoma+8XatU6cOQVaHCca6zQh+GrYvlrWOVnvbgxrzUo/POzrz2JmpuLuu+
VuntT+9ML316T3VWuf79HXX/t/GuKTJIPBj5UW7bzB0fko75frwVGzP1ffIRa934
tpiQp88O9Zq3q84pL3qwq593uZ621dus61NCJ097K/714b7l3tf1bAv03jfNmv/v
264t3wu2Hn0r9973y6uiy2aql235hJeef35hovexONmK8jc3rzapXLeL03r+6cXl
1fHn9+39/f3D49Pz/ffv+/v7x+fX98/v3////1NWFgZrALxatNdHBAAA
}

write/binary %./frames/frame-4.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5uWnp5ukHxKZMWCZWdnSuW+urOSId11nkP+rx6JLS8C2l0n
y6XO2PLyUovvXDtTCdNXV5pCl8YtnRn68tq6qOVNX6tKdW4uT+ud5sv9RTt6Xt79
Vz3a4Stu7Cq7+OitZ/i7i3tza5n4tCo+3JzWdniTz5oI1cfHNOVXt2pWqp87VaPv
LZf1413C3s7pdmKys0rSL88PZGbbe+vzva1rY3+/PV32+sCubRtnnd0rkJdwj/0h
0wyemh2p644UC7fl7H778NGh3vO6fKbGX1/f2Jx9/9ze3d/fPzjczSvvv2/Pz88v
Lq+Oj7dTYLAGANdbpyswBAAA
}

write/binary %./frames/frame-5.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5uWnp5ukHxqjufmZWdnWxS/unNy8/Lz8x2auWR/BTVeXOwi
Khe7y2Sl47KAiVamXApZV5b4rnWSXbVVO3RB3OF/PN7X1G9usjnfdXdl2dpz2/IK
D339VZZ3fVfZ2kdnd5uqx++t+/9tqvaMlWfXh3IrT7sZ/jHxaHim0zWtSqOnM6a9
FDtbU26cfkDPvrlNc1dm6kVTb22Lv5alaYfm5C+qu3OrNPfa+tzj13Ijv+XemZzI
zv9n+oq7Kye6f9+js2Fz5IFZx4PK+MR+JSy/sTn7/rm9u7+/f3C4m/m7pACDNQAX
yZ/iJgQAAA==
}

write/binary %./frames/frame-6.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5uWendyiezhkdy8zHemsfm9O5LG6m7zHGqjWKRCMo7MY+h4
Z/IrYGXwMp65dq2rAl6FrGJbG3fUKuB12DrPvVqs2gFvwlelHZ/ku3qadvSilMP7
9kqW653fWvay6ezq67rxS6r/P1qjPWPDg4Nu/N+/rvyh9/iYt7zzNs0So6enpi2M
cuuRNLp3qJH/d6hNlEnY+eXS09l6w0qzLq+PPP7s98yy3N2Fp5+dvTtVN78lqf77
u5XTi3wfHpYVj5lTnX3xfsHkeDe98qrS11catc/PK7D+/u74fnNpHv19e35+fnF5
dfz5fXt/f//w+PR8//37/v5mYGJisAYARqapGj4EAAA=
}

write/binary %./frames/frame-7.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8loBjYyMaj5ToqJNHjqOV0zsq/l56RnnjPlcq9t6Zy8+Nx8w+okFq8vywK6XDvl
ZGdNeR7Uyb9oUY7X55dH2INX7trCZbr62oIYSa+vv65mRDRHs05rrRR7GLU09+K+
v5LmD++sKuW/d3R2+YO4fbUn//G+MV+bsKpF9JzvnSKDx/vbhJ3DTkbo3j5coB2v
F72z4MzWubrBbLJWL25fWuZv7/d6y4q0bdMNj6udub7mzYnGuVV+v6qK8k/sl/We
l7Nb/+Ojyv5ytX0yFq/2LnRdfW3P79ef515b73/9nFRGSVPJ00c2fXwSf9685y1d
7B9ft/fu53ei/f3/5xnVtie8f33//P79wEKATeNBA4tYxoNGDrUVD5p4zF48aBZw
00h0ZGRksAYAd264o18EAAA=
}

write/binary %./frames/frame-8.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5tUvVi5Yia1eG5edqbPtPjSnpWBy/0YDCvDvvwsXh7Q6TL5
kI1UYGbQMv65Wq2nAl6FrApd++vIrA8HmRc4smbxni59cH294d46Vu2tOQc3OzDO
cc2+ujZiZ9zjc6mvr+hFNGV+/rT31bUX9xuTTybFWllsTFzXI5uv6xO2yXe3m669
nrfIxrAzDaLqx9bc2Jx8aVZ90bWcWYZXr6xj39+W++NT4K1VuZ9LeqPfpM2cWHj8
ytmQHx/u79b9zSf3e9un5iOth/QkYnd9fHVy/fSydbWl5e8PBbYHLreJ+1Oyv1d1
cX5tVe2Li+94t/X7y9b9Wf5y4mx3u5919d/Orr1+s8jyovr9ZFYpjol1XGYvHjQL
uGk8bBEJy3jYKpG24mGbTNmLh+0KbRqPOoTYWBisAbfrxM90BAAA
}

write/binary %./frames/frame-9.gif to-binary decompress 64#{
eJxz93SzsEwMZwhn+M4AAg1g3ACmGsCsBjDnPxj/B1P/waz/YM4oGAXDBij+ZAHT
OiAClCfYOf4zMHLIeGxYcLCZQ1gr5sSGhYfbBZS95nhsXHS0W8I4686JjYuP9ys4
d8l4blpycrJG8KqYk5uWnp5ukHxqjufmZWdnWxRHhRwIfu46z6Hx1xSJLSsuLOTt
1XLdFfDy0mIfTqu5t4xfOayKWMt04NRVretrAvc3yWqVrTm/LnqlUuusba9Ct6aL
ctQ4mL+9syt3+jHWgO+Nd/fVPXxm88p8Q8y+Gl7/q5Il667sZjp7S0drqm7UHP/T
UrJ7LNc/2zFFOXudlNWyG9uzvs6yO1NgEj29V3RXH2/1tzfTthVv9lt52+zdvcXZ
zPZ/rb99OKfvLF+vu+d50Xaju3b3bSutnj+fsTx4/sra6pK3N9fed2Op/2uR/OZ5
+/pQf7GKiJ37tlb905I3LVw7s//St1W7NgW8f/l1+41qZr6O+MxvjuH3m3jMXjxo
FnDTeNgiEpbxsFUibUViGyMjgzUAhlm/D2kEAAA=
}

view center-face layout [
	size 625x415
	backcolor black
	anim: anim rate 10 frames [%./frames/frame-1.gif %./frames/frame-2.gif %./frames/frame-3.gif %./frames/frame-4.gif %./frames/frame-5.gif %./frames/frame-6.gif %./frames/frame-7.gif %./frames/frame-8.gif %./frames/frame-9.gif %./frames/frame-10.gif %./frames/frame-11.gif %./frames/frame-12.gif]
	btn "Run Animation" [
		for counter 0 31 1 [anim/offset: anim/offset + to-pair rejoin [counter "x" 0] show anim wait .05]
		for counter 0 24 1 [anim/offset: anim/offset + to-pair rejoin [0 "x" counter] show anim wait .05]
		for counter 0 31 1 [anim/offset: anim/offset + to-pair rejoin ["-" counter "x" 0] show anim wait .05]
		for counter 0 24 1 [anim/offset: anim/offset + to-pair rejoin [0 "x-" counter] show anim wait .05]
	]
]


