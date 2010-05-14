# Makefile for zavolaj's NativeCall.pm

PERL_EXE  = perl
PERL6_EXE = perl6
CP        = $(PERL_EXE) -MExtUtils::Command -e cp
# try to make these OS agnostic (ie use the same definition on Unix and Windows)
LIBSYSTEM = $(shell $(PERL6_EXE) -e 'print @*INC[2]')
LIBUSER   = $(shell $(PERL6_EXE) -e 'print @*INC[1]')

# first the default target
lib/NativeCall.pir:
	$(PERL6_EXE) --target=pir --output=lib/NativeCall.pir lib/NativeCall.pm6

test: lib/NativeCall.pir
	prove --exec $(PERL6_EXE) t/mysqlclient.t
	prove --exec $(PERL6_EXE) t/win32-api-call.t

# standard install is to the shared system wide directory (
install: lib/NativeCall.pir
	@echo "--> $(LIBSYSTEM)"
	@$(CP) lib/NativeCall.pm6 lib/NativeCall.pir $(LIBSYSTEM)

# if user has no permission to install globally, try a personal directory 
install-user: lib/NativeCall.pir
	@echo "--> $(LIBUSER)"
	@$(CP) lib/NativeCall.pm6 lib/NativeCall.pir $(LIBUSER)

help:
	@echo
	@echo "You can make the following 'zavolaj' targets:"
	@echo "test         runs a local test suite"
	@echo "clean        removes compiled, temporary and backup files"
	@echo "install      copies .pm6 and .pir file(s) to system lib/"
	@echo "             (may need admin or root permission)"
	@echo "install-user copies .pm6 and .pir file(s) to user's lib/"
