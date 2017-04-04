#!/usr/bin/env ruby
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Definicion de las clases del Arbol Sintactico Abstracto (AST).
# La clase base es tomada del ejemplo de la calculadora:
# (https://github.com/dvdalilue/retina/blob/master/etapa2/ejemplo_ruby/calculator_ast.rb)
# y se modifica en las subclases que lo requieran.
#

class AST
  def print_ast indent=""
    puts "#{indent}#{self.class}:"

    attrs.each do |a|
        a.print_ast indent + "   " if a.respond_to? :print_ast
    end
  end

  def attrs
    instance_variables.map do |a|
        instance_variable_get a
    end
  end
end

class Retina < AST
  def initialize(func, prog)
    @funciones = func
    @programa = prog
  end
end

class Funciones < AST 
  def initialize(l)
    @lista = l
  end

  def print_ast indent=""
      puts "#{indent}#{self.class}:"

      if !@lista.nil?
        @lista.each do |a|
            a.print_ast indent + "   " if a.respond_to? :print_ast
        end
      else
        puts "#{indent}   -"
      end
  end
end

class Funcion < AST
  def initialize(d, c)
    @definicion = d
    @interior = c
  end
end

class Llamada < AST
  def initialize(i, l=[])
    @ident = i
    @lista = l
  end

  def print_ast indent=""
    puts "#{indent}Llamada a función:"
    @ident.print_ast indent + "   "
    puts "#{indent}Parámetros:"
    if @lista.empty?
      puts "#{indent}   -"
    else
      @lista.each do |a|
          a.print_ast indent + "   " #if !a.respond_to? :print_ast
      end
    end
  end
end

class Definicion < AST
  def initialize(id, args, r)
    @ident = id
    @args = args
    @t_retorno = r
  end

  def print_ast indent=""
    puts "#{indent}#{self.class}:"
    @ident.print_ast(indent+"   ")
    indent+="   "
    puts "#{indent}Lista Argumentos:"
    if !@args.nil?
      @args.each do |a|
          a.print_ast indent + "   " if a.respond_to? :print_ast
      end
    else
      puts "#{indent}   -"
    end
    puts "#{indent}Retorno:"
    @t_retorno.print_ast(indent+"   ") if !@t_retorno.nil?
    puts "#{indent}   -" if @t_retorno.nil?
  end
end

class Argumento < AST
  def initialize(t, i)
    @tipo = t
    @ident = i
  end
end

class Programa < AST
  def initialize(c)
    @cuerpo = c
  end
end

class Bloque < AST
  def initialize(d, c)
    @cabeza = d
    @cuerpo = c
  end
end

class CuerpoFunc < AST 
  attr_reader :lista
  def initialize(l)
    @lista = l
    @linea = 0
    @col = 0
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end
  
  def print_ast indent=""
      puts "#{indent}Cuerpo Función:"
      
      unless @lista.nil?
        @lista.each do |a|
            a.print_ast indent + "   " if a.respond_to? :print_ast
        end
      end
  end
end

class ListaDecl < AST
  def initialize(l)
    @lista = l
  end

  def print_ast indent=""
      puts "#{indent}Declaraciones:"

      if !@lista.nil?
        @lista.each do |a|
            a.print_ast indent + "   " #if !a.respond_to? :print_ast
        end
      else 
        puts "#{indent}   -"
      end

  end
end

class Declaracion < AST
  def initialize(t, l, v)
    @tipo = t
    @lista = l
    @val = v
  end

  def print_ast indent = ""
      puts "#{indent}#{self.class}: "
      indent += "   "
      puts "#{indent}Lado Izquierdo: "
      @tipo.print_ast indent + "   "
      @lista.each do |a|
          a.print_ast indent + "   " #if !a.respond_to? :print_ast
      end
      puts "#{indent}Lado Derecho: "
      @val.print_ast indent + "   " if !@val.nil?
      puts "#{indent}   -" if @val.nil?

  end
end

class Cuerpo < AST
  def initialize(l)
    @lista = l
  end

  def print_ast indent=""
      puts "#{indent}Instrucciones:"

      unless @lista.empty?
        @lista.each do |a|
          a.print_ast indent + "   " if a.respond_to? :print_ast
        end
      else
        puts "#{indent}   -"
      end
  end
end

class Asignacion < AST
  def initialize(i, v)
    @ident = i
    @val = v
  end

  def print_ast indent = ""
      puts "#{indent}#{self.class}: "
      indent += "   "
      puts "#{indent}Lado Izquierdo: "
      @ident.print_ast indent + "   "
      puts "#{indent}Lado Derecho: "
      @val.print_ast indent + "   "
  end
end

class Tipo < AST
  attr_reader :tipo
  def initialize(t)
    @tipo = t
  end

  def print_ast indent = ""
      puts "#{indent}#{self.class}: "
      indent += "   "
      puts "#{indent}Nombre: '#{@tipo.texto}'"
  end
end

class Condicional < AST
  def initialize(e, l, le)
    @exp = e
    @cuerpo = l
    @else = le
    @linea = 0
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end

  def print_ast indent=""
      puts "#{indent}#{self.class}:"
      indent += "   "
      puts "#{indent}Condición:"
      @exp.print_ast indent + "   "
      puts "#{indent}Acción:"
      @cuerpo.print_ast indent + "   " if a.respond_to? :print_ast

      if !@else.nil?
        puts "#{indent}Else:"
        @else.print_ast indent + "   " #if a.respond_to? :print_ast
      end
  end
end

class While < AST
  def initialize(e, l)
    @exp = e
    @cuerpo = l
    @linea = 0
    @col = 0
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end

  def print_ast indent=""
      puts "#{indent}Iteración Indeterminada:"
      indent += "   "
      puts "#{indent}Condición:"
      @exp.print_ast indent + "   "
      puts "#{indent}Acción:"
      @cuerpo.print_ast(indent + "   ") if a.respond_to? :print_ast

  end
end


class CicloFor < AST
  def initialize(c, i, f, l, s)
    @contador = c
    @inicio = i
    @final = f 
    @step = s
    @cuerpo = l
    @linea = 0
    @col = 0
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end

  def print_ast indent=""
    puts "#{indent}Iteración Determinada:"
    indent += "   "
    puts "#{indent}Contador:"
    @contador.print_ast indent + "   "
    puts "#{indent}Inicio:"
    @inicio.print_ast indent + "   "
    puts "#{indent}Final:"
    @final.print_ast indent + "   "
    puts "#{indent}Incremento:"
    @step.print_ast indent + "   "
    puts "#{indent}Acción:"
    @cuerpo.print_ast indent + "   " if a.respond_to? :print_ast
  end
end

class CicloRepeat < AST
  def initialize(f, l)
    @final = f 
    @cuerpo = l
    @linea = 0
    @col = 0
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end

  def print_ast indent=""
    puts "#{indent}Iteración Repeat:"
    indent += "   "
    puts "#{indent}Final:"
    @final.print_ast indent + "   "
    puts "#{indent}Acción:"
    @cuerpo.print_ast indent + "   " if a.respond_to? :print_ast

  end
end

class ES < AST
  def initialize(m, l)
    @modo = m
    @lista = l
    @linea = 0
    @col = 0
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end

  def print_ast indent = ""
    case @modo.texto
    when 'read'
      puts "#{indent}Lectura estándar:"
    when 'write'
      puts "#{indent}Salida estándar:"
    when 'writeln'
      puts "#{indent}Salida estándar con salto:"
    end

    @lista.each do |a|
      a.print_ast indent + "   " if a.respond_to? :print_ast
    end
  end
end

class Retorno < AST
  def initialize(e)
    @e = e
    @linea = 0
    @col = 0
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end

end

class True < AST
  attr_reader :ident
  def initialize(i)
    @ident = i
  end

  def print_ast indent = ""
      puts "#{indent}Literal booleano:"
      indent += "   "
      puts "#{indent}Valor: True"
  end
end

class False < AST
  attr_reader :ident
  def initialize(i)
    @ident = i
  end

  def print_ast indent = ""
      puts "#{indent}Literal booleano:"
      indent += "   "
      puts "#{indent}Valor: False"
  end
end

class Variable < AST
  attr_reader :ident
  def initialize(i)
    @ident = i
  end

  def print_ast indent = ""
      puts "#{indent}Identificador:"
      indent += "   "
      puts "#{indent}Nombre: '#{@ident.texto}'"
  end
end

class IdReservado < AST
  attr_reader :ident
  def initialize(i)
    @ident = i
  end

  def print_ast indent = ""
      puts "#{indent}Identificador reservado:"
      indent += "   "
      puts "#{indent}Nombre: '#{@ident.texto}'"
  end
end

class Numero < AST
  attr_reader :d 
  def initialize(d)
    @d = d
  end

  def print_ast indent = ""
    puts "#{indent}Literal numérico:"
    indent += "   "
    puts  "#{indent}Valor: '#{@d.texto}'"
  end
end

class Cadena < AST
  def initialize(s)
    @s = s
  end

  def print_ast indent = ""
    puts "#{indent}Cadena de caracteres:"
    indent += "   "
    puts  "#{indent}Texto: #{@s.texto}"
  end
end

class BinOp < AST
  def initialize(l, r)
    @left = l
    @right = r 
    @linea = 0
    @col = 0
  end

  def print_ast indent = ""
      puts "#{indent}#{self.class}: "
      indent += "   "
      puts "#{indent}Lado Izquierdo: "
      @left.print_ast indent + "   "
      puts "#{indent}Lado Derecho: "
      @right.print_ast indent + "   "
  end

  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end
end

class UnOp < AST
  def initialize(op)
    @op = op
    @linea = 0
    @col = 0
  end


  def set_linea(n)
    @linea = n
    return self
  end

  def set_col(n)
    @col = n
    return self
  end
end

class Suma < BinOp; end
class Resta < BinOp; end
class Mult < BinOp; end
class DivEntera < BinOp; end
class DivReal < BinOp; end
class ModEntero < BinOp; end
class ModReal < BinOp; end
class Conjuncion < BinOp; end
class Disyuncion < BinOp; end
class Mayor < BinOp; end
class MayorIgual < BinOp; end
class Menor < BinOp; end
class MenorIgual < BinOp; end
class Igualdad < BinOp; end
class Desigualdad < BinOp; end

class Negacion < UnOp; end
class Negativo < UnOp; end