#!/usr/bin/perl

use strict;
use warnings;
use Carp qw(croak);

my $xbuf = ""; # output buffers
my $ofbuf = "";
my $ybuf = "";

open(my $in,"<","values.csv") or croak("Ah shit");
until(eof($in)) {
	my ($line,$val,$output);
	my $overflow = "";
	for (my $i=0;$i<8;$i++) {
		$line = <$in>;
		$val = substr($line,0,index($line,','));
		if ($val > 254) {
			$val -= 254;
			$overflow = '1' . $overflow;
		} else {
			$overflow = '0' . $overflow;
		}
		$output .= sprintf("\t.byte \$%x\n",$val);
	}
	$ofbuf .= "\t.byte %$overflow\n";
	$xbuf .= $output;
}

seek($in,0,0); # rewind file

until(eof($in)) {
	my ($line,$val,$output);
	for (my $i=0;$i<8;$i++) {
		$line = <$in>;
		$val = substr($line,index($line,',')+1);
		$output .= sprintf("\t.byte \$%x\n",$val);
	}
	$ybuf .= $output;
}

printf("xbuf:\n%s\n",$xbuf);
printf("ofbuf:\n%s\n",$ofbuf);
printf("ybuf:\n%s\n",$ybuf);
