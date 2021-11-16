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
    <style>
      * {
        font-family: Arial, Helvetica, sans-serif;
      }
      h2 {
        text-align: left;
        color: #c1121f;
      }
    </style>
  </head>
  <body>
    <h1 class="titulo">Resultados de la Consulta</h1>
HTML

#Realizamos la aplicación de las Subrutinas
mostrarDatosUniversidad($codigo);

#Se imprime la cola del texto HTML
print<<HTML;
    <br>
    Ingrese <a href="../form.html">aqui</a> para realizar otra consulta
    <br>
    <br>
  </body>
</html>
HTML

#Subrutina que muestra la Información Esencial de la Consulta
sub mostrarDatosUniversidad {
  my $codigo = $_[0];
  my %universidad = recolectarDatosUniversidad($codigo);
    
  print "<table>\n";
  print "<tr>\n";
  print "<th>Universidad Encontrada</th>\n";
  print "<th>Estado Licenciamiento</th>\n";
  print "<th>Tipo Gestión</th>\n";
  print "<th>Numero de Carreras Pregrado</th>\n";
  print "<th>Numero de Carreras Posgrado</th>\n";
  print "<th>Cantidad de Carreras</th>\n";
  print "</tr>\n";
  
  print "<tr>\n";
  print "<td>" . $universidad{"nombre"} . "</td>\n"; 
  print "<td>" . $universidad{"tipoGestion"} . "</td>\n"; 
  print "<td>" . $universidad{"estadoLicenciamiento"} . "</td>\n";
  print "<td>" . $universidad{"numCarrerasPregrado"} . "</td>\n"; 
  print "<td>" . $universidad{"numCarrerasPosgrado"} . "</td>\n"; 
  print "<td>" . $universidad{"cantidadCarreras"} . "</td>\n"; 
  print "</tr>\n";
  print "</table>\n";

  print "<h2>Carreras de Pregrado:</h2>\n";
  mostrarCarrerasPorTipo($codigo, "PREGRADO");
  print "<h2>Carreras de Posgrado:</h2>\n";
  mostrarCarrerasPorTipo($codigo, "POSGRADO");
}

#Subrutina que muestra las Carreras según Tipo Nivel Académico
sub mostrarCarrerasPorTipo {
  my $codigo = $_[0];
  my $tipo = $_[1];
  my @carreras = extraerCarrerasPorTipo($codigo, $tipo);

  print "<ul>\n";
  foreach my $carrera (@carreras) {
    print "<li>$carrera</li>\n";
  }
  print "</ul>\n";
}

#Subrutina que recolecta en un Arreglo Asociativo los diferentes datos
#relacionados a la Universidad de Consulta
sub recolectarDatosUniversidad {
  my $codigo = $_[0];
  open(IN, "< :encoding(Latin1)", 'Programas de Universidades.csv') or die "No descargo el archivo de datos";
  binmode(IN, ":encoding(Latin1)") || die "can't binmode to encoding Latin1";
  my @arreglo = <IN>;
  close(IN);

  my $size = contarColumnas($arreglo[0]);
  my $pattern = construirRegExp($size);

  my %universidad = ();

  foreach my $linea (@arreglo) {
    if($linea =~ /$pattern/) {
      my $codigoEntidad = $1;
      my $nombre = $2;
      my $tipoGestion = $3;
      my $estadoLicenciamiento = $4;
      if($codigoEntidad eq $codigo) {
        $universidad{"nombre"} = $nombre;
        $universidad{"tipoGestion"} = $tipoGestion;
        $universidad{"estadoLicenciamiento"} = $estadoLicenciamiento;
        $universidad{"numCarrerasPregrado"} = contarCarrerasPorTipo($codigo, "PREGRADO");
        $universidad{"numCarrerasPosgrado"} = contarCarrerasPorTipo($codigo, "POSGRADO");
        $universidad{"cantidadCarreras"} = $universidad{"numCarrerasPregrado"} + $universidad{"numCarrerasPosgrado"};
        last;
      }
    }      
  }
  return %universidad;
}

#Subrutina que Extrae en un Array de Strings las Carreras Profesionales que tiene una Universidad según Tipo
sub extraerCarrerasPorTipo {
  my $codigo = $_[0];
  my $tipo = $_[1];
  my @carreras;
  #Leyendo todas las líneas del Archivo
  open(IN, "< :encoding(Latin1)", "Programas de Universidades.csv") or die "can't binmode to encoding Latin1";
  binmode(IN, ":encoding(Latin1)") || die "can't binmode to encoding Latin1";
  my @arreglo = <IN>;
  close(IN);

  my $size = contarColumnas($arreglo[0]);
  my $pattern = construirRegExp($size);

  foreach my $linea (@arreglo) {
    if($linea =~ /$pattern/) {
      my $codigoEntidad = $1;
      my $tipoNivelAcademico = $18;
      my $denominacionPrograma = $17;
      if($codigoEntidad eq $codigo) {
        if($tipoNivelAcademico eq $tipo) {
          push(@carreras, $denominacionPrograma);
        }
      }
    }
  }
  return @carreras;
}

#Subrutina que Cuenta las Carreras por Tipo Nivel Académico
sub contarCarrerasPorTipo {
  my $codigo = $_[0];
  my $tipo = $_[1];
  #Leyendo todas las líneas del Archivo
  open(IN, "< :encoding(Latin1)", "Programas de Universidades.csv") or die "can't binmode to encoding Latin1";
  binmode(IN, ":encoding(Latin1)") || die "can't binmode to encoding Latin1";
  my @arreglo = <IN>;
  close(IN);

  my $size = contarColumnas($arreglo[0]);
  my $pattern = construirRegExp($size);
  my $counter = 0;

  foreach my $linea (@arreglo) {
    if($linea =~ /$pattern/) {
      my $codigoEntidad = $1;
      my $tipoNivelAcademico = $18;
      if($codigoEntidad eq $codigo) {
        if($tipoNivelAcademico eq $tipo) {
          $counter++;
        }
      }
    }
  }
  return $counter;
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

