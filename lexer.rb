#
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Implementación del Lexer: Guarda una entrada de datos que se va analizando 
# lexicograficamente con la función Lexer#catch_token. 
# La función Lexer#resultado permite imprimir los tokens que se han encontrado.
#

require_relative 'token'
require_relative 'errores'

class Lexer

  def initialize
    @linea               = 1
    @tokens_encontrados  = []
    @errores_encontrados = []
  end

  # Ignora todo el whitespace al inicio de la entrada actual que se este procesando
  # y suma su longitud al contador de columna.
  def ignore_ws
    @entrada.match(/\A\s*/)
    @col += $&.length
    @entrada = $'
  end

  # Recibe una linea de texto desde el archivo de entrada y encuentra todos los 
  # lexemas presentes, conocidos o desconocidos, ignorando whitespace.
  def catch_token(line)
    # Retorna nil si está vacio
    return if line.empty?

    # Inicializar el procesamiento
    @entrada = line
    @col = 1

    while !@entrada.nil?

      # Ignoramos whitespace y salimos si hay comentario.
      ignore_ws
      break if @entrada.match(/\A\#/)

      instanciar = LexError

      # Buscamos match con los tokens registrados
      $tokens.each do |sym, regexp|
        if @entrada.match(regexp)
          instanciar = Object::const_get("Tk#{sym.to_s}")
          break
        end
      end

      # Si no hicimos match en el ciclo anterior => caso desconocido
      if $&.nil? and instanciar.eql? LexError
        # Extraer la palabra o simbolo desconocido
        @entrada.match(/\A(\w+|\p{punct})/)
        @entrada = $'

        # Salimos si ya se consumió toda la línea
        break if $'.nil?

        @errores_encontrados << LexError.new(@linea, @col, $&)
      end

      @tokens_encontrados << instanciar.new(@linea, @col, $&)
      
      # Actualizar contador columna y contenido de la entrada
      @col += $&.length
      @entrada = $'
    end

    @linea += 1
  end

 # Imprime la lista de errores si se encontró alguno, o en caso contrario imprime
 # la lista de tokens encontrados.
  def print_e
    @errores_encontrados.each { |tkn| tkn.print }
  end

  def print_t
    @tokens_encontrados.each { |tkn| tkn.print }
  end

  def errores
    @errores_encontrados
  end

  def tokens
    @tokens_encontrados
  end

end
