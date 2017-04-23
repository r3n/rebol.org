Rebol [
    title: "Embedded binary file demo"
    date: 29-june-2008
    file: %embedded-binary-demo.r
    purpose: {
        To demonstrate how executables and any other binary data can be 
        embedded in Rebol code, written to the hard drive, and then used 
        as needed.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
        See section 18.1 for the code needed to embed files like this.
    }
]

program: load to-binary decompress 64#{
eJztF11sU2X03K4VqJsrkZJp6OzchhFJsx8qDB9od1fHdIO6ds7AgJX2jttyey/p
vWUjJuNnmNhMibzwaCSLi+EBE1ziGIkBGh0BSYTwwAMme9Dk4kgkgSiKcj3nu7es
QrKFhMUQOcn5+c7fd875+vXe27FJAg4AbIiGAQwWIwZMEbqTcmODN5xRdmRi6aoy
Z83YogngLlaNtV+s6kV7q9KelHeu9LYqQTXt7e/v97UqLcLuqKJIvriShnAIoJ0r
gXvPn+StlDAF5dyzHLwAdlw4TZ1Mm7oQvWDu7jKLslsxBc4KQ30bb9bMHF3F/D5j
MFAHEIbHD+cwb88s9riSEIjvK7EKogZs//bxAvQmYlqM5JsOUwHPWFgEAYDTvqTp
eYdy1Fn5Sh/O96h9nLrrDcD4IpQm7UOkWL/nt6MlqMvxrkl+GVWS7xqWalzDzqGz
9rbyD5ehpmnl+ezt3M/RSPe7Q9/ajeh5+9Ztm3vKh9xoM7SaimLUR18C2JKf+Kg2
APoJwzDOuiAF+hHU/pHXryObdLyP+y2kEhx7UaLfo0gq/RJa60/n88Ndrpz7FmqG
u5bk3L8zwdWXc0+jdOYXkn4lnYfW++/qOPLyDz7BfH3jTXVnplx949inhPvnSgw/
8RSIHM7P8PdSUYtxlxSkONE+o/u7EkNElMbpcuRKUhTjmLH/iHbDQQ7DHqL77zbh
oQxeRa9duBQHkRj+HnIdr7y/e178AvmmnHt5VQAmaNo59/EZ8QSJAY7EURJvMu2x
KipYj2CaEToYve2eYYiwl4rWY6jN8RWF5XtsuWSyhO7aJG8XXQFkNdWYIqIHK8nH
8FOSFJMoteEfZfQEo1SNCPCW2/BTjWK1uXkp9dDDegjrDqpkAUtiJhNp4ma3qUrx
MG6dqkyFMQ2ExQmaxgU2c/07D2ZJsCz3Q68Xh76Cvac2pZwi8jCO8rIZd4jielmc
uHxmsEMe1vMBZJf0YY8Pda95yH5p+tWrI86XMZbTE5a1gVlXFKyryeowp0Cy4Wf+
hdSrWGp26N008hW4XnS6/OBS7MnUVHoK0osoTV+22qF56c95qKdtZBzB66J/imSc
/Rmsg/KDdHFbA9O3RrZWByD/qPf1KTCwze3y2KCbn9vnP4ExoItiwr11zvncqq6+
oXGV//XVa5qCzXxL6M3ZfBfMZyFPBvywgD3FGDjLnGVl83o4T+HJAZ/PFxWTqrcj
GxerHljRqyL9sWXxqU2/nkHki1H4HDkvJeM7vZooeLdnNU2R10K34G1XdgveTmE7
vmv7fNDcFY1u3ABpNa5J6rZd9MouqGpjw6z1GLXn6vDxV/s9o1cYvcroNUanGP2J
UZ3RG4zeZPQ2o3cY/YtRqCdqZ3Qho6WMuhitYHQZ0pr6mRr21Zvv03VFuuMoX0Gd
VqT7BlupKFoXw8eo/8yynUR+HvEa4g3EPxEXYuwSxOWIaxADiGHEBKKGeADxCOIx
a1wXkE81zH/ut0OdG0LtjQ2+hCSBzLUKWoeSyErC+pickIQgfAmhgaSG319xPEvo
ioQ6Ld9D0CL04ddZQuknaxA4W1hRtXeySa0DXWM7BHjDFhHkhLUKYs2cJTcrA0H4
mmtXYgk+m1GVTBBOsVVbXJGDsNTWKexIqpqQ4aWYqgbps4LPCDFNMPcLYXQpldrC
g0bcVHcKcQ220DqyB4PTHYKWScZVgCGsw/LBEgHWsjYLZR2zRTMxWZUwfaFwOAot
SXVXTIuLM9V/ZeuSMw/UxW/s4KOF6W2GNjmp8Uo6rci8ImsZRVLxG+1hZWhgrlv6
/4F/ABcSIgQAEAAA
}
write/binary %program.exe program
call/show %program.exe