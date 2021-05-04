# Merely Another Shell Utility Project

## Guidelines:
* There should be no dependencies other than `linux-utils` and `coreutils`
    * An exception is the shell itself
    * Wrappers are excluded from this
* All tools should be distro or even OS independent
    * distro specific tools are excluded from this
* The usage of coreutils should stick to POSIX definitions of their interfaces
* POSIX shell is preferred
* Shebang:
    * `#!/bin/sh` for POSIX shell scripts
    * `#!/bin/bash` for Bash scripts

## Resources
* [POSIX Shell manual](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
