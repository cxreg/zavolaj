class CPointer { }

our sub perl6-sig-to-backend-sig(Signature $siggy) {
    my $sig-string = "l"; # XXX Need to handle return types.
    my @params = $siggy.params();
    for @params -> $p {
        given $p.type {
            when Int      { $sig-string = $sig-string ~ 'l' }
            when Str      { $sig-string = $sig-string ~ 't' }
            when Num      { $sig-string = $sig-string ~ 'd' }
            when Rat      { $sig-string = $sig-string ~ 'd' }
            when CPointer { $sig-string = $sig-string ~ 'P' }
            default { die "Can not handle type " ~ $_.perl ~ " in a native signature." }
        }
    }
    return $sig-string;
}

our multi trait_mod:<is>(Routine $r, $libname, :$native!) {
    my $entry-point = $r.name();
    my $call-sig = perl6-sig-to-backend-sig($r.signature());
    pir::setattribute__vPsP($r, '$!do', -> |$c {
        (pir::dlfunc__PPss(
            pir::loadlib__Ps($libname),
            $entry-point,
            $call-sig
        )).(|$c)
    });
}
