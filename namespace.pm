package namespace;

=head1 NAME

namespace - Perl pragma to use like C++ namespace aliasing

=head1 SYNOPSIS

 use namespace qw/File IO::File SEEK_END SEEK_CUR $VERSION/;

 my $fh = new File ">foo";
 if( defined $fh )
 {
     print $fh "bar\n";
     $fh->close;
 }

=head1 DESCRIPTION

 use namespace 
    qw/ ALIAS PACKAGE [ IMPORT_LIST [ ::SUBPACKAGE [ IMPORT_LIST ]]] /;

 ALIAS and PACKAGE is required parameters;
 IMPORT_LIST is the usual list of import.

NOTE! The the names of variables will be imported to ALIAS or 
ALIAS::SUBPACKAGE namespace. And the names of functions will be 
imported to caller package.

=head1 EXAMPLES

 use namespace qw/DOM XML::DOM $VERSION ::Document $VERSION/;

    # DOM is alias for XML::DOM
    #       $VERSION from XML::DOM will be imported to DOM
    #
    # ::Document subpackage of XML::DOM will be aliased to DOM::Document
    #       $VERSION from XML::DOM::Document will be imported to DOM::Document

 my $doc = new DOM::Document;

 print "Current used DOM version is $DOM::VERSION \n";

=head1 AUTHOR

Albert MICHEEV <Albert@f80.n5049.z2.fidonet.org>

=cut

use strict;
our $VERSION = '0.01';

sub import{
    my ($slf, $als, $pkg) = (shift, shift, shift);
    my $clr = (caller)[0];

    eval sprintf q{package %s; use %s; our @ISA = qw/%s/;}, 
        $als, $pkg, $pkg unless defined @{$als.'::ISA'};

    my $sub = '';
    no strict qw/refs/;

    while( my $imp = shift ){
        if( substr($imp, 0, 2) eq '::' ){
            $sub = $imp;
            eval sprintf q{package %s; our @ISA = qw/%s/;}, 
                $als.$sub, $pkg.$sub unless defined @{$als.$sub.'::ISA'};
        }
        elsif( $imp =~ /^([\$%@])(.+)$/ ){
            *{$als.$sub.'::'.$2} = $1 eq '$' ? \${$pkg.$sub.'::'.$2} :
               $1 eq '@' ? \@{$pkg.$sub.'::'.$2} : \%{$pkg.$sub.'::'.$2};
        }
        else{
            *{$clr.'::'.$imp} = *{$als.$sub.'::'.$imp} = 
                \&{$pkg.$sub.'::'.$imp};
        }
    }
}

1;
