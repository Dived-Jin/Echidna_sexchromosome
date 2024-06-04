#!/usr/bin/perl -w
use strict;

die "perl $0 <m8.format>" unless @ARGV == 1;

open(IN, $ARGV[0]) or die $!;
while(<IN>){
    chomp;
    next if(/^#/);
    my ($info, $bg, $ed, $sscaf, $sbg, $sed) = (split /\t/)[0,2,3,6,8,9];
    $info =~ /(\S+):(\d+)-(\d+)/;
    my ($qscaf, $base) = ($1, $2);
    $bg += $base;
    $ed += $base;
    next if($qscaf eq $sscaf);
    my $flag = 0;
    if($bg >= $sbg and $bg <= $sed){
        $flag = 1;
    }
    elsif($ed >= $sbg and $ed <= $sed){
        $flag = 1;
    }
    if($flag == 0){
        print "$_\n";
    }
}
close IN;

