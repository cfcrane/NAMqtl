#!/usr/bin/env perl
use warnings;
#This script identifies map positions of interest closest to approximate cumulative positions noted from QTL LOD plots.
open (MAP, "< $ARGV[0]"); #/scratch/halstead/c/ccrane/raksha/NAMimputed2rmap.csv
open (APP, "< $ARGV[1]"); #NAMapproxpositionsofinterest0223.txt
open (OUT, "> $ARGV[2]");
$line = <MAP>; #Skip the header.
while ($line = <MAP>) {
  chomp $line;
  #S1_4040233,1,5.85156812414522
  @vars = split(/,/, $line);
  $positions{$vars[0]} = $vars[2];
  push(@{$markers[$vars[1]]}, $vars[0]);
}
while ($line = <APP>) {
  chomp $line;
  ($chr, $index) = split(/\t/, $line);
  $marker = $markers[$chr][$index];
  print OUT "$chr\t$marker\t$positions{$marker}\n";
}
