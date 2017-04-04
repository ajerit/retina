#!/usr/bin/env ruby
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Extensión de las clases del árbol sintáctico para realizar el análisis de contexto
#

require_relative 'tabla'
require_relative 'ast'

class AST
  # Funcion base para checkear
  def check(sym)
    attrs.each do |element|
      element.check(sym)
    end
  end
end

class Retina
  def check
    # Tabla raiz
    sym = Simbolos.new()

    # Añadir funciones predef
    sym.tabla[:home] = { :token => nil, :tipo => nil, :args => {} }
    sym.tabla[:openeye] = { :token => nil, :tipo => nil, :args => {} }
    sym.tabla[:closeeye] = { :token => nil, :tipo => nil, :args => {} }
    sym.tabla[:forward] = { :token => nil, :tipo => nil, :args => {:a1 => {:tipo => TkNumber} } }
    sym.tabla[:backward] = { :token => nil, :tipo => nil, :args => {:a1 => {:tipo => TkNumber} } }
    sym.tabla[:rotatel] = { :token => nil, :tipo => nil, :args => {:a1 => {:tipo => TkNumber} } }
    sym.tabla[:rotater] = { :token => nil, :tipo => nil, :args => {:a1 => {:tipo => TkNumber} } }
    sym.tabla[:setposition] = { :token => nil, :tipo => nil, :args => {:a1 => {:tipo => TkNumber}, :a2 => {:tipo => TkNumber} } }

    @funciones.check(sym)
    @programa.check(sym)
  end

  def print_alcances(indent="")
    @funciones.print_alcances()
    @programa.print_alcances()
  end
end

class Funciones
  def check(sym)
    unless @lista.nil?
      @lista.each do |func|
        sym_h = Simbolos.new(sym)
        func.check(sym_h)
      end
    end
  end

  def print_alcances(indent="")
    unless @lista.nil?
      @lista.each do |func|
        func.print_alcances()
      end
    end
  end
end

class Funcion
  def check(sym)
    @definicion.check(sym)
    @interior.check(sym)
  end

  def print_alcances(indent="")
    @definicion.print_alcances()
    @interior.print_alcances("   ")
    puts ""
  end
end

class Definicion
  def check(sym)
    @dic_args = {}
    unless @args.nil?
      @args.each do |arg|
        @dic_args = arg.check(sym, @dic_args)
      end
    end

    if @t_retorno.nil?
      tipo = nil
      retorno = true
    else
      tipo = @t_retorno.tipo.class
      retorno = false
    end

    sym.tabla[:func] = {:token => @ident.ident, :tipo => tipo, :retorno? => retorno }
    sym.parent.addFunc(@ident.ident, tipo, @dic_args, sym)
  end

  def print_alcances(indent="")
    puts "#{indent}Alcance func #{@ident.ident.texto}:"
    puts "#{indent}   Variables:"
    unless @dic_args.empty?
      @dic_args.each do |key, tipo|
        puts "      #{key}: #{tipo[:tipo]}"
      end
    else 
      puts "      -"
    end
  end
end

class Retorno
  def check(sym)
    @e.check(sym)
    func = sym.find(:func)

    raise ReturnFueraFuncError.new(@linea, @col) if func.nil?

    if func[:tipo].nil?
      raise NoReturnTipoError.new(@linea, @col)
    else
      unless @e.tipo == func[:tipo]
        raise ReturnTiposError.new(@linea, @col, @e.tipo, func[:tipo])
      end
    end

    # Si tiene retorno definido se hace true para verificar que está la instrucción
    func[:retorno?] = true
  end

  def print_alcances(indent="")
  end
end

class Argumento
  def check(sym, dic_args)
    # Añadir args en la tabla local y en dic_args
    key = @ident.ident.texto.to_sym
    unless dic_args.has_key?(key)
      dic_args[key] = {:token => @ident.ident, :tipo => @tipo.tipo.class}
      sym.addSym(@ident.ident, @tipo.tipo.class)
    else
      raise ParametroYaDecl.new(sym.find(key)[:token], @ident.ident)
    end

    return dic_args
  end
end

class CuerpoFunc
  def check(sym)
    unless @lista.empty?
      @lista.each do |inst|
        inst.check(sym)
      end
    end

    # Error si la funcion tiene retorno definido pero no instruccion return
    raise FaltaReturnError.new(@linea, @col) unless sym.find(:func)[:retorno?]
  end

  def print_alcances(indent="")
    puts "#{indent}Sub-Alcances:"
    unless @lista.empty?
      @lista.each do |inst|
        inst.print_alcances(indent+"   ")
      end
    else
      puts "#{indent}      -"
    end
  end
end

class Programa
  def check(sym)
    @cuerpo.check(sym)
  end

  def print_alcances(indent="")
    puts "Alcance program:"
    puts "   Variables:"
    puts "   Sub-Alcances:"
    @cuerpo.print_alcances(indent+"   ")
  end
end

class Bloque
  def check(sym)
    sym_h = Simbolos.new(sym)
    @cabeza.check(sym_h)
    @cuerpo.check(sym_h)
  end

  def print_alcances(indent="")
    puts "#{indent}Alcance:"
    puts "#{indent}   Variables:"
    @cabeza.print_alcances(indent+"      ")
    puts "#{indent}   Sub-Alcances:"
    @cuerpo.print_alcances(indent+"   ")
  end
end

class ListaDecl
  def check(sym)
    unless @lista.nil?
      @lista.each do |decl|
        decl.check(sym)
      end
    end
  end

  def print_alcances(indent="")
    unless @lista.nil?
      @lista.each do |decl|
        decl.print_alcances(indent)
      end
    end
  end
end

class Declaracion
  def check(sym)
    @lista.each do |var|
      sym.addSym(var.ident, @tipo.tipo.class)
    end
    # Revisar en caso de que sea una expresion, sea valida.
    unless @val.nil? 
      @val.check(sym)
      unless @tipo.tipo.class == @val.tipo
        raise TiposAsignacionError.new(@lista[0].ident, @tipo.tipo.class, @val.tipo)
      end
    end
  end

  def print_alcances(indent="")
    @lista.each do |var|
      puts "#{indent}#{var.ident.texto}: #{@tipo.tipo.class}"
    end
  end
end

class Cuerpo
  def check(sym)
    unless @lista.empty?
      @lista.each do |inst|
        inst.check(sym)
      end
    end
  end

  def print_alcances(indent="")
    unless @lista.empty?
      @lista.each do |inst|
        inst.print_alcances(indent+"   ")  
      end
    end
  end
end

class Llamada
  attr_reader :tipo
  def check(sym)
    key = @ident.ident.texto

    # Revisar cantidad de argumentos
    if sym.isIn?(key)
      func = sym.find(key)
      param = func[:args]
      @tipo = func[:tipo]

      raise NumArgsError.new(@ident.ident, param.length, @lista.length) unless param.length == @lista.length
    else  
      raise FuncNoDeclarada.new(@ident.ident)
    end  

    # Revisar tipos de argumentos
    unless @lista.empty?
      @lista.each do |arg|
        arg.check(sym)
      end

      i = 0      
      param.each do |var, hash|
        unless hash[:tipo] == @lista[i].tipo
          if @lista[i].respond_to?(:ident)
            raise TiposArgsError.new(@lista[i].ident, @lista[i].tipo , hash[:tipo])
          elsif @lista[i].respond_to?(:d)
            raise TiposArgsError.new(@lista[i].d, @lista[i].tipo , hash[:tipo])
          end
        end
        i = i + 1
      end
    end
  end

  def print_alcances(indent="")
  end
end

class Asignacion
  def check(sym)
    txt = @ident.ident.texto

    # Revisar que variable está declarada
    raise VarNoDeclError.new(@ident.ident) unless sym.isIn?(txt)

    # Revisar que tipo de var y de la exp coincidan
    @val.check(sym)
    var = sym.find(txt)

    unless var.fetch(:tipo) == @val.tipo
      raise TiposAsignacionError.new(@ident.ident, var.fetch(:tipo), @val.tipo)
    end
  end

  def print_alcances(indent="")
  end
end

class Condicional
  def check(sym)
    # Condicion debe ser booleana
    @exp.check(sym)

    unless @exp.tipo == TkBoolean
      raise IfNoBooleanoError.new(@linea, @col, @exp.tipo)
    end

    @cuerpo.check(sym)
  end

  def print_alcances(indent="")
  end
end

class While
  def check(sym)
    # Condicion debe ser booleana
    @exp.check(sym)

    unless @exp.tipo == TkBoolean
      raise WhileNoBooleano.new(@linea, @col, @exp.tipo)
    end

    @cuerpo.check(sym)
  end

  def print_alcances(indent="")
    unless @lista.empty?
      @lista.each do |inst|
        inst.print_alcances(indent+"")
      end
    end
  end
end

class CicloFor
  def check(sym)
    sym_c = Simbolos.new(sym)
    sym_c.addSym(@contador.ident, TkNumber)

    @inicio.check(sym)
    @final.check(sym)
    @step.check(sym)

    raise ForNoNumerico.new(@linea, @col) if (@inicio.tipo != TkNumber || @final.tipo != TkNumber || @step.tipo != TkNumber)

    @cuerpo.check(sym_c)
  end

  def print_alcances(indent="")
    puts "#{indent}Alcance for:"
    puts "#{indent}   Variables:"
    puts "#{indent}      #{@contador.ident.texto}: TkNumber"
    puts "#{indent}   Sub-Alcances:"
    @cuerpo.print_alcances(indent+"      ")
  end
end

class CicloRepeat
  def check(sym)
    @final.check(sym)

    unless @final.tipo == TkNumber
      raise RepeatNoNumerico.new(@linea, @col)
    end

    @cuerpo.check(sym)
  end

  def print_alcances(indent="")
  end
end

class ES
  def check(sym)
    case @modo.texto
    when 'read'
      @lista[0].check(sym)
    when 'write'
      @lista.each do |exp|
        exp.check(sym)
      end
    when 'writeln'
      @lista.each do |exp|
        exp.check(sym)
      end
    end
  end

  def print_alcances(indent="")
  end
end

class True
  attr_reader :tipo
  def check(sym)
    @tipo = TkBoolean
  end

  def print_alcances(indent="")
  end
end

class False
  attr_reader :tipo
  def check(sym)
    @tipo = TkBoolean
  end

  def print_alcances(indent="")
  end
end

class Variable
  attr_reader :tipo
  def check(sym)
    if sym.isIn?(@ident.texto)
      @tipo = sym.find(@ident.texto).fetch(:tipo)
    else
      raise VarNoDeclError.new(@ident)
    end
  end

  def print_alcances(indent="")
  end
end

class Numero
  attr_reader :tipo
  def check(sym)
    @tipo = TkNumber
  end

  def print_alcances(indent="")
  end
end 

class Cadena
  attr_reader :tipo
  def check(sym)
    @tipo = TkCadena
  end

  def print_alcances(indent="")
  end
end

class Suma
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorAritmetico.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkNumber
  end

  def print_alcances(indent="")
  end
end

class Resta
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorAritmetico.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkNumber
  end

  def print_alcances(indent="")
  end
end

class Mult
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorAritmetico.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkNumber
  end

  def print_alcances(indent="")
  end
end

class DivEntera
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    # Chequear que ambos son Number
    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorAritmetico.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkNumber
  end

  def print_alcances(indent="")
  end
end

class DivReal
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    # Chequear que ambos son Number
    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorAritmetico.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkNumber
  end 

  def print_alcances(indent="")
  end
end

class ModEntero
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorAritmetico.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkNumber
  end

  def print_alcances(indent="")
  end
end

class ModReal
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorAritmetico.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkNumber
  end

  def print_alcances(indent="")
  end
end

class Conjuncion
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkBoolean && @right.tipo == TkBoolean)
      raise ErrorBooleano.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end
  def print_alcances(indent="")
  end
end

class Disyuncion
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkBoolean && @right.tipo == TkBoolean)
      raise ErrorBooleano.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end 
  def print_alcances(indent="")
  end
end

class Mayor
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorComparacion.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end
  def print_alcances(indent="")
  end
end

class MayorIgual 
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorComparacion.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end
  def print_alcances(indent="")
  end
end

class Menor
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorComparacion.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end 
  def print_alcances(indent="")
  end
end

class MenorIgual
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber)
      raise ErrorComparacion.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end 
    def print_alcances(indent="")
  end
end

class Igualdad
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber or @left.tipo == TkBoolean && @right.tipo == TkBoolean)
      raise ErrorComparacion.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end 
    def print_alcances(indent="")
  end
end

class Desigualdad
  attr_reader :tipo
  def check(sym)
    @left.check(sym)
    @right.check(sym)

    unless (@left.tipo == TkNumber && @right.tipo == TkNumber or @left.tipo == TkBoolean && @right.tipo == TkBoolean)
      raise ErrorComparacion.new(@left.tipo, @right.tipo, @linea, @col)
    end

    @tipo = TkBoolean
  end
    def print_alcances(indent="")
  end
end

class Negacion
  attr_reader :tipo
  def check(sym)
    @op.check(sym)

    unless (@op.tipo == TkBoolean)
      raise ErrorNegacion.new(@linea, @col, @op.tipo)
    end

    @tipo = TkBoolean
  end
    def print_alcances(indent="")
  end
end

class Negativo
  attr_reader :tipo
  def check(sym)
    @op.check(sym)

    unless (@op.tipo == TkNumber)
      raise ErrorNegativo.new(@linea, @col, @op.tipo)
    end

    @tipo = TkNumber
  end
    def print_alcances(indent="")
  end
end