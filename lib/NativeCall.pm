class OpaquePointer { }

class NativeArray {
    has $!unmanaged;
    has $!max-index = -1;

    method postcircumfix:<[ ]>($idx) {
        if $idx > $!max-index {
            self!update-desc-to-index($idx);
        }
        $!unmanaged[$idx]
    }

    method !update-desc-to-index($idx) {
        my $fpa = pir::new__Ps('FixedIntegerArray');
        pir::set__vPi($fpa, 3);
        given self.of {
            when Str { $fpa[0] = -70 }
            when Int { $fpa[0] = -92 }
            when Num { $fpa[0] = -83 }
        }
        $fpa[1] = $idx + 1;
        $fpa[2] = 0;
        pir::set__vPP($!unmanaged, $fpa);
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
            -> \$unmanaged-struct {
                NativeArray.new(unmanaged => $unmanaged-struct) does $type
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
