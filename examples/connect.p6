# connect.p6

use NativeCall;

class CPointer { ... }
# hack compensating for too-late import of CPointer from NativeCall.pm

sub mysql_init( CPointer $mysql_client)
    returns CPointer
    is native('libmysqlclient')
    { say "wtf" }

sub mysql_real_connect( CPointer $mysql_client, Str $host, Str $user,
    Str $password, Str $database, Int $port, Str $socket, Int $flag )
    returns CPointer
    is native('libmysqlclient')
    { ... }

sub mysql_error( CPointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { say "wtf" }

sub mysql_query( CPointer $mysql_client, Str $dbname )
    returns Int
    is native('libmysqlclient')
    { say "wtf" }

say "ok startup";
my $client = mysql_init( pir::null__P() );
say "inited";

mysql_real_connect( pir::descalarref__PP($client), 'localhost', 'testuser',
    'testpass', 'mysql', 0, pir::null__P(), 0 );

say "called connect";

mysql_query( pir::descalarref__PP($client), 'create database zavolaj' );

say mysql_error($client);

say "called error";
