use v6;
use NativeCall;

sub fork() returns Int is native('libz') { ... }

my $pid = fork();
if $pid {
    say "process $pid is parent. ";
}
else {
    say "process $pid is child. ";
}

# Notes:
# * This is very OS-dependent.  Win32 will definitely not work.  Tested
#   on Debian Linux.  Patches welcome for OSX, Solaris, FreeBSD etc.
# * The 'libz' may not be the best or only usable library.  YMMV.
# * The newlines from 'say' are often delayed, they come out together
#   after both strings have been printed on the same line.  Hmm.

