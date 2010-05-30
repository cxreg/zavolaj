# sqlite3.p6

# An attempt to use libsqlite3-dev via zavolaj and Parrot NCI;

# This example does not work yet, because Parrot probably needs at least
# the following signatures added to parrot/src/nci/extra_thunks.nci:
#
#   iptppp      sqlite3_exec()
#   iptipp      sqlite3_prepare_v2()
#   iptttppppp  sqlite3_table_column_metadata()
#
# There will probably be others that will only become apparent after
# these are tried out.

use NativeCall;

# -------- foreign function definitions in alphabetical order ----------

# See http://sqlite.org/capi3ref.html and http://sqlite.org/quickstart.html

sub sqlite3_close( OpaquePointer $ppDB )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_column_count( OpaquePointer $ppStmt )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_column_text( OpaquePointer $ppStmt, Int $iCol )
    returns Str
    is native('libsqlite3')
    { ... }

sub sqlite3_column_type( OpaquePointer $ppStmt, Int $iCol )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_exec( OpaquePointer $ppDB, Str $sql_command, OpaquePointer $callback, OpaquePointer $callbackarg0, OpaquePointer $error_pointer )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_finalize( OpaquePointer $ppStmt )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_open( Str $filename, OpaquePointer $ppDB )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_open_v2( Str $filename, OpaquePointer $ppDB, Int $flags, Str $zVfs )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_prepare_v2( OpaquePointer $ppDB, Str $sql_command, Int $nByte, OpaquePointer $ppStmt, OpaquePointer $pzTail )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_step( OpaquePointer $ppStmt )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_table_column_metadata(OpaquePointer $ppDB, Str $zDbName, Str $zTableName, Str $zColumnName, Positional of Str $pzDataType, Positional of Str $pzCollSeq, Positional of Int $pNotNull, Positional of Int $pPrimaryKey, Positional of Int $pAutoinc )
    returns Int
    is native('libsqlite3')
    { ... }

# ----------------------- main example program -------------------------

my OpaquePointer $db;
my OpaquePointer $stmt;
my OpaquePointer $pzTail;
my Positional of Str $pzDataType;
my Positional of Str $pzCollSeq;
my Positional of Int $pNotNull;
my Positional of Int $pPrimaryKey;
my Positional of Int $pAutoinc;

my $status = sqlite3_open( "test.db", $db );
say "open status $status";
$status = sqlite3_exec( $db, "CREATE TABLE a ( b INT );", pir::null__P(), pir::null__P(), pir::null__P() );
say "exec status $status";
$status = sqlite3_prepare_v2( $db, "CREATE TABLE a ( b INT );", 0, $stmt, $pzTail );
say "prepare status $status";
$status = sqlite3_table_column_metadata($db,"","","",$pzDataType,$pzCollSeq,$pNotNull,$pPrimaryKey,$pAutoinc);
say "table_column_metadata status $status";
$status = sqlite3_column_text( $stmt, 1 );
say "step status $status";
$status = sqlite3_step( $stmt );
say "step status $status";
$status = sqlite3_finalize( $stmt );
say "finalize status $status";
$status = sqlite3_close( $db );
say "close status $status";

