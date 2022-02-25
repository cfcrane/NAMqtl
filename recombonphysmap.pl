#!/usr/bin/env perl
use warnings;
#This script calculates a recombinational map given a physical marker order and observed genotypes.
open (OBS, "< $ARGV[0]"); #/scratch/halstead/c/ccrane/raksha/NAMimputedpolymorphicgenotypes.csv
open (OUT, "> $ARGV[1]"); #NAMimputedassemblybasedrecombfracs.csv
$divider = $ARGV[2]; #_
$lastline = <OBS>;
$lastname = "header";
$isvalid{$ARGV[3]} = 1; #B
$isvalid{$ARGV[4]} = 1; #L
$flag = $ARGV[5]; #0 for R, 1 for r-hat; see estrecombinRILs.pdf
$cumul = $ARGV[6]; #0 for individual recombination fractions, 1 for cumulative recombination from start
$subsout = $ARGV[7]; #S
while ($line = <OBS>) {
  #Markers are presumed to be listed in ascending order of physical position, e.g., by nucleotide in a finished genome.
  chomp $line;
  ($currname,@currvars) = split(/,/, $line);
  #S1_237585,-,B,-,L,L,L,B,B,B,L,L,L,L,L,L,B,B,B,B,B,B,B,B,L,B,L,B,L,L,B,B,L,L,...
  #S1_516355,-,L,L,L,L,L,B,B,B,-,L,L,L,L,L,-,B,B,B,B,B,-,B,L,B,L,B,L,-,B,B,L,L,...
  if ($lastname ne "header") {
    if (scalar(@currvars) != scalar(@lastvars)) {die "Consecutive lines differ in length for $lastname and $currname\n";}
    @lars = split(/$divider/, $lastname);
    @cars = split(/$divider/, $currname);
    if ($lars[0] eq $cars[0]) {
      $sumdiff = 0;
      $sumsame = 0;
      for ($i = 0; $i < scalar(@currvars); $i++) {
        if (exists($isvalid{$lastvars[$i]})) {
          if (exists($isvalid{$currvars[$i]})) {
            if ($currvars[$i] eq $lastvars[$i]) {$sumsame++;}
            else {$sumdiff++;}
          }
        }
      }
      if ($flag == 0) {$recombfrac = 100 * $sumdiff / ($sumdiff + $sumsame);}
      else {
        $recombfrac = 100 * $sumdiff * ($sumsame - 1) / (2 * $sumsame ** 2); #Equation 12 in estrecombinRILs.pdf
      }
      $cumulativerf{$cars[0]} += $recombfrac;
      ($printedchr = $cars[0]) =~ s/$subsout//;
      if ($cumul == 0) {print OUT "$currname,$printedchr,$recombfrac\n";}
      elsif ($cumul == 1) {print OUT "$currname,$printedchr,$cumulativerf{$cars[0]}\n";}
    }
    else {
      $cumulativerf{$cars[0]} = 0;
      ($printedchr = $cars[0]) =~ s/$subsout//;
      if ($cumul == 0) {print OUT "$currname,$printedchr,0\n";}
      elsif ($cumul == 1) {print OUT "$currname,$printedchr,0\n";}
    }
  }
  else {
    ($chr, $position) = split(/$divider/, $currname);
    ($printedchr = $chr) =~ s/$subsout//;
    print OUT "$currname,$printedchr,0\n";
  }
  $lastname = $currname;
  @lastvars = @currvars;
}
for $key (sort(keys(%cumulativerf))) {print "$key\t$cumulativerf{$key}\n";}
