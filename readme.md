# a qbe fork

QBE - Backend Compiler              http://c9x.me/compile/

QBE is, and will remain, a small project (less than 8 kloc). It is programmed in non-fancy C99 without any dependencies.

doc/    Documentation.
minic/  An example C frontend for QBE.
tools/  Miscellaneous tools (testing).
test/   Tests.
amd64/
arm64/
rv64/   Architecture-specific code.

The LICENSE file applies to all files distributed.

- Compilation and Installation

Invoke make in this directory to create the executable
file qbe.  Install using 'make install', the standard
DESTDIR and PREFIX environment variables are supported.
Alternatively, you may simply copy the qbe binary manually.
