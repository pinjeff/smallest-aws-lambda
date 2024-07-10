format ELF64 executable

SYS_READ = 0
SYS_WRITE = 1
SYS_SOCKET = 41
SYS_CONNECT = 42

AF_INET = 2
SOCK_STREAM = 1

macro syscall3 number, a, b, c {
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
}

macro read fd, buf, count {
    syscall3 SYS_READ, fd, buf, count
}

macro write fd, buf, count {
    syscall3 SYS_WRITE, fd, buf, count
}

macro socket domain, type, protocol {
    syscall3 SYS_SOCKET, domain, type, protocol
}

macro connect sockfd, addr, addrlen {
    syscall3 SYS_CONNECT, sockfd, addr, addrlen
}

segment readable executable
entry main
main:
    ; opens a socket
    socket AF_INET, SOCK_STREAM, 0
    mov rbx, rax ; store socket_fd in rbx

    ; connects to the scoket
    connect rbx, servaddr.sin_family, sizeof_servaddr

    ; allocates 1Mb of stack memory for reading the request
    sub rsp, 1048576
l:
    ; gets the next invocation
    write rbx, get_request, get_request_len

    ; reads the response from the socket
    read rbx, rsp, 1048576

    ; memcpy request_id into the response
    mov rdi, post_request + 36
    mov rsi, rsp
    add rsi, 80 ; request_id offset in the response
    mov rcx, 36 ; request_id_len
    rep movsb
    
    ; responds to the request
    write rbx, post_request, post_request_len
    read rbx, rsp, 1048576
    jmp l

segment readable writeable
servaddr.sin_family dw AF_INET
servaddr.sin_port dw 10531 ; 9001 
servaddr.sin_addr db 127, 0, 0, 1
servaddr.sin_zero dq 0
sizeof_servaddr = $ - servaddr.sin_family

get_request db 'GET /2018-06-01/runtime/invocation/next HTTP/1.1', 13, 10
db 'Host: 127.0.0.1', 13, 10, 13, 10
get_request_len = $ - get_request

post_request db 'POST /2018-06-01/runtime/invocation/000000000000000000000000000000000000/response HTTP/1.1', 13, 10
db 'Host: 127.0.0.1', 13, 10
db 'Content-Length: 13', 13, 10, 13, 10
db 'Hello, World!'
post_request_len = $ - post_request
