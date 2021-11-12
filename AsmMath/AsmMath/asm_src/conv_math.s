; Conversions
; Conversions, mainly between drgrees and radians
DEFAULT rel

%define ASM_MATH_CONVS

section .text
global degsToRads
global radToDegs
global changeSign

degsToRads:
    ; gets a Double precision floating point value in degrees on xmm0, converts it
    ; to radians using the formula: radians = degrees * (pi / 180) and stores the
    ; result in xmm0

    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define FPU_SPACE rbp-8

    mov qword[FPU_SPACE], 180

    finit
    fild qword[FPU_SPACE] ; load 180 to st1
    fldpi ; load pi to fpu on st0

    fdiv st0, st1 ; divide st1 by st0

    fstp qword[FPU_SPACE] ; store result in st0
    movlpd xmm1, qword[FPU_SPACE] ; store result in xmm1
    
    fstp st0 ; release stack

    mulsd xmm0, xmm1 ; multiply xmm0 by xmm1

    mov rsp, rbp
    pop rbp
    ret
;}

radToDegs:
    ; gets a Double precision floating point value in radians on xmm0, converts it
    ; to degrees using the formula: degrees = radians * (180 / pi) and stores the
    ; result in xmm0

    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define FPU_SPACE rbp-8

    mov qword[FPU_SPACE], 180

    finit
    fldpi ; load pi to fpu on st1
    fild qword[FPU_SPACE] ; load 180 to st0

    fdiv st0, st1 ; divide st0 by st1

    fstp qword[FPU_SPACE] ; store result in st0
    movlpd xmm1, qword[FPU_SPACE] ; store result in xmm1

    fstp st0 ; release stack

    mulsd xmm0, xmm1 ; multiply xmm0 by xmm1

    mov rsp, rbp
    pop rbp
    ret
;}

changeSign:
    ; gets a Double precision floating point value on xmm0, changes its sign
    ; and stores the result in xmm0

    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define FPU_SPACE rbp-8

    movlpd qword[FPU_SPACE], xmm0 ; store xmm0 in qword[FPU_SPACE]

    finit

    fld qword[FPU_SPACE] ; load qword[FPU_SPACE] to st0
    fchs

    fstp qword[FPU_SPACE] ; store st0 in qword[FPU_SPACE]

    movlpd xmm0, qword[FPU_SPACE] ; store qword[FPU_SPACE] in xmm0

    mov rsp, rbp
    pop rbp
    ret
;}