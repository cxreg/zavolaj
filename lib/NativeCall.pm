class OpaquePointer { }

class NativeArray {
    has $!unmanaged;
    has $!of;
    has $!max-index = -1;

    method postcircumfix:<[ ]>($idx) {
        say "in postcircumfix:<[ ]>($idx)";
        if $idx > $!max-index {
            self!update-desc-to-index($idx);
        }
        say "trying to index";
        Q:PIR {
            $P0 = find_lex 'self'
            $P0 = getattribute $P0, '$!unmanaged'
            $P1 = find_lex '$idx'
            $S0 = $P0[$P1]
            %r = box $S0
        };
    }

    method !update-desc-to-index($idx) {
        say "in update-desc-to-index($idx)";
        my $fpa = pir::new__Ps('FixedIntegerArray');
        pir::set__vPi($fpa, 3);
        my $typeid;
        given $!of {
            when Str { $typeid = -70 }
            when Int { $typeid = -92 }
            when Num { $typeid = -83 }
            default { die "Unknown type"; }
        }
        Q:PIR {
            $P0 = find_lex '$fpa'
            $P1 = find_lex '$typeid'
            $P0[0] = $P1
            $P1 = find_lex '$idx'
            $I0 = $P1
            inc $I0
            $P0[1] = $I0
            $P0[2] = 0
        };
        pir::assign__vPP(pir::descalarref__PP($!unmanaged), $fpa);
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
                NativeArray.new(unmanaged => $unmanaged-struct, of => $type.of)
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
