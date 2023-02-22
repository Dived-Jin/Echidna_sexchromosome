#!/usr/bin/perl -w
use strict;

die "perl $0 <HOMSAP.X.fasta.fai.10K.bed.fasta.m8.format.filt.filt.tab.hcluster>" unless @ARGV == 1;

open(IN, $ARGV[0]) or die $!;
while(<IN>){
	chomp;
	my ($id, $info) = (split /\t/)[0,2];
	$info =~ s/,$//;
	my @tmp = split /,/, $info;
	foreach my $i (@tmp){
		$i =~ /(\S+?):(\d+)-(\d+)/;
		print "$1\t$2\t$3\t$id\n";
	}
}
close IN;

