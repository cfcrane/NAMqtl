#!/usr/bin/env perl
use warnings;
#This naive imputation script fills in missing data based on the genotype at the preceding and following row.
#Obviously, the input must be sorted by marker position in a sequenced genome.
#The marker name is presumed to have two parts, chromosome and position, connected by an underscore.
open (INP, "< $ARGV[0]"); #/scratch/halstead/c/ccrane/raksha/NAMrawpolymorphicgenotypes07.csv
open (OUT, "> $ARGV[1]");
$tolerance = $ARGV[2]; #50000?
$isvalid{$ARGV[3]} = 1; #B
$isvalid{$ARGV[4]} = 1; #L
$searchedchar = $ARGV[5]; #"-"
$header = <INP>;
print OUT $header;
chomp $header;
($name, @vars) = split(/,/, $header);
$ncolumns = scalar(@vars);
while ($line = <INP>) {
  chomp $line;
  ($name, @vars) = split(/,/, $line);
  push(@names, $name);
  ($chr, $coordinate) = split(/_/, $name);
  push(@chrs, $chr);
  push(@coordinates, $coordinate);
  for ($i = 0; $i < $ncolumns; $i++) {
    push(@{$data[$i]}, $vars[$i]);
  }
}
print OUT "First half action:\n\n";
$hyphensbefore = 0;
for ($i = 0; $i < $ncolumns; $i++) {
  print OUT $i;
  for ($j = 0; $j < scalar(@names); $j++) {
    if ($data[$i][$j] eq "-") {$hyphensbefore++;}
    print OUT ",$data[$i][$j]";
  }
  print OUT "\n";
}
$nreplaced = 0;
for ($i = 0; $i < $ncolumns; $i++) {
  $lastvalid = -1;
  $lastchr = -1;
  $lastvalidj = 0;
  for ($j = 0; $j < scalar(@names); $j++) {
    if (exists($isvalid{$data[$i][$j]})) {
      if ($data[$i][$j] eq $data[$i][$lastvalidj]) {
        if ($chrs[$j] eq $chrs[$lastvalidj]) {
          if ($j - $lastvalidj > 1) {
            if ($coordinates[$j] - $lastvalid < $tolerance) {
              for ($k = $lastvalidj + 1; $k < $j; $k++) {
                $data[$i][$k] = $data[$i][$j];
              }
            }
          }
        }
      }
      $lastvalid = $coordinates[$j];
      $lastvalidj = $j;
    }
  }
  for ($j = 1; $j < scalar(@names) - 1; $j++) {
    if (exists($isvalid{$data[$i][$j-1]})) {
      if (exists($isvalid{$data[$i][$j]})) {
        if (exists($isvalid{$data[$i][$j+1]})) {
          if ($data[$i][$j] ne $data[$i][$j-1]) {
            if ($data[$i][$j] ne $data[$i][$j+1]) {
              if ($chrs[$j-1] eq $chrs[$j+1]) {
                if ($coordinates[$j+1] - $coordinates[$j-1] < $tolerance) {$data[$i][$j] = $data[$i][$j-1]; $nreplaced++;}
              }
            }
          }
        }
      }
    }
  }
}
print OUT "\n\nSecond half action:\n\n";
$hyphensafter = 0;
for ($i = 0; $i < $ncolumns; $i++) {
  print OUT $i;
  for ($j = 0; $j < scalar(@names); $j++) {
    if ($data[$i][$j] eq "-") {$hyphensafter++;}
    print OUT ",$data[$i][$j]";
  }
  print OUT "\n";
}
print "before $hyphensbefore after $hyphensafter\n";
print "$nreplaced singleton called alleles were corrected.\n";
print OUT "\n\nPrinting final genotypes:\n\n";
print OUT "$header\n";
for ($j = 0; $j < scalar(@names); $j++) {
  print OUT $names[$j];
  for ($i = 0; $i < $ncolumns; $i++) {print OUT ",$data[$i][$j]";}
  print OUT "\n";
}
