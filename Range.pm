package Date::Range;

=head1 NAME

Date::Range - deal with a range of dates

=head1 SYNOPSIS

  use Date::Range;

  my $range = Date::Range->new($date1, $date2);

  my $earliest = $range->start;
  my $latest   = $range->end;
  my $days     = $range->length;

  if ($range->includes($date3)) { ... }
  if ($range->includes($range2)) { ... }

  if ($range->overlaps($range2)) {
    my $range3 = $range->overlap($range2);
  }

  foreach my $date ($range->dates) { ... }

=head1 DESCRIPTION

Quite often, when dealing with dates, we don't just want to know
information about one particular date, but about a range of dates. For
example, we may wish to know whether a given date is in a particular
range, or what the overlap is between one range and another.  This module
lets you ask such questions.

=cut

use strict;
use Carp;
use vars qw/$VERSION/;

$VERSION = '0.9';

=head1 METHODS

=head2 new()

  my $range = Date::Range->new($date1, $date2);

A range object is instantiated with two dates, which do not need
to be in chronological order (we'll sort all that out internally).

These dates must be instances of the Date::Simple class.

=cut

sub new {
  my $that = shift;
  my $class = ref($that) || $that;
  my @dates = sort { $a <=> $b } grep $_->isa("Date::Simple"), @_;
  croak "You must create a range from two date objects" unless (@dates == 2);
  my $self = bless {
    _start => $dates[0],
    _end   => $dates[1],
  }, $class;
  return $self;
}

=head2 start() / end()

  my $earliest = $range->start;
  my $latest   = $range->end;
  my $days     = $range->length;

These methods allow you retrieve the start and end dates of the range,
and the number of days in the range. 

=cut

sub start  { $_[0]->{_start} }
sub end    { $_[0]->{_end}   }
sub length { $_[0]->end - $_[0]->start + 1 }

=head2 equals

  if ($range1->equals($range2)) { }

This tells you if two ranges are the same - i.e. start and end at
the same dates. 

=cut

sub equals {
  my $self = shift;
  my $check = shift;
  return unless $check->isa('Date::Range');
  return $self->start == $check->start and $self->end == $check->end;
}

=head2 includes

  if ($range->includes($date3)) { ... }
  if ($range->includes($range2)) { ... }

These methods tell you if a given range includes a given date, 
or a given range.

=cut

sub includes {
  my $self = shift;
  my $check = shift;
  if ($check->isa('Date::Range')) {
    return $self->includes($check->start) && $self->includes($check->end);
  } elsif ($check->isa('Date::Simple')) {
    return $self->start <= $check && $check <= $self->end;
  } else {
    croak "Ranges can only include dates or ranges";
  }
}

=head2 overlaps / overlap

  if ($range->overlaps($range2)) {
    my $range3 = $range->overlap($range2);
  }

These methods let you know whether one range overlaps another or not,
and access this overlap range.

=cut

sub overlaps { 
  my $self = shift;
  my $check = shift;
  return unless $check->isa('Date::Range');
  return $check->includes($self->start) or $check->includes($self->end) 
      or $self->includes($check);
}

sub overlap { 
  my $self = shift;
  my $check = shift;
  return unless $check->isa('Date::Range');
  return unless $self->overlaps($check);
  my @dates = sort { $a <=> $b } $self->start, $self->end, 
                                 $check->start, $check->end;
  return $self->new(@dates[1..2]);
}

=head2 dates

  foreach my $date ($range->dates) { ... }

This returns a list of each date in the range as a Date::Simple object.

=cut

sub dates {
  my $self = shift;
  my @dates; 
  my $start = $self->start;
  push @dates, $start++ for 1 .. $self->length;
  return @dates;
}

1;

=head1 BUGS

None known.

=head1 AUTHOR

Tony Bowden, E<lt>tony@tmtm.comE<gt>, based heavily on
Martin Fowler's "Analysis Patterns 2" discussion and code at
http://www.martinfowler.com/ap2/range.html

=head1 COPYRIGHT

Copyright (C) 2001 Tony Bowden. All rights reserved.

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


