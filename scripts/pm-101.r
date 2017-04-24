REBOL [
    Title: {Sintezar PM-101 - Phase Manipulation Digital Synthesizer} 
    Date: 23-Jun-2006 
    Name: 'PM-101 
    Version: 0.4.0 
    File: %pm-101.r 
    Author: "Boleslav Brezovsky" 
    Email: "rebolek<>gmail<>com" 
    Purpose: "synthetiser"
    library: [
        level: 'intermediate
        platform: 'all
        type: [tool demo]
        domain: [sound ui]
        tested-under: [view 1.3.2 WXP]
        support: none
        license: none
        see-also: none
    ]
    History: [
        0.4.0 23-Jun-2006 [
            "FIRST PUBLIC RELEASE" 
            {Uses Ladislav's Include to be compatible with preprocessor. Now I can produce single file for easier distribution.} 
            "PLAY button crashed when sound buffer was empty." 
            "EXPORT-WAV button crashed on cancel" 
            "EXPORT button crashed on cancel" 
            "IMPORT button crashed on cancel" 
            {IMPORT crashed when trying to import non-sintezar file}
        ] 
        0.3.9 22-Feb-2006 {OSC basic volume set to -3dB to prevent possible clipping.
^-^-^-^-^-^-^-^-dB equations fixed, maximal gain is up to 12dB} 
        0.3.8 19-Sep-2005 {AMPs support +6dB gain, all AMP values shown in dB's.
^-^-^-^-^-^-^-^-FInalCrusher is fully working (freq. divider and bit resolution destroyer)} 
        0.3.7 18-Sep-2005 "GUI changes to support LFO's and FinalCrusher" 
        0.3.6 16-Sep-2005 {added: waveshaper with normaliser, RingModulator mode 2
^-^-^-^-^-^-^-^-fixed: DCA, resonance} 
        0.3.5 15-Sep-2005 {ENV button envelopes are always zoomed at 100%
^-^-^-^-^-^-^-^-!!!ADDED WAV Saver!!! Great moment for Sintezar! ;)} 
        0.3.4 14-Sep-2005 {Added: Pitch envelope (+/- 2 oct.), OSC SYNC (Hardsync)} 
        0.3.3 13-Sep-2005 {Octave/keyboard for pitch-selection is functional now.
^-^-^-^-^-^-^-^-Vibrato is working now, main DCA fixed.
^-^-^-^-^-^-^-^-SAVE/LOAD support all parameters (I hope ;) - Not all GUI facets are updated after load (knobs)} 
        0.3.2 12-Sep-2005 {main filter bug fixed!!! limiter was missing and freq/reso envs were exchanged
^-^-^-^-^-^-^-^-added: Main DCA, init/copy/paste envelope, sample window enhanced} 
        0.3.1 9-Sep-2005 {GUI changes, added progress bar, main filter bug still not fixed :/} 
        0.3.0 8-Sep-2005 {added: load, GUI update after load. fixed: main filter bug.} 
        0.2.5 6-Sep-2005 {save enhanced, envelope rates enhanced (1ms - 16s range exponencial instead of 0s-1s linear),
^-^-^-^-^-^-^-^-envelope refresh fixed (although button envelopes refresh still doesn't work)} 
        0.2.4 2-Sep-2005 {added: new mix mode - mix-ring, basic save, intro screen, toolbox, fixed: envelopes, gui changes} 
        0.2.3 1-Sep-2005 "added: ESE-eight step envelope, detune part" 
        0.2.2 28-Aug-2005 {added: mixer, ring modulator, make/play sound, fixed: envelopes} 
        0.2.1 26-Aug-2005 "added: phase stretching" 
        0.2.0 19-Aug-2005 {added: filter, more waves, window function, octave modulation} 
        0.1.0 15-Aug-2005 {phase distortion rewritten from scratch to make it casioCZ-like} 
        0.0.1 25-Jul-2005 "initial version"
    ] 
    references: [
        [1] http://en.wikipedia.org/wiki/Phase_distortion_synthesis 
        [2] http://homepage.mac.com/synth_seal/html/cz1.html 
        [3] http://www.cosmosynthesizer.de/
    ] 
    notes: {
CasioCZ waves:
^-sawtooth (done)
^-square (done)
^-pulse (done)
^-double-sine (pending)
^-saw-pulse (done)
^-sine-sync (done)
^-*triangle (not available on CasioCZ, but done)
^-**waveforms are just my aproximation, not checked against original sampled CasioCZ waves
^-
CasioCZ windows:
^-sawtooth (done)
^-triangle (done)
^-trapezoid (done)
^-*saw-pulse (done, unofficial window)
^-*spike (pending, unofficial window)
^-
Octave modulation: CZ can combine two waveforms in a single DCO: DCO can alternatively playback two different waveforms. [2]
When the original wave is constituted by 2 waveforms (octave modulated), the window affects both waves. [2]
^-Thanks to implementation, when two same waveforms are used, window affects both waveforms together, so there's sound difference compared to one waveform.
^-
Envelopes - there is five of them (only ADSR at the moment, I'll write 8-stage ENV later)
^-DCO (pitch) envelope
^-DCW (phase distortion) envelope
^-DCF/cutoff envelope
^-DCF/resonance envelope
^-DCA envelope

Digital phase stretch - not found on CasioCZ - stretch waveform but cycle lenght is left

Mixer/Ring Modulator
^-PH101 supports Mix-Ring - it's ring modulator with second line (modulator) added to output, so it works both as carrier and modulator
} 
    missing: [
        #1 'pending {(there are three types of RM on CasioCZ...let's see)} 
        #2 'pending {All Casio waves are missing. My waves are different. This is not a priority.} 
        #3 'done "vibrato" 
        #4 'fixed "there's probably some bug in main filter section" 
        #5 'fixed {save does not save global parameters - detune, length (vibrato)} 
        #6 'pending "save WAV" 
        #7 'pending "strange LED behavior when changing sample length" 
        #8 'pending {Math overfolw error where it shouldn't be (square waveh)} 
        #9 'pending "Reset phase before making new sound" 
        #10 'pending "Hard sync for DCO2"
    ]
] 
if not exists? %sounds/ [
    make-dir %sounds/ 
    path: %sounds/ 
    verbose: none 
    files: [%sounds/bassdrum.sin 392 %sounds/basskiller.sin 425 %sounds/blaum.sin 411 %sounds/cosi.sin 456 %sounds/elecguit.sin 529 %sounds/elecguit2.sin 554 %sounds/elecneguit.sin 453 %sounds/epiano.sin 448 %sounds/hardsync.rps 464 %sounds/horn.sin 475 %sounds/horn.wav 444 %sounds/organ.sin 407 %sounds/pluckpling.sis 416 %sounds/resobass.sin 493 %sounds/ressonator.sin 483 %sounds/trumpet.sin 425 %sounds/violin.sin 448 %sounds/violin2.sin 515 %sounds/wildpitcher.sin 403] 
    check: 1799181 
    if not exists? path [make-dir path] 
    archive: debase {eJzdVN1LwzAQfx/sfzj2Kq25pN26vmlbdKDbWOsXIQ+FZa7QJdpWB/713j7QzQ/EFxWTHIG7+11+90EmyfHoDGS7BbSyoil1CJ2
0MI1+yisYnzvIEFL7YKYd2Dhd6qourAmBuczFrTLOGwJi4KT6zuGM+YfohX4Qet0DHjLWbql2a5RGCDKOjgAhjq4I7/G9BfE4BQb
3JDMkp2X+qJ1Sm9tmDj7zXUQRMN4TzBddWBZmapdgrNGQl7e2Kpr5AmSdLxtrCWCss8IrmBVlo6uNozaPurR3ugYpK6JMN2VBTIT
Heq8HV9x6eyritN0KSk1R1lAfcA3HfpfvHNgEfSdKwcuzlB/7MCjgG9O/BBGM5oHvzsOqlL8yAZ/Spv5+IX++zj/a0fPBNciFnWo
qeVU3TlkYvVf9ewKtG/utNvxyVnGSXQwTkB3Wga0ouBwcT46y0eb/8FwPkwMeKBgPsugUpPD6LucBF+gJwYSv4CwZnmRkQcEFvZj
eDCOQs7ystXoGtKViAoMFAAB4nNVTbU+DMBD+vmT/4bKvhnqtgGzfFBZdotsi+JaGDyTrJgkWZbgl/nqvTDeYLkZjjF6vlOs9d9e
Xpxf949EZyHYLSKK0zFQPOmGqS/WcFDA+tzhyCPMnPenACnSlinma6x4gQ8ZfJ4OkpEDuWqF6sASis895TwjSPdFDbLfidmsU+hx
k4B8BZwiBfw0cgnFYWY/0P+X0WSYLZWVKz8o7sBFZF9eNnKme5EvQuVaQZLO8SMu7e5Dzx6ekUDRtmegYpmlWqmIFU3qhsvxBzUH
KghZJI1IZ3LQYMkUY42AOfNLjGDZpkNmHeLBRA2iIW0Hq4n1Q1SyH2aIhBDHH8gZuVnXrRdHesZkqLTac9TS7zgD4lusXgyiMSCK
2SGJGoskOknjImcfXTfwxkrADz+E1NVfddUVNzcw71jjC6W7U/ej0DGe2QOzwfaJGdfGPyPBdBp0PbkDe5xMFRapnjXteE+hLF/7
z+6EnLBok+Mr+gn50OeyDtDh0sGN6DFeD44ujaFSFxDAeRP4pSNumXGf94UlUGRzJDG+HPshpks1V/AKwInjk+wUAAHic3ZRBa9t
AEIXvBv+Hh69F6sxKu1J0SyTTGhLbRGraInQQeO0IFMmW5Rj66zt2WuKUuqW0h7a7WgQ7897s6hNzO76aXSMfDiAjq/raRhilVdP
bT2WH+Y3DxEjbXbMY4Snpznbbqm0ikEsuf9lMyl6EKnBSu3YUkX7NKvJVpPmVioiGg2I4mKUxI0/iS1EGFDCZIGQOjfZDJPF7sEt
I5ikIG1lLBmNfPlqnts2qv4cJfFf5hjw/CAyzxr5qFu0eTdtYlPWq7ar+/gH5eldvrew6B3GBZVX3tnvKss2jrdu13SLPOzmxvEm
q0PMsUFvJOQRcjZ+sosCzDbnGOx3+GdtDPZdeBE9tzp0G/E3obxeJTICrHwI/4j5g/y5wzzOu9i7kW+pQUxieA77d7Mru3yUuNur
i9Pl/fhyR3Uw+IH9oFxZd1azUCzgbyT9S/yVKf/5CvwNSjJJx9m46Rs4Y0QhegbvJ1e1lNjsqCswnWfz2a4dVhgW31kZ7RIaNNEZ
cj6dvMsnwfSYpl36cxsiXpXSx4jOoOGSmngUAAHiczVTfa9tADH4P5H8QeR32JNl3/vHWOmELtEmovW7D+MGQS2pw7MZxm7G/fnK
z4aRbWMfY6J2O4yR9ktB3dzeTy/kVpMMByEiKtjQhjOKias3XvIHFtUVIENcP1XIEB6db0+yKugoBbbTpu3KctwJktmJzbzGiekt
OqHRI/hsOEYeDbDiYxxFBOo4uBOk5vsPa9VzN7HkE4+gjkI0wXsSAsJW1IiDY54/GKk21bu+AtG8rTQp9HbjIAeyLalnvoaorA3m
5rpuivdtAuts+5I0RtdWhM1gVZWuag5upHk1Z35sdpGkjJcuOkgb7mUFpxKcz2Ap+s7IM+jBydo+HOhO2y2fjifE4zLlqgJ6ZXjt
IYMI4HxhnG5E8xEAjU+D6LyHccZQQ7nseC4zZPUt4vm/rWgD/nfLX2Pa/BaHtKvJ74U7juXgkonGe+/z6mjusgl50pyHX70UdFyF
lXE8/QbqplwY2xRerKar1CZdbCfp0Tf6I1H/RI/VTj+jk8bsvfyTjSfJhNoHUIhjhCPwMbqeXNxfJ/AmQwWKaRO9//NCsydaslFY
OoiYtHytcTWbvEvFgRiXZ4s+zCNJVXu5M9g3sZHMw3gUAAHiczZTfb5swEMffI+V/OPV1wvMZG5y8tQnaIrVJVLJuE+IBKW6KRCE
B0kj763dky4LzQ2u0Ttv5EPIXn31nf/B9cDO5hajbAbJZWmemD1dhmtfmW1LC9M5BjhAW63x+BT8GPZiySou8D5xxhj/FYVJTIHp
OaJaO4Fy9R9FHt6/cd6LPebcTdzuTcIAQDQfXgIzDcPAZEIbTEDisQJDyiCRskhfjZCZf1E+gaH50vV2TsEnzebGBvMgNJNmiKNP
66RmiKtnURUEB1WqdlCaGxzSrTQlZsXGWSVWByV9MVixNBVFUUqb05rQW37cYMkNjmg9MwW+eOIb9NJxJrbDljdLuY28Xx33Z8qO
Fm4yY73N3740gLSPFU5b9KqGd1bniAA8+HZRizeydSvr1pXi+ZU2YJWhShG5b7+1qeX0QhRGZ4iIyUTPN3Z7HlecLTRtwnkxnuc4
qcxmanLlHTHko9d7VyeK2Z6Ots2k2WWkr9r/AGq3JRaP8LRRoN1VPtPzPsHYP82R4EKaZXVzgiH8E9t3oC0TPxdxAmeaLHXxbSlc
0fMv1RZfjG6Vmg4aWnT0deQqQI9CEZUfo4faWO8ChtWPDYPZpHECEoMBxY3gY3dxfzyYQKSZ86SupPenRr+8HjguSbjH6u3yle8i
VjmE6mg0+QiQl5XUbjD/Mth3k1A2/jgcQ1eXaxN8BHAXIs3QHAAB4nMWUUW/aMBDH35H4Dqe+TvHOiR0b3lpAG1ILqGHtpigPkXB
ppDSBJBRpn34OhRIbUMuGtIujyH/7nLvzz74f3IxvIWy3QNs0qVLVhasgySr1Oy5gcudQpBDkq2x2BW+THlRRJnnWBSRI6Fbsx5V
2pL4TqIXjIvKvlHVRdJn84nYR262o3RoHPQphv3cNlCD0e49AoT8JAGEJrlaeqBbW8atyUpXNq2dgiKSD748eTLJZvoYszxTE6Tw
vkur5BcIyXld5rh3K5SouVARPSVqpAtJ87SzisgSVvao0X6gSwrDQkeov6n/h/okgVXpOPUA4fPBGEeyXQcIkp41WK80+7Wz9GGW
y0WrFNCuQOkIiBHr7Vgu2D/G5YZvqInlLqxnpqYSBWkNWesbqfp0MCtZou7LY6rF0fGFY7WYIUivSNexoWH+Vy+edtJum1T2LVsp
1rTzqS8Y96TK+o1XT6SxWaWkjuxXPYhaJdwibIbh1kQ0TpxiXxobVlefSQPTC/H8KkAPemWxavZbwrDmX4kNXl3fcRvs31r2DyJm
5M/Uce6sItY/bf2D/bvgTwpd8pqBIsvkOzc21u9TTN+ifdadeKDQTO2rYyb06AOgodvadY4FINwfNgqNRsf5g+mM0gJACB8eL4GF
4c389HUPIiSuY4Ez6zEevIwaOB0xfdPqsCS47FLmMYDKc9r5DyJiO63Yw+jbddCjqbvBr1IOwKlYq+gNKe9SxqwcAAHic7VNNb5t
AEL1b8n8Y+Vqx3dldzMctAZRYSmwr0DTVigOS1wkSZm3Aoeqv7+ImNUbqR6K0pwyDkGbem51h39xE54srkOMRGEvyplA+TOK8bNS
3rILltYUUIdb7cjWBH6BbVdW5Ln2ghBJ8CoZZY4joWLHaWoxS+yM6vuA+8g/Mp3Q8SsejRRwgyDA4AyQUwuAzIITLGCjsgJnIGk2
gzR6VVajyvnmAKSfIPcZsLpCjA21ernQLpS4VZMW9rvLmYQOyztpGa4Ovd/usUims86JRFRS6tbZZXYMqH1Wht6oGKSvTqPlScxQ
9PikUymC6BLHhD2+awrEMJdz2WM87BHVEz595w+jg4K4jwt2+dcXQRvforIsMMU+l+m39ajrAQer/zjKgueR0uMhibzfN35MMzWi
TvUibniBTip5w0TajiOlvxGlt90Wt3tX5rs7XqvN6dgdyo1cKNvnXZwEdlLYz6IM2X6SiN+rs312Og2axfvqBNu1bV0y4J9dz8sP
CKPk0j0BaCDZM6CSF29n5zVmy6FaIdjuewnKWBJcgufAIYy7jKDin3E7hKppfJCYjBFKDi7/MA5DrzOxw+h3BILpyLgcAAHic1VR
Rb5tADH6PlP9g9bXiZt8BR3lrCdoitUlUWLsJ8YCUS4tEuDZhzbRfXzO6NrRB2qRO2owPhM/2+T5/8mV8Nj+HbDwClrRsKhPCUVL
WjflRbGBx4RASJPZbvTyCzunKbLalrUNAgYKejJOi4UDSTmLuHInofSAdShlK71iGiONRPh7Nk4ggm0SnQDCJrtv3IgGEe14r4t9
d8WCcytQ3zS0opQVJhaRVEKAXwK6sl3YHta0NFNWN3ZTN7RqybbFrrOWA2jptfA6rsmrMpnM09YOp7J3ZQpZtuET+IpDo1vOTQ2X
Yr90UHl/LDWhPJXTWgyvP4Tlxm1K4LuoXJcCBg3jjhHrSufbc95IzPAOJ6NXWvx7EYcwE+dtMcLWQdII60MSQkv+eTBgoerjfg30
fptTBTivd40lrCTza0/+ooW+QYHxUT1qLRvWifwUmruRi+gWytV0aWJffe/2/56p/UuuPiPD+sKLw1UEo3ibpzYKnC07i9PMshkw
CIagcrqZnl6fpvMPeFS7FxzLIYTFNo0+/prr0SfjS83xPIfrk8zCG83j2MWUP1yXkY5OvswiyVVFtTf4IENh8exIGAAB4nMVT226
bQBB9t+R/OPJrxXaWmw1vCVitpcS2Ak1bIR6QvHGQCOsAjqV+fXedqoBr2lrqZXYQ2pk5M7M7Z+/m16sbJOMRlMR5UwgfkygvG/E
lq7C+NThxRHJfbiZ4DboXVZ3L0gcxYvybMcwaBeSOEYmdYRI5b7nrk+Wb9hvTJxqP0vFoFQUcSRhcgTNCGHwER7iOQHiGqSwPXBk
O2YswClFum0fYRMyj70s583IjDyhlKZAVW1nlzeMTkvp5n1VCmQ2NTvGQF42oUMiDscvqGqJ8EYXciRpJUqlG1Z9UKWpXikKoGO1
gDn7xpSnaNMRcqyv2QFpdj1HP2U0z1A34iatf26ZpR2e6G6cr7nAvDrdnrTp/trPfBymY4oV5ES88jzmeabuma9kuWdNBXmSHRko
FuIwZ6m5U0lZtfdFuV6baolroqEb1psHPMUsfkNi0J8ep8ZnTqneM6WX7KQf/8ohaENN9uOeO+U/4fhGrbhefkDzJjUCVl9sfJt+
h1jkSMLP3qi098NOBuKchQ9dgd4c7+59PLZzHH5ZzJCYmNAHnKe4X13dX8eoISLFexMF7JOqoKW7my3fxccNJbaPPywBJU+1F+hX
7SIbXNAYAAHic3ZRfb5swEMDfI+U7nPI64flsbANvbYK2SG0SFdZtsnhAipMiUWgIbaR9+h3ttEGbbsq0PWzHHYj7g8/cD67i8+U
F2PEISNKiLV0Ek6SoWvclb2B16SFHSOr7aj2Bp6Rr1+yLuoqAM87wm3OWt1SIgZe4O09wrt6iioSMhHojIs7Ho2w8WiZTBDubngH
CbPqxO68S4LAj2yDdHvIH55Wu2rY3gFIyExipAiQRAg5Fta4PUNWVg7zc1k3R3tyC3e/u88aR2+uqM9gUZeuapzRXPbiyvnN7sLa
hBunKaRn+48igdJTTBZiCX1iWwffHMCkN72kXf+kZOPDosl0/TAfo9/TRo7CnvdJeE6/uBfBZ6L/o/IQiKiPaxBHamOLG7+lx+oT
WTPoEHg9Ra8r6OX1tU+TVtvwX8eMsIJODmXVjlP5gsq+wJJ69TM78AQ/qtDbwRfFxFDTTfTGxJ/42Ub+L4eX8E9jbeu2gKartgI8
dpT+SdxIof34/9M3KgZyyv1mcfljEYD2ECZ9AkMH1/PzqLF2CNUxpSX9wwUWoDRexJwEFckGQGCNDIZWfwWqeTt+DlSJkWhildIg
iCE0GF/HiXUoR30dObSSfF1Owm7zcu+wr4Q+erLUGAAB4nN2TUW+bMBDH3yPlO5zyWuH6bGMIby1BW6Q2iQrtWiE/IMVJkSg0hDb
SPv2OtNqgTTWl2l56nEHc3R+f7R9X0fn8AtLhAMiSvClsAKM4Lxv7M6thcekgR4irp3I5gpeiG1tv86oMgDPO8DU4yRoSou/E9tE
RnLun6AYCA6VORMD5cGCGg3kcIqST8AwQJuGP9r6IgcOGxgrpdZc9W6ew5bq5B5SSeb4nXR/JhIBdXi6rHZRVaSEr1lWdN/cPkG4
3T1ltKey0agOrvGhs/VJmy2dbVI92C2laU4P05DQN/3MZKCzVtAnmwl+GMfD7M0xKj3e8zb+P9AJ4cNq2H6Z9VB3fR1zseEfaaeL
DtQC+SX2Jzo8QkYxoEwdoYy73VMcP0ye0ZlIReHyMWlPVV6WPM5+G7B1Ze4pS9Q72A5TEm73kTPVwcI9rA9+JD5Ogme6aFznifwP
1WQovp7eQPlRLC3Vernt8bKh8D95RoPz79dAvK3t2zPomUXI9iyB1EEZ8BL6Bm+n51Vky3wsMLKZJ+B1SKcZMC8919RiFP/YMXES
zbwlllEJOs8R3sxDSVVZsrfkFbdKXX5MGAAB4nO2U32vbMBDH3wP5H468Dmt3imVbfmtt0wbaJNRe1yH8YIjSGhwrtZ167K/fZV1
p2djKXlYYk+4kuPuefn1AV9np6gLMdALcinpobAyzvG4H+6XqYH3pERLk7tBuZvAourZdX7s2BhQo6HswrQYupMDL7d6TiOo9qVh
hjP47GSNOJ+V0ssoTApMmJ0ACIU0+8gqBDuSzhZCuc0C4B4It8TBWD9ZrbHs73AGRFAppjjrySWMAY91u3Aitay1Uza3r6uFuB6a
vxsE5Ltgfmt6WsK2bwXaPMts+2MbtbQ/GdHxknpG3wedeQmNZc0wIBa94WcLrywD9kPoni7iM+cqf+CotX9jv+MpIkFRzGfoB+mG
gfsX3G1bo7w9V95/u36N7ubgBs3MbC7v689OzN2709lXfPxFFISNFL+zPmLzxFdOs+LDMwEiY4ezoJVwvTq9OihUYEnOtJLsfRBS
iyjwJUaglhymKtB+EGJawXhTJORiOCc3SudIsjjhxkS3PCs74PiGfI/+0TMBsq+MH9RUesWFRggUAAHic7ZNdS8MwFIbvB/sPL7u
V1iRrZ7c7bYsOdBu2fhF6UVimha7Z2s6Kv97T6dgs+ImIFyZpQ07Oez7gybl/ND6FbLdAI0zKVA3QCZKsVI9xjsmZwRlHoFfZtIN
np0uVF4nOBmAmM/mL0YtLEvKeEaiFIRiz97kYMD6w+nu0s3YrarfGgcshPfcQ3GTw3CtweJMADEsIssw4Gar4Xhmpym7LO9gUn3d
7m2mhSrKprpDpTCFOb3WelHdzyCKuSq1JUCxXca4izJK0VDlSXRmLuCigsnuV6oUqIGVOldLOKBfbzgipIp/6wrTxwRdF2IZhZtf
ui51Ve7ADa2dtdE1rI3Fdkdl1dkcdjNvc2S5RW5o+L6F2y3qrO/DG1e/20pA55uvmfEP8XDefF5GM4BRfgrN7YNqWcJhDsDui33s
HTmOxSgv1T+c/nd+l82x4DTnXU4V58rABaE3akrzXbH6Joh+q7I+CRoV5fngx8iE7rAMb9I9wOTw6PwzH6wwRJsPQPYG0LEp96o+
Ow/WBMzoGNyMXchbTm42eAOAGt6YfBwAAeJzdVVFvmzAQfo+U/3DK6wSzDRjDW0uiLVKbRIW1mxAPSHFTJGonQBppv35nMqmQkLW
btIftOIP02d/57vwBd7Pr5Q2k4xGgJUVTyhAmcaEa+T2vYHVrUUIh1nu1nsBx0b2s6kKrEIhNbPoTnOYNEim3Yrm1GCHeRxqEjgg
Z+8BCQsajbDxaxhGFdBpdAYVp9GDuqxijCFfQjsMOsYB3zYdHCtQmcMhfpFVKtWmegBNic+EGTJDAYS6DQ6HW+gBKKwl5udFV0Tw
9Q1rnh0ZrJChtGX4Gj0XZyApKfbC2eV2DVC+y1FtZQ5pWWAg+CWZHXq8MSolrzITtwRsjy+DtMDjRn+qQsFBiu75LOm4CE8d/9Rb
pAo5/YZtjuL79YmPv5DgQ6QHMRDvd2PYCzjp+OREzqOhaMJTKHzXuN0hIQz2yox5NQT3r6tPosdVfT32UEWo7PBAep4Jjmy6pb7f
PK3mmvXbZoO6wlazXS4P0DYzwhzt4olP/7Cz9k0L/lob/HxLSbudfIX3WawlVoTbs7AOya7XdamToTP/51wplQ3uGiDOU2XuaOZ0
lXxYzSC0KEzIxI4P7+fXdVbJsKRms5kn0GVIWODbnrs/9gPquk8HNbPEpwQkh8A+TQfxtEUHaVHuZ/QB5FaRDxgYAAHic3VRRb5s
wEH6PlP9wyuuEZxswhreWoC1Sm0SFtZsQD0hxUyRqJ0CKtF8/m06qaZK1m7SXftgg3fm7O58/fJNcrq4gn05AI6u6WkQwSyvZiZ9
lA+trh2ACqTrIzQyeF92Kpq2UjAAjjMhv47zsNJEwJxU7h2LsfyZh5LqRxz/RCOPppJhOVmlMIJ/HF0BgHt+Z9zrVUbjHiTVgr20
hsxHAPQGCMPTlk3BqIbfdAzCMEeNeSDkOXepR6Cu5UT1IJQWU9VY1VffwCHlb9p1SmiCVY/gF3Fd1JxqoVe/syrYFIZ9ErXaihTx
v9Eb0F+vq8MtTQC30GuNAPrwxiwLeDqMdY5dNwsgLbHATFrvBy/DOBcXI9W2wPyTxXzVeW+wcbmAKObL43giniuDIjkv8xKFGLXo
SbiM8Wdg/tez9JE3TSqTPSjQbHMFWplHioLyR7gjFBLks5D4jnOm2ndPd/lA24kh1w7KTijOn/qrXAeG+Nc4LMjg+yv8nzw9D0rT
rxXfIH9VGQFPJLT26G/bDvTOI4MyhfaS/yNyoo6R/08p5kn1bJpA7BGZ4ZmYBt4vLm4tsNVAKWC+y+CvkNHQRY17AgpAEnlvAVbL
8kmkHY8TXadIfyxjyrjmI4hffXZxznwYAAHic3VTfb5tADH6PlP/ByuvE1T64C+StJWiL1CZRoV2nEw9IuaRIFFJCG2l//XzrmiZ
pp2l9WTVjc8L2x/3w57tMzmbnYPo9YMnKrrIjGKRl3dnvRQvzC4+QIG0e6sUAnpKubbspm3oEKFDQL+e46BhIQy+1a08iqhOSI6Q
RhZ94xH4v7/dmaUxgxvEpEIzjr+49TwHhnm1J/LktHq1X2XrV3QLpUChNCkMdBSgj2Jb1otlC3dQWimrVtGV3ewdm/VBtLHs9B85
hWVadbZ+ybP1oq2ZtN2BMy+vjEXkWfHlyqCznuIBQ8AfLc9j9RgQy0jv1XfjYMQxC2tM3J3WrERGF6kUj5wkOZA+6t4Tf7gToKPT
RQQxjasj/hRr+oQAJdK3y9mGgCF+VP1SR3Kk+wn70Yr6XAReTGzB3zcJCW9arg2Ldc/pPEvxV1f7xfsZJdjVNwAxwAM4YcD05uzz
NZmAi7nk5JK3UMPCVrxLPh0ChL0KNAdOAVBjkMJ9k8Zfnm1lqEloqpZWPqEnzhQrnyfRzxhna9UIO6bdpDGZZMOnzH+aFcDHWBQA
AeJzNVFFvm0AMfo+U/2DldYLaB3cXeGsJ2iK1SVRotwnxgJRLi0SPFGgj7dfPtNlCpkbaHrbV+EAYf/aHz+fr+GJ5Cdl4BCxp2VU
mhElS2s58KxpYXTmEBEn9ZNcTeHW6NU1b1jYEdNGlvXFWdAwk7SRm6whEeUYiJAql/iBCxPEoH4+WSUSQzaJzIJhFn/v7KgGER14
b4tdd8Wycyti77h584ZKPntakPYlawK6063oHtrYGiuqubsru/gGytth1dc2A7VPVmhw2ZdWZ5tXN2GdT1VvTQpY1TJCfyKyFp3G
gbNHToQTMZ3/lUBmO0QNdyY6K/OlBe8vJlefwM6nr0VQeNOhJyKFJ9LF91AelN0mwW0BH0rNXIjio11vkUNQg1IAUDFIcJ6FfPr1
3EMO4t8Tf6y1bOz3+N7rrFOnTffJWv7zLKv/T/byaf4HsoV4bLnnTdk5VWnNU/UcGvWzsH23Df/6rWZzeLGLIJjiB/crhdn5xfZ4
uIRM8mVCIgDzuyynK2BEgUQWuZrsSqJSWOazmafTpx8AWilwl+IhLD1GR4jkLl/HiY8oevk/IjJKviwiyTdFPx+/THXbU7QUAAHi
cxVXbbtpAEH1H4h9GvFbe7Kz3YnhLALVICaCYpK0sP1hiAUuODcYEqV/fMUmLl4KaVlUznvVldmbOXs6s74c3k1uI2i0gmaVVZnv
QCdO8st+SEqZ3HnKEsNjl8w68OD3acpsWeQ844wxfjYOkokA0XmjXnuBcXQnew6CH6oPocd5uxe3WJOwjRIP+NSAM+p/r+zQEDht
qC6TPffJsvczmy2oFgWQi4EZJXxqOUsI+zefFHvIit5Bky6JMq9UTRNvNLiktmb06OoZFmlW2fHGz+bPNirXdQhSVNEB6coLhxyu
GzJJP3cEU/KbFMRzTcOY7IsmiA4UNPQtT4zOlm2Jqi+jqn+o3IpuYl4YOeNL1LkG0X+70356E0hA5xJvJIZF1Dfd9oYSW9dpfIke
y99a7bGuB3qqiqFb/jSDMN5I3lPolOnIgDMqGXiaM7gp1VP8Xi3jvzf+7IFqlJmOwW1scEtHEmBGOXCwqR/S5QGYcuMBh4N3oC0R
PxdxCmeZLhycbAjiQ8I8I8+8rDE1TgppT3DdHPRxCymFG7XP2bDldPtNM5NdnkmyEkZ4U7GA4exgPIULo8A6YGB5HN/fXswlZmHB
SDT0ByqAkCM55gNrvxjAdzfqffvx3hEamBW2aIg+Nmn4XcDscf5yRh9aoaLDh13EfokVCxRx/Bz8OnrK0BgAAeJzdUt9PgzAQfl+
y/+HCq2G2BcbG2wZEl+i2CE5N0weSdRsJtgroEv96D5wCJpr4oovXK6Vf72vv11U4XVwA7/cAJU7LTHpgRKkq5UuSw/LSpIRCpJ/
U2oA3o5XMi1QrD8iADOgBDJISiXRoRvLBZIQ4p5R4jutR54R5hPR7ot9bRD4FHvgToAMCgX8DFIJlBAQe8W9D8bNPnqWZSbUtd0A
JGTDmvg8L9qla6z0orSQk2Vbnabm7B14k+1JrJChtVnwBmzQrZf5mKNWzzPSDLIDzHJ3EFa91xm3FSGxiuY3aiLT3llsB9oi2tCI
5dNQoqxDakQphHamQrgjIJLpY++Xg8bjzSkVw6nxhtg8rG3XeRcQdsnGjVmUrBDTxDq2OYKJJM1oOAP101Lrk/5CQhq3IjqIVv3S
77oVv59Hn+Vcrejm7BX6v1xJTnhelmaVKdrL/UdgfleGPowrC+HoeAjeIAYcpYDWbXk3iRc0RsJzF/jlw28bLLsL5WVxvsGMFRHd
zH/gmyQopXgGfCXZ16AUAAA==} 
    if check <> checksum archive [print ["Checksum failed" check checksum archive] halt] 
    foreach [file len] files [
        if verbose [print [tab file]] 
        either len = 'DIR [
            if not exists? file [make-dir/deep file]
        ] [
            data: decompress copy/part as-binary archive len 
            archive: skip archive len 
            write/binary file data
        ]
    ]
] 
toolbox-images: context [
    new-project: first reduce load decompress 64#{
eJztl8EKgzAMhu99CsdeYOhBfAFfYuzgQYYM74Oxdx+zwiJpuqRaU6HJYSDL8v2l
38Cxe/TFMHb3/lRcq/JZlcX5ZdoVlYfzcB6mhy9BZexH1X5bAxvCWwpOG/zI/sS+
2BCec5DkZk6EODcMXwkcgbWZihBTDOpWz5dEug1GiO8zqSS81eLNUhnE2LawsA4l
+REWm3fyeXHaYaXuc9i/d1I+8yMk67M/wrrNCj6Lh8nNzdQH9bkBfTifG9QH8hnD
4wjJ+kzB11Mn7jMFb+r216n67MCGRy+NsK/PDmwK3h9Bw2cHNgc+EZ/9xvrh1X0O
g9d4f3b4LIUn3zE0fOb3H2x/hK3FgHv8ZThfwjVn3hg7D+dh5rB53z5iBFREfxgA
AA==
} 
    open-project: first reduce load decompress 64#{
eJztVksKg0AM3ecUll5AlOK+Cy9RunAhpRT3hdK7F80sIjFj5uNnislCUZ55b5KX
tmtebfbsmkd7ym5l8S6L7PyBOiAO8H+B8yG2qBwBnJNYt3IEMNK+1H0CXqRmRK4c
AYxMDe1qSFcJG7aKHn1FUiNh8wmj5PGeSuBvd0Ibg9KjT/j5G2P4WWJUOfcKVWU+
SAbsR3hEm1a41toE/sguhJ4/UA1BtF0lTNDWSwDJBkG0uQRxSDRR1n3OgLkNeDjQ
5hKQBeDFLyfA+G1uAxGsbw8NkL4qMfJsVRB4gra9GXYJM8YIcpXdbTMTZpdgDmxV
2gYstUEjAXgD1qLNG6CXIPpZI2GZCdNIGP0+u5Jf0hh28g5+5hLW8jOX4Onnna8h
u4Qk1hCXkNwawhD9nMQakpqR0BrSS9jtGrJLSGIN8UhuDRnaUhs0Efv/tiftIM0H
OAAM3/sPwwsyNn8YAAA=
} 
    save-project: first reduce load decompress 64#{
eJztmDEOwjAMRXefoogLVO0NGHoJxNChQgh1R0LcHQmWhtQ/32kyFNneUH/8X+K/
MI/3qbnN43U6NOe+e/Rdc3zKsKFc7GJQ7aekVeo0pFuYj+JWJ5uZNfMYIdN2IMaT
DU/FI1C2tYNWxHjyEiSxYfgI820HYu0yGARZMlgREpMTS6JZYhAyg6GKeQTBxjCC
OplBqJNn5iAqzxqC59mIsNc859GuTLYiJFJFXVgVMTZP5TlzcjGxahtv0rf64bcl
/onvhBgjZOa5vm2MUCLP1W3HCKXzXN12IMabpFUiz/Vtx8/AIHiey9rGCJ5nI4Ln
2YjgeS5rGyOY8xw8FbNJBWzHCIKNYQTP8/an4hF296fpf4rldXkDbAq9gX8YAAA=
} 
    make-sound: first reduce load decompress 64#{
eJztlD1u5DAMhXueYhZ7AVkjS3LpkTSXWGyRIggWi/QBgr178EgWNDRO5J0izfDr
aMl84t/r09/n05/Xp5fnH6dfPrz5cPr5Ttc77HH52y5fGkgOeDbHlj2YHCgNyBmy
h+IK9E8etAncJbtEkB1gEfm6ArKuGkF/KGagT8tgLuC+hB1Nkj1DNkklAH5g+Twm
vyNSdeA/ZY8cWs5gdmBzWSvJVRWXPCRX0P+orSAmQFyd2tguV7AwcQLlAqxHzmhk
Z6wGoEc5J2UFmiSuv9iNN0snzYxrQH6XMpAiLRWkBsi6Ipv8yCpqEfgAVg+0ziop
AHHNVzCiiPYkjSgiaX3X2VRAWoF4fAPbOpu6HS0b2brZyImtV7SRrSKZmsBIw96o
c29chPxF5BHjZs92/qlfAJ+vhDmDTW/zaDUbRz2F2ZOdC7Cd1C/APQ/ZvWm35BTA
ythoSwYhApUdGM+IpQDkR3tLko4mqTK6AOWCjJt8lh7m/tNh8AVIt2vHjjTJ4Q6T
IRVFZw80Ptu8AL08JzBlYH/B2r3OFq9emT/rIVm6N0byDOzvZCS5wHlagcoWkf0T
+AWbOePceXkaSQ6rB+JSD8vo91Z04EbCpEt4hWm0wgxl20oaUUR7kkZsqEn2ykbW
NV62A5Hvkv24/Lj89aF/vz8As15irdINAAA=
} 
    play-sound: first reduce load decompress 64#{
eJztlkFuwyAQRfecIlUvANgEWGJjX6LqIouoqqrsK1W9e/pnqISVkIASV6raeavI
Hs3nfyA+7N72m9fD7mX/sHnS/bvuN48fYr6h/mSzUYQHPzu59EAHILPyEUwKrDm5
VJ0EXEKelJ3B7Ij7Ti4255LyGjqQfszADGB9w/QEeHCI4Ewzi2FhKVuqPNvmyUXZ
2hEk7Mq7FB4Huci5Ptsq2UkR0dDM9rBVrItPrYmganKNohvd7oEciYpsF80lSVWT
Sw+cAX4LzAROj62oybakqMEw14PRAxuBMBpsqUYDkjI63OSmLq651aRIpGY5gcEB
q4HzRABKA5aiOzA5cGXNDXvbUXkJ2H4bgJ8BOeVMD1gF5ehEUKBmtQtFdP7PyE6R
BMAT6F/Q0H7xgwVyAN+Xfg/iAOpVLPd2dktuNVBpVSAQVgE3AsEilQTp6NOrUwQN
ky+b1FlA4r5+AMG7NEhQiqSUyI03SWaS6QBbkkdSSmTNbxK2ip2XvHuzRERNJM2T
S3Xmm+RyJHebXGxO94YDNYfkt34y/zev0Cw+n4/dHITu0g0AAA==
}
] 
leds: load to block! decompress 64#{
eJzVlr0KwkAQhPt9ihNf4CSCqS3yEmKRIojI9YL47oraxFxmdvIH2YNt7ubbWW6L
TfWtCddUX5pNOO2K+yFsHxZHRK+4OPJj+BrjiBjjZHGmstotse3BCbaFr/LET2zP
c0iLzVBV8Wz4GuOIGONkcaay2i2x7cEJtruxvhmKcf8+OBt7hHBUjHADxJnKWrfU
NsdJtv9jfTNUOrLha4wjYoyTxZnK2J7cswcn2O7GrDNUfsoOy73iUbvB92CcvNK0
bKviTGW1W2LbgxNsC18l/POyMzTBPoRx8krTsj3BPqR2S2x7cILt2WboBVK1ya2X
DQAA
} 
logo.png: load as-binary decompress 64#{
eJwBHwPg/IlQTkcNChoKAAAADUlIRFIAAABuAAAALQgCAAAAwPXJbgAAAARnQU1B
AACxjwv8YQUAAALWSURBVGhD7Zo7csJADED3uBwiZcqcgAvQ06dOS0tJSUfJpCGa
CIRYfSybDVmwPCoYW2h3n75mKCWvtgTeT98p0wjUjgArbX0zE2sKt/Ot5bKQnE5l
UA6HQjITeLfHTJTN3J4oE2UzAs0M2VF5PBYSXigjNfTO7X1+FpSnuhJlM3f1h/Lt
7TotNDvmIwz1h3K/9wYvYvL1paiBG+jypzdS2+0KiKq8Xp+1fFOXQmSj5HMit/Xx
UUh8Z08eM2k51T6WUdDBD6vVFcR2q6BcLAoIPAJBy+AGSRzcQCI3QHfQDl/oYipR
Xt4+EuU8onJyrfcTHOsGDGpqWZSLQskDQZtQiEEGLyfB7e/aCa4GfFWA+ezJ9Qf3
6iv4KIP9BJfg8wB8EeumvNQmBvrSW/+Akh/Y6qrgCVLDeMFzJsprB0R2FhHeDTFM
KAEhcwdRYirwkHFiHAzictDoQeRFwxAEJgrsp7sEn4ySYNHUtdmczwks4DMIGMci
SHdQhy7kAmqojz5zGFGBopmJFwQ/UX4XtWul5Wo+V/Islr9XDqLkS3BljKCqJuK7
P13qJM8VgiVVXauaIi1Tt4gSpea2RHkTthmVTgvp/JGd4JZXrd8r+YzJuzAvgtJm
1esD1b1boImymWv+DGWzHT6NoUTZzFU2SnyTQ/G7IT6N/47ZbPN9GUqUzfyRKJ8E
ZfBPTHiaoDJXUzFUdrhOZAl1MxHe418cI1YvOpGt0w6CynNHKflLIk408ZitPjue
RYMyKiObIR1pxFrxQVEZ2X2i9BJe5mzlbe7zRDkOpVoQI5WevqgmOH/q5Kbquarj
VedRLVvtrr6v5PyYVjO2Y1ptxzmSPF7kDiGT7JxW1h3KiC+cgJ0QKX6cVs0kUXr/
mQ+mvKwtE9xGRh6R4L1FpcVLFrdZJ3i8s92jqY53rxaV9wCyeqAz1fGB4Q9RRvL6
ZXT0tx3VsXlzkMDLhEVHB/kBkIiuI8JwoEkAAAAASUVORK5CYIJIk2nxHwMAAA==
} 
sine.png: load as-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtKiQMzPwQQkWyyEbYAUY3GQuxPDunMyL4EclnRH
X0cGho393H8SWYF8hWSPIF8Ghio1BoaGFgaGX0ChhhcMDKUGDAyvEhgYrGYwMIgX
zNkVCDIo2dPFMcTCf+vkQC4GBQ7nt8/u3ulxasoxVvro3GPuu3rFKptI0ULzlQ+z
hY6H1c9ITHxz0mDGGa73RQ6LPlvPmV7xzP/oZN0NmY9jv6Q6Lr4rOM/vu738tgff
H339+HpP1auL7w98Xr6cd8Ojje1uLg89gNYxeLr6uaxzSmgCAFN4UjvlAAAA
} 
triangle.png: load as-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtKiQMzPwQQkWyyEbYAUS7qjryMDw8Z+7j+JrEB+
uqeLY4iF/9LJkXwMihzO1ubfn/F0/mYzlagPiTvaNL9DwURIYGbVfwuFiLI3T0Xm
PlTvPNcvoR/4Q1ZBdU2LJGfGhKf7q1/tqj29aNZbrjlal1xuZt1fdfjTWv1pz20+
HL/WZbq/TuaQnfYT9ikHNnXyvT7lC7SSwdPVz2WdU0ITAKEvP8CwAAAA
} 
pulse.png: load as-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtKiQMzPwQQkWyyEbYAUS7qjryMDw8Z+7j+JrEC+
m6eLY4iFf/Kf///tmV0XNDY2Ch1h2CKnz2QlwM+QeUy9N1zszfeF6+XjfzDbdqiX
Odw7Lr+nxSn9x2v1CQ6aXn8OrDgo/48llfF2dNfGhjkZ+4EmMni6+rmsc0poAgBm
VS4QjwAAAA==
} 
saw.png: load as-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtKiQMzPwQQkWyyEbYAUS7qjryMDw8Z+7j+JrEB+
tKeLY4iF/9LJnnwMChzMr8//tXxUFNB06lLFYb/GDEWlJSGNZxiPC+/onjHN0sfy
ELPI0krxp1Z7Jl76u/5v/er7W+2lJFVnh3Qdtg9mOfpWfMqC+uVP5OzrZW7/Wrdd
ykJ03tzPz/xcgNYweLr6uaxzSmgCAD2dOcakAAAA
} 
keyboard.png: load as-binary decompress 64#{
eJwBqAFX/olQTkcNChoKAAAADUlIRFIAAABjAAAARAgCAAAAGvAcTAAAAARnQU1B
AACxjwv8YQUAAAFfSURBVHhe7dvREoIwDERR/v+nFRQFEei2I8zIHF5JBbZ3kxRq
1zlyBW7bx86PLAblkfOB/aiTr958n8PAk++VUpuztT8TJ88TptJ5ohSlNhRorieY
whSmnvY5v0fhPu7jPu5bYUCP/qFAc6a0mpmkwxSmZgrknsojvXVJOxpKUerXvR+m
MIWpx0reF4e076MUpV4KNL9HXlQeTGEKU6tVKF9L5ZHc19j3yVPylDwlT628Gc2z
7xGRMrqMfvBKXu1T+9Q+tU/tK+1Nvsg35OcWp+9j9fHyyPfwfsiOUgddve0+C7Uv
/45y+UhK7TM9nh0xjGJLOw0xNSlQzCl59vnHSO6LHMV9hco7Zx9TmAoUqMq8mAoU
TfYlXL72RzpRivsqKhqmIgUwhakIlMI/4ZprlC4hkt9qpsKnmMJUoIDaV+GpQM8h
RJ6q0FSeiqjCFKYiUOp6VO6LRN3cc+XEtwJ3Q20XtjlRpMkAAAAASUVORK5CYIIA
8sGbqAEAAA==
} 
stz-home: what-dir 
sample-rate: 44100 
sample-length: 44100 
sample: make binary! 1000000 
pitch: 440 
oct: 1 
vibrato-wave-length: 1 
vibrato-phase: 0 
vibrato-depth: 0 
vibrato-amount: 0 
knob-style: stylize/master [
    knob: box 50x50 with [
        colors: white 
        data: 0 
        outer-part: none 
        inner-part: none 
        guideline: 'outer 
        guideline-point: 25 
        angle: -45 
        inner-radius: 14 
        last-offset: 0x0 
        feel: make feel [
            redraw: func [f a p] [
                f/data: max 0 min 1 f/data 
                f/effect/draw/transform: min 225 max -45 f/data * 270 - 45 
                f/effect/draw: skip find f/effect/draw 'arc 4 
                f/effect/draw/1: to integer! f/data * 270 
                f/effect/draw: head f/effect/draw
            ] 
            engage: func [f a e] [
                if not any [
                    all [f/data = 0 f/last-offset/y <= e/offset/y] 
                    all [f/data = 1 f/last-offset/y >= e/offset/y]
                ] [
                    switch a [down [f/last-offset: e/offset]] 
                    f/effect/draw/transform: min 225 max -45 f/effect/draw/transform + f/last-offset/y - e/offset/y 
                    f/data: (f/effect/draw/transform + 45) / 270 
                    f/effect/draw: skip find f/effect/draw 'arc 4 
                    f/effect/draw/1: to integer! f/data * 270 
                    f/effect/draw: head f/effect/draw 
                    f/last-offset: e/offset 
                    do-face f f/text 
                    show f
                ]
            ]
        ] 
        multi: make multi [
            color: func [face blk] [
                face/colors: reduce switch length? blk [0 [[66.155.148 44.103.98 51.51.51 39.39.39 255.255.255]] 1 [[blk/1 blk/1 / 1.5 blk/1 blk/1 * 1.3 blk/1 blk/1 / 2.25]] 
                    2 [[blk/1 blk/1 / 1.5 blk/2 blk/2 / 1.3 blk/1 / 2.25]] 
                    3 [[blk/1 blk/1 / 1.5 blk/2 blk/2 / 1.3 blk/3]] 
                    4 [[blk/1 blk/4 blk/2 blk/2 / 1.3 blk/3]] 
                    5 [[blk/1 blk/4 blk/2 blk/5 blk/3]]
                ]
            ]
        ] 
        words: [
            guideline [new/guideline: second args next args] 
            inner-radius [new/inner-radius: second args next args]
        ] 
        append init [
            inner-radius: min inner-radius (size/x / 2) - 3 
            guideline-point: switch guideline [
                inner [(size/x / 2) * 0.75] 
                outer [3]
            ] 
            effect: compose/deep [
                draw [
                    line-width 2 
                    line-cap round 
                    pen (colors/1) 
                    arc (size / 2) ((size / 2) - 1) 135 (data * 270) closed 
                    circle (size / 2) inner-radius inner-radius 
                    transform -45 (size / 2) 1 1 0x0 
                    line (as-pair guideline-point size/y / 2) (as-pair (size/x / 2) - inner-radius - 1 size/y / 2) 
                    line-width 1.5 
                    line (as-pair guideline-point size/y / 2) (as-pair (size/x / 2) - inner-radius - 1 size/y / 2)
                ]
            ] 
            effect/draw/transform: (data * 270) - 45 
            angle: (data * 270) - 45
        ]
    ]
] 
demo: layout [
    styles knob-style across 
    knob 100x100 180.180.190 180.180.190 black inner-radius 30 
    knob 15x15 250.200.170 200.200.200 guideline 'inner inner-radius 7 
    knob 40x40 200.205.220 100.105.120 200.205.220 inner-radius 10 
    knob inner-radius 5 
    knob yellow gold orange inner-radius 17 guideline 'inner 
    knob yellow gold orange inner-radius 17 guideline 'outer 
    knob 100x100 180.180.190 white black inner-radius 30
] 
stz-styles: stylize [
    slider: slider 150x20 220.220.230 180.180.190 
    field: field 50x20 51.51.51 66.155.148 font-size 10 edge [size: 1x1 color: black] font-color 132.255.250 with [font: make font [offset: 0x0] para: make para [origin: 0x0 margin: 0x0]] 
    button: button 60x21 black black 132.255.250 effect [fit contrast 10] edge [size: 1x1 color: 132.255.250 effect: none] font-size 9 font-color 132.255.250 
    button-lfo: button 21x21 effect [draw [pen 180.0.0 text 3x3 "lfo" pen 90.0.0 line-width 2 line 0x0 21x21 line 0x20 20x0]] 
    text: text 89x20 
    inp-txt: txt 100 white gray bold 
    txt: txt 132.255.250 bold 
    tx: txt font-size 9 43x10 with [para: make para [origin: 0x0 margin: 0x0]] 
    radio: radio 15x9 with [images: reduce leds] edge [size: 1x1 color: 51.51.51] 
    radio-line: radio-line font-color 132.255.250 font-size 9 with [images: reduce leds] 
    check-line: check-line font-color 132.255.250 font-size 9 with [images: reduce leds] 
    bar: bar 110x1 66.155.148 edge [size: 0x0]
] 
stylize/master [
    toolpanel: panel with [
        txt: "" 
        type: 'toolpanel 
        siz: 16 
        group: 0 
        closed?: no 
        color: none 
        edge: none 
        multi: make multi [
            text: func [face blk] [
                if pick blk 1 [
                    face/txt: first blk 
                    face/texts: copy blk
                ]
            ]
        ] 
        words: [
            closed [
                new/closed?: yes 
                next args
            ] 
            group [
                new/group: second args next args
            ]
        ]
    ] 
    tool: box with [
        edge: make edge [size: 1x1 color: none effect: none] 
        type: 'tool 
        colors: reduce [none 132.255.250] 
        color: none 
        effect: [merge key 255.255.255] 
        feel: make feel [
            engage: func [face action event] [
                switch action [
                    time [if not face/state [face/blinker: not face/blinker]] 
                    down [
                        face/state: on 
                        if face/type = 'tool [
                            foreach fc face/parent-face/pane [
                                if equal? fc/type 'tool [fc/edge/color: fc/colors/1 fc/edge/effect: none]
                            ]
                        ] 
                        face/edge/color: face/colors/2 
                        face/edge/effect: 'ibevel 
                        show face/parent-face
                    ] 
                    alt-down [face/state: on] 
                    up [if face/state [do-face face face/text] face/state: off] 
                    alt-up [if face/state [do-face-alt face face/text] face/state: off] 
                    over [face/state: on] 
                    away [face/state: off]
                ] 
                cue face action 
                show face
            ]
        ] 
        words: [
            nt [
                new/type: none 
                new/colors: [200.200.210 200.200.210] 
                next args
            ]
        ] 
        append init [
            edge: make edge [] 
            size: image/size + 2x2
        ]
    ]
] 
to-AIFF: func [{converts SINTEZAR sound to AIFF using SINTEZAR values} 
    sample 
    bits 
    samples 
    sample-rate 
    /local COMM-chunk SSND-chunk FORM-chunk
] [
    SSND-chunk: join load rejoin [
        "#{" 
        "53534e44" 
        to-string to-hex bits / 8 * samples + 8 
        "0000000000000000" 
        "}"
    ] sample 
    COMM-chunk: load rejoin [
        "#{" 
        "434f4d4d000000120001" 
        to-string to-hex samples 
        to-string skip to-hex bits 4 
        "400e" 
        to-string skip to-hex sample-rate 4 
        "000000000000" 
        "}"
    ] 
    FORM-chunk: load rejoin [
        "#{" 
        "464F524D" 
        to-string to-hex (
            4 + (length? COMM-chunk) + (length? SSND-chunk)
        ) 
        "41494646" 
        "}"
    ] 
    return join FORM-chunk (join COMM-chunk SSND-chunk)
] 
Chunk-ID: "RIFF" 
RIFF-Type-ID: "Wave" 
itble4: func [n /local rslt] ["Integer To Binary Little Endian (4 bytes align)" 
    rslt: copy 64#{} 
    n: to string! to-hex n 
    forskip n 2 [insert rslt load rejoin ["#{" n/1 n/2 "}"]] 
    rslt
] 
itble2: func [n /local rslt] ["Integer To Binary Little Endian (2 bytes align)" 
    rslt: copy 64#{} 
    n: to string! to-hex n 
    forskip n 2 [insert rslt load rejoin ["#{" n/1 n/2 "}"]] 
    copy/part rslt 2
] 
wav-structure: func [smpl] [
    to binary! rejoin [
        to binary! "RIFF" 
        itble4 ((length? format-chunk) + (length? data-chunk smpl) + 4) 
        to binary! "WAVE" 
        format-chunk 
        data-chunk smpl
    ]
] 
format-chunk: to binary! rejoin [
    to binary! "fmt " 
    64#{EAA=} 
    64#{AAA=} 
    64#{AQA=} 
    64#{AQBErA==} 
    64#{AAAQsQ==} 
    64#{AgA=} 
    64#{BAA=} 
    64#{EAA=}
] 
data-chunk: func [smpl] [
    to binary! rejoin [
        to binary! "data" 
        itble4 length? smpl 
        smpl
    ]
] 
buffer: context [
    length: 256 
    data: make block! length 
    init: does [
        data: make block! length
    ] 
    fill: func [fnc] [
        init 
        loop length [
            insert tail data do fnc 
            data
        ]
    ]
] 
pipe: context [
    length: 256 
    data: make block! length 
    init: does [
        data: make block! length
    ] 
    insert: func [value] [
        insert tail data value 
        if (length? data) > length [
            remove first data
        ]
    ]
] 
convert: func [
    {Converts sample value to 8 or 16 bit signed or unsigned binary value} 
    value "Sample value (-1..1)" 
    /bit16 /signed
] [
    if bit16 [
        if signed [
            return load rejoin ["#{" to-string skip to-hex to-integer value * 32767.5 4 "}"]
        ] 
        return load rejoin ["#{" to-string skip to-hex to-integer 1 + value * 32767.5 4 "}"]
    ] 
    if signed [
        return load rejoin ["#{" to-string to-hex to-integer value * 127.5 "}"]
    ] 
    to-binary (to-string (to-char (to-integer ((1 + value) * 127.5))))
] 
if (false) [
    foreach file [
        %styles/knob.r 
        %styles/stz-styles.r 
        %styles/toolpanel.r 
        %tools/aiff.r 
        %tools/wav.r 
        %tools/buffer.r 
        %tools/convert.r
    ] [include file]
] 
sndport: open sound:// 
~fnt-h1: make face/font [name: "arial black" size: 60] 
~fnt-h2: make face/font [name: "arial black" size: 12] 
~fnt-h3: make face/font [name: "arial black" size: 15] 
~btn-chg: none 
~fld-smplen: context [text: "1"] 
modules: either exists? %modules/ [read %modules/] [copy []] 
m-offset: 10x10 
remove-each module modules [not equal? "r" last parse module "."] 
forall modules [modules/1: to word! first parse modules/1 "."] 
outputs: copy [] 
main-output: none 
module-stack: copy [] 
modnr: 0 
add-module: func [value] [
    modnr: modnr + 1 
    either issue? prepared-modules [
        do rejoin [%modules/ value ".r"]
    ] [
        do select prepared-modules value
    ] 
    tmp: get to word! value 
    tmp-name: to word! rejoin [get in tmp 'name "-" modnr] 
    insert tail module-stack set tmp-name make tmp [id: tmp-name] 
    do get in get tmp-name 'init-gui 
    append outputs compose/deep [(tmp-name) [(get in get tmp-name 'output)]]
] 
prepared-modules: copy [] unset 
prepared-modules: ["ESE" [
        ese: context [
            name: "ESE" 
            info: "Envelope generator" 
            type: 'generator 
            id: none 
            input: none 
            output: 'envelope 
            value: 0 
            rates: [0 1 0 0 0 0 0 0] 
            levels: [0 1 1 0 0 0 0 0 0] 
            step: 1 
            steps: 0 
            length: sample-rate 
            position: 1 
            zoom: 1 
            export: does [
                reduce ['rates head rates 'levels head levels]
            ] 
            main: func [/local rate level next-level tmp] [
                either step = 9 [0] [
                    rate: rates/:step 
                    level: levels/:step 
                    next-level: levels/(step + 1) 
                    step-length: (rate + 1 ** 14 / 1000 * sample-rate) + 1 
                    step-pos: 0 
                    repeat i step [step-pos: step-pos + (1 - rates/:i * sample-rate)] 
                    tmp: ((steps / step-length) * (next-level - level)) + level 
                    steps: steps + 1 
                    if steps >= step-length [steps: 0 step: min 9 step + 1] 
                    position: position + 1 
                    value: tmp
                ]
            ] 
            ~knb-rt1: ~knb-rt2: ~knb-rt3: ~knb-rt4: ~knb-rt5: ~knb-rt6: ~knb-rt7: ~knb-rt8: 
            ~knb-lv1: ~knb-lv2: ~knb-lv3: ~knb-lv1: ~knb-lv5: ~knb-lv6: ~knb-lv7: ~knb-lv8: 
            ~env-name: 
            ~curve: none 
            gui: none 
            init-gui: does [
                gui: layout/tight compose [
                    styles stz-styles 
                    style knob knob 16x16 inner-radius 3 
                    style tx txt white bold font-size 9 25x12 with [origin: 0x0 margin: 0x0] 
                    backdrop 66.155.148 effect [gradient 0x-1 66.155.148 51.51.51] 
                    across 
                    origin 0x10 
                    space 2x2 
                    box 150x18 effect [merge gradmul 1x0 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 text 0x0 "ENVELOPE" vectorial]] 
                    return 
                    ~curve: box 150x50 black effect [draw []] edge [size: 1x1 color: black] 
                    slider 12x50 edge [size: 0x0] effect [merge luma -30] [zoom: (value * 9) + 1 show-curve] 
                    across 
                    return 
                    box 10x10 
                    return 
                    space 2x2 
                    tx 27 "rate" 
                    ~knb-rt1: knob 132.255.250 with [data: 0] [rates/1: value show-curve] 
                    ~knb-rt2: knob 132.255.250 with [data: 1] [rates/2: value show-curve] 
                    ~knb-rt3: knob 132.255.250 with [data: 0] [rates/3: value show-curve] 
                    ~knb-rt4: knob 132.255.250 with [data: 0] [rates/4: value show-curve] 
                    ~knb-rt5: knob 132.255.250 with [data: 0] [rates/5: value show-curve] 
                    ~knb-rt6: knob 132.255.250 with [data: 0] [rates/6: value show-curve] 
                    ~knb-rt7: knob 132.255.250 with [data: 0] [rates/7: value show-curve] 
                    ~knb-rt8: knob 132.255.250 with [data: 0] [rates/8: value show-curve] 
                    box 10x5 
                    return 
                    tx 27 "level" 
                    ~knb-lv1: knob 51.51.51 with [data: 1] [levels/2: value show-curve] 
                    ~knb-lv2: knob 51.51.51 with [data: 1] [levels/3: value show-curve] 
                    ~knb-lv3: knob 51.51.51 with [data: 0] [levels/4: value show-curve] 
                    ~knb-lv4: knob 51.51.51 with [data: 0] [levels/5: value show-curve] 
                    ~knb-lv5: knob 51.51.51 with [data: 0] [levels/6: value show-curve] 
                    ~knb-lv6: knob 51.51.51 with [data: 0] [levels/7: value show-curve] 
                    ~knb-lv7: knob 51.51.51 with [data: 0] [levels/8: value show-curve] 
                    ~knb-lv8: knob 51.51.51 with [data: 0] [levels/9: value show-curve] 
                    return 
                    space 2x2 
                    button 58 "init" [
                        either any [
                            equal? self module-stack/3/envelopes/1 
                            equal? self module-stack/4/envelopes/1
                        ] [
                            rates: [0 1 0 0 0 0 0 0] 
                            levels: [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5]
                        ] [
                            rates: copy [0 1 0 0 0 0 0 0] 
                            levels: copy [0 1 1 0 0 0 0 0 0]
                        ] 
                        init-module
                    ] 
                    button 58 "copy" [clipboard-envelope/rates: copy rates clipboard-envelope/levels: copy levels] 
                    button 58 "paste" [rates: copy clipboard-envelope/rates levels: copy clipboard-envelope/levels init-module]
                ] 
                show-curve
            ] 
            show-curve: has [old-wave-length old-position] [
                old-step: step 
                old-steps: steps 
                old-position: position 
                old-sample-rate: sample-rate 
                step: 1 
                steps: 0 
                sample-rate: 60 / (length / sample-rate) 
                bluk: make face [size: 60x21 edge: none color: black effect: [draw []]] 
                bluk/effect/draw: compose [pen green line-width 2 line] 
                repeat i 60 [
                    position: i * (length / 60) 
                    insert tail bluk/effect/draw as-pair i (-20 * main) + 20
                ] 
                if not none? ~btn-chg [
                    ~btn-chg/image: to image! bluk 
                    show ~btn-chg
                ] 
                step: 1 
                steps: 0 
                sample-rate: 14.8 * zoom 
                ~curve/effect/draw: compose [
                    pen 0.0.0 line-width 0.75 
                    fill-pen 0.92.28 
                    box 0x0 (as-pair (to decimal! ~fld-smplen/text) * sample-rate 50) 
                    pen green line-width 3 line
                ] 
                repeat i 148 [
                    position: i * (length / 148) 
                    insert tail ~curve/effect/draw as-pair i (-48 * main) + 48
                ] 
                show ~curve 
                position: old-position 
                step: old-step 
                steps: old-steps 
                sample-rate: old-sample-rate
            ] 
            init-gui 
            init-module: does [
                position: 1 
                steps: 0 
                step: 1 
                length: sample-length 
                repeat i 8 [
                    set in get bind to word! join "~knb-rt" i 'gui 'data pick rates i 
                    set in get bind to word! join "~knb-lv" i 'gui 'data pick levels i + 1
                ] 
                show-curve 
                show self/gui
            ] 
            init-module
        ]
    ] "PHiDO2" [
        switch-range: func [number blk] [
            foreach [rfrom rto action] reduce blk [
                if all [number >= rfrom number < rto] [return do action]
            ]
        ] 
        phido2: context [
            name: "PHiDO2" 
            info: "Phase distortion oscillator" 
            type: 'generator 
            id: none 
            input: [DCW none feedback none amplitude none] 
            output: 'main 
            value: none 
            phase: 0 
            DCA: 0.707106781186548 
            DCW: 1 
            DPS: 0 
            ph: phw: 0 
            d1: d2: h: l: b: n: f1: q: 0 
            q1: q2: 1 
            f1: f2: 1 
            pole1: 0 
            wave-length: 400 
            windows: [
                none [1] 
                sawtooth [1 - phw] 
                triangle [2 * either phw < 0.5 [phw] [1 - phw]] 
                trapezoid [either phw < 0.5 [1] [2 * (1 - phw)]] 
                saw-pulse [either phw < 0.5 [1 - (phw * 2)] [1]]
            ] 
            wins: copy [] 
            forskip windows 2 [append wins to string! windows/1] 
            window: 'none 
            algorithms: [
                sawtooth [
                    d: (1 - dcw) / 2 
                    cosine 360 * case [0 < ph and (ph <= d) (ph / (2.0 * d)) 
                        d < ph and (ph <= 1) (((ph - d / (1 - d)) * 0.5 + 0.5))
                    ]
                ] 
                new-sawtooth [
                    d: (1 - dcw) / 4 + 5E-2 
                    sine 360 * do select reduce [0 < ph and (ph <= d) [ph / d / 4] 
                        d < ph and (ph <= (1 - (d / 4))) [ph + 0.3 - d] (1 - (d / 4)) < ph and (ph <= 1) [0]
                    ] true
                ] 
                square [
                    d: 1 / max 1E-24 (1 - dcw) 
                    cosine 360 * case [0 < ph and (ph < 0.25) (ph * 4 ** d / 4) 
                        0.25 <= ph and (ph <= 0.5) ((abs ph - 0.5) * 4 ** d / 4 + 0.5) 
                        0.5 < ph and (ph <= 0.75) (ph * 4 - 2 ** d / 4 + 0.5) 
                        0.75 < ph and (ph <= 1) ((abs ph - 1) * 4 ** d / 4 + 1)
                    ]
                ] 
                pulse [
                    d: 0.875 * (1 - dcw) + 0.125 
                    cosine 360 * case [0 < ph and (ph <= d) (ph / d) 
                        d < ph and (ph <= 1) 0
                    ]
                ] 
                saw-pulse [
                    d: 1 - dcw / 2 + 0.5 
                    cosine 360 * case [0 < ph and (ph <= d) ph 
                        d < ph and (ph <= 1) 1
                    ]
                ] 
                sine-sync [
                    cosine 360 * ph * (1 + (15 * dcw))
                ] 
                triangle [
                    d: 1 - (dcw * 0.41111) 
                    cosine 360 * case [0 < ph and (ph <= 0.25) (ph * 4 ** d / 4) 
                        0.25 < ph and (ph <= 0.5) ((abs ph - 0.5) * 4 ** d / 4 + 0.5) 
                        0.5 < ph and (ph <= 0.75) (ph * 4 - 2 ** d / 4 + 0.5) 
                        0.75 < ph and (ph <= 1) ((abs ph - 1) * 4 ** d / 4 + 1)
                    ]
                ] 
                no-wave [none]
            ] 
            algorithm: [sawtooth no-wave] 
            octave-modulation: true 
            curves: copy [] 
            forskip algorithms 2 [append curves to string! algorithms/1] 
            filters: [
                none [snd-value] 
                low-pass [q1 * l] 
                by-pass [q1 * b] 
                hi-pass [q1 * h] 
                notch [n]
            ] 
            filts: copy [] forskip filters 2 [append filts to string! filters/1] 
            filter: 'none 
            export: has [enves] [
                enves: copy [] 
                foreach env envelopes [append/only enves env/export] 
                reduce ['DCA DCA 'DCW DCW 'DPS DPS 'q q 'f1 f1 'wave-length wave-length 'window window 'algorithm head algorithm 'filter filter 'envelopes enves]
            ] 
            sync?: false 
            phaser: func [] [
                sync?: false 
                phase: 1 / (wave-length * (2 ** vibrato-amount) * (4 ** (envelopes/1/value - 0.5 * -2))) + phase 
                if phase >= 1 [
                    sync?: true 
                    phase: phase - 1 
                    if not none? algorithm/2 [
                        octave-modulation: not octave-modulation
                    ]
                ] 
                phase
            ] 
            envelopes: make block! 6 
            env-backup: make block! 6 
            loop 6 [append envelopes make ese []] 
            envelopes/1/rates: [0 1 0 0 0 0 0 0] 
            envelopes/1/levels: [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5] 
            foreach envelope envelopes [envelope/init-module envelope/init-gui] 
            init-envs: does [
                foreach envelope envelopes [envelope/init-module]
            ] 
            dummy-env: context [main: [] value: 1] 
            dummy-envs: does [
                env-backup: copy envelopes 
                envelopes: make block! 6 
                loop 6 [append envelopes make dummy-env []] 
                envelopes/1/value: 0.5
            ] 
            revert-envs: does [
                envelopes: copy env-backup
            ] 
            init-envs 
            init-module: does [
                if not none? algorithm/2 [
                    octave-modulation: not octave-modulation
                ] 
                ~rot-flt/data: find head ~rot-flt/data to string! filter 
                ~knb-dcw/data: ~fld-dcw/text: dcw 
                ~knb-dps/data: ~fld-dps/text: dps 
                ~knb-cut/data: ~fld-cut/text: f1 
                ~knb-res/data: ~fld-res/text: q 
                ~knb-dca/data: (square-root dca) / 2 
                ~fld-dca/text: 20 * log-10 dca 
                repeat i 7 [set in get bind to word! join "~rw1" i 'gui 'data off] 
                set in get bind to word! join "~rw1" (index? find algorithms algorithm/1) + 1 / 2 'gui 'data on 
                repeat i 8 [set in get bind to word! join "~rw2" i 'gui 'data off] 
                set in get bind to word! join "~rw2" (index? find algorithms algorithm/2) + 1 / 2 'gui 'data on 
                repeat i 5 [set in get bind to word! join "~rwi" i 'gui 'data off] 
                set in get bind to word! join "~rwi" (index? find windows window) + 1 / 2 'gui 'data on 
                show gui 
                show-curve 
                init-envs
            ] 
            main: func [] [
                ph: phaser 
                foreach env envelopes [env/main] 
                algo: pick algorithm octave-modulation 
                if equal? 'no-wave algo [algo: pick algorithm not octave-modulation] 
                either equal? 'no-wave algorithm/2 [
                    phw: ph
                ] [
                    phw: ph / 2 + either octave-modulation [0] [0.5]
                ] 
                dcws: dcw 
                dcw: dcw * envelopes/2/value 
                ph: min 1 (1.0 + (dps * envelopes/3/value)) ** 6 * ph 
                snd-value: 2 * ((do select windows window) * (((do select algorithms algo) - 1) / 2)) + 1 
                dcw: dcws 
                q1: 1 / max 1E-24 q * 3.0 * envelopes/5/value + 1.0 
                f2: sine (f1 * envelopes/4/value * 90.0) 
                d2: l: f2 * d1 + d2 
                h: snd-value - l - (q1 * d1) 
                d1: b: f2 * h + d1 
                n: h + l 
                value: min 1 max -1 envelopes/6/value * dca * (do select filters filter)
            ] 
            ~knb-dcw: ~knb-dps: ~knb-cut: ~knb-res: ~knb-dca: 
            ~fld-dcw: ~fld-dps: ~fld-cut: ~fld-res: ~fld-dca: 
            ~txt-amp: 
            ~dd1: ~dd2: 
            ~b1: ~b2: ~b3: ~b4: ~b5: ~b6: 
            ~rw11: ~rw12: ~rw13: ~rw14: ~rw15: ~rw16: ~rw17: 
            ~rw21: ~rw22: ~rw23: ~rw24: ~rw25: ~rw26: ~rw27: ~rw28: 
            ~rwi1: ~rwi2: ~rwi3: ~rwi4: ~rwi5: 
            ~rot-flt: 
            ~name: 
            ~curve: none 
            waves.img: load as-binary decompress 64#{
eJwB/AID/YlQTkcNChoKAAAADUlIRFIAAAAjAAAAkQgCAAAAxrmWcAAAAAFzUkdC
AK7OHOkAAAAEZ0FNQQAAsY8L/GEFAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1
MAAA6mAAADqYAAAXcJy6UTwAAAJ6SURBVGhD7ZjrbsMgDIX7bHuyPcT+7WG7qFQJ
NQYfXyBL5CmaNtX1hy9wTB6PlT/P5/f2fP3+zHve4RTMVN4HqQQ0iceQJvG6pHCe
QArkQaQQnoLk5KlJZp6RZOC5SCpeAAnkhZFEXjBpwJtCYnkTSYQ3nbTzVsrti1U0
SfWo1HnzbMyedhRIUl2YzN5r3sre25siOyI74vNqddOOUInZcUask17POQ2K7zuY
E0j71RpcKW5GY0qS5k3JR/bqna89BcSCJUlM0cDgyF5bmNhSJSmgTr2SBJZKfuvm
iaP+rkzSamvPfp3YBihhHQS0c20zN2mZQQe5lJD124PZSYPlsx/9e5K4o1sDoxLe
jiQGtL//Yk6j9jNta7V7lniwKKE3JlzdF5FATFsOdfa8JFBzVRgSlqyEtjO+vZDJ
b6h2+fHI/Nn33N7ayYCgDZFRd+KCzZ6hNUakwmDXHkka+wojiY5EgzYTxiksgAS6
AM26+rR9ALoAzSAlHG+Xi5BUy1QZl/SM9GmQwCuQtGvU2h/Z035Ta38REpEr8d9T
77mImNrrhHgnQ5IWJqt7K/a2uUxHauPAI1OQnDMFSvKPFRAJSZFoI5NEF2CDCCQc
w95tR3NEe0dQbbXBJNKNSRuNuESe5MH00micLJGUkuXyb6gQR4hNDeu+N0IcITY7
zDgbIQyyz+R7rsppz3iL7CTNrQsY8jfUESGk+sigHVEAM34nyZPVG2evTNWTuq44
p6fRDF4JgFeNWB6959ZamSTp9Do7e2RgizrRjxt1b1qLJ62T3pBhYexEvmtELSJJ
nkxm9gKyV2Rx6pN1CqiTxwX43awTmCjWbHn21mjuH74rxHHG2MGHAAAAAElFTkSu
QmCCLDJbrvwCAAA=
} 
            windows.img: load as-binary decompress 64#{
eJzrDPBz5+WS4mJgYOD19HAJAtLKQBzNwQQky06tXgSkWNIdfR0ZGDb2c/9JZGVg
YOzzdHEMyXB+eyO677ACD+uFdblhZt0v7utsE+7s+LTlvalZkPYqj78rPgbyHlTp
P37u/Ouv0rV3658n1f2bV3h96n+PZ5/mvZrpXc5rc9X66urv2zYr2eW6vnm9a+XD
dVfcZaNLDwXkXyhu3pNZXv59SnHLYva5ETE2Hl6vsy4qL3Htn3ZmXqBRhbfQU0uP
Bc/VVs7brFKheOkC9xQp/ZhT9/alVXtnHc9h4uG9paTadjRjJYtGz+RfVyzcPDYv
UWjzKrJiaVZRmSi12Durq4b5xMSuFuNK/Rl3Z006YmRkNjWnp6F3qWhaG++S0rSO
rZPELydPfXLa5EZ0V4LXm+7qvKq+BXrbfG+vPn5udWyS9J9JLomrhfosPRSeKSvO
mL0kad6kHktvpmf6ZzcIZHa4etqKaZhGrAlJehh0rMyDc/fS2vic6MW7irnqwvsP
rXiwqipTxU6uP+e++5OJCVwGa2q2SK2xVeEWCpabt6oyq24Cf2TeJKt0vEbeVllp
7bF/8tt3O//P9H+v/sBK7i4wphg8Xf1c1jklNAEArsXPI9cBAAA=
} 
            gui: none 
            init-gui: does [
                gui: layout/tight compose copy/deep [
                    styles knob-style 
                    styles stz-styles 
                    style text text 69x20 132.255.250 
                    style field field 69x20 
                    style knob knob 21x21 inner-radius 3 
                    style radio radio 15x9 effect [merge alphamul 50] 
                    origin 2x4 
                    space 2x2 
                    backdrop 33.77.74 
                    panel [
                        ~name: box 15x180 
                        return 
                        panel [
                            space 2x5 
                            txt "WAVE" 
                            box 37x148 effect [draw [image waves.img 0x0 35x146]] edge [size: 2x2 color: black] 
                            return 
                            txt "1" 
                            box 5x5 
                            panel [
                                space 5x9 
                                ~rw11: radio [algorithm/1: 'sawtooth show-curve] on 
                                ~rw12: radio [algorithm/1: 'square show-curve] 
                                ~rw13: radio [algorithm/1: 'pulse show-curve] 
                                ~rw14: radio [algorithm/1: 'square show-curve] 
                                ~rw15: radio [algorithm/1: 'saw-pulse show-curve] 
                                ~rw16: radio [algorithm/1: 'triangle show-curve] 
                                ~rw17: radio [algorithm/1: 'sine-sync show-curve]
                            ] 
                            return 
                            txt "2" 
                            box 5x5 
                            panel [
                                space 5x9 
                                ~rw21: radio [algorithm/2: 'sawtooth show-curve] 
                                ~rw22: radio [algorithm/2: 'square show-curve] 
                                ~rw23: radio [algorithm/2: 'pulse show-curve] 
                                ~rw24: radio [algorithm/2: 'square show-curve] 
                                ~rw25: radio [algorithm/2: 'saw-pulse show-curve] 
                                ~rw26: radio [algorithm/2: 'triangle show-curve] 
                                ~rw27: radio [algorithm/2: 'sine-sync show-curve] 
                                ~rw28: radio [algorithm/2: 'no-wave show-curve] on
                            ] 
                            across 
                            tx 80 "DCO......ENV/LFO" 
                            return 
                            ~b1: button [~p4/pane: envelopes/1/gui ~btn-chg: ~b1 envelopes/1/init-module show ~p4] 
                            button-lfo
                        ]
                    ] 
                    return 
                    bar 3x220 
                    return 
                    panel [
                        space 2x3 
                        panel [
                            tx "window" 
                            box 37x94 effect [draw [image windows.img 0x0 35x92]] edge [size: 2x2 color: black] 
                            return 
                            tx "" 
                            box 5x0 
                            panel [
                                space 5x9 
                                ~rwi1: radio [window: 'none show-curve] on 
                                ~rwi2: radio [window: 'sawtooth show-curve] 
                                ~rwi3: radio [window: 'triangle show-curve] 
                                ~rwi4: radio [window: 'trapezoid show-curve] 
                                ~rwi5: radio [window: 'saw-pulse show-curve]
                            ]
                        ] 
                        bar 90x2 
                        across 
                        tx 30 "DCW" 
                        ~fld-dcw: tx 30 "1.0" 
                        ~knb-dcw: knob with [data: 1] [dcw: value ~fld-dcw/text: DCW show ~fld-dcw show-curve] 
                        return 
                        ~b2: button [~p4/pane: envelopes/2/gui ~btn-chg: ~b2 envelopes/2/init-module show ~p4] 
                        button-lfo 
                        return 
                        tx 30 "DPS" 
                        ~fld-dps: tx 30 "0.0" 
                        ~knb-dps: knob with [data: 0] [dps: value ~fld-dps/text: DPS show ~fld-dps show-curve] 
                        return 
                        ~b3: button [~p4/pane: envelopes/3/gui ~btn-chg: ~b3 envelopes/3/init-module show ~p4] 
                        button-lfo
                    ] 
                    return 
                    bar 3x220 
                    return 
                    ~curve: box 150x50 effect [merge luma -70 grid 15x6 0x2 66.155.148 draw []] edge [size: 1x1 color: black] 
                    panel [
                        across 
                        box 16x150 effect [merge gradmul 0x1 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 rotate -90 translate -47x-2 text 0x0 "DCF" vectorial]] 
                        panel [
                            across 
                            origin 10x2 
                            space 2x2 
                            tx 50x20 "Filter type" ~rot-flt: rotary 66.155.148 60x20 "none" "low-pass" "by-pass" "notch" "hi-pass" [filter: to word! value show-curve] font-size 10 edge [color: 66.155.148] 
                            return 
                            tx 30 "CUT" 
                            ~fld-cut: tx 30 "1.0" 
                            ~knb-cut: knob with [data: 1] [f1: value ~fld-cut/text: f1 show ~fld-cut show-curve] 
                            return 
                            ~b4: button [~p4/pane: envelopes/4/gui ~btn-chg: ~b4 envelopes/4/init-module show ~p4] 
                            button-lfo 
                            return 
                            tx 30 "RES" 
                            ~fld-res: tx 30 "0.0" 
                            ~knb-res: knob [q: value ~fld-res/text: value show ~fld-res show-curve] 
                            return 
                            ~b5: button [~p4/pane: envelopes/5/gui ~btn-chg: ~b5 envelopes/5/init-module show ~p4] 
                            button-lfo 
                            return 
                            tx 30 "DCA" 
                            ~fld-dca: tx 30 "-3.0" 
                            ~knb-dca: knob with [data: 0.42] [dca: value * 2 ** 2 ~fld-dca/text: either zero? dca ["-OO"] [round/to 20 * log-10 dca 1E-2] show ~fld-dca show-curve] 
                            return 
                            ~b6: button [~p4/pane: envelopes/6/gui ~btn-chg: ~b6 envelopes/6/init-module show ~p4] 
                            button-lfo 
                            return
                        ]
                    ]
                ] 
                show-curve
            ] 
            show-curve: has [old-wave-length old-phase old-vibrato-amount] [
                octave-modulation: true 
                old-wave-length: wave-length 
                old-phase: phase 
                old-vibrato-amount: vibrato-amount 
                dummy-envs 
                ~curve/effect/draw: copy [pen green line-width 1.5 line] 
                phase: 0 
                wave-length: 75 
                repeat i 2 * wave-length [
                    insert tail ~curve/effect/draw as-pair i 23 + (-23 * main)
                ] 
                show ~curve 
                phase: old-phase 
                wave-length: old-wave-length 
                vibrato-amount: old-vibrato-amount 
                revert-envs
            ] 
            init-gui
        ]
    ] "RMX" [
        average: func [blk /local tmp] [
            tmp: 0 
            repeat i length? blk [tmp: tmp + blk/:i] 
            tmp / length? blk
        ] 
        RMX: context [
            name: "RMX" 
            info: "Envelope generator" 
            type: 'effect 
            id: none 
            input: none 
            output: none 
            value: 0 
            osc1: none 
            osc2: none 
            dca: 1 
            shaper: 0.5 
            d1: d2: h: l: b: n: f1: q: 0 
            q: q1: q2: 1 
            f1: f2: 1 
            bit-res: none 
            freq-div: 1 
            div-value: 0 
            div-cache: copy [] 
            modes: [
                first-line [osc1] 
                second-line [osc2] 
                mix [(osc1 + osc2) / 2.0] 
                ring [osc1 * osc2] 
                ring2 [osc1 + 1.0 / 2.0 * (osc2 + 1.0 / 2.0) * 2.0 - 1.0] 
                mix-ring [(osc1 * osc2 + osc2) / 2.0] 
                noise [osc1 + (osc2 * (random 10000000.0) / 10000000.0) / 2.0]
            ] 
            mode: 'first-line 
            filters: [
                none [snd-value] 
                low-pass [q1 * l] 
                by-pass [q1 * b] 
                hi-pass [q1 * h] 
                notch [n]
            ] 
            filts: copy [] forskip filters 2 [append filts to string! filters/1] 
            filter: 'none 
            export: has [enves] [
                enves: reduce [module-stack/1/export module-stack/2/export module-stack/6/export] 
                reduce ['mode mode 'filter filter 'q q 'f1 f1 'envelopes enves]
            ] 
            main: func [/local tmp] [
                vibrato-phase: 1 / vibrato-wave-length + vibrato-phase // 1.0 
                vibrato-amount: vibrato-depth * sine 360.0 * vibrato-phase 
                module-stack/1/main 
                module-stack/2/main 
                module-stack/3/main 
                if ~chk-sync/data and module-stack/3/sync? [module-stack/4/phase: 0] 
                module-stack/4/main 
                module-stack/6/main 
                osc1: module-stack/3/value 
                osc2: module-stack/4/value 
                snd-value: do select modes mode 
                q1: 1 / max 1E-24 q * 3.0 * module-stack/2/value + 1.0 
                f2: sine (f1 * module-stack/1/value * 90.0) 
                l: f2 * b + l 
                h: snd-value - l - (q1 * b) 
                b: f2 * h + b 
                n: h + l 
                value: dca * module-stack/6/value * min 1 max -1 do select filters filter 
                if ~chk-shaper/data [
                    absval: abs value 
                    value: (1 / (shaper + 1.0 / 2.0)) * (sign? value) * case [
                        absval < shaper absval 
                        absval > 1 (shaper + 1.0 / 2.0) 
                        absval >= shaper (shaper + ((absval - shaper) / ((absval - shaper) / (1.0 - shaper) ** 2.0 + 1.0)))
                    ]
                ] 
                if not none? bit-res [value: (to integer! value * (2 ** bit-res)) / (2 ** bit-res)] 
                insert tail div-cache value 
                if freq-div <= length? div-cache [div-value: average div-cache div-cache: copy []] 
                value: div-value
            ] 
            ~t1: ~t2: ~t3: 
            ~b1: ~b2: ~b3: 
            ~knb-cut: ~knb-res: ~knb-dca: 
            ~rot-flt: 
            ~curve: none 
            gui: none 
            init-gui: does [
                gui: layout/tight compose [
                    styles stz-styles 
                    style knob knob 21x21 inner-radius 3 
                    backdrop 66.155.148 effect [gradient 0x1 66.155.148 51.51.51] 
                    origin 2 
                    space 2x2 
                    across 
                    panel [
                        space 0x1 
                        tx 85 "Line selection" 
                        ~rl1: radio-line "1" [mode: 'first-line] on 
                        ~rl2: radio-line "2" [mode: 'second-line] 
                        ~rl3: radio-line "1 + 2" [mode: 'mix] 
                        ~rl4: radio-line "1 + 1'"
                    ] edge [size: 1x1 color: black] 
                    panel [
                        style radio-line radio-line 70x13 
                        space 0x0 
                        tx 85 "Modulation" 
                        ~rm1: radio-line "no" [mode: 'mix] on 
                        ~rm2: radio-line "ring" [mode: 'ring] 
                        ~rm5: radio-line "ring2" [mode: 'ring2] 
                        ~rm3: radio-line "mix-ring" [mode: 'mix-ring] 
                        ~rm4: radio-line "noise" [mode: 'noise]
                    ] edge [size: 1x1 color: black] 
                    return 
                    bar 180 return 
                    box 150x18 effect [merge gradmul 1x0 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 text 0x0 "DCF + DCA" vectorial]] 
                    return 
                    tx 110 "Filter type" 
                    ~rot-flt: rotary 66.155.148 60x20 "none" "low-pass" "by-pass" "notch" "hi-pass" [filter: to word! value] font-size 10 edge [color: 66.155.148] 
                    return 
                    tx "CUTOFF" ~t1: tx "1" ~knb-cut: knob 132.255.250 [f1: value ~t1/text: round/to value 1E-2 show ~t1] with [data: 1] 
                    ~b1: button [~p4/pane: module-stack/1/gui ~btn-chg: ~b1 module-stack/1/init-module show ~p4] return 
                    tx "RESO" ~t2: tx "0" ~knb-res: knob 132.255.250 [q: value ~t2/text: round/to value 1E-2 show ~t2] with [data: 0] 
                    ~b2: button [~p4/pane: module-stack/2/gui ~btn-chg: ~b2 module-stack/2/init-module show ~p4] return 
                    tx "DCA" ~t3: tx "0.0" ~knb-dca: knob 132.255.250 [dca: value * 2 ** 2 value ~t3/text: either zero? dca ["-OO"] [round/to 20 * log-10 dca 1E-2] show ~t3] with [data: 0.5] 
                    ~b3: button [~p4/pane: module-stack/6/gui show ~p4 ~btn-chg: ~b3] 
                    return 
                    box 150x18 effect [merge gradmul 1x0 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 text 0x0 "FinalCrusher" vectorial]] 
                    return 
                    ~chk-shaper: check-line "Waveshaper" 90 ~knb-wsh: knob 132.255.250 with [data: 0.5] [shaper: to decimal! value] return 
                    ~tx-bit: tx "Bit resolution: full" 90 knob with [data: 1] [either value = 1 [~tx-bit/text: "Bit resolution: full" bit-res: none] [bit-res: to integer! value * 25 ~tx-bit/text: join "Bit resolution: " bit-res] show ~tx-bit] 132.255.250 return 
                    ~tx-div: tx "Freq. divider: 1" 90 knob with [data: 1] [freq-div: to integer! 1 - value + 1 ** 6 ~tx-div/text: join "Freq. divider: " freq-div show ~tx-div] 132.255.250 return
                ]
            ] 
            init-gui 
            init-module: does [
                repeat i 4 [set in get bind to word! join "~rl" i 'gui 'data off] 
                repeat i 4 [set in get bind to word! join "~rm" i 'gui 'data off] 
                switch mode [
                    first-line [~rl1/data: on] 
                    second-line [~rl2/data: on] 
                    mix [~rl3/data: on ~rm1/data: on] 
                    ring [~rl3/data: on ~rm2/data: on] 
                    mix-ring [~rl3/data: on ~rm3/data: on] 
                    ring2 [~rl3/data: on ~rm5/data: on] 
                    noise [~rl3/data: on ~rm4/data: on]
                ] 
                ~rot-flt/data: find head ~rot-flt/data to string! filter 
                ~knb-cut/data: ~t1/text: f1 
                ~knb-res/data: ~t2/text: q 
                show self/gui
            ]
        ]
    ]] 
add-module "ese" 
add-module "ese" 
add-module "phido2" 
add-module "phido2" 
add-module "rmx" 
add-module "ese" 
module-stack/1/init-module 
module-stack/1/init-gui 
module-stack/2/init-module 
module-stack/2/init-gui 
module-stack/6/init-module 
module-stack/6/init-gui 
detune-osc: has [freq] [
    freq: sample-rate / module-stack/3/wave-length 
    freq: freq * (2 ** to integer! ~det-oct/text) * (1.0594630943593 ** to integer! ~det-not/text) * (1.00057778950655 ** to integer! ~det-cen/text) 
    module-stack/4/wave-length: sample-rate / freq
] 
export-wav: does [
    wav-sample: copy 64#{} 
    forall sauple [
        insert tail wav-sample itble2 to integer! 32767 * sauple/1 - 1
    ] 
    wav: wav-structure wav-sample 
    attempt [write/binary first request-file/save wav]
] 
export: does [
    attempt [save/header first request-file/save reduce [
            'OSC1 module-stack/3/export 
            'OSC2 module-stack/4/export 
            'MIX module-stack/5/export 
            'DETUNE reduce [~det-oct/text ~det-not/text ~det-cen/text] 
            'VIBRATO reduce [vibrato-depth vibrato-wave-length] 
            'PITCH reduce [pitch] 
            'LENGTH reduce [sample-length] 
            'SYNC reduce [~chk-sync/data]
        ] compose [
            Title: "Sintezar PM-101 Sound" 
            Version: 0.0.1 
            Date: (now)
        ]]
] 
import: has [tmp-preset osc1 osc1-envs osc2 osc2-envs mix] [
    tmp-preset: attempt [load/header first request-file] 
    if found? find tmp-preset 'osc1 [
        osc1-envs: last tmp-preset/osc1 
        osc1: head remove/part back back tail tmp-preset/osc1 2 
        foreach [word value] osc1 [set in module-stack/3 word value] 
        repeat i 6 [
            module-stack/3/envelopes/:i/rates: osc1-envs/:i/rates 
            module-stack/3/envelopes/:i/levels: osc1-envs/:i/levels
        ] 
        module-stack/3/init-module 
        osc2-envs: last tmp-preset/osc2 
        osc2: head remove/part back back tail tmp-preset/osc2 2 
        foreach [word value] osc2 [set in module-stack/4 word value] 
        repeat i 6 [
            module-stack/4/envelopes/:i/rates: osc2-envs/:i/rates 
            module-stack/4/envelopes/:i/levels: osc2-envs/:i/levels
        ] 
        module-stack/4/init-module 
        module-stack/1/rates: tmp-preset/mix/envelopes/1/rates 
        module-stack/1/levels: tmp-preset/mix/envelopes/1/levels 
        module-stack/2/rates: tmp-preset/mix/envelopes/2/rates 
        module-stack/2/levels: tmp-preset/mix/envelopes/2/levels 
        module-stack/6/rates: tmp-preset/mix/envelopes/3/rates 
        module-stack/6/levels: tmp-preset/mix/envelopes/3/levels 
        mix: head remove/part back back tail tmp-preset/mix 2 
        foreach [word value] mix [set in module-stack/5 word value] 
        module-stack/5/init-module 
        ~det-oct/text: tmp-preset/detune/1 
        ~det-not/text: tmp-preset/detune/2 
        ~det-cen/text: tmp-preset/detune/3 
        show reduce [~det-oct ~det-not ~det-cen] 
        vibrato-depth: to decimal! tmp-preset/vibrato/1 
        ~vib-dep/text: to string! tmp-preset/vibrato/1 
        vibrato-wave-length: to decimal! tmp-preset/vibrato/2 
        ~vib-rat/text: sample-rate / vibrato-wave-length 
        show reduce [~vib-rat ~vib-dep] 
        pitch: tmp-preset/pitch/1 
        sample-length: tmp-preset/length/1 
        ~fld-smplen/text: to string! sample-length / sample-rate 
        show ~fld-smplen 
        ~chk-sync/data: first reduce tmp-preset/sync 
        show ~chk-sync
    ]
] 
sauple: copy 64#{} 
make-sound: does [
    module-stack/3/wave-length: sample-rate / (oct * pitch) 
    freq: sample-rate / module-stack/3/wave-length 
    freq: freq * (2 ** to integer! ~det-oct/text) * (1.0594630943593 ** to integer! ~det-not/text) * (1.00057778950655 ** to integer! ~det-cen/text) 
    module-stack/4/wave-length: sample-rate / freq 
    module-stack/3/phase: 0 
    module-stack/4/phase: 0 
    vibrato-phase: 0 
    sample: make binary! sample-length 
    sauple: copy [] 
    x: now/time/precise 
    loop sample-length [
        module-stack/5/main 
        insert tail sample do rejoin ["#{" skip to-hex to integer! (module-stack/5/value + 1) * 32767.5 4 "}"] 
        insert tail sauple module-stack/5/value 
        if (length? sample) // 100 = 0 [~prog/data: (length? sauple) / sample-length show ~prog]
    ] 
    ~ttt/text: now/time/precise - x 
    show ~ttt 
    ~sample-window/effect/draw: copy [pen green fill-pen linear 0x0 0 100 90 1 1 red yellow green yellow red line-width 0.5 polygon 0x50] 
    length: 690 
    repeat i length [
        insert tail ~sample-window/effect/draw as-pair i (pick sauple (length? sauple) / length * i) * -50 + 50
    ] 
    insert tail ~sample-window/effect/draw 690x50 
    show ~sample-window 
    module-stack/1/init-module 
    module-stack/2/init-module 
    module-stack/6/init-module 
    foreach env module-stack/3/envelopes [env/init-module] 
    foreach env module-stack/4/envelopes [env/init-module]
] 
bold32: make face/font [style: 'bold size: 32] 
bold12: make face/font [size: 12] 
pitches: [
    261.625565300616 293.66476791743 329.627556912897 349.228231433035 391.995435981787 440 493.883301256181
] 
intro-image: to image! make face [
    edge: none 
    color: none 
    size: 703x584 
    effect: [
        merge 
        key 0.0.0 
        draw [
            image-filter bilinear 
            image logo.png 170x110 510x110 550x270 130x270 0.0.0 
            image logo.png 180x100 500x100 540x280 140x280 0.0.0 
            image logo.png 190x90 490x90 530x290 150x290 0.0.0
        ] 
        blur sharpen blur contrast 50 blur sharpen blur 
        luma -30 
        colorize 132.255.250
    ]
] 
synth: layout [
    backdrop 51.51.51 
    styles stz-styles 
    styles knob-style 
    style text txt bold 132.255.250 font-size 11 with [origin: 0x0 margin: 0x0] 
    style knob knob 16x16 inner-radius 3 66.155.148 51.51.51 255.255.255 
    style button button 40x26 effect [merge multiply 30.50.50] edge [size: 2x2 color: 30.50.50] font-size 8 
    style tx txt white bold font-size 9 43x12 with [origin: 0x0 margin: 0x0] 
    style panel panel edge [color: 66.155.148 size: 0x0 effect: none] 
    style imag image 24x24 font-size 9 font-color 132.255.250 with [
        font: make font [valign: 'bottom] 
        feel: make feel [
            over: func [f a p] [
                either a [
                    append f/effect [luma 100]
                ] [
                    remove back back tail f/effect 2
                ] 
                show f
            ] 
            engage: func [face action event] [
                remove/part find face/effect 'luma 2 
                switch action [
                    time [if not face/state [face/blinker: not face/blinker]] 
                    down [face/state: on] 
                    alt-down [face/state: on] 
                    up [if face/state [do-face face face/text] face/state: off] 
                    alt-up [if face/state [do-face-alt face face/text] face/state: off] 
                    over [face/state: on] 
                    away [face/state: off]
                ] 
                cue face action 
                show face
            ]
        ]
    ] 
    origin 5 
    space 2x2 
    below 
    ~p0: panel 120x442 [
        size 118x440 
        styles stz-styles 
        style knob knob 16x16 
        style button button 40x21 effect [merge multiply 30.50.50] edge [size: 2x2 color: 30.50.50] font-size 8 
        backdrop 66.155.148 effect [gradient 0x-1 66.155.148 51.51.51 grid 0x0 66.155.148] 
        origin 0 
        space 0 
        across 
        image logo.png effect [key black colorize 132.255.250 blur] 
        return 
        text font-size 10 132.255.250 "phase manipulation digital synthesizer" 110x30 
        return 
        panel [
            space 2x2 
            below 
            box 100x18 effect [merge gradmul 1x0 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 text 0x0 "detune" vectorial]] 
            panel [
                tx 38x15 "OCT" 
                tx 38x15 "NOTE" 
                tx 38x15 "CENT" 
                return 
                ~det-oct: tx 25x15 "0" 
                ~det-not: tx 25x15 "0" 
                ~det-cen: tx 25x15 "0" 
                return 
                knob with [data: 0.5] [~det-oct/text: to integer! value - 0.5 * 4 show ~det-oct detune-osc] 
                knob with [data: 0.5] [~det-not/text: to integer! value - 0.5 * 24 show ~det-not detune-osc] 
                knob with [data: 0.5] [~det-cen/text: to integer! value - 0.5 * 200 show ~det-cen detune-osc]
            ] 
            return
        ] edge [size: 0x0] 
        return 
        panel [
            below 
            space 2x2 
            box 100x18 effect [merge gradmul 1x0 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 text 0x0 "vibrato" vectorial]] 
            panel [
                styles stz-styles 
                space 28x2 
                tx 38x15 "RATE" 
                ~vib-rat: field 50x15 "0" [vibrato-wave-length: sample-rate / (max 1E-24 to decimal! value) ~knb-vib-rat/data: (to decimal! value) / 1000 ** 0.1 show ~knb-vib-rat] 
                tx 38x15 "DEPTH" 
                ~vib-dep: tx 50x15 "0" 
                space 30x17 
                return 
                ~knb-vib-rat: knob [~vib-rat/text: round/to value ** 10 * 1000 1E-4 vibrato-wave-length: sample-rate / (max 1E-24 to decimal! ~vib-rat/text) show ~vib-rat detune-osc] 
                ~knb-vib-dep: knob [~vib-dep/text: round/to vibrato-depth: value ** 3 1E-6 show ~vib-dep detune-osc]
            ] edge [size: 0x0] 
            toolpanel group 1 [
                origin 0 
                space 0 
                across 
                tool sine.png 
                tool triangle.png 
                tool pulse.png 
                tool saw.png
            ]
        ] edge [size: 0x0] 
        return 
        ~chk-sync: check-line "OSC SYNC" 
        return 
        radio [oct: 0.125] radio [oct: 0.25] radio [oct: 0.5] radio [oct: 1] on radio [oct: 2] radio [oct: 4] radio [oct: 8] 
        return 
        box 2x2 image keyboard.png effect [draw []] with [
            feel: make feel [
                engage: func [f a e] [
                    switch a [
                        down [
                            either e/offset/y > 41 [
                                pitch: (pick pitches 1 + to integer! e/offset/x / 14) 
                                f/effect/draw: compose [pen red circle (as-pair 14 * (to integer! e/offset/x / 14) + 7 60) 5 5] 
                                show f
                            ] [
                                print "pultony"
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ] edge [size: 1x1 color: 66.155.148] 
    return 
    ~p1: panel 376x220 [] 
    ~p2: panel 376x220 [] 
    return 
    space 0 
    ~p3: panel 182x280 [] 
    ~p4: panel 181x190 [] 
    return 
    space 0 
    at 5x451 ~sample-window: box 687x104 51.51.51 effect [grid 43x25 0x12 33.78.74 grid 86x25 0x0 66.155.148 draw []] edge [size: 2x2 color: 66.155.148] 
    panel [
        styles stz-styles 
        space 2 
        across 
        backdrop effect [gradient 0x-1 51.51.51 66.155.148] 
        imag toolbox-images/new-project effect [key white invert colorize 132.255.250 fit] 
        imag toolbox-images/open-project effect [key white colorize 132.255.250 fit] [import] 
        imag toolbox-images/save-project effect [key white colorize 132.255.250 fit] "rps" [export] 
        imag toolbox-images/save-project effect [key white colorize 132.255.250 fit] "wav" [export-wav] 
        imag toolbox-images/make-sound effect [key white invert colorize 132.255.250 fit] [make-sound] 
        imag toolbox-images/play-sound effect [key white invert colorize 132.255.250 fit] [
            snd: make sound [rate: 44100 bits: 16 volume: 1 data: sample] 
            if not empty? sample [
                insert sndport snd 
                wait []
            ]
        ] 
        tx "length" ~fld-smplen: field "1" [
            sample-length: to integer! sample-rate * to decimal! value 
            module-stack/1/init-module 
            module-stack/2/init-module 
            module-stack/3/init-module 
            module-stack/4/init-module 
            module-stack/6/init-module
        ] 
        ~ttt: tx white 100x12 
        ~prog: progress 115 51.51.51 132.255.250 edge [size: 1x1]
    ] 
    at 0x0 image intro-image effect [
        key 0.0.0 
        merge luma -70 blur blur blur contrast 50 blur blur blur luma -30 gradmul 0x-1 80.80.80 127.127.127
    ] 
    at 0x270 ~bb: box 698x100 effect [
        draw [
            line-width 0.5 pen 132.255.250 fill-pen linear 300x0 0 100 30 1 1 black white black white black white reflect font bold32 text 65x5 "Phase Manipulation Digital Synthesizer" vectorial 
            font bold12 text 500x45 "written by REBolek, (c) 2005" vectorial 
            pen 250.255.250 line-width 0.1 
            font bold12 text 280x80 "press here to continue" vectorial
        ] 
        emboss 
        colorize 132.255.250
    ] [remove/part back back tail synth/pane 2 show synth] with [
        saved-area: true 
        rate: 0 
        feel: make feel [
            n: 0 
            engage: func [face action event] [
                switch action [
                    time [
                        n: n + 2 
                        change skip face/effect/draw 6 as-pair n 0 
                        change skip face/effect/draw 33 n // 10.0 / 5
                    ] 
                    down [face/state: on] 
                    alt-down [face/state: on] 
                    up [if face/state [do-face face face/text] face/state: off] 
                    alt-up [if face/state [do-face-alt face face/text] face/state: off] 
                    over [face/state: on] 
                    away [face/state: off]
                ] 
                cue face action 
                show face
            ]
        ]
    ]
] 
module-stack: head module-stack 
~p1/pane: module-stack/3/gui 
~p2/pane: module-stack/4/gui 
~p3/pane: module-stack/5/gui 
~p4/pane: module-stack/1/gui 
~chk-sync/data: false 
module-stack/3/~name/effect: [merge gradmul 0x1 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 rotate -90 translate -47x-2 text 0x0 "DCO1" vectorial]] 
module-stack/4/~name/effect: [merge gradmul 0x1 black 127.127.127 draw [line-width 0.5 pen white fill-pen 132.255.250 font ~fnt-h3 rotate -90 translate -47x-2 text 0x0 "DCO2" vectorial]] 
clipboard-envelope: copy [rates [] levels []] 
melody-parser: does [
    ot: now/time/precise 
    parse melody [
        some [
            set time tuple! () 
            any [
                set nt string! (note: nt) 
                | set nt 'none (note: none) 
                | set param word! set value number! ()
            ]
        ]
    ] 
    ~t2/text: now/time/precise - ot show ~t2
] 
view center-face synth