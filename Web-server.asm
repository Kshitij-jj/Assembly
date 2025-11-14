.intel_syntax noprefix
.global _start
.section .text
_start:
mov rax, 41
mov rdi, 2
mov rsi, 1
mov rdx, 0
syscall

mov rbx, rax
mov rdi, rax
lea rsi, [rip+sockaddr_in]
mov rdx, 16
mov rax, 49 
syscall

mov rdi, rbx
mov rsi, 0
mov rax, 50
syscall

PARENT_PROCESS:

mov rax, 43
mov rsi, 0
mov rdx, 0
mov rdi, rbx
syscall
mov r12, rax

# forking child process to handel read write connection
mov rax, 57
syscall

cmp rax, 0
jz CHILD
mov rax, 3
mov rdi, r12
syscall
jmp PARENT_PROCESS

CHILD:
mov rax, 3
mov rdi, rbx
syscall

mov rax, 0
mov rdi, r12
lea rsi, [rip+buf]
mov rdx, 2046
syscall

#total length read
mov r15, rax

lea rsi, [rip+buf]
find_slash:
mov al, byte ptr[rsi]
cmp  al , '/'
jz extract_path
inc rsi
jmp find_slash

extract_path:
lea rdi, [rip+file_path]

store_path:
mov al, byte ptr [rsi]
cmp al, ' '
jz end
mov byte ptr [rdi], al
inc rsi
inc rdi
jmp store_path

# find length upto \r\n\r\n
end:
lea rdi, [rip+buf]
call length
mov rbx, rax
mov rax, 0
mov rsi, rdi
lea  rdi, [rip+file_content]
sub r15, rbx
mov rcx, r15
rep movsb

#Opening file
mov rax, 2
lea rdi, [rip+file_path]
mov rsi, 65
mov rdx, 0777
syscall

mov r13, rax

#Writing to  the file
mov rax, 1
mov rdi, r13
lea rsi,[rip+file_content]
mov rdx, r15
syscall

mov r14, rax

#Closing the file
mov rdi, r13
mov rax, 3
syscall


#Writing to the Clinet socket end masage
mov rax, 1
mov rdi, r12
lea rsi, [rip+ msg]
mov rdx, 19
syscall

#Closing the Socket
mov rax, 3
mov rdi, r12
syscall

#Halting the progrm 
mov rax, 60
mov rdi, 0
syscall

length:
    mov rax, 0              
.loop:
    cmp rax, r15            
    jge .not_found
    cmp byte ptr [rdi], 13
    jne .next
    cmp byte ptr [rdi+1], 10
    jne .next
    cmp byte ptr [rdi+2], 13
    jne .next
    cmp byte ptr [rdi+3], 10
    jne .next

    add rax, 4              
    add rdi, 4              
    ret

.next:
    inc rax
    inc rdi
    jmp .loop

.not_found:
    mov rax, -1
    ret

.section .data
sockaddr_in:
    .word 2
    .word 0x5000
    .long 0
    .quad 0
msg:
    .asciz "HTTP/1.0 200 OK\r\n\r\n"
buf:
    .space 2046

file_path:
    .space 100

file_content:
    .space 300

