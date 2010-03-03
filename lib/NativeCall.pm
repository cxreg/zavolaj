class CPointer { }

our sub map-type-to-sig-char(Mu $type) {
    given $type {
        when Int      { 'i' }
        when Str      { 't' }
        when Num      { 'd' }
        when Rat      { 'd' }
        when CPointer { 'p' }
        default { die "Can not handle type " ~ $_.perl ~ " in an 'is native' signature." }
    }
}

our sub perl6-sig-to-backend-sig(Routine $r) {
    my $sig-string = map-type-to-sig-char($r.returns());
    my @params = $r.signature.params();
    for @params -> $p {
        $sig-string = $sig-string ~ map-type-to-sig-char($p.type);
    }
    return $sig-string;
}

our multi trait_mod:<is>(Routine $r, $libname, :$native!) {
    my $entry-point = $r.name();
    my $call-sig = perl6-sig-to-backend-sig($r);
    pir::setattribute__vPsP($r, '$!do', pir::clone__PP(-> |$c {
        (pir::dlfunc__PPss(
            pir::loadlib__Ps($libname),
            $entry-point,
            $call-sig
        )).(|$c)
    }));
}
