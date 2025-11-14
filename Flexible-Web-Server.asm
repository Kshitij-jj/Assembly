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

# Extracting the File name
lea rsi, [rip+buf]
mov cx, 0
find_slash:
mov al, byte ptr[rsi]
cmp  al , '/'
jz extract_path
inc rsi
inc rcx
cmp rcx, r15
jz Close_Socket
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

end:
mov byte ptr [rdi] , 0
#Detemining Whether the req is GET or POST
lea rsi, [rip+buf]
mov al , byte ptr [rsi]
cmp al, 'G'
jz Get_Req
cmp al, 'P'
jz Post_Req

# if not any of these end with syscall 60
mov rax, 60 
mov rdi, 5
syscall

Get_Req:
#Opening the file to read
mov rax, 2
lea rdi, [rip+file_path]
mov rsi, 0
mov rdx, 0
syscall
mov r13, rax
cmp r13, 0
jge Proceed_Reading

#File openenig Operation failed
mov rax, 1
mov rdi, r12
lea rsi, [rip+debug]
mov rdx, 39
syscall

mov rax, 1
mov rdi, r12
lea rsi, [rip+file_msg]
mov rdx, 20
syscall

jmp Close_Socket

Proceed_Reading:
#Reading the file
mov rax, 0
mov rdi, r13
lea rsi, [rip+file_content]
mov rdx, 300
syscall
mov r15, rax
 
#Closing the file
mov rax, 3
mov rdi, r13
syscall

#Writing to the Clinet socket end masage
mov rax, 1
mov rdi, r12
lea rsi, [rip+ msg]
mov rdx, 19
syscall

#Sending to socket
mov rax, 1
mov rdi, r12
lea rsi,[rip+file_content]
mov rdx, r15
syscall

jmp Close_Socket

Post_Req:
# find length upto \r\n\r\n
lea rdi, [rip+buf]
call length

#Comparing the return value
cmp rax, -1
jz Send_Msg
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
Send_Msg:
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
Close_Socket:
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
   sockaddr_in:
    .word 2
    .word 0x5000
    .long 0
    .byte 0,0,0,0,0,0,0,0

msg:
    .asciz "HTTP/1.0 200 OK\r\n\r\n"
debug:
    .asciz "HTTP/1.0 500 Internal Server Error \r\n\r\n"
buf:
    .space 2046

file_path:
    .space 2046

file_content:
    .space 2046
file_msg:
    .asciz "Opening file failed\n"
