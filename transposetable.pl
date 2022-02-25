#!/usr/bin/env perl
use warnings;
#This script transposes rows and columns in a tabular file.
open (INP, "< $ARGV[0]"); #NAMimputed2genotypesonly.csv
open (OUT, "> $ARGV[1]");
$header = <INP>;
chomp $header;
($filler, @plants) = split(/,/, $header);
$ncolumns = scalar(@plants);
while ($line = <INP>) {
  chomp $line;
  ($name,  @vars) = split(/,/, $line);
  push(@genenames, $name);
  for ($i = 0; $i < $ncolumns; $i++) {push(@{$genotypes{$plants[$i]}}, $vars[$i]);}
}
print OUT "SNP";
for ($i = 0; $i < scalar(@genenames); $i++) {print OUT ",$genenames[$i]";}
print OUT "\n";
for ($i = 0; $i < $ncolumns; $i++) {
  print OUT $plants[$i];
  for ($j = 0; $j < scalar(@genenames); $j++) {print OUT ",$genotypes{$plants[$i]}[$j]";}
  print OUT "\n";
}
