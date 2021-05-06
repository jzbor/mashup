<!-- START doctoc.sh generated TOC please keep comment here to allow auto update -->
<!-- DO NOT EDIT THIS SECTION, INSTEAD RE-RUN doctoc.sh TO UPDATE -->
**Table of Contents**

- [Guidelines:](#guidelines)
- [Resources](#resources)
- [LICENSING](#licensing)

<!-- END doctoc.sh generated TOC please keep comment here to allow auto update -->
# Merely Another Shell Utility Project

## Guidelines:
* There should be no dependencies other than `linux-utils` and `coreutils` unless strictly necessary
    * An exception is the shell itself
    * Wrappers are excluded from this
    * Check dependencies with `check_dependencies` or `check_optional_dependencies`
* All tools should be distro or even OS independent
    * distro specific tools are excluded from this
* The usage of coreutils should stick to POSIX definitions of their interfaces
* POSIX shell is preferred
* Shebang:
    * `#!/bin/sh` for POSIX shell scripts
    * `#!/bin/bash` for Bash scripts

## Resources
* [POSIX Shell manual](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
* [Rick's sh (POSIX shell) tricks](https://www.etalabs.net/sh_tricks.html)

## Credits
* to **OliverLew** for [the original xdg-open script](https://github.com/OliverLew/xdg-xmenu)
* to **pedrolab** for the [doctoc utility](https://gitlab.com/pedrolab/doctoc.sh)

## LICENSING
* `doctoc` is provided under the [GPLv3 License](./LICENSE.gpl3)
* All other utils are provided under the [BSD-3-Clause License](./LICENSE)
