#!/usr/bin/env ruby
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Definición de los diferentes tipos de errores de contexto que pueden haber en Retina
#

class ContextError < RuntimeError; end
class ExecError < RuntimeError; end

class TiposAsignacionError < ContextError
  def initialize(var, val, asig)
    @var = var
    @val = val
    @asig = asig
  end

  def to_s
    @asig = 'vacio' if @asig.nil?

    "[Error] Linea #{@var.linea}, Columna #{@var.col}: #{self.class}\nAsignación de una expresión de tipo '#{@asig}' a una variable de tipo '#{@val}'"
  end
end

class VarYaDeclError < ContextError
  def initialize(declarado, nuevo)
    @d = declarado
    @n = nuevo
  end

  def to_s
    "[Error] Linea #{@n.linea}, Columna #{@n.col}: #{self.class}\nLa variable '#{@n.texto}' ya ha sido declarada en la línea #{@d.linea}, columna #{@d.col}"
  end
end

class VarNoDeclError < ContextError
  def initialize(var)
    @var = var
  end

  def to_s
    "[Error] Linea #{@var.linea}, Columna #{@var.col}: #{self.class}\nLa variable '#{@var.texto}' no ha sido declarada."
  end
end

class IfNoBooleanoError < ContextError
  def initialize(l, c, t)
    @linea = l
    @col = c
    @tipo = t
  end

  def to_s
    "[Error] Linea #{@linea}, Columna #{@col}: #{self.class}\nLa condición de la instrucción 'If' es de tipo '#{@tipo}' y debe ser 'TkBoolean'"
  end
end

class WhileNoBooleano < IfNoBooleanoError
  def to_s
    "[Error] Linea #{@linea}, Columna #{@col}: #{self.class}\nLa condición de la instrucción 'While' es de tipo '#{@tipo}' y debe ser 'TkBoolean'"
  end
end

class ErrorAritmetico < ContextError
  def initialize(l, r, linea, col)
    @t_r = r 
    @t_l = l
    @linea = linea
    @col = col
  end

  def to_s
    "[Error] Linea #{@linea}, Columna #{@col}: #{self.class}\nOperación aritmética con operando izquierdo de tipo '#{@t_l}'' y el derecho de tipo '#{@t_r}'"
  end
end

class ErrorBooleano < ErrorAritmetico
  def to_s
    "[Error] Linea #{@linea}, Columna #{@col}: #{self.class}\nOperación booleana con operando izquierdo de tipo '#{@t_l} y el derecho de tipo '#{@t_r}'"
  end
end

class ErrorComparacion < ErrorAritmetico
  def to_s
    "[Error] Linea #{@linea}, Columna #{@col}: #{self.class}\nOperación de comparación con operando izquierdo de tipo '#{@t_l}' y el derecho de tipo '#{@t_r}'"
  end
end

class ErrorNegacion < ContextError
  def initialize(linea, col, tipo)
    @linea = linea
    @col = col
    @tipo = tipo
  end

  def to_s
    "[Error] Linea #{@linea}, Columna #{@col}: #{self.class}\nOperación booleana [negación] con operando de tipo '#{@tipo}'"
  end
end

class ErrorNegativo < ErrorNegacion
  def to_s
    "[Error] Linea #{@linea}, Columna #{@col}: #{self.class}\nOperación aritmética [negativo] con operando de tipo '#{@tipo}'"
  end
end

class ForNoNumerico < ContextError
  def initialize(l, c)
    @l = l
    @c = c 
  end

  def to_s
    "[Error] Linea #{@l}, Columna #{@c}: #{self.class}\nInicialización de ciclo 'for' con valores no numéricos"
  end
end

class RepeatNoNumerico < ForNoNumerico
  def to_s
    "[Error] Linea #{@l}, Columna #{@c}: #{self.class}\nInicialización de ciclo 'repeat' con valor no numérico"
  end
end

class IOErrorNoString < ContextError
  def initialize(l, c)
    @l = l
    @c = c
  end

  def to_s
    "[Error] Linea #{@l}, Columna #{@c}: #{self.class}\nExpresión en instrucción de salida no es una cadena"
  end
end

class FuncNoDeclarada < ContextError
  def initialize(token)
    @token = token
  end

  def to_s
    "[Error] Linea #{@token.linea}, Columna #{@token.col}: #{self.class}\nLa función '#{@token.texto}' no ha sido declarada"
  end
end

class FuncYaDeclarada < VarYaDeclError
  def to_s
    "[Error] Linea #{@n.linea}, Columna #{@n.col}: #{self.class}\nLa función '#{@n.texto}' ya ha sido declarada en la línea #{@d.linea}, columna #{@d.col}"
  end
end

class ParametroYaDecl < VarYaDeclError
  def to_s
    "[Error] Linea #{@n.linea}, Columna #{@n.col}: #{self.class}\nEl parámetro '#{@n.texto}' ya ha sido declarada en la línea #{@d.linea}, columna #{@d.col}"
  end
end

class NumArgsError < ContextError
  def initialize(token, n_param, n_args)
    @np = n_param
    @na = n_args
    @token = token
  end

  def to_s
    "[Error] Linea #{@token.linea}, Columna #{@token.col}: #{self.class}\nLa llamada a la función '#{@token.texto}' se hizo con #{@na} argumentos, y necesita #{@np}"
  end
end

class TiposArgsError < ContextError
  def initialize(arg, tipo, param)
    @arg = arg
    @param = param
    @tipo = tipo
  end

  def to_s
    "[Error] Linea #{@arg.linea}, Columna #{@arg.col}: #{self.class}\nArgumento es de tipo '#{@tipo}' pero el parámetro definido es de tipo '#{@param}'"
  end
end


class ReturnTiposError < ContextError
  def initialize(l, c, exp, param)
    @l = l
    @c = c
    @exp = exp
    @param = param
  end

  def to_s
    "[Error] Linea #{@l}, Columna #{@c}: #{self.class}\nRetorno de la función es de tipo '#{@param}' y se intenta retornar un tipo '#{@exp}'"
  end
end

class NoReturnTipoError < ContextError
  def initialize(l, c)
    @l = l
    @c = c
  end

  def to_s
    "[Error] Linea #{@l}, Columna #{@c}: #{self.class}\nSe intenta hacer retorno cuando la función no tiene tipo de retorno definido"
  end
end

class FaltaReturnError < ContextError
  def initialize(l, c)
    @l = l
    @c = c
  end

  def to_s
    "[Error] Linea #{@l}, Columna #{@c}: #{self.class}\nFunción con tipo de retorno definido no tiene instrucción 'return'"
  end
end

class ReturnFueraFuncError < NoReturnTipoError
  def initialize(l, c)
    @l = l
    @c = c
  end

  def to_s
    "[Error] Linea #{@l}, Columna #{@c}: #{self.class}\nSe intenta hacer retorno fuera de una función"
  end
end

class DivEntreCero < ExecError
  def initialize(l, c)
    @l = l
    @c = c
  end
  def to_s
    "<Error> Línea #{@l}, Columna #{@c}: #{self.class}\nDivisión entre cero"
  end
end

class TipoEntradaError < ExecError
  def initialize(l, c)
    @l = l
    @c = c
  end

  def to_s
    "<Error> Linea #{@l}, Columna #{@c}: #{self.class}\nValor de entrada no coincide con el tipo de la variable"
  end
end

class LimitesCicloError < ExecError
  def initialize(l, c)
    @l = l
    @c = c
  end

  def to_s
    "<Error> Linea #{@l}, Columna #{@c}: #{self.class}\nLos límites del ciclo no son válidos"
  end
end



class SyntacticError < RuntimeError
    attr_reader :token
    def initialize(tok)
        @token = tok
    end

    def to_s
        "Linea <#{@token.linea}>, columna <#{@token.col}>: error sintáctico cerca del token: '#{@token.texto}'"   
    end
end

class LexError < RuntimeError
  def initialize(linea, col, texto)
    @linea = linea
    @col = col 
    @texto = texto
  end

  def print
    puts "línea #{@linea}, columna #{@col}: lexema inesperado \'#{@texto}\'"
  end
end