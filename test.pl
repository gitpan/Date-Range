#!/usr/bin/perl -w

use strict;
use Test::More tests => 32;
use Date::Simple;
use Date::Range;

my $date1 = Date::Simple->new(2000,12,31);
my $date2 = $date1->next;
my $date3 = $date2->next;

eval { my $range = Date::Range->new() };
ok($@, "Can't create a range with no dates");

eval { my $range = Date::Range->new($date1) };
ok($@, "Can't create a range with one date");

eval { my $range = Date::Range->new($date1, $date2, $date3) };
ok($@, "Can't create a range with three dates");

eval { my $range = Date::Range->new("2001-01-01", "2001-02-02") };
ok($@, "Can't create a range with strings");

{
  ok(my $range = Date::Range->new($date1, $date1), "Create an single day range");
  is($range->start, $range->end, "Start and end on same date");
  is($range->length, 1, "1 day long");
}

ok(my $range1 = Date::Range->new($date1, $date2), "Create a range");
is($range1->start, $date1, "Starts OK");
is($range1->end, $date2, "Starts OK");
is($range1->length, 2, "2 days long");

ok(my $range2 = Date::Range->new($date2, $date1), "Create a range in wrong order");
is($range2->start, $date1, "Starts OK");
is($range2->end, $date2, "Starts OK");
is($range2->length, 2, "1 days long");
ok($range1->equals($range2), "Range 1 and 2 are equal");

ok(my $range3 = Date::Range->new($date1, $date3), "Longer Range");
is($range3->length, 3, "3 days long");

ok($range3->includes($date1), "Range includes first day");
ok($range3->includes($date2), "Range includes middle day");
ok($range3->includes($date3), "Range includes last day");
ok($range3->includes($range1), "Range includes first range");
ok($range3->includes($range2), "Range includes second range");
ok($range3->includes($range3), "Range includes itself");

#-------------------------------------------------------------------------
# Test overlaps
#-------------------------------------------------------------------------

{ 
  my $range = Date::Range->new($date2, $date3);
  ok($range->overlaps($range1), "The ranges overlap");
  ok(my $overlap = $range->overlap($range1), "Get that overlap");
  is($overlap->start, $date2, "Starts on day2");
  is($overlap->end, $date2, "Ends on day2");
}

{ 
  my $range = Date::Range->new($date2, $date3);
  ok($range->overlaps($range3), "The ranges overlap");
  ok(my $overlap = $range->overlap($range3), "Get that overlap");
  is($overlap->start, $date2, "Starts on day2");
  is($overlap->end, $date3, "Ends on day3");
}


