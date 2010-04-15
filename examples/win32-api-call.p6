use NativeCall;

sub MessageBoxA(Int $phWnd, Str $message, Str $caption, Int $flags)
    returns Int
    is native('user32')
    { ... }

MessageBoxA(0, "We can haz NCI?", "oh lol", 64);
