use strict ;
use warnings ;
use Test::More ;
use System::Command ;
use Config ;
use IO::File ;

my $tstr = "foo\n\r\n" ;

our @hd_f = (
    $^X, '-e',
    '$/=undef; open STDIN, $ARGV[0]; binmode STDIN; print join( q/ /, map { unpack( q/H*/, $_) } split //, <STDIN> ), qq/\n/'
    ) ;
our @hd_s = (
    $^X, '-e',
    '$/=undef; binmode STDIN; print join( q/ /, map { unpack( q/H*/, $_) } split //, <STDIN> ), qq/\n/'
    ) ;
our @cat = (
    $^X, '-e',
    '$/=undef; open STDIN, $ARGV[0]; binmode STDIN; binmode STDOUT; print STDOUT <STDIN>;'
    ) ;

sub hd {
    join( q/ /, map { unpack( q/H*/, $_ ) } split //, shift ), qq/\n/ ;
    }

# these must work, or Perl is borked
sub fiducial_write {
    my ( $write_mode ) = @_ ;
    my $mode = $write_mode eq 'default' ? '>' : '>:raw' ;
    IO::File->new( $write_mode, $mode )->print( $tstr ) ;
    print "expected: " ;
    system( @hd_f, $write_mode ) ;
    }

sub fiducial_read {
    my ( $write_mode, $read_mode ) = @_ ;
    my $mode = $read_mode eq 'default' ? '<' : '<:raw' ;
    IO::File->new( $write_mode, $mode )->read( my $buf, 1000 ) ;
    print "expected: ", hd( $buf ) ;
    }

{
    my $cmd = System::Command->new( @hd_s );
    $cmd->stdin->print( $tstr );
    # $cmd->stdin->close;
    # print "default write to pipe:\n";
    # fiducial_write( 'default' );
    # print "got     : ", $cmd->stdout->getline;
    # print "\n";
}

#
# {
#     my $cmd = System::Command->new( @hd_s );
#     binmode $cmd->stdin;
#     $cmd->stdin->print( $tstr );
#     $cmd->stdin->close;
#     print "binary write to pipe:\n";
#     fiducial_write( 'binary' );
#     print "got     : ", $cmd->stdout->getline;
#     print "\n";
# }
#
# {
#     my $cmd = System::Command->new( @cat, 'binary' );
#     $cmd->stdin->close;
#     $cmd->stdout->read( my $buf, 100 );
#     print "default read of non-crlf encoded data: \n";
#     fiducial_read( 'binary', 'default' );
#     print "got     : ", hd( $buf );
#     print "\n";
# }
#
# {
#     my $cmd = System::Command->new( @cat, 'binary' );
#     binmode $cmd->stdout;
#     $cmd->stdin->close;
#     $cmd->stdout->read( my $buf, 100 );
#     print "binary read of non-crlf encoded data: \n";
#     fiducial_read( 'binary', 'binary' );
#     print "got     : ", hd( $buf );
#     print "\n";
# }
#
# {
#     my $cmd = System::Command->new( @cat, 'default' );
#     $cmd->stdin->close;
#     $cmd->stdout->read( my $buf, 100 );
#     print "default read of crlf encoded data\n";
#     fiducial_read( 'default', 'default' );
#     print "got     : ", hd( $buf );
#     print "\n";
# }
#
# {
#     my $cmd = System::Command->new( @cat, 'default' );
#     binmode $cmd->stdout;
#     $cmd->stdin->close;
#     $cmd->stdout->read( my $buf, 100 );
#     print "binary read of crlf encoded data \n";
#     fiducial_read( 'default', 'binary' );
#     print "got     : ", hd( $buf );
#     print "\n";
# }
#
#
#
