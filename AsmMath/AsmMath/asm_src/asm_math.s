
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