package namespace;

=head1 NAME

namespace - Perl pragma to use like C++ namespace aliasing

=head1 SYNOPSIS

 use namespace File => IO::File;

 my $fh = new File "foo", O_CREAT|O_WRONLY;
 if( defined $fh )
 {
     print $fh "bar\n";
     $fh->close;
 }

=head1 DESCRIPTION

Allow aliasing namespace. May be useful for reusability increase.

 use namespace ALIAS => PACKAGE 
    [, qw/IMPORT_LIST [ ::SUBPACKAGE [ IMPORT_LIST ]] /];

 ALIAS and PACKAGE is required parameters;
 IMPORT_LIST is the usual list of import.

NOTE! The the names of variables will be imported to ALIAS or 
ALIAS::SUBPACKAGE namespace. And the names of functions will be 
imported also to caller package.

=head1 EXAMPLES

 EXAMPLE 1

 use namespace DOM => XML::DOM, qw/$VERSION ::Document $VERSION/;

    # DOM is alias for XML::DOM
    #       $VERSION from XML::DOM will be imported to DOM
    #
    # ::Document subpackage of XML::DOM will be aliased to DOM::Document
    #       $VERSION from XML::DOM::Document will be imported to DOM::Document

 my $doc = new DOM::Document;
 print "Current used DOM version is $DOM::VERSION \n";



 EXAMPLE 2

 use namespace DOM => XML::DOM, qw/::Document/;
 # or
 # use namespace DOM => XML::Sablotron::DOM, qw/:constants ::Document/;

 my $doc = new DOM::Document;
 print "Constant 'TEXT_NODE' = ", TEXT_NODE;

=head1 AUTHOR

Albert MICHEEV <Albert@f80.n5049.z2.fidonet.org>

=cut

use strict;
$namespace::VERSION = '0.02';


sub import{
    my ($slf, $als, $pkg) = (shift, shift, shift);
    my $clr = (caller)[0];

    eval sprintf q{package %s; use %s; @%s::ISA = qw/%s/;}, 
        $als, $pkg, $als, $pkg unless defined @{$als.'::ISA'};

    my $sub = '';
    no strict qw/refs/;

    if( $_[0] and $_[0] eq '()' ){ shift }
    else{ 
        unshift @_, @{$pkg.'::EXPORT'} if 
            defined @{$pkg.'::EXPORT'} 
    }

    while( my $imp = shift ){
        if( substr($imp, 0, 2) eq '::' ){
            $sub = $imp;
            eval sprintf q{package %s; @%s::ISA = qw/%s/;}, $als.$sub, 
                $als.$sub,  $pkg.$sub unless defined @{$als.$sub.'::ISA'};
            if( $_[0] and $_[0] eq '()' ){ shift }
            else{ unshift @_, @{$pkg.$sub.'::EXPORT'} if 
                defined @{$pkg.$sub.'::EXPORT'} 
            }
        }
        elsif( $imp =~ /^([\$%@])(.+)$/ ){
            *{$als.$sub.'::'.$2} = $1 eq '$' ? \${$pkg.$sub.'::'.$2} :
               $1 eq '@' ? \@{$pkg.$sub.'::'.$2} : \%{$pkg.$sub.'::'.$2};
        }
        elsif( $imp =~ /^:(.+)$/ ){
            unshift @_, @{(\%{$pkg.$sub.'::EXPORT_TAGS'})->{$1}};
        }
        else{
            *{$clr.'::'.$imp} = *{$als.$sub.'::'.$imp} = 
                \&{$pkg.$sub.'::'.$imp};
        }
    }
}

1;
