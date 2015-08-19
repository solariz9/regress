#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $min;
my $hour;
my $sec;
my $line;
my $mday;
my $mon;
my $year;
my $GroupName;

my $dbh = DBI->connect('DBI:mysql:regress', 'regress', 'password') || die "Could not connect to database: $DBI::errstr";

my $TrackFound=0;

while ($TrackFound==0) {

    ($sec,$min,$hour,$mday,$mon,$year) = localtime();
    $year=$year+1900;
    $mon=$mon+1;

    srand;
    open FILE, "</home/radio/audio/denplaylist.m3u" or die "Could not open filename: $!\n";
	rand($.)<1 and ($line=$_) while <FILE>;
    close FILE;

  my @values = split('/', $line);
  my $prev='';
  foreach my $val (@values) {
   if ($prev eq "Radio") {$GroupName=$val}
   $prev=$val;
			    }

    my $sth = $dbh->prepare('select * from playstream where year='.$year.' and month='.$mon.' and day='.$mday.' and ('.$hour.'-hour<3) and groupname="'.$GroupName.'"');
    $sth->execute;

    my $ref;
    my $i=0;
    while ($ref = $sth->fetchrow_arrayref) {
	$i++;
					   }

    $sth = $dbh->prepare('select * from playstream where year='.$year.' and month='.$mon.' and day='.$mday.' and songname="'.$prev.'"');
    $sth->execute;

    while ($ref = $sth->fetchrow_arrayref) {
	$i++;
					   }

    if ($i==0) {
	my $Chopped = chop($prev);
	$Chopped = chop($line);
	print "$line\n";

	$sth = $dbh->prepare('insert into playstream (groupname,songname,year,month,day,hour,min) values ("'.$GroupName.'","'.$prev.'",'.$year.','.$mon.','.$mday.','.$hour.','.$min.')');
	$sth->execute;
	$TrackFound=1;
	    }

    $sth->finish;

						}
$dbh->disconnect();
