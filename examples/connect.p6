# connect.p6

use NativeCall;

sub my_init( CPointer $mysql_client)
    is native('mysqlclient')
    returns CPointer
    { ... }

sub mysql_real_connect( CPointer $mysql_client, Str $host, Str $user,
    Str $password, Str $database, Int $port, Str $socket, Int $flag )
    returns CPointer
    { ... }

my $client = my_init( 0 );
my $client = mysql_real_connect( $client, 'localhost', 'testuser',
    'testpass', 'mysql', 0, 0, 0 );

