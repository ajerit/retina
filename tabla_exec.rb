#!/usr/bin/env ruby
# Proyecto CI3725 Traductores e Interpretadores
# Adolfo Jeritson. 12-10523
#
# Definición de la tabla de símbolos usada en la ejecución
#

require_relative 'errores'

# Añadimos conversion a radianos y grados al modulo Math
module Math

  def self.to_rad(degrees)
    (degrees * Math::PI) / 180
  end

  def self.to_deg(radians)
    radians * (180 / Math::PI)
  end

end

class ExecTabla
  attr_reader :parent, :tabla
  def initialize(parent=nil)
      @tabla = {}
      @parent = parent
  end

  def addFunc(var)
    @tabla[var.to_sym] = { :cuerpo => nil, :params => nil }
  end

  def updateFunc(var, cuerpo)
    func = find(var.to_sym)
    func[:cuerpo] = cuerpo
  end

  def addParams(var, params)
    func = find(var.to_sym)
    func[:params] = params
  end

  def addVal(var)
    @tabla[var.to_sym] = { :val => nil }
  end

  def updateVal(var, value)
    key = find(var.to_sym)
    key[:val] = value
  end

  # Retorna la entrada más inmediata del simbolo a buscar
   def find(key)
    key = key.to_sym
     if @tabla.has_key?(key)
       return @tabla[key]
     elsif !@parent.nil?
       return @parent.find(key)
     else
       return nil
     end
   end

end

class MatrizPBM
  def initialize()
    #temp = Array.new(11, 0)
    @m = Array.new(1001) {Array.new(1001, 0)}
    @m[500][500] = 1
    @actual_x = 500
    @actual_y = 500
    @grados = 90
    @write = true
  end

  def save_to_file()
    $file.match(/(\w+)\.rtn/)

    File.open("#{$1}.pbm", "w") do |f|
      @m.each { |arr| f.write("#{arr}\n")}
    end
  end

  def save_to_img()
    $file.match(/(\w+)\.rtn/)

    pixels = @m
    image = PNM.create(pixels, :type=>:pbm)
    image.write("#{$1}.pbm")
  end

  def openeye()
    @write = true
  end

  def closeeye()
    @write = false
  end

  # Dada la posicion actual y el grado a moverse, retorna
  # los valores en y correspondientes
  def recta(m, x, x_o, y_o)
    y = m*(x-x_o)+y_o
    return y.floor
  end

  def forward(n)
    #puts @grados
    if @grados == 90
      n.times do
        @actual_y -= 1
        begin
          (@m[@actual_y][@actual_x] = 1) if @write
        rescue NoMethodError
        end
      end
    elsif @grados == 270
      n.times do
        @actual_y += 1
        begin
          (@m[@actual_y][@actual_x] = 1) if @write
        rescue NoMethodError
        end
      end
    else
      m = Math.tan(Math.to_rad(@grados))
      #puts "m: #{m}"
      # Calculamos Y por trigonometria
      dist_x = (Math.cos(Math.to_rad(@grados)) * n).round.abs
      #puts "dx: #{dist_x}"

      x_o = @actual_x
      y_o = @actual_y

      for x in 1..(dist_x)
        dist_y = (Math.tan(Math.to_rad(@grados)) * x).round
        #y = recta(m, x, x_o, y_o).round
        #puts "tan: #{dist_y}, recta: #{y}, x: #{x}"
        
        if @grados >= 0 and @grados <=90
          # PRIMER CUADRANTE
          @actual_y=y_o-dist_y
          @actual_x=x_o+x
        elsif @grados > 90 and @grados <= 180
          # SEGUNDO CUADRANTE
          @actual_y=y_o+dist_y
          @actual_x=x_o-x
        elsif @grados > 180 and @grados <= 270
          # TERCER CUADRANTE
          @actual_y=y_o+dist_y
          @actual_x=x_o-x
        elsif @grados > 270 and @grados < 360
          # CUARTO CUADRANTE
          @actual_y=y_o-dist_y
          @actual_x=x_o+x
        end

        begin
          (@m[@actual_y][@actual_x] = 1) if @write
        rescue NoMethodError
        end
      end
    end
  end

  def backward(n)
    if @grados == 90
      n.times do
        @actual_y += 1
        begin 
          (@m[@actual_y][@actual_x] = 1) if @write
        rescue NoMethodError
        end
      end
    elsif @grados == 270
      n.times do
        @actual_y -= 1
        begin
          (@m[@actual_y][@actual_x] = 1) if @write
        rescue NoMethodError
        end
      end
    else
      m = Math.tan(Math.to_rad(@grados))
      #puts "m: #{m}"
      dist_x = (Math.cos(Math.to_rad(@grados)) * n).round.abs
      #puts "dx: #{dist_x}"

      x_o = @actual_x
      y_o = @actual_y

      for x in 1..(dist_x)
        dist_y = (Math.tan(Math.to_rad(@grados)) * x).round
        #y = recta(m, x, x_o, y_o).round
        #puts "tan: #{dist_y}, recta: #{y}, x: #{x}"
        
        if @grados >= 0 and @grados <=90
          # PRIMER CUADRANTE
          @actual_y=y_o-dist_y
          @actual_x=x_o+x
        elsif @grados > 90 and @grados <= 180
          # SEGUNDO CUADRANTE
          @actual_y=y_o+dist_y
          @actual_x=x_o-x
        elsif @grados > 180 and @grados <= 270
          # TERCER CUADRANTE
          @actual_y=y_o+dist_y
          @actual_x=x_o-x
        elsif @grados > 270 and @grados < 360
          # CUARTO CUADRANTE
          @actual_y=y_o-dist_y
          @actual_x=x_o+x
        end

        begin 
          (@m[@actual_y][@actual_x] = 1) if @write
        rescue NoMethodError
        end
      end
    end
  end

  def rotater(n)
    @grados = ((@grados-n) % 360).round
  end

  def rotatel(n)
    @grados = ((@grados+n) % 360).round
  end

  def set_pos(x, y)
    @actual_x = x + 500
    @actual_y = y + 500
  end
end