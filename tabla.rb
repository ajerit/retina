#!/usr/bin/env ruby
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Definición de la tabla de símbolos usada en el análisis de contexto
#

require_relative 'errores'

class Simbolos
  attr_reader :parent, :tabla
  def initialize(parent=nil)
      @tabla = {}
      @parent = parent
  end

  # Añadir identificador y su tipo en la tabla
  def addSym(token, tipo)
    key = token.texto.to_sym
    if isInCurrent?(key)
      raise VarYaDeclError.new(find(key)[:token], token)
    else
      #raise FuncYaDeclarada.new(find(key)[:token], token) if funcDef?(key) 
      @tabla[key] = { :token => token, :tipo => tipo }
    end
  end

  # Añadir función y sus argumentos en la tabla
  def addFunc(token, tipo, args, tabla)
    key = token.texto.to_sym
    if isInCurrent?(key)
      raise FuncYaDeclarada.new(find(key)[:token], token)
    else  
      @tabla[key] = { :token => token, :tipo => tipo, :args => args, :tabla => tabla }
    end
  end

  # Retorna la entrada más inmediata del simbolo a buscar
  def find(ident)
    key = ident.to_sym
    if @tabla.has_key?(key)
      return @tabla.fetch(key)
    elsif !@parent.nil?
      return @parent.find(key)
    else
      return nil
    end
  end

  # Revisa especificamente si un identificador ya esta definido como funcion
  def funcDef?(ident)
    key = ident.to_sym
    return @parent.nil? ? @tabla.has_key?(key) : @parent.funcDef?(key)
  end

  # Revisa todas las tablas del programa
  def isIn?(ident)
    key = ident.to_sym
    return @parent.nil? ? @tabla.has_key?(key) : (@parent.isIn?(key) or @tabla.has_key?(key))
  end

  # Revisa solo la tabla actual
  def isInCurrent?(ident)
    key = ident.to_sym
    return @tabla.has_key?(key)
  end

  # Revisa todos los padres, no la actual
  def isInParent?(ident)
    key = ident.to_sym
    return @parent.isIn?(key)
  end

  # Imprimir contenidos
  def print_t
    @tabla.select do |k, v|
      puts "#{k} => #{v}"
    end
  end

end
