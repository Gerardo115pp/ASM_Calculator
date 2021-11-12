DEFAULT rel

section .text
global additionF
global subtractionF
global multiplicationF
global divisionF
global squareRoot
global exponential
global  logarithm
global antiLogarithm
global sin
global cos
global tangent
global arccos
global arcsin
global arctan

additionF:
    ; get two double-precision floating-point values on xmm0 and xmm1
    ; return result in xmm0
    addsd xmm0, xmm1 ; add xmm1 to xmm0, that was hard...
    ret
;}

subtractionF:
    ; get two double-precision floating-point values on xmm0 and xmm1
    ; return result in xmm0
    subsd xmm0, xmm1 ; subtract xmm1 from xmm0
    ret
;}

multiplicationF:
    ; get two double-precision floating-point values on xmm0 and xmm1
    ; return result in xmm0
    mulsd xmm0, xmm1 ; multiply xmm1 with xmm0
    ret
;}

divisionF:
    ; get two double-precision floating-point values on xmm0 and xmm1
    ; return result in xmm0
    divsd xmm0, xmm1 ; divide xmm1 with xmm0
    ret
;}

squareRoot:
    ; get double-precision floating-point value on xmm0
    ; return result in xmm0
    sqrtsd xmm0, xmm0 ; square root of xmm0, for future me: sqrtsd computes the square root of source operand and stores the result in destination operand
    ret
;}

exponential:
    ; get double-precision floating-point value on xmm0, and exponent on rdi
    ; return result in xmm0
    ; rcx is control register for the exponentiation loop
    
    ; move the base to xmm1
    movsd xmm1, xmm0
    mov rcx, rdi
    dec rcx

    .exponential_loop:
        mulsd xmm1, xmm0; multiply xmm1 with xmm0
        loop .exponential_loop
    
    ; return result in xmm0
    movsd xmm0, xmm1
    ret
;}

logarithm:
    ; get double-precision floating-point value on xmm0 and calculate logarithm
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define X rbp-8


    finit

    fldl2t ; load log_2(10) to st(0)

    movlpd qword [X], xmm0
    fld1 ; load 1.0 to st1
    fld qword [X] ; load 10 to st0
    fyl2x ; calculate logarithm of xmm0

    fdiv st0, st1 ; (log_2(x) / log_2(10)) == log_10(x). st0 = log_2(x), st1 = log_2(x) 

    fstp qword [X] ; store result in xmm0

    movlpd xmm0, qword [X] ; load result from xmm0

    mov rsp, rbp
    pop rbp
    ret
;}

antiLogarithm:
    ; get double-precision floating-point value on xmm0 and calculate antiLogarithm
    ; the formula for antiLogarithm of log_a(x) if just a^x, for this lib we just need
    ; the common logarithm and antiLogarithm which means antiLogarithm = 10^x
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 4
    %define A rbp-4

    mov dword [A], 10 ; load 10 to A
    cvttsd2si rdi, xmm0 ; convert xmm0 to integer

    pxor xmm0, xmm0 ; clear xmm0
    cvtsi2sd xmm0, dword [A] ; load 10 to xmm0
    call exponential ; calculate 10^x

    mov rsp, rbp
    pop rbp
    ret
;}


sin:
    ; get double-precision floating-point value on xmm0 and calculate sin
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define X rbp-8

    finit

    movlpd qword [X], xmm0
    fld qword [X] ; load x to st0
    fsin ; calculate sin(x) and cos(x)
    fstp qword [X] ; store result in xmm0

    movlpd xmm0, qword [X] ; load result from xmm0

    mov rsp, rbp
    pop rbp
    ret
;}

cos:
    ; get double-precision floating-point value on xmm0 and calculate cos
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define X rbp-8

    finit
    movlpd qword [X], xmm0
    fld qword [X] ; load x to st0
    fcos ; calculate sin(x) and cos(x)
    fstp qword [X] ; store result in xmm0

    movlpd xmm0, qword [X] ; load result from xmm0

    mov rsp, rbp
    pop rbp
    ret
;}

tangent:
    ; get double-precision floating-point value on xmm0 and calculate tangent
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define X rbp-8

    finit
    movlpd qword [X], xmm0
    fld qword [X] ; load x to st0
    fptan ; calculate tangent of xmm0

    fxch st1 ; swap st0 and st1, because for some reason fptan puts result in st1 and 1.0 in st0...

    fstp qword [X] ; store result in xmm0
    
    movlpd xmm0, qword [X] ; load result from xmm0

    mov rsp, rbp
    pop rbp
    ret
;}

arccos:
    ; get double-precision floating-point value on xmm0 and calculate arccos
    ; this algorithm is based on an interpolation of the arccos function x = {-1, -0.5, 0, 0.5, 1}
    ; it has an absolute error of 6.7e-5
    ; return result in xmm0

    push rbp
    mov rbp, rsp
    sub rsp, 0x30 ; we need to store negate var + 4 coefficients. we reserve 40 bytes of memory
    %define X rbp-8
    %define Neg rbp-16
    %define C1 rbp-24
    %define C2 rbp-32
    %define C3 rbp-40
    %define C4 rbp-48

    mov qword [Neg], __?float64?__(0.0) ; load 0.0 to X, X must be float(x < 0), we will check this later
    
    mov rax, __?float64?__(-0.0187293) ; coefficient 1
    mov qword [C1], rax

    mov rax, __?float64?__(0.0742610) ; coefficient 2
    mov qword [C2], rax

    mov rax, __?float64?__(-0.2121144) ; coefficient 3
    mov qword [C3], rax

    mov rax, __?float64?__(1.5707288) ; coefficient 4
    mov qword [C4], rax

    ; C5 is pi, we can use fldpi instead of loading it

    finit

    movlpd qword [X], xmm0

    fldz ; load 0.0 to st1
    fld qword [X] ; load x to st0, wi will check if x < 0 
    fcomip ; compare st0 and st1 then free both st0 and st1
    fstp st0 ; clear st0
    ja .start_arccos ; if st0 > st1 then x < 0, we will use the formula for arccos(x) = pi - arccos(-x)

    mov rax, __?float64?__(1.0)
    mov qword [Neg], rax ; load 1.0 to X, we will use the formula for arccos(-x)

    .start_arccos:

    fld qword [X] ; load x to st0
    fabs ; calculate abs(x)
    fstp qword [X] ; store abs(x) in X

    movlpd xmm0, qword [C1] ; xmm0 = -0.0187293
    movlpd xmm2, qword [X] ; xmm1 = abs(x)
    mulsd xmm0, xmm2 ; xmm0 *= abs(x)

    movlpd xmm1, qword [C2] ; xmm1 = 0.0742610
    addsd xmm0, xmm1 ; xmm0 += 0.0742610
    mulsd xmm0, xmm2 ; xmm0 *= abs(x)

    movlpd xmm1, qword [C3] ; xmm1 = -0.2121144
    addsd xmm0, xmm1 ; xmm0 += -0.2121144
    mulsd xmm0, xmm2 ; xmm0 *= abs(x)

    movlpd xmm1, qword [C4] ; xmm1 = 1.5707288
    addsd xmm0, xmm1 ; xmm0 += 1.5707288

    ; clac SQRT(1-x)

    mov rax, __?float64?__(1.0)
    movq xmm1, rax

    subpd xmm1, xmm2 ; xmm1 = 1.0 - abs(x)

    sqrtsd xmm1, xmm1 ; xmm1 = SQRT(1-abs(x))
    mulsd xmm0, xmm1 ; xmm0 *= SQRT(1-abs(x))

    movaps xmm1, xmm0 ; xmm1 = result
    movlpd xmm2, qword [Neg] ; xmm2 = negate var
    mulsd xmm1, xmm2 ; xmm1 *= negate var
    mov rax, __?float64?__(2.0)
    movq xmm2, rax
    mulsd xmm1, xmm2 ; xmm1 *= 2.0

    subpd xmm0, xmm1 ; xmm0 = xmm0 - 2 * negate * result

    movlpd xmm2, qword [Neg] ; xmm2 = negate var
    mov rax, __?float64?__(3.141592653589793)
    movq xmm1, rax
    mulsd xmm2, xmm1 ; xmm2 = negate * 3.141592653589793

    addsd xmm0, xmm2 ; xmm0 = xmm0 + negate * 3.141592653589793

    mov rsp, rbp
    pop rbp
    ret
;}

arcsin:
    ; get double-precision floating-point value on xmm0 and calculate arcsin
    ; we will use the trigonometric identity arcsin(x) = arctan(x/sqrt(1-x^2))
    ; this is because the arctan function is on x86 instruction set.

    mov rax, __?float64?__(1.0)
    movq xmm1, rax ; xmm1 = 1.0
    movaps xmm2, xmm0 ; xmm2 = xmm0
    mulsd xmm2, xmm2 ; xmm2 = x^2

    subpd xmm1, xmm2 ; xmm1 = 1.0 - x^2
    sqrtsd xmm1, xmm1 ; xmm1 = SQRT(1.0 - x^2)
    
    divsd xmm0, xmm1 ; xmm0 = x/SQRT(1.0 - x^2)

    finit

    push rbp
    mov rbp, rsp
    sub rsp, 8 ; temporary space for xmm0
    %define Temp rbp-8
    movlpd qword [Temp], xmm0 ; store xmm0 in X
    fld qword [Temp] ; load xmm0 to st0
    
    mov rax, __?float64?__(1.0)
    mov qword [Temp], rax
    fld qword [Temp] ; load 1

    fpatan ; calculates the arctan of st1/st0 that why we put 1 on st0

    fstp qword [Temp] ; store result in xmm0
    movlpd xmm0, qword [Temp] ; load result to xmm0

    mov rsp, rbp
    pop rbp
    ret
;} 

arctan:
    ; get double-precision floating-point value on xmm0 and calculate arctan
    ; for arctan(x) = we will use the fpatan instruction, which calculates the arctan of st1/st0
    ; we first need to set st0 to 1

    push rbp
    mov rbp, rsp
    sub rsp, 8 ; memory to use fpu instructions
    %define FPU_SPACE rbp-8

    mov rax, __?float64?__(1.0)
    movq xmm1, rax ; xmm1 = 1.0

    finit 

    movlpd qword [FPU_SPACE], xmm0 
    fld qword [FPU_SPACE] ; load xmm0 to st1

    movlpd qword [FPU_SPACE], xmm1
    fld qword [FPU_SPACE] ; load 1.0 to st0

    fpatan ; calculates the arctan of st1/st0

    fstp qword [FPU_SPACE] ; store result in xmm0
    movlpd xmm0, qword [FPU_SPACE] ; load result to xmm0

    mov rsp, rbp
    pop rbp
    ret
;}
















