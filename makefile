.POSIX:
.SUFFIXES: .o .c

PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

BUILDDIR = build
COMMOBJ  = $(BUILDDIR)/main.o $(BUILDDIR)/util.o $(BUILDDIR)/parse.o $(BUILDDIR)/abi.o $(BUILDDIR)/cfg.o $(BUILDDIR)/mem.o $(BUILDDIR)/ssa.o $(BUILDDIR)/alias.o $(BUILDDIR)/load.o \
           $(BUILDDIR)/copy.o $(BUILDDIR)/fold.o $(BUILDDIR)/simpl.o $(BUILDDIR)/live.o $(BUILDDIR)/spill.o $(BUILDDIR)/rega.o $(BUILDDIR)/emit.o
AMD64OBJ = $(BUILDDIR)/amd64/targ.o $(BUILDDIR)/amd64/sysv.o $(BUILDDIR)/amd64/isel.o $(BUILDDIR)/amd64/emit.o
ARM64OBJ = $(BUILDDIR)/arm64/targ.o $(BUILDDIR)/arm64/abi.o $(BUILDDIR)/arm64/isel.o $(BUILDDIR)/arm64/emit.o
RV64OBJ  = $(BUILDDIR)/rv64/targ.o $(BUILDDIR)/rv64/abi.o $(BUILDDIR)/rv64/isel.o $(BUILDDIR)/rv64/emit.o
OBJ      = $(COMMOBJ) $(AMD64OBJ) $(ARM64OBJ) $(RV64OBJ)

SRCALL   = $(OBJ:$(BUILDDIR)/%.o=%.c)

CC       = cc
CFLAGS   = -std=c99 -g -Wall -Wextra -Wpedantic

qbe: $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) -o $@

$(BUILDDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(COMMOBJ): all.h ops.h
$(AMD64OBJ): amd64/all.h
$(ARM64OBJ): arm64/all.h
$(RV64OBJ): rv64/all.h
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
