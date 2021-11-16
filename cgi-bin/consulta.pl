#!/usr/bin/perl
use strict;
use warnings;
use CGI;

my $q = CGI->new;
my $codigo = $q->param("codigo");

print $q->header(
  -type => "text/html",
  -charset => "utf-8"
);
print<<HTML;
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Resultados de la Consulta</title>
    <link rel="stylesheet" href="../css/estilos.css">
  </head>
  <body>
    <h1 class="titulo">Resultados de la Consulta</h1>
HTML

#Aplicación de las Subrutinas
my %universidades = recolectarUniversidad($codigo);

#Mostramos la Información Recolectada en Forma de una Tabla
print<<HTML;
<table>
  <tr>
    <th>Universidad Encontrada</th>
    <th>Estado de Licenciamiento</th>
  </tr>
HTML
mostrarArreglo(%universidades);
print "</table>";

sub mostrarArreglo {
  my %unis = @_;
  foreach my $universidad (keys %unis) {
    print "<tr>\n";
    print "<td>$universidad</td>\n";
    print "<td>$unis{$universidad}</td>\n";
    print "</tr>\n";
  } 
}

#Se imprime la cola del texto HTML
print<<HTML;
    <br>
    Ingrese <a href="../form.html">aqui</a> para realizar otra consulta
    <br>
    <br>
  </body>
</html>
HTML

sub recolectarUniversidad {
  my $codigo = $_[0];
  open(IN, "< :encoding(Latin1)", 'Programas de Universidades.csv') or die "No descargo el archivo de datos";
  binmode(IN, ":encoding(Latin1)") || die "can't binmode to encoding Latin1";
  my @arreglo = <IN>;
  close(IN);

  my $size = contarColumnas($arreglo[0]);
  my $patter = construirRegExp($size);

  my %unis = ();

  foreach my $linea (@arreglo) {
    if($linea =~ /$patter/) {
      my $entidad = $1;
      my $universidad = $2;
      my $estado = $4;
      if($entidad eq $codigo) {
        $unis{$universidad} = $estado;      
        last;
      }
    }      
  }
  return %unis;
}

sub contarCarrerasPosgrado {
  my $codigo = $_[0];
}

#Subrutina que cuenta el Número de Columnas del Encabezado
sub contarColumnas {
  my $line = $_[0];
  my $counter = 1;
  while($line =~ /^([^\|]+)\|(.+)/) {
    $counter++;
    $line = $2;
  }
  return $counter;
}

#Subrutina que construye la Expresión Regular según Extensión
sub construirRegExp {
  my $num = $_[0];
  my $s = "^";
  for(my $i = 1; $i < $num; $i++) {
    $s .= '([^\|]+)\|';
  }
  $s .= '([^\|]+)';
  return $s;
}

