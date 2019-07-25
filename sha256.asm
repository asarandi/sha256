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

            push    rbp
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
            mov     ebx, eax
            mov     edx, eax
            ror     eax, 7
            ror     edx, 18
            xor     eax, edx
            shr     ebx, 3
            xor     ebx, eax                    ; ebx = s0

            mov     eax, dword [rdi-2*4]
            mov     ebp, eax
            mov     edx, eax
            ror     eax, 17
            ror     edx, 19
            xor     eax, edx
            shr     ebp, 10
            xor     eax, ebp                    ; ebx == s1

            add     eax, ebx
            add     eax, dword [rdi-16*4]
            add     eax, dword [rdi-7*4]

            stosd
            loop    .extend
            pop     rdi                         ; rdi == buf

            push    rsi
            lea     rsi, [rel K_const]

.compress:
            mov     ebx, r12d
            ror     ebx, 6
            mov     eax, ebx
            ror     ebx, 5
            xor     eax, ebx
            ror     ebx, 14
            xor     eax, ebx                    ; eax == S1

            ror     ebx, 7                      ; ebx == e
            mov     edx, ebx
            not     ebx
            and     ebx, r14d                   ; G
            and     edx, r13d
            xor     ebx, edx                    ; ebx == ch

            add     eax, ebx                    ;
            add     eax, r15d                   ; h
            add     eax, dword [rsi + rcx*4]    ; k[i]
            add     eax, dword [rdi + rcx*4]    ; w[i]

            mov     ebp, eax

            mov     ebx, r8d
            ror     ebx, 2
            mov     eax, ebx
            ror     ebx, 11
            xor     eax, ebx
            ror     ebx, 9
            xor     eax, ebx
                                                ; eax = S0
            ror     ebx, 10

            mov     edx, ebx
            and     ebx, r9d                    ; a and b
            and     edx, r10d                   ; a and c
            xor     ebx, edx
            mov     edx, r9d                    ;
            and     edx, r10d                   ; b and c
            xor     ebx, edx
                                                ; ebx = maj
            add     ebx, eax                    ; ebx = temp2

            mov     r15d, r14d
            mov     r14d, r13d
            mov     r13d, r12d
            mov     r12d, r11d
            add     r12d, ebp
            mov     r11d, r10d
            mov     r10d, r9d
            mov     r9d, r8d
            add     ebx, ebp
            mov     r8d, ebx

            inc     rcx
            cmp     rcx, 64
            jl      .compress

            pop     rsi

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
            pop     rbp

            ret

section .data

K_const:
dd   0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
dd   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
dd   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
dd   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
dd   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
dd   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
dd   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
dd   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2

result      times 8 dd 0
tail        times 128 db 0
buf         times 256 db 0
