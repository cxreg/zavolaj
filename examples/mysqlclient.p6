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

# ----------------------- main example program -------------------------

say "init";
my $client = mysql_init( pir::null__P() );
print mysql_error($client);

say "connect";
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
    INSERT nom (name, description, price)
    VALUES ( 'BUBH', 'Hot beef burrito',         1, 4.95 ),
           ( 'TAFM', 'Mild fish taco',           1, 4.85 ),
           ( 'BEOM', 'Medium size orange juice', 2, 1.20 )
");
print mysql_error($client);

say "SELECT * FROM nom";
mysql_query( pir::descalarref__PP($client), "
    SELECT * FROM nom
");
print mysql_error($client);

print "field_count ";
my $field_count = mysql_field_count($client);
say $field_count;
print mysql_error($client);

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
    if $num_rows == 0 {
# fudge the row count until the unsigned long long return type works
        print "*FUDGED* ";
        $num_rows = 3;      # because we know there are 3 rows
    }
    say $num_rows;
    print mysql_error($client);

    say "fetch_row";
    my $row_number;
    loop ( $row_number=0; $row_number<$num_rows; $row_number++ ) {
#       my $row_data = mysql_fetch_row( $result_set );
    }
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
