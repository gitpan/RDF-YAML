# $File: //member/autrijus/RDF-YAML/lib/RDF/YAML.pm $ $Author: autrijus $
# $Revision: #1 $ $Change: 8523 $ $DateTime: 2003/10/22 04:14:34 $

package RDF::YAML;
$RDF::YAML::VERSION = '0.1';

use strict;

=head1 NAME

RDF::YAML - RDF YAML parser and dumper

=head1 VERSION

This document describes version 0.01 of RDF::YAML, released October 22,
2003.

=head1 SYNOPSIS

    # Get triples from a RDF/YAML file
    $rdf = RDF::YAML->new;
    $triples = $rdf->parse_file("input.yml");

    # Translate RDF/XML to RDF/YAML
    my $triples = RDF::Simple::Parser->new->parse_rdf($xml_string);
    $rdf->set_triples($triples);
    $rdf->dump_file("output.yml");

    # Add new triples to a RDF/YAML string
    $rdf->parse_string($yaml_string);
    $rdf->add_triples(\@triples);
    $yaml_string = $rdf->dump_string;

=head1 DESCRIPTION

This module is a RDF/YAML parser/dumper; it can parse RDF/YAML files or
strings, provide results as triples, and dump triples back to RDF/YAML
format.  It is only a thin wrapper around L<RDF::Simple::Parser::YAML>
and L<RDF::Simple::Serialiser::YAML>.

Note that this is a proof-of-concept work; the RDF/YAML format used by
this module is purely experimental, and may change without notice.

=head1 METHODS

=head2 new()

Constructor.  Currently takes no parameters.

=cut

sub new {
    my $class = shift;
    bless({ triples => [] }, $class);
}

=head2 parse_file($file)

Parses a RDF/YAML file specified by $file.  Returns an array reference
to parsed triples, in the standard C<[ $subject, $predicate, $object ]>
format.  This also replaces all previous triples stored within the object.

=head2 parse_string($string)

Similar to C<parse_file>, but parses RDF/YAML data from string.

=cut

sub parse_file {
    my ($self, $file) = @_;
    local $/;
    local *FH;
    open FH, $file or die $!;
    $self->parse_string(<FH>);
    close FH;
    return $self->get_triples;
}

sub parse_string {
    my $self = shift;
    $self->set_triples( [ $self->_parser->new->parse_rdf(@_) ] );
    $self->add_ns( %{$self->_parser->ns || {}} );
    return $self->get_triples;
}

=head2 dump_file($file)

Writes all triples stored in the object into a file specified by C<$file>,
in RDF/YAML format.

=head2 dump_string()

Similar to C<dump_file>, but returns a RDF/YAML string instead.

=cut

sub dump_file {
    my ($self, $file) = @_;
    local *FH;
    open FH, "> $file" or die $!;
    print FH $self->dump_string;
    close FH;
}

sub dump_string {
    my $self = shift;
    require RDF::Simple::Serialiser::YAML;
    $self->_serialiser->serialise($self->get_triples || []);
}

=head2 get_triples()

Returns a reference to array of triples currently stored in this object.

=head2 set_triples($triples)

Takes a reference to array of triples and stores it in the object,
replacing previous ones.  If invoked with no arguments, clears the
stored triples.

=head2 add_triples($triples)

Similar to C<set_triples>, but adds to currently stored triples instead
of replacing them.

=cut

sub get_triples { $_[0]->{triples} }
sub set_triples { $_[0]->{triples} = ($_[1] || []) }
sub add_triples { push @{$_[0]->get_triples}, @{$_[1] || []} }

=head2 get_ns()

Returns a hash reference of namespaces currently in use.

=head2 add_ns( $qname => $uri, $qname2 => $uri2 ... )

Add new namespaces to the RDF document.  Default ones are the same as
supported in L<RDF::Simple::NS>, and new ones are accumulated from each
parsed file or string.

=cut

sub get_ns {
    my $self = shift;
    return { $self->_serialiser->ns->lookup };
}

sub add_ns {
    my $self = shift;
    $self->_serialiser->addns(@_);
}

# Internal methods

sub _parser {
    my $self = shift;
    require RDF::Simple::Parser::YAML;
    $self->{parser} ||= RDF::Simple::Parser::YAML->new;
}

sub _serialiser {
    my $self = shift;
    require RDF::Simple::Serialiser::YAML;
    $self->{serialiser} ||= RDF::Simple::Serialiser::YAML->new;
}

1;

=head1 SEE ALSO

L<RDF::Simple::Parser::YAML>, L<RDF::Simple::Serialiser::YAML>

L<RDF::Simple>, L<RDF::Notation3>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
