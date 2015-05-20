use strict;
use warnings;

use File::Find::Rule;
use Getopt::Long;
use Encode 'encode';

# ##########################################
# ############## Perl Project ##############
# ##########################################
# This is the perl exam project. LIC.LIG — L2 — Section A
# Project Members : BOUCHAALA Reda — 201300005606 — <bouchaala.reda@gmail.com>
#                   DJELOUEH Mohamed — 201300005133
#                   BEDAR Abdellah — 201300005506
#                   BOUKHARI Mohamed — 201200006613
#                   HAFID Mohamed Lamine — 201200006815
# 
# This file is devided to several parts, to be more readable.
# 

if( $ARGV[0] && ($ARGV[0] eq "-h" || $ARGV[0] eq "--help") ) {
    print_help_message();
}

# #################################################################################################
# #################### Setup command-line arguments ###############################################
# #################################################################################################

my $dir         = "";
my $depth       = 30;                      # Maximaum directory depth to traverse.
my $filename    = "dico_corpus.dic";       # The file name...

# Check the existence of --dir option.
my $hasDir = 0;
foreach my $arg(@ARGV) {
  if( substr($arg, 0, 6) eq '--dir=' ) {
    $hasDir = 1;
  }
}

if( $hasDir == 0 ) {
  print_missing_args_error();
  exit;
}

GetOptions("--dir=s" => \$dir,
            "--file=s"   => \$filename,
            "--depth=i"   => \$depth);

# #################################################################################################
# ###### Traverse the directory stucture, and return the relative path to this file. ##############
# #################################################################################################

# File lookup using the File::Find::Rule module.
my $src_file = (File::Find::Rule->file()
                ->name($filename)
                ->maxdepth($depth)
                ->in($dir))[0];

# #################################################################################################
# ############# SORTING ###########################################################################
# #################################################################################################
# # Open files
open(IN,"<$src_file");
# Truncate the output file 
open(OUT, '>:encoding(utf8)', 'dico_corpus.txt');
# Now open with append mode, using utf8 as an encoding
open(OUT, '>>:encoding(utf8)', 'dico_corpus.txt');

my @src_lines = ();
# 1 — Reading loop.
# Read line-by-line, encode it to UTF-8, and then push it to an array to be sorted later.
while (my $src_line = <IN>) {
  $src_line = Encode::encode('unicode', $src_line);
  my ($f, $n, $u) = $src_line =~ /(.+)\s+(.+)\s+(.+)\s+/ig;
  push(@src_lines, "$n-$f-$u\n");
}

# 2 — Sort the result array
my @sorted_lines = sort {
  chomp($a); chomp($b);

  my $u1 = (split("-", $a))[2] || '';
  my $u2 = (split("-", $b))[2] || '';

  return ( $u1 cmp $u2 );
} @src_lines;

# 3 — Write the sorted results to the out-file.

foreach my $sorted_line(@sorted_lines) {
  chomp($sorted_line);
  my ($n, $f, $u) = split('-', $sorted_line);
  $f = Encode::encode('unicode', $f);
  $f =~ s/(\t+|\n+)//ig;
  
  if( $n =~ m/^\d+$/g && $f =~ m/^\d+$/g ) { # $n and $f must be numeric
    unless( $u eq '%' ){ # Fixes a small problem with '%'
      print OUT "\t$n\t$f\t".fix_chars_in_word($u)."\n";
    }
  }
}


print "\n###### Working...\n";
sleep 1; # Sleep for 1 second, to get that loading feeling...
print "\n###### Done!\n\n";


sub fix_chars_in_word {
    my $word = shift;
    $word =~ s/\xa0/ /g;
    $word =~ s/\x91/'/g;
    $word =~ s/\x92/'/g;
    $word =~ s/\x93/"/g;
    $word =~ s/\x94/"/g;
    $word =~ s/\x97/-/g;
    $word =~ s/\xab/"/g;
    $word =~ s/\xa9//g;
    $word =~ s/\xae//g;

    $word =~ s/\x{2018}/'/g;
    $word =~ s/\x{0085}//g;
    $word =~ s/\x{2019}/'/g;
    $word =~ s/\x{201C}/"/g;
    $word =~ s/\x{201D}/"/g;
    $word =~ s/\x{2022}//g;
    $word =~ s/\x{2013}/-/g;
    $word =~ s/\x{2014}/-/g;
    $word =~ s/\x{2122}//g; 
    return $word ;
}

sub print_help_message {
  print "\n############################################
### Perl Project — LIC.LIG L2 Section A ###
############################################

This is the script that was written for the Perl exam.

Project Members : BOUCHAALA Reda \t 201300005606 \t <bouchaala.reda\@gmail.com>
                  DJELOUEH Mohamed \t 201300005133
                  BEDAR Abdellah \t 201300005506
                  BOUKHARI Mohamed \t 201200006613
                  HAFID Mohamed Lamine   201200006815

-- Usage Example -------------
------------------------------\n
 perl main.pl --dir=\"lookup_directory\" --file=\"my_file.txt\" --depth=15
\n\n-- Script arguments ----------
------------------------------\n
--help OR -h \t\t Display this help message.\n
--dir\t\t\t The directory to traverse looking for the file.\n
--file\t\t\t The file name to look for.\n
--depth\t\t\t Specify the maximaum directory depth to traverse.\n
";
    exit;
}

sub print_missing_args_error {
  print "\n############################################################################\n\n";
  print "\t--dir=\"...\" Option is required.\n\tPlease run this program with -h option to get a usage example. \n";
  print "\ti.e: perl main.pl -h\n\n";
  print "############################################################################\n\n";
}