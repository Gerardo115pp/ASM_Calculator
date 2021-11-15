
%define ASM_MATH_N

%include "./real_math.s"
%ifndef ASM_MATH_CONVS
    %include "./conv_math.s"
%endif

DEFAULT rel

section .text
global addition
global subtraction
global multiplication
global division
global factorial

addition:
    add rdi, rsi
    mov rax, rdi
    ret

subtraction:
    sub rdi, rsi
    mov rax, rdi
    ret

multiplication:
    push rdx ; save rcx
    xor rdx, rdx ; prevent rcx from ruinning multiplication
    mov rax, rdi ; rax = rdi
    mul rsi ; rax = rdi * rsi
    pop rdx ; restore rcx
    ret

division:
    push rdx ; save rcx
    xor rdx, rdx ; prevent rcx from ruinning division
    mov rax, rdi ; rax = rdi
    div rsi ; rax = rdi / rsi
    pop rdx ; restore rcx
    ret

factorial:
    ; get n on rdi, compute n! and return it on rax
    ; method: n! = \prod_{k=0}^n i-k
    mov rcx, rdi ; set the counter
    mov rax, 1 ; set the result
    push rbx ; rbx is callee-save
    mov rbx, rdi ; rbx stores n-k(k starts at 0 so rbx starts at n)

    cmp rcx, 0 ; if n == 0, return 1
    je .factorial_end

    .factorial_loop:
        xor rdx, rdx ; prevent rcx from ruinning multiplication
        mul rbx ; rax = rax * rbx-k
        dec rbx ; rbx = rbx-1

        loop .factorial_loop
    

    .factorial_end:
    pop rbx ; restore rbx
    ret