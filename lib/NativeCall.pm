our sub perl6-sig-to-backend-sig(Signature $siggy) {
    "llttl"
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
