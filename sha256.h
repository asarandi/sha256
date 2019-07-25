#ifndef SHA256_H
# define SHA256_H

typedef struct  s_sha256
{
    uint32_t    h0;
    uint32_t    h1;
    uint32_t    h2;
    uint32_t    h3;
    uint32_t    h4;
    uint32_t    h5;
    uint32_t    h6;
    uint32_t    h7;
}               t_sha256;

t_sha256    *sha256(void *buf, size_t count);

#endif
