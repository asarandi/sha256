bits 64
default rel
section .text

%ifidn __OUTPUT_FORMAT__, macho64
 global _sha256
 _sha256:
%elifidn __OUTPUT_FORMAT__, elf64
 global sha256
 sha256:
%endif

            push    rbx
            push    r12
            push    r13
            push    r14
            push    r15

            mov     rcx, rsi
            mov     rbx, rcx
            and     rcx, 63
            sub     rsi, rcx

            push    rdi
            push    rsi
            push    rcx

            add     rsi, rdi
            lea     rdi, [rel tail]

            rep     movsb
            mov     al, 0x80
            stosb

            pop     rax                         ; size - (size % 64)
            inc     rax
            mov     rcx, 64
            mov     rdx, rcx
            sub     rcx, rax
            cmp     rcx, 8
            jae     .size_ok
            add     rcx, 64
            add     rdx, 64
.size_ok:   sub     rcx, 8
            xor     al, al
            rep     stosb
            shl     rbx, 3
            mov     eax, ebx
            bswap   eax
            mov     dword [rdi + 4], eax
            shr     rbx, 32
            mov     eax, ebx
            bswap   eax
            stosd

            pop     rbx                         ; rbx = size - (size % 64)
            pop     rsi                         ; rsi = data
                                                ; rdx = tail size (64 or 128)

            mov     r8,  0x6a09e667             ; h0, A
            mov     r9,  0xbb67ae85             ; h1, B
            mov     r10, 0x3c6ef372             ; h2, C
            mov     r11, 0xa54ff53a             ; h3, D
            mov     r12, 0x510e527f             ; h4, E
            mov     r13, 0x9b05688c             ; h5, F
            mov     r14, 0x1f83d9ab             ; h6, G
            mov     r15, 0x5be0cd19             ; h7, H
.loop:
            
            test    rbx, rbx
            jnz     .chunk
            test    rdx, rdx
            jz      .done
            xchg    rbx, rdx
            lea     rsi, [rel tail]

.chunk:
            sub     rbx, 64
            push    rbx
            push    rdx

            push    r8
            push    r9
            push    r10
            push    r11
            push    r12
            push    r13
            push    r14
            push    r15

            mov     rcx, 16
            lea     rdi, [rel buf]
            push    rdi

.byteswap:
            lodsd
            bswap   eax
            stosd
            loop    .byteswap

            mov     rcx, 48
.extend:
            mov     eax, dword [rdi-15*4]
            ror     eax, 7
            mov     edx, dword [rdi-15*4]
            ror     edx, 18
            xor     eax, edx
            mov     edx, dword [rdi-15*4]
            shr     edx, 3
            xor     eax, edx                    ; eax = s0

            mov     ebx, dword [rdi-2*4]
            ror     ebx, 17
            mov     edx, dword [rdi-2*4]
            ror     edx, 19
            xor     ebx, edx
            mov     edx, dword [rdi-2*4]
            shr     edx, 10
            xor     ebx, edx                    ; ebx = s1

            add     eax, ebx
            add     eax, dword [rdi-16*4]
            add     eax, dword [rdi-7*4]

            stosd

            loop    .extend
            pop     rdi                         ; rdi = buf

.compress:
            push    rcx


;
;
;



            pop     rcx
            inc     rcx
            cmp     rcx, 64
            jl      .compress

            mov     rax, r15
            pop     r15
            add     r15, rax

            mov     rax, r14
            pop     r14
            add     r14, rax

            mov     rax, r13
            pop     r13
            add     r13, rax

            mov     rax, r12
            pop     r12
            add     r12, rax

            mov     rax, r11
            pop     r11
            add     r11, rax

            mov     rax, r10
            pop     r10
            add     r10, rax

            mov     rax, r9
            pop     r9
            add     r9, rax

            mov     rax, r8
            pop     r8
            add     r8, rax

            pop     rdx
            pop     rbx

            jmp     .loop

.done:
            lea     rax, [rel result]

            mov     dword [rax], r8d
            mov     dword [rax + 1*4], r9d
            mov     dword [rax + 2*4], r10d
            mov     dword [rax + 3*4], r11d
            mov     dword [rax + 4*4], r12d
            mov     dword [rax + 5*4], r13d
            mov     dword [rax + 6*4], r14d
            mov     dword [rax + 7*4], r15d


            pop     r15
            pop     r14
            pop     r13
            pop     r12
            pop     rbx

            ret

section .data

result      times 8 dd 0
tail        times 128 db 0
buf         times 256 db 0
