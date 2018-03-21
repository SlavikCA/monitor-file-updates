#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use File::stat;
use Cwd 'abs_path';

my $dirname = '/volume1/homes/reporter'; # folder to monitor
my $freq = 12*60; # maximum frequency of emails
my $reportEmail = 'TO_EMAIL@SERVER.NET'; # recipient of reports

my $scriptdir = dirname(abs_path($0));
my $reportFile = $scriptdir.'/report.txt';
my $reportSent = $scriptdir.'/sent.txt';
my $Current = $scriptdir.'/current.txt';
my $Prev = $scriptdir.'/prev.txt';

system ("ls $dirname -R -1 > $Current");

unless (-e $Prev) {
system ("cp $Current $Prev");
print "Running for the 1st time\nObtaining file list\n";
}

system ("diff $Prev $Current > $reportFile");
my $filesize = -s "$reportFile";
if ($filesize > 0) {
my $modif = 0;
if (-e $reportSent) { $modif=stat($reportSent)->mtime;}
else {
print "Sending first email\n";
}

my $delay = (time - $modif) / 60 ;
if ($delay < $freq) {
print "only $delay minutes passed since last email. Waiting for $freq minutes after last sent email\n";
}
else {
system ('perl '.$scriptdir.'/sendEmail -f FROM_EMAIL@SERVER.NET -t '.$reportEmail.' -u "Reporter folder updates" -xu USERNAME -xp PASSWORD -o message-charset=UTF-8 -o message-file='.$reportFile);
system ("mv -f $reportFile $reportSent");
system ("mv -f $Current $Prev");
}
}
