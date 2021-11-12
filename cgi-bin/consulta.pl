#!/usr/bin/perl
use strict;
use warnings;
use CGI;

my $q = CGI->new;
my $codigo = $q->param("codigo");
print $q->header("text/html");
print<<BLOCK;
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Resultados de la Consulta</title>
  </head>
  <body>
    <h1>Resultados de la Consulta:$codigo</h1>
BLOCK

sub recolectarUniversidad {
  my $codigo = $_[0];
  open(IN, "< :encoding(Latin1)", 'Programas de Universidades.csv') or die "No descargo el archivo de datos";
  binmode(IN, ":encoding(Latin1)") || die "can't binmode to encoding Latin1";
  my @arreglo = <IN>;
  close(IN);

  my $size = contarColumnas($arreglo[0]);

  print $size;
  foreach my $linea (@arreglo) {
    
  }
}

sub contarColumnas {
  my $line = $_[0];
  my $counter = 1;
  while($line =~ /^([^\|]+)\|(.+)/) {
    $counter++;
    $line = $2;
  }
  return $counter;
}

sub construirRegExp {
  my $num = $_[0];
  my $s = "^";
  for(my $i = 1; $i < $num; $i++) {
    $s .= '([^\|]+)\|';
  }
  $s .= '([^\|]+)';
  return $s;
}

