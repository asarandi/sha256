#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include "sha256.h"

int msg(int fd, char *s)
{
    if (fd != -1)
        close(fd);
    puts(s);
    return 0;
}

int main(int ac, char **av)
{
    struct stat     st;
    t_sha256        *hash;
    void            *mem;
    int             fd;

    if (ac != 2)
        return msg(-1, "missing file name");
    fd = open(av[1], O_RDONLY);
    if (fd < 0)
        return msg(-1, "open() failed");
    if (fstat(fd, &st))
        return msg(fd, "fstat() failed");
    mem = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (mem == MAP_FAILED)
    {
        if (st.st_size)
            return msg(fd, "mmap() failed");
    }
    hash = sha256(mem, st.st_size);
    munmap(mem, st.st_size);
    close(fd);
    printf("%08x%08x%08x%08x%08x%08x%08x%08x  %s\n",
        hash->h0, hash->h1, hash->h2, hash->h3, hash->h4, hash->h5, hash->h6, hash->h7, av[1]);
    return 0;
}
