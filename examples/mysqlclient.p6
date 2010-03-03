# mysqlclient.p6

# Fortunately supported by explicitly by hardcoded support in
# parrot/src/nci/extra_thunks.nci.
# See /usr/include/mysql.h for what should be callable.

# Status:
# Works: init, connect, query.
# Fails: create_db.
# Needs: fetch_row_array (returns UnManagedStruct)

use NativeCall;

class CPointer { ... }
# hack compensating for too-late import of CPointer from NativeCall.pm

# ------------------- foreign function definitions ---------------------

sub mysql_init( CPointer $mysql_client)
    returns CPointer
    is native('libmysqlclient')
    { ... }

sub mysql_real_connect( CPointer $mysql_client, Str $host, Str $user,
    Str $password, Str $database, Int $port, Str $socket, Int $flag )
    returns CPointer
    is native('libmysqlclient')
    { ... }

sub mysql_error( CPointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_stat( CPointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_get_client_info( CPointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_query( CPointer $mysql_client, Str $sql_command )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_store_result( CPointer $mysql_client )
    returns CPointer
    is native('libmysqlclient')
    { ... }

sub mysql_use_result( CPointer $mysql_client )
    returns CPointer
    is native('libmysqlclient')
    { ... }

sub mysql_field_count( CPointer $mysql_client )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_fetch_row( CPointer $result_set )
    returns CPointer
    is native('libmysqlclient')
    { ... }

sub mysql_num_rows( CPointer $result_set )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_fetch_field( CPointer $result_set )
    returns CPointer
    is native('libmysqlclient')
    { ... }

sub mysql_free_result( CPointer $result_set )
    returns CPointer
    is native('libmysqlclient')
    { ... }

# ----------------------- main example program -------------------------

say "init";
my $client = mysql_init( pir::null__P() );
print mysql_error($client);

say "real_connect";
mysql_real_connect( pir::descalarref__PP($client), 'localhost', 'testuser',
    'testpass', 'mysql', 0, pir::null__P(), 0 );
print mysql_error($client);

say "DROP DATABASE zavolaj";
mysql_query( pir::descalarref__PP($client), "
    DROP DATABASE zavolaj
");
print mysql_error($client);

say "CREATE DATABASE zavolaj";
mysql_query( pir::descalarref__PP($client), "
    CREATE DATABASE zavolaj
");
print mysql_error($client);

say "USE zavolaj";
mysql_query( pir::descalarref__PP($client), "
    USE zavolaj
");
print mysql_error($client);

print "stat: ";
say mysql_stat($client);

print "get_client_info: ";
say mysql_get_client_info($client);

say "CREATE TABLE nom";
mysql_query( pir::descalarref__PP($client),"
    CREATE TABLE nom (
        name char(4),
        description char(30),
        quantity int,
        price numeric(5,2)
    )
");
print mysql_error($client);

say "INSERT nom";
mysql_query( pir::descalarref__PP($client), "
    INSERT nom (name, description, quantity, price)
    VALUES ( 'BUBH', 'Hot beef burrito',         1, 4.95 ),
           ( 'TAFM', 'Mild fish taco',           1, 4.85 ),
           ( 'BEOM', 'Medium size orange juice', 2, 1.20 )
");
print mysql_error($client);

say "SELECT *, quantity*price AS amount FROM nom";
mysql_query( pir::descalarref__PP($client), "
    SELECT *, quantity*price AS amount FROM nom
");
print mysql_error($client);

print "field_count ";
my $field_count = mysql_field_count($client);
print mysql_error($client);
say $field_count;

# There are two ways to retrieve result sets: all at once in a single
# batch, or one row at a time.  Choose according to the amount of data
# and the overhead on the server and the client.
my $batch-mode = True;
if $batch-mode {
    # Retrieve all the rows in a single batch operation
    say "store_result";
    my $result_set = mysql_store_result($client);
    print mysql_error($client);

    print "num_rows ";
    my $num_rows = mysql_num_rows($result_set);
    print mysql_error($client);
    say $num_rows;

    say "fetch_row and fetch_field";
    loop ( my $row_number=0; $row_number<$num_rows; $row_number++ ) {
        print "row $row_number: ";
        my $row_data = mysql_fetch_row( $result_set );
        # It would be better to be able to call mysql_fetch_fields().
        loop ( my $field_number=0; $field_number<$field_count; $field_number++ ) {
           print "field $field_number ";
#          my $field = mysql_fetch_field( $result_set );
        }
        say " ";
    }
    say "free_result";
    mysql_free_result($result_set);
    print mysql_error($client);

}
else {
    # Retrieve rows one at a time from the server
    say "use_result";
    my $result_set = mysql_use_result($client);
    print mysql_error($client);

    my $row;
    while ( $row = mysql_fetch_row($result_set) ) {
        say "row";
    }
}

say " ";
say "mysqlclient.p6 done";
