#!/usr/bin/env perl
use warnings;
#This script combines the specified columns and prints out columns between specified limits.
open (LIS, "< $ARGV[0]"); #NAMimputedsourcefiles.txt
open (PAR, "< $ARGV[1]"); #B73_CML52_phasingfiles.txt
open (CDI, "< $ARGV[2]"); #columndirections.txt
open (OUT, "> $ARGV[3]");
$minfraccanonical = $ARGV[4]; #0.9;
$maxmaxfrac = $ARGV[5]; #0.75
$iscanonical{A} = 1; $iscanonical{C} = 1; $iscanonical{G} = 1; $iscanonical{T} = 1;
while ($file = <PAR>) {
  chomp $file;
  open (INP, "< $file");
  while ($line = <INP>) {
    chomp $line;
    ($name, $par1, $par2) = split(/\t/, $line);
    push(@{$parentalalleles{$name}}, $par1, $par2);
  }
}
while ($line = <CDI>) {
  chomp $line;
  @vars = split(/\t/, $line);
  push (@columns, $vars[0]);
  push (@names, $vars[1]);
  push (@codes, $vars[2]);
}
print OUT "SNP";
for ($i = 0; $i < scalar(@names); $i++) {print OUT ",$names[$i]";}
print OUT "\n";
#Codes usage: 0, do nothing but print out the column value; 1, merge with the following column, e.g., 1712 and 1713.
while ($file = <LIS>) {
  chomp $file;
  open (INP, "< $file");
  $line = <INP>; #Discard the header.
  while ($line = <INP>) {
    chomp $line;
    @printeditems = ();
    @vars = split(/\t/, $line);
    for ($i = 0; $i < scalar(@columns); $i++) {
      if ($codes[$i] == 0) {push(@printeditems, $vars[$columns[$i]]);}
      else {
        #push(@printeditems, "SP");
        $nextcolumn = $columns[$i] + 1;
        $candidate = "Q";
        if (exists($iscanonical{$vars[$columns[$i]]})) {
          if (exists($iscanonical{$vars[$nextcolumn]})) {
            if ($vars[$columns[$i]] eq $vars[$nextcolumn]) {$candidate = $vars[$columns[$i]];}
            else {$candidate = $vars[$columns[$i]];} #Otherwise flip a coin.
          }
          else {$candidate = $vars[$columns[$i]];}
        }
        else {
          if (exists($iscanonical{$vars[$nextcolumn]})) {$candidate = $vars[$nextcolumn];}
          else {$candidate = $vars[$columns[$i]];}
        }
        push(@printeditems, $candidate);
      }
    }
    $totalcanonicals = 0; $sumA = 0; $sumC = 0; $sumG = 0; $sumT = 0;
    for ($i = 0; $i < scalar(@printeditems); $i++) {
      if (exists($iscanonical{$printeditems[$i]})) {
        $totalcanonicals++;
        if ($printeditems[$i] eq "A") {$sumA++;}
        if ($printeditems[$i] eq "C") {$sumC++;}
        if ($printeditems[$i] eq "G") {$sumG++;}
        if ($printeditems[$i] eq "T") {$sumT++;}
      }
    }
    if ($totalcanonicals / scalar(@printeditems) >= $minfraccanonical) {
      $maxcount = $sumA;
      if ($sumC > $maxcount) {$maxcount = $sumC;}
      if ($sumG > $maxcount) {$maxcount = $sumG;}
      if ($sumT > $maxcount) {$maxcount = $sumT;}
      if ($maxcount / $totalcanonicals <= $maxmaxfrac) {
#        print OUT $vars[0];
#        for ($i = 0; $i < scalar(@printeditems); $i++) {print OUT "\t$printeditems[$i]";}
#        print OUT "\n";
#        print OUT $vars[0];
#        for ($i = 0; $i < scalar(@columns); $i++) {print OUT "\t$vars[$columns[$i]]";}
#        print OUT "\n";
        if (exists($parentalalleles{$vars[0]}[0])) {
          print OUT $vars[0];
          for ($i = 0; $i < scalar(@printeditems); $i++) {
            if ($printeditems[$i] eq $parentalalleles{$vars[0]}[0]) {print OUT ",B";}
            elsif ($printeditems[$i] eq $parentalalleles{$vars[0]}[1]) {print OUT ",L";}
            else {print OUT ",-";}
          }
          print OUT "\n";
        }
        else {print "There are no parental alleles for marker $vars[0]\n";}
#        printf OUT "%d elements in columns, %d elements in printeditems\n", scalar(@columns), scalar(@printeditems);
      }
    }
  }
}
