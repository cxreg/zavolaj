class OpaquePointer { }

class NativeArray {
    has $!unmanaged;

    method postcircumfix:<[ ]>($key) {
        die "Native Array NYI";
    }
}

our sub map-type-to-sig-char(Mu $type) {
    given $type {
        when Int           { 'i' }
        when Str           { 't' }
        when Num           { 'd' }
        when Rat           { 'd' }
        when OpaquePointer { 'p' }
        when Positional    { 'p' }
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

our sub make-mapper(Mu $type) {
    given $type {
        when Positional {
            -> \$umanaged-struct {
                NativeArray.new(unmanaged => $umanaged-struct)
            }
        }
        default { -> \$x { $x } }
    }
}

our multi trait_mod:<is>(Routine $r, $libname, :$native!) {
    my $entry-point   = $r.name();
    my $call-sig      = perl6-sig-to-backend-sig($r);
    my $return-mapper = make-mapper($r.returns);
    pir::setattribute__vPsP($r, '$!do', pir::clone__PP(-> |$c {
        $return-mapper(
            (pir::dlfunc__PPss(
                pir::loadlib__Ps($libname),
                $entry-point,
                $call-sig
            )).(|$c)
        )
    }));
}
