PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

LIB_FILE_NAME = mashup-lib.sh
LIB_FILE_PATH = ${PREFIX}/lib/${LIB_FILE_NAME}

VPATH = out
UTILS = cleancache docconv doctoc duplicates eggtimer mkhl open pacmirrors pkg \
		screencast slink tester texcleanup xdg-xmenu
FMUTILS = bulkrename pick preview skel trash unpack unpreview untrash
MANPAGES_FMUTILS = $(subst fmutils/,,$(shell find fmutils -name *.1))

all: ${UTILS}

out:
	mkdir out

$(UTILS): %: utils/% ${LIB_FILE_NAME} out
	cp "utils/$@" "out/$@"
ifdef DYNAMIC
	sed -i "s|__LIB_FILE__|${LIB_FILE_PATH}|g" "out/$@"
else
	sed -i -e "/__LIB_FILE__/r ${LIB_FILE_NAME}" -e '//d' "out/$@"
endif

$(FMUTILS): %: fmutils/% out
	cp "fmutils/$@" "out/$@"

clean:
	rm -rf out

install-%: %
	install -Dm755 "out/$(subst install-,,$@)" "${PREFIX}/bin/$(subst install-,,$@)"

uninstall-%: %
	rm -f "${PREFIX}/bin/$(subst uninstall-,,$@)"

install-utils: $(addprefix install-,${UTILS})
	@echo Installed regular utils

uninstall-utils: $(addprefix uninstall-,${UTILS})
	@echo Uninstalled regular utils

install-fmutils: $(addprefix install-,${FMUTILS})
	@echo Installed fmutils
	@echo Installing fmutils manpages
	install -Dm 644 $(addprefix fmutils/, ${MANPAGES_FMUTILS}) "${PREFIX}/share/man/man1/"


uninstall-fmutils: $(addprefix uninstall-,${FMUTILS})
	@echo Uninstalled fmutils
	@echo Uninstalling fmutils manpages
	rm -rf $(addprefix ${PREFIX}/share/man/man1/, ${MANPAGES_FMUTILS})

install-all: install-utils install-fmutils
	@echo Installed all utils

uninstall-all: uninstall-utils uninstall-fmutils
	@echo Uninstalled all utils

.PHONY: all clean install-% uninstall-%
