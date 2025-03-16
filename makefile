.POSIX:
.SUFFIXES: .o .c

PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

BUILDDIR = build
COMMOBJ  = main util parse abi cfg mem ssa alias load copy fold simpl live spill rega emit
AMD64OBJ = amd64/targ amd64/sysv amd64/isel amd64/emit
ARM64OBJ = arm64/targ arm64/abi arm64/isel arm64/emit
RV64OBJ  = rv64/targ rv64/abi rv64/isel rv64/emit
OBJ      = $(COMMOBJ:%=$(BUILDDIR)/%.o) $(AMD64OBJ:%=$(BUILDDIR)/%.o) $(ARM64OBJ:%=$(BUILDDIR)/%.o) $(RV64OBJ:%=$(BUILDDIR)/%.o)

SRCALL   = $(OBJ:$(BUILDDIR)/%.o=%.c)

CC       = cc
CFLAGS   = -std=c99 -g -Wall -Wextra -Wpedantic

qbe: $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) -o $@

$(BUILDDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(COMMOBJ:%=$(BUILDDIR)/%.o): all.h ops.h
$(AMD64OBJ:%=$(BUILDDIR)/%.o): amd64/all.h
$(ARM64OBJ:%=$(BUILDDIR)/%.o): arm64/all.h
$(RV64OBJ:%=$(BUILDDIR)/%.o): rv64/all.h
$(BUILDDIR)/main.o: config.h

config.h:
	@case `uname` in                               \
	*Darwin*)                                      \
		case `uname -m` in                     \
		*arm64*)                               \
			echo "#define Deftgt T_arm64_apple";\
			;;                             \
		*)                                     \
			echo "#define Deftgt T_amd64_apple";\
			;;                             \
		esac                                   \
		;;                                     \
	*)                                             \
		case `uname -m` in                     \
		*aarch64*|*arm64*)                     \
			echo "#define Deftgt T_arm64"; \
			;;                             \
		*riscv64*)                             \
			echo "#define Deftgt T_rv64";  \
			;;                             \
		*)                                     \
			echo "#define Deftgt T_amd64_sysv";\
			;;                             \
		esac                                   \
		;;                                     \
	esac > $@

install: qbe
	mkdir -p "$(DESTDIR)$(BINDIR)"
	install -m755 qbe "$(DESTDIR)$(BINDIR)/qbe"

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/qbe"

clean:
	rm -f $(BUILDDIR)/*.o $(BUILDDIR)/*/*.o qbe

clean-gen: clean
	rm -f config.h

check: qbe
	./test.sh all

check-arm64: qbe
	TARGET=arm64 ./test.sh all

check-rv64: qbe
	TARGET=rv64 ./test.sh all

src:
	@echo $(SRCALL)

80:
	@for F in $(SRCALL);                       \
	do                                         \
		awk "{                             \
			gsub(/\\t/, \"        \"); \
			if (length(\$$0) > $@)     \
				printf(\"$$F:%d: %s\\n\", NR, \$$0); \
		}" < $$F;                          \
	done

wc:
	@wc -l $(SRCALL)

.PHONY: clean clean-gen check check-arm64 check-rv64 src 80 wc install uninstall
