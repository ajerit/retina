#!/usr/bin/env ruby
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Extensión de las clases del árbol sintáctico para realizar la ejecución del código retina
#
# EL INTERPRETE GENERA UN ARCHIVO .PBM CON LA MATRIZ
# PARA GENERAR UNA IMAGEN, DESCOMENTAR require 'pnm' (LINEA 15, LA GEMA PNM DEBE ESTAR INSTALADA) 
# Y LA INSTRUCCION SAVE_TO_IMG EN EL METODO #RUN DE LA CLASE RETINA (LINEA 46)
#

require_relative 'tabla_exec'
require_relative 'ast'
require 'bigdecimal'
#require 'pnm'

class AST
  # Funcion base para correr
  def run(sym)
    attrs.each do |element|
      unless element.nil?
        element.run(sym)
      end
    end
  end
end

class Retina
  def run
    sym = ExecTabla.new()
    $m = MatrizPBM.new()

    # Añadir funciones predef
    sym.tabla[:home] = { :cuerpo => nil, :params => [] }
    sym.tabla[:openeye] = { :cuerpo => nil, :params => [] }
    sym.tabla[:closeeye] = { :cuerpo => nil, :params => [] }
    sym.tabla[:forward] = { :cuerpo => nil, :params => [:n] }
    sym.tabla[:backward] = { :cuerpo => nil, :params => [:n] }
    sym.tabla[:rotatel] = { :cuerpo => nil, :params => [:n] }
    sym.tabla[:rotater] = { :cuerpo => nil, :params => [:n] }
    sym.tabla[:setposition] = { :cuerpo => nil, :params => [:x, :y] }

    @funciones.prerun(sym)
    @programa.run(sym)
    $m.save_to_file
    #$m.save_to_img
  end
end

class Funciones
  def prerun(sym)
    unless @lista.nil?
      @lista.each do |func|
        func.prerun(sym)
      end
    end
  end
end

class Funcion
  def prerun(sym)
    sym_f = ExecTabla.new(sym)
    @definicion.prerun(sym_f)

    # Recupero el nombre ############
    func = sym_f.find(:func)[:cuerpo]
    #################################

    sym.addFunc(func)
    sym.updateFunc(func, @interior)

    # Recupero los params #############
    params = sym_f.find(:func)[:params]
    ###################################

    sym.addParams(func, params)
    end
end

class Definicion
  def prerun(sym)
    sym.addFunc(:func)
    sym.updateFunc(:func, @ident.ident.texto)

    unless @args.nil?
      params = []
      @args.each do |arg|
        params = arg.prerun(params)
      end
      sym.addParams(:func, params)
    end
  end
end

class Retorno
  def run(sym)
    @e.run(sym)
    # Guardar retorno en tabla
    sym.addVal(:retorno)
    sym.updateVal(:retorno, @e.valor)
  end
end

class Argumento
  def prerun(lista)
    param = @ident.ident.texto
    lista << param.to_sym
    return lista
  end
end

class CuerpoFunc
  def run(sym)
    unless @lista.nil?
      @lista.each do |inst|
        inst.run(sym)
        
        # Se ejecutó un retorno, salimos de la funcion
        break unless sym.find(:retorno).nil?
      end
    end
  end
end

class Programa
  def run(sym)
    @cuerpo.run(sym)
  end
end

class Bloque
  def run(sym)
    sym_h = ExecTabla.new(sym)
    @cabeza.run(sym_h)
    @cuerpo.run(sym_h)
  end
end

class ListaDecl
  def run(sym)
    unless @lista.nil?
      @lista.each do |decl|
        decl.run(sym)
      end
    end
  end
end

class Declaracion
  def run(sym)
    default = nil
    if @tipo.tipo.class == TkBoolean
      default = false
    elsif @tipo.tipo.class == TkNumber
      default = 0
    end

    @lista.each do |var|
      sym.addVal(var.ident.texto)
      sym.updateVal(var.ident.texto, default)
    end

    # Si tiene valor, se lo asignamos.
    unless @val.nil? 
      @val.run(sym)
      sym.updateVal(@lista[0].ident.texto, @val.valor)
    end
  end
end

class Cuerpo
  def run(sym)
    unless @lista.empty?
      @lista.each do |inst|
        inst.run(sym)
      end
    end
  end
end

class Llamada
  attr_reader :valor
  def run(sym)
    sym_f = ExecTabla.new(sym)
    func = sym.find(@ident.ident.texto)

    unless @lista.empty?
      @lista.each do |arg|
        arg.run(sym)
      end

      # Agarramos los valores de los argumentos
      # Y los instroducimos a la tabla de la funcion 
      params = func[:params]
      i=0
      params.each do |var, val|
        sym_f.addVal(var)
        sym_f.updateVal(var, @lista[i].valor)
        i+=1
      end
    end

    case @ident.ident.texto
    when 'home'
      $m.set_pos(500, 500)
    when 'openeye'
      $m.openeye
    when 'closeeye'
      $m.closeeye
    when 'forward'
      $m.forward(sym_f.find(:n)[:val])
    when 'backward'
      $m.backward(sym_f.find(:n)[:val])
    when 'setposition'
      $m.set_pos(sym_f.find(:x)[:val], sym_f.find(:y)[:val])
    when 'rotater'
      $m.rotater(sym_f.find(:n)[:val])
    when 'rotatel'
      $m.rotatel(sym_f.find(:n)[:val])
    else
      func[:cuerpo].run(sym_f)
    end
    
    # Recuperamos el valor de retorno, si lo hay
    retorno = sym_f.find(:retorno)
    unless retorno.nil?
      @valor = retorno[:val]
    end
  end
end

class Asignacion
  def run(sym)
    @val.run(sym)
    sym.updateVal(@ident.ident.texto, @val.valor)
  end
end

class Condicional
  def run(sym)
    @exp.run(sym)
    if @exp.valor
      @cuerpo.run(sym)
    else
      @else.run(sym) unless @else.nil?
    end
  end
end

class While
  def run(sym)
    @exp.run(sym)
    while @exp.valor
      @cuerpo.run(sym)
      @exp.run(sym)
    end
  end
end

class CicloFor
  def run(sym)
    symfor = ExecTabla.new(sym)
    @inicio.run(sym)
    @final.run(sym)
    @step.run(sym)

    raise LimitesCicloError.new(@linea, @col) if @inicio.valor > @final.valor

    symfor.addVal(@contador.ident.texto)
    symfor.updateVal(@contador.ident.texto, @inicio.valor.floor)

    @contador.run(symfor)
    while @contador.valor.floor <= @final.valor.floor
      @cuerpo.run(symfor)
      symfor.updateVal(@contador.ident.texto, @contador.valor + @step.valor)
      @contador.run(symfor)
    end
  end
end

class CicloRepeat
  def run(sym)
    @final.run(sym)
    contador = 1

    while contador <= @final.valor.floor
      @cuerpo.run(sym)
      contador += 1
    end
  end
end

class ES
  def run(sym)
    case @modo.texto
    when 'read'
      tmp = $stdin.gets.chomp
      tmp.match(/\A[[:digit:]]+(\.[[:digit:]]+)?/)

      if (tmp == "true") and (@lista[0].tipo == TkBoolean)
        sym.updateVal(@lista[0].ident.texto, true)
      elsif (tmp == "false") and (@lista[0].tipo == TkBoolean)
        sym.updateVal(@lista[0].ident.texto, false)
      elsif !$&.nil?
        if @lista[0].tipo == TkNumber
          valor = BigDecimal.new(tmp)
          if valor.frac == 0
            valor = valor.to_i
          else
            valor = valor.to_f
          end
          sym.updateVal(@lista[0].ident.texto, valor)
        else
          raise TipoEntradaError.new(@linea, @col)
        end
      else 
        raise TipoEntradaError.new(@linea, @col)
      end

    when 'write'
      @lista.each do |exp|
        exp.run(sym)
        print(exp.valor)
      end
    when 'writeln'
      @lista.each do |exp|
        exp.run(sym)
        puts exp.valor
      end
    end

  end
end

class True
  attr_reader :valor
  def run(sym)
    @valor = true
  end
end

class False
  attr_reader :valor
  def run(sym)
    @valor = false
  end
end

class Variable
  attr_reader :valor
  def run(sym)
    @valor = sym.find(@ident.texto)[:val]
  end
end

class Numero
  attr_reader :valor
  def run(sym)
    @valor = BigDecimal.new(@d.texto.to_s)
    if @valor.frac == 0
      @valor = @valor.to_i
    else
      @valor = @valor.to_f
    end
  end
end 

class Cadena
  attr_reader :valor
  def run(sym)
    @valor = @s.texto.match(/(?<=")(?:\\.|[^"\\])*(?=")/)
  end
end

class Suma
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = @left.valor + @right.valor
  end
end

class Resta
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = @left.valor - @right.valor
  end
end

class Mult
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = @left.valor * @right.valor
  end
end

class DivEntera
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    begin
      @valor = @left.valor.to_i / @right.valor.to_i
    rescue ZeroDivisionError
      raise DivEntreCero.new(@linea, @col)
    end

  end
end

class DivReal
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    begin
      @valor = @left.valor.to_f / @right.valor
    rescue ZeroDivisionError
      raise DivEntreCero.new(@linea, @col)
    end

  end
end

class ModEntero
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = @left.valor.to_i % @right.valor.to_i
  end
end

class ModReal
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = @left.valor % @right.valor
  end
end

class Conjuncion
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor and @right.valor)
  end
end

class Disyuncion
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor or @right.valor)
  end
end

class Mayor
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor > @right.valor)
  end
end

class MayorIgual 
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor >= @right.valor)
  end
end

class Menor
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor < @right.valor)
  end
end

class MenorIgual
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor <= @right.valor)
  end
end

class Igualdad
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor == @right.valor)
  end
end

class Desigualdad
  attr_reader :valor
  def run(sym)
    @left.run(sym)
    @right.run(sym)

    @valor = (@left.valor != @right.valor)
  end
end

class Negacion
  attr_reader :valor
  def run(sym)
    @op.run(sym)
    @valor = (not @op.valor)
  end
end

class Negativo
  attr_reader :valor
  def run(sym)
    @op.run(sym)
    @valor = (- @op.valor)
  end
end