# mysqlclient.p6

# Fortunately supported by explicitly by hardcoded support in
# parrot/src/nci/extra_thunks.nci.
# See /usr/include/mysql.h for what should be callable.

# Status:
# Works: init, connect, query.
# Fails: create_db.
# Needs: fetch_row_array (returns UnManagedStruct)

use NativeCall;

class OpaquePointer { ... }
# hack compensating for too-late import of OpaquePointer from NativeCall.pm

# ------------------- foreign function definitions ---------------------

sub mysql_init( OpaquePointer $mysql_client)
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_real_connect( OpaquePointer $mysql_client, Str $host, Str $user,
    Str $password, Str $database, Int $port, Str $socket, Int $flag )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_error( OpaquePointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_stat( OpaquePointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_get_client_info( OpaquePointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_query( OpaquePointer $mysql_client, Str $sql_command )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_store_result( OpaquePointer $mysql_client )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_use_result( OpaquePointer $mysql_client )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_field_count( OpaquePointer $mysql_client )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_fetch_row( OpaquePointer $result_set )
    returns Positional of Str
    is native('libmysqlclient')
    { ... }

sub mysql_num_rows( OpaquePointer $result_set )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_fetch_field( OpaquePointer $result_set )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_free_result( OpaquePointer $result_set )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

# ----------------------- main example program -------------------------

say "init";
my $client = mysql_init( pir::null__P() );
print mysql_error($client);

say "real_connect";
mysql_real_connect( $client, 'localhost', 'testuser', 'testpass',
    'mysql', 0, pir::null__P(), 0 );
print mysql_error($client);

say "DROP DATABASE zavolaj";
mysql_query( $client, "
    DROP DATABASE zavolaj
");
print mysql_error($client);

say "CREATE DATABASE zavolaj";
mysql_query( $client, "
    CREATE DATABASE zavolaj
");
print mysql_error($client);

say "USE zavolaj";
mysql_query( $client, "
    USE zavolaj
");
print mysql_error($client);

print "stat: ";
say mysql_stat($client);

print "get_client_info: ";
say mysql_get_client_info($client);

say "CREATE TABLE nom";
mysql_query( $client,"
    CREATE TABLE nom (
        name char(4),
        description char(30),
        quantity int,
        price numeric(5,2)
    )
");
print mysql_error($client);

say "INSERT nom";
mysql_query( $client, "
    INSERT nom (name, description, quantity, price)
    VALUES ( 'BUBH', 'Hot beef burrito',         1, 4.95 ),
           ( 'TAFM', 'Mild fish taco',           1, 4.85 ),
           ( 'BEOM', 'Medium size orange juice', 2, 1.20 )
");
print mysql_error($client);

say "SELECT *, quantity*price AS amount FROM nom";
mysql_query( $client, "
    SELECT *, quantity*price AS amount FROM nom
");
print mysql_error($client);

print "field_count ";
my $field_count = mysql_field_count($client);
print mysql_error($client);
say $field_count;

my @rows;
my $row_count;
my @width = 0 xx $field_count;
# There are two ways to retrieve result sets: all at once in a single
# batch, or one row at a time.  Choose according to the amount of data
# and the overhead on the server and the client.
my $batch-mode;
$batch-mode = (True,False).pick; # aha, you came looking for this line :-)
$batch-mode = True;
if $batch-mode {
    # Retrieve all the rows in a single batch operation
    say "store_result";
    my $result_set = mysql_store_result($client);
    print mysql_error($client);

    print "row_count ";
    $row_count = mysql_num_rows($result_set);
    print mysql_error($client);
    say $row_count;

    # Since mysql_fetch_fields() is not usable yet, derive the
    # column widths from the maximum widths of the data in each
    # column.
    say "fetch_row and fetch_field";
    loop ( my $row_number=0; $row_number<$row_count; $row_number++ ) {
        my $row_data = mysql_fetch_row( $result_set );

        # It would be better to be able to call mysql_fetch_fields().
        # my @row = mysql_fetch_fields($result_set);
        # But that cannot be implmented yet in Rakudo because the
        # returned result is a packed binary record of character
        # pointers, unsigned longs and unsigned ints. See mysql.h
        my @row = ();
        loop ( my $field_number=0; $field_number<$field_count; $field_number++ ) {
            my $field = $row_data[$field_number];
            @width[$field_number] = max @width[$field_number], $field.chars;
            push @row, $field;
        }
        push @rows, [@row];
    }
    say "free_result";
    mysql_free_result($result_set);
    print mysql_error($client);
    # Having determined the column widths by measuring every field,
    # it is finally possible to pretty print the table.
    loop ( my $j=0; $j<$field_count; $j++ ) {
        print "+--";
        print '-' x @width[$j];
    }
    say '+';
    loop ( my $i=0; $i<$row_count; $i++ ) {
        my @row = @rows[$i];
        loop ( my $j=0; $j<$field_count; $j++ ) {
            my $field = @row[0][$j];
            print "| $field ";
            print ' ' x ( @width[$j] - $field.chars );
        }
        say '|';
    }
    loop ( my $k=0; $k<$field_count; $k++ ) {
        print "+--";
        print '-' x @width[$k];
    }
    say '+';
}
else {
    # Retrieve rows one at a time from the server
    say "use_result";
    my $result_set = mysql_use_result($client);
    print mysql_error($client);

    my $retrieving = True;
    while ( $retrieving ) {
        my $row_data = mysql_fetch_row($result_set);
        my @row = ();
        loop ( my $field_number=0; $field_number<$field_count; $field_number++ ) {
            my $field = $row_data[$field_number];
            @width[$field_number] = max @width[$field_number], $field.chars;
            push @row, $field;
        }
        @row.join(',').say;
#       $retrieving = False;
    }
    say "free_result";
    mysql_free_result($result_set);
    print mysql_error($client);
}


say "mysqlclient.p6 done";
