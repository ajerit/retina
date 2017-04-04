#!/usr/bin/env ruby
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Definicion de la gramática de Retina para Racc
#

class RetinaParser

  token 'program' 'end' 'not' 'or' 'and' 'read' 'write' 'writeln' 'with' 'do' 'if' 'then'
        'else' 'while' 'for' 'from' 'to' 'repeat' 'func' 'times' 'div' 'mod' 'number' 
        'boolean' 'true' 'false' '->' '==' '/=' '>=' '<=' ';' '=' '(' ')' ',' '>' '<' '-' 
        '+' '*' '/' '%' 'home' 'openeye' 'closeeye' 'rotatel' 'rotater' 'forward' 'backward' 
        'arc' 'setposition' 'var' 'num' 'str' '->' 'begin' 'return' 'by'

  prechigh
    right 'not' UMINUS
    left '*' '/' '%' 'mod' 'div'
    left '+' '-'
    left '<' '>' '<=' '>=' '==' '/='
    left 'and'
    left 'or'
    left '='
    right 'else' 'then'
  preclow

  convert
    'program'       'TkProgram'
    'begin'         'TkBegin'
    'end'           'TkEnd'
    'return'        'TkReturn'
    'not'           'TkNot'     
    'or'            'TkOr'        
    'and'           'TkAnd' 
    'read'          'TkRead'   
    'write'         'TkWrite'   
    'writeln'       'TkWriteln' 
    'with'          'TkWith'   
    'do'            'TkDo'     
    'if'            'TkIf'    
    'then'          'TkThen'
    'else'          'TkElse'   
    'while'         'TkWhile'     
    'for'           'TkFor'      
    'from'          'TkFrom'    
    'to'            'TkTo'
    'by'            'TkBy'   
    'repeat'        'TkRepeat'    
    'func'          'TkFunc'     
    'times'         'TkTimes'
    'div'           'TkDivEntera'                        
    'mod'           'TkModEntero'
    'number'        'TkNumber'    
    'boolean'       'TkBoolean'
    'true'          'TkTrue'
    'false'         'TkFalse'
    '=='            'TkIgual'
    '/='            'TkDesigual'                      
    '>='            'TkMayorIgualQue'                        
    '<='            'TkMenorIgualQue'
    ';'             'TkPuntoYComa'                 
    '='             'TkAsignacion'                    
    '('             'TkParentAb'                    
    ')'             'TkParentCi'                      
    ','             'TkComa'                         
    '>'             'TkMayorQue'                         
    '<'             'TkMenorQue'                     
    '-'             'TkResta'                     
    '+'             'TkSuma'                        
    '*'             'TkMulti'                       
    '/'             'TkDivExacta'                         
    '%'             'TkModExacto'
    '->'            'TkFuncRetorno'
    #'home'          'TkHome'     
    #'openeye'       'TkOpeneye'    
    #'closeeye'      'TkCloseeye'
    #'forward'       'TkForward'      
    #'backward'      'TkBackward'     
    #'rotatel'       'TkRotatel'   
    #'rotater'       'TkRotater'     
    #'setposition'   'TkSetposition'     
    'var'           'TkVariable'
    'num'           'TkNumero'    
    'str'           'TkCadena'
end

start Retina
  rule
    # Raiz
    Retina: Funciones Programa                                              { result = Retina.new(val[0], val[1]) }
          ;

    # Declaraciones de funciones
    Funciones:                                                              { result = Funciones.new(val[0]) }
             | ListaFunciones                                               { result = Funciones.new(val[0]) }
             ;

    ListaFunciones: Funcion                                                 { result = [val[0]] }
                  | Funcion ListaFunciones                                  { result = [val[0]] + val[1] }
                  ;

    Funcion: Definicion Interior                                            { result = Funcion.new(val[0], val[1]) }
           ;

    Definicion: 'func' 'var' '(' ')'                                        { result = Definicion.new(Variable.new(val[1]), nil, nil) }
              | 'func' 'var' '(' ')' '->' Tipo                              { result = Definicion.new(Variable.new(val[1]), nil, val[5]) }
              | 'func' 'var' '(' ListaArg ')'                               { result = Definicion.new(Variable.new(val[1]), val[3], nil) }
              | 'func' 'var' '(' ListaArg ')' '->' Tipo                     { result = Definicion.new(Variable.new(val[1]), val[3], val[6]) }
              ;

    ListaArg: Argumento                                                     { result = [val[0]] }
            | Argumento ',' ListaArg                                        { result = [val[0]] + val[2] }
            ;

    Argumento: Tipo 'var'                                                   { result = Argumento.new(val[0], Variable.new(val[1])) }
             ;

    # NUEVO
    Interior: 'begin' ListaInst 'end' ';'                                   { result = CuerpoFunc.new(val[1]).set_linea(val[2].linea).set_col(val[2].col) }

    # Programa
    Programa: 'program' Cuerpo 'end' ';'                                    { result = Programa.new(val[1]) }
            ;

    # Declaraciones de variables al inicio del bloque
    Cabeza:                                                                 { result = ListaDecl.new(nil) }
          | ListaDecl                                                       { result = ListaDecl.new(val[0]) }
          ;

    ListaDecl: Declaracion ';'                                              { result = [val[0]] }
             | Declaracion ';' ListaDecl                                    { result = [val[0]] + val[2] }
             ;

    Declaracion: Tipo ListaVar                                              { result = Declaracion.new(val[0], val[1], nil)}
               | Tipo 'var' '=' Exp                                         { result = Declaracion.new(val[0], [Variable.new(val[1])], val[3]) }
               ;

    ListaVar: 'var'                                                         { result = [Variable.new(val[0])] }
            | 'var' ',' ListaVar                                            { result = [Variable.new(val[0])] + val[2] }
            ;

    Tipo: 'boolean'                                                         { result = Tipo.new(val[0]) }
        | 'number'                                                          { result = Tipo.new(val[0]) }
        ;  

    # Instrucciones
    Cuerpo:                                                                 { result = Cuerpo.new([]) }
          | ListaInst                                                       { result = Cuerpo.new(val[0]) }
          ;

    ListaInst: Instr ';'                                                    { result = [val[0]] }
             | Instr ';' ListaInst                                          { result = [val[0]] + val[2] }
             ;

    Instr: 'var' '=' Exp                                                    { result = Asignacion.new(Variable.new(val[0]), val[2]) }
        | Condicional                                                       { result = val[0] }
        | 'while' Exp 'do' Cuerpo 'end'                                     { result = While.new(val[1], val[3]).set_linea(val[0].linea).set_col(val[0].col)}
        | CicloFor                                                          { result = val[0] }
        | 'repeat' Exp 'times' Cuerpo 'end'                                 { result = CicloRepeat.new(val[1], val[3]).set_linea(val[0].linea).set_col(val[0].col) }
        | BloqueAnidado                                                     { result = val[0] }
        | IO                                                                { result = val[0] }
        | Llamada                                                           { result = val[0] }
        | 'return' Exp                                                      { result = Retorno.new(val[1]).set_linea(val[0].linea).set_col(val[0].col) }
        ;

    BloqueAnidado: 'with' Cabeza 'do' Cuerpo 'end'                          { result = Bloque.new(val[1], val[3]) }

    Condicional: 'if' Exp 'then' Cuerpo 'end'                               { result = Condicional.new(val[1], val[3], nil).set_linea(val[0].linea).set_col(val[0].col) }
               | 'if' Exp 'then' Cuerpo 'else' Cuerpo 'end'                 { result = Condicional.new(val[1], val[3], val[5]).set_linea(val[0].linea).set_col(val[0].col) }
               ;

    CicloFor: 'for' 'var' 'from' Exp 'to' Exp 'do' Cuerpo 'end'             { result = CicloFor.new(Variable.new(val[1]), val[3], val[5], val[7], Numero.new(TkNumero.new(1, 1, 1))).set_linea(val[0].linea).set_col(val[0].col) }
            | 'for' 'var' 'from' Exp 'to' Exp 'by' Exp 'do' Cuerpo 'end'    { result = CicloFor.new(Variable.new(val[1]), val[3], val[5], val[9], val[7]).set_linea(val[0].linea).set_col(val[0].col) }

    # Entrada y Salida
    IO: 'read' 'var'                                                        { result = ES.new(val[0], [Variable.new(val[1])]).set_linea(val[0].linea).set_col(val[0].col) }
      | 'write' ListaStr                                                    { result = ES.new(val[0], val[1]).set_linea(val[0].linea).set_col(val[0].col) }
      | 'writeln' ListaStr                                                  { result = ES.new(val[0], val[1]).set_linea(val[0].linea).set_col(val[0].col) }
      ;
 
    ListaStr: Exp                                                           { result = [val[0]] }
            | Exp ',' ListaStr                                              { result = [val[0]] + val[2] }
            ;

    Llamada: 'var' '(' ')'                                                  { result = Llamada.new(Variable.new(val[0])) }
       | 'var' '(' ListaParam ')'                                           { result = Llamada.new(Variable.new(val[0]), val[2]) }
       #| 'home' '(' ')'                                                     { result = Llamada.new(IdReservado.new(val[0])) }
       #| 'openeye' '(' ')'                                                  { result = Llamada.new(IdReservado.new(val[0])) }
       #| 'closeeye' '(' ')'                                                 { result = Llamada.new(IdReservado.new(val[0])) }
       #| 'forward' '(' Exp ')'                                              { result = Llamada.new(IdReservado.new(val[0]), [val[2]]) }
       #| 'backward' '(' Exp ')'                                             { result = Llamada.new(IdReservado.new(val[0]), [val[2]]) }
       #| 'rotatel' '(' Exp ')'                                              { result = Llamada.new(IdReservado.new(val[0]), [val[2]]) }
       #| 'rotater' '(' Exp ')'                                              { result = Llamada.new(IdReservado.new(val[0]), [val[2]]) }
       #| 'setposition' '(' Exp ',' Exp ')'                                  { result = Llamada.new(IdReservado.new(val[0]), [val[2], val[4]]) }

    ListaParam: Exp                                                         { result = [val[0]] }
              | Exp ',' ListaParam                                          { result = [val[0]] + val[2] } 
              ; 

    # Expresiones arit y bool del lenguaje
    Exp: 'var'                                                              { result = Variable.new(val[0]) }
       | 'num'                                                              { result = Numero.new(val[0]) }
       | Exp '+' Exp                                                        { result = Suma.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '-' Exp                                                        { result = Resta.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '*' Exp                                                        { result = Mult.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '/' Exp                                                        { result = DivReal.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '%' Exp                                                        { result = ModReal.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp 'div' Exp                                                      { result = DivEntera.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp 'mod' Exp                                                      { result = ModEntero.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | '-' Exp = UMINUS                                                   { result = Negativo.new(val[1]).set_linea(val[0].linea).set_col(val[0].col) }
       | 'true'                                                             { result = True.new(val[0]) }
       | 'false'                                                            { result = False.new(val[0]) }
       | 'not' Exp                                                          { result = Negacion.new(val[1]).set_linea(val[0].linea).set_col(val[0].col) }
       | Exp 'and' Exp                                                      { result = Conjuncion.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp 'or' Exp                                                       { result = Disyuncion.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '<' Exp                                                        { result = Menor.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '>' Exp                                                        { result = Mayor.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '<=' Exp                                                       { result = MenorIgual.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '>=' Exp                                                       { result = MayorIgual.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '==' Exp                                                       { result = Igualdad.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | Exp '/=' Exp                                                       { result = Desigualdad.new(val[0], val[2]).set_linea(val[1].linea).set_col(val[1].col) }
       | '(' Exp ')'                                                        { result = val[1] }
       | Llamada                                                            { result = val[0] } 
       | 'str'                                                              { result = Cadena.new(val[0]) }
       ;

---- header

require_relative "lexer"
require_relative "contexto"
require_relative "ejecucion"
require_relative "errores"

---- inner

def on_error(id, token, stack)
    token = !token ? @token_last : token
    raise SyntacticError.new(token)
end
   
def next_token
    token = @tokens.shift
    return [false, false] unless token
    return [token.class, token]
end
   
def parse(lista_tokens)
    @yydebug = true
    @tokens = lista_tokens
    @token_last = @tokens.last
    ast = do_parse
    return ast
end