#
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Contiene las deficiones de las clases y expresiones regulares para el lenguaje
# Retina.
# Hace disponible la variable global $tokens con un diccionario de expresiones 
# regulares para que el Lexer pueda usarlas.
#

# Clase base para los tokens
class Lexema
  attr_accessor :col, :linea, :texto

  def initialize(linea, col, texto)
    @linea = linea
    @col = col 
    @texto = texto
  end
end

# Clases para cada tipo de Lexema
class PalabraReservada < Lexema
  def print
    puts "línea #{@linea}, columna #{@col}: palabra reservada \'#{@texto}\'"
  end
end

class TiposDatos < Lexema
  def print
    puts "línea #{@linea}, columna #{@col}: tipo de dato \'#{@texto}\'"
  end
end

class Booleanos < Lexema
  def print
    puts "línea #{@linea}, columna #{@col}: literal booleano \'#{@texto}\'"
  end
end

class Identificadores < Lexema
  def print
    puts "línea #{@linea}, columna #{@col}: identificador \'#{@texto}\'"
  end
end

class Signos < Lexema
  def print
    puts "línea #{@linea}, columna #{@col}: signo \'#{@texto}\'"
  end
end

class LiteralNum < Lexema
  def print
    puts "línea #{@linea}, columna #{@col}: literal numérico \'#{@texto}\'"
  end
end

class Char < Lexema
  def print
    puts "línea #{@linea}, columna #{@col}: cadena de caracteres \'#{@texto}\'"
  end
end

# Deficiones de las expresiones regulares de los tokens del lenguaje
# Palabras Reservadas
palabras = {
  Program:       /\Aprogram\b/,
  Begin:         /\Abegin\b/,
  End:           /\Aend\b/,       
  Not:           /\Anot\b/,       
  Or:            /\Aor\b/,        
  And:           /\Aand\b/,       
  Read:          /\Aread\b/,      
  Write:         /\Awrite\b/,     
  Writeln:       /\Awriteln\b/,    
  With:          /\Awith\b/,      
  Do:            /\Ado\b/,      
  If:            /\Aif\b/,      
  Then:          /\Athen\b/,
  Else:          /\Aelse\b/,                 
  While:         /\Awhile\b/,      
  For:           /\Afor\b/,      
  From:          /\Afrom\b/,     
  To:            /\Ato\b/,
  By:            /\Aby\b/,        
  Repeat:        /\Arepeat\b/,      
  Func:          /\Afunc\b/,      
  Times:         /\Atimes\b/,
  DivEntera:     /\Adiv\b/,                        
  ModEntero:     /\Amod\b/,
  Return:        /\Areturn\b/
}

# Tipos de Dato
tipos = {
  Number:        /\Anumber\b/,    
  Boolean:       /\Aboolean\b/
}

# Literales Booleanos
bools = {
  True:          /\Atrue\b/,
  False:         /\Afalse\b/
}

# Signos
signos = {
  FuncRetorno:   /\A\-\>/,
  Igual:         /\A\=\=/,
  Desigual:      /\A\/\=/,                       
  MayorIgualQue: /\A\>\=/,                        
  MenorIgualQue: /\A\<\=/,
  PuntoYComa:    /\A\;/,                          
  Asignacion:    /\A\=/,                          
  ParentAb:      /\A\(/,                          
  ParentCi:      /\A\)/,                          
  Coma:          /\A\,/,                             
  MayorQue:      /\A\>/,                         
  MenorQue:      /\A\</,                         
  Resta:         /\A\-/,                         
  Suma:          /\A\+/,                        
  Multi:         /\A\*/,                       
  DivExacta:     /\A\//,                         
  ModExacto:     /\A\%/,
  Backslash:     /\A\\/,
  Comillas:      /\A\"/
}

# Identificadores
ids = {      
  #Home:          /\Ahome\b/,      
  #Openeye:       /\Aopeneye\b/,      
  #Closeeye:      /\Acloseeye\b/,      
  #Forward:       /\Aforward\b/,      
  #Backward:      /\Abackward\b/,      
  #Rotatel:       /\Arotatel\b/,     
  #Rotater:       /\Arotater\b/,     
  #Setposition:   /\Asetposition\b/,      
  #Arc:           /\Aarc\b/, 
  Variable:      /\A[[:lower:]][\w]*/
}

# Literal numerico
num = {
  Numero:        /\A[[:digit:]]+(\.[[:digit:]]+)?/       
}

# Cadena de caracteres
char = {
  Cadena:       /\A"(?:\\.|[^"\\])*"/
}

# Creamos clases de forma dinámica para cada elemento de los tipos de Tokens
palabras.each do |sym, reg| 
  Object.const_set("Tk#{sym.to_s}", Class.new(PalabraReservada))
end

tipos.each do |sym, reg| 
  Object.const_set("Tk#{sym.to_s}", Class.new(TiposDatos))
end

bools.each do |sym, reg| 
  Object.const_set("Tk#{sym.to_s}", Class.new(Booleanos))
end

signos.each do |sym, reg| 
  Object.const_set("Tk#{sym.to_s}", Class.new(Signos))
end

ids.each do |sym, reg| 
  Object.const_set("Tk#{sym.to_s}", Class.new(Identificadores))
end

num.each do |sym, reg| 
  Object.const_set("Tk#{sym.to_s}", Class.new(LiteralNum))
end

char.each do |sym, reg| 
  Object.const_set("Tk#{sym.to_s}", Class.new(Char))
end

# Unir todo en orden en una sola variable global para el Lexer
$tokens = palabras.merge(tipos)
$tokens = $tokens.merge(bools)
$tokens = $tokens.merge(char)
$tokens = $tokens.merge(signos) 
$tokens = $tokens.merge(ids)
$tokens = $tokens.merge(num)

