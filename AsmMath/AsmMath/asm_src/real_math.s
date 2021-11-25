DEFAULT rel

%ifndef ASM_MATH_N
    %include './asm_math.s'
%endif


section .text
global additionF
global subtractionF
global multiplicationF
global divisionF
global squareRoot
global power
global powerNExp
global powerRExp
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

powerRExp:
    ; get double-precision floating-point value on xmm0 and calculate power of xmm1
    ; we will support reals to the power of any real number, so will use, for the fractional part, the
    ; identity: x^y = 2^(y*log(x)). for the integer part we just use the standard exponentiation. then
    ; we will multiply integer part by the result of the fractional part.
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 0x20; allocate stack space for local variables
    %define REAL rbp-8
    %define INTEGER rbp-16
    %define BASE rbp-24
    %define FPU_SPACE rbp-32

    movlpd qword [BASE], xmm0 ; save the base value 


    finit
    
    ; getting the fractional part of exponent
    fld1 ; st1 = 1
    movlpd qword [FPU_SPACE], xmm1 
    fld qword [FPU_SPACE] ; st0 = xmm0
    fprem ; st0 = xmm0 - st1 * floor(xmm0)

    fstp qword [REAL] ; st0 = xmm0 - st1 * floor(xmm0)
    fstp st0 ; free fpu stack

    movlpd xmm0, qword [REAL] ; get the integer part of exponent
    subsd xmm1, xmm0 ; exponent - fractional part = integer part
    movlpd qword [INTEGER], xmm1 ; save the integer part

    ; caculating the power of base to the fractional part
    fld qword [REAL] ; st0 = xmm0 - st1 * floor(xmm0)
    fld qword [BASE] ; st0 = base
    fyl2x ; st1 = st1 * log_2(base); pop register stack, so st0 = fractiona * log_2(base)
    fld1 ; st0 = 1
    faddp ; add st0 to st1, store in st1 and pop register stack. st0 = fractional * log_2(base) + 1

    f2xm1 ; st0 = 2^(fractional * log_2(base)) - 1
    fld1 ; st0 = 1
    faddp ; add st0 to st1, store in st1 and pop register stack. st0 = fractional * log_2(base) + 1

    fstp qword [REAL] ; st0 = 2^(fractional * log_2(base)) - 1

    ; calculating the integer part of the power
    movlpd xmm0, qword [BASE] ; xmm0  will store the result

    xor rcx, rcx ; clear rcx, rcx will be used as a counter
    cvtsd2si ecx, qword [INTEGER] ; ecx = integer part of exponent
    movlpd xmm1, qword [BASE] ; xmm1 = base
    dec rcx ; decrement counter
    .integerpart_loop:

        mulsd xmm0, xmm1 ; xmm0 = xmm0 * xmm1

        loop .integerpart_loop
    
    movlpd xmm1, qword [REAL]
    mulsd xmm0, xmm1 ; xmm0 = (base ^ fractional) * (base ^ integer)

    mov rsp, rbp
    pop rbp
    ret 
;}

powerNExp:
    ; get double-precision floating-point value on xmm0 and calculate power of rdi
    ; this is a fast version of power, only supports natural numbers for the exponent
    ; return result in xmm0

    
    mov rax, __?float64?__(1.0) ; n^1 = n V n, and at this point we are sure n > 0, that means if n = 1 at the first iteration rax will be equal to 1*n
    movaps xmm1, xmm0 ; xmm1 will hold the base

    pxor xmm0, xmm0 ; clear xmm0
    movq xmm0, rax

    cmp rdi, 0
    je .powerNExp_end ; if exponent is 0, return 1

    mov rcx, rdi ; rcx = counter
    .powerNExp_loop:
        mulsd xmm0, xmm1 ; multiply xmm0 with xmm1

        loop .powerNExp_loop ; loop until counter is 0

    .powerNExp_end:
    ret
;}

exponential:
    ; get double-precision floating-point value on xmm0 and calculate e^x
    ; wi will use \sum_{i=0}^n (x^i)/i!, with n = 18
    ; rcx = n
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 8
    %define XMM_HOLDER rbp-8
    %define N 20

    xor rax, rax ; clear result
    xor rcx, rcx ; set n SUSPECT
    
    pxor xmm2, xmm2 ; xmm2 will temporarily hold the result of the sum
    .exponential_loop:

        ; get x^i by calling powerNExp, it expects the base on xmm0(which is already set) and the exponent on rdi
        push rcx ; save n
        mov rdi, rcx ; set exponent
        movlpd qword [XMM_HOLDER], xmm0 ; save xmm0
        call powerNExp
        movaps xmm1, xmm0 ; save result
        pop rcx ; restore n

        ; get i! by calling factorial, it expects the value on rdi
        mov rdi, rcx ; set value
        push rcx ; save n
        call factorial
        pop rcx ; restore n
        
        movlpd xmm0, qword [XMM_HOLDER] ; restore xmm0
        
        movlpd qword [XMM_HOLDER], xmm1 ; save x^i
        fld qword [XMM_HOLDER] ; load x^i
        mov qword [XMM_HOLDER], rax
        fild qword [XMM_HOLDER] ; load i! as a real number
        fdivp ; divide x^i by i! and pop the stack

        fstp qword [XMM_HOLDER] ; save result
        movlpd xmm1, qword [XMM_HOLDER] ; restore x^i
        addsd xmm2, xmm1 ; add x^i to the sum

        inc rcx ; increment n
        cmp rcx, N ; check if we have reached the end of the loop
        jle .exponential_loop ; if not, jump to the beginning of the loop

    mov rax, rcx ; save n
    movaps xmm0, xmm2 ; save the result
    mov rsp, rbp
    pop rbp
    ret
;}

logarithm:
    ; get double-precision floating-point value on xmm0 and calculate log_xmm1(xmm0)
    ; FYL2X computes `st1 * log2(st0)` so if we set st1 = 1, we get log_2(xmmi)
    ; we will use the identity log_y(x) = log_2(y) / log_2(x)
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 0x18 ; allocate stack space for local variables
    %define FPU_SPACE rbp-8
    %define LOG_2_XMM0 rbp-16
    %define LOG_2_XMM1 rbp-24

    finit

    ; get log_2(xmm0)

    fld1 ; st1 = 1
    movlpd qword [FPU_SPACE], xmm0 ; st0 = xmm0
    fld qword [FPU_SPACE] ; st0 = xmm0, st1 = 1
    fyl2x ; st0 = log_2(xmm0)
    fstp qword [LOG_2_XMM0] ; st0 = log_2(xmm0)

    fld1 ; st1 = 1
    movlpd qword [FPU_SPACE], xmm1 ; st0 = xmm1
    fld qword [FPU_SPACE] ; st0 = xmm1, st1 = 1
    fyl2x ; st0 = log_2(xmm1)
    fstp qword [LOG_2_XMM1] ; st0 = log_2(xmm1)
    ; fyl2x is suppose to be setting the result on st1 and popint st0, so we shouldnt need to clean the fpu stack

    ; get log_2(xmm0) / log_2(xmm1)
    fld qword [LOG_2_XMM1] ; st1 = log_2(xmm1)
    fld qword [LOG_2_XMM0] ; st0 = log_2(xmm0), st1 = log_2(xmm1)
    fdiv st0, st1 ; st0 = log_2(xmm0) / log_2(xmm1)

    fstp qword [FPU_SPACE]
    movlpd xmm0, qword [FPU_SPACE] ; xmm0 = log_xmm1(xmm0)

    mov rsp, rbp
    pop rbp
    ret
;}

antiLogarithm:
    ; get double-precision floating-point value on xmm0 and calculate antiLogarithm(aka 10^x)
    ; return result in xmm0
    push rbp
    mov rbp, rsp
    sub rsp, 4
    %define A rbp-4

    mov dword [A], 10 ; load 10 to A
    ; cvttsd2si rdi, xmm0 ; convert xmm0 to integer
    movaps xmm1, xmm0 ; xmm1 will hold the base

    pxor xmm0, xmm0 ; clear xmm0
    cvtsi2sd xmm0, dword [A] ; load 10 to xmm0
    call powerRExp ; calculate 10^x

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
















