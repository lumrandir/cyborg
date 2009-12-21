require 'lib/interface'
require 'pp'
require 'mathn'

class Application
  include Interface
  
  def initialize
    @window = CyWindow.new self
  end

  def cardano what
    while (what.size ** 0.5) % 2 != 0
      what.concat " "
    end
    size = (what.size ** 0.5).to_i
    empty_count = what.size / 4
    lattice = [[1.0,0,0,0,1.0,0],[0, 1.0,0,0,0,0],[0,0,1.0,0,1.0,0],[0,0,0,0,0,1.0],
      [1.0,0,1.0,0,0,0],[0,0,0,1.0,0,0]
    ]
    encrypted = ""
    source = what.scan /.{#{size}}/
    4.times do
      lattice.each_with_index do |r, i|
        r.each_with_index do |c, j|
          if c == 1.0
            encrypted.concat source[i][j]
          end
        end
      end
      lattice = rotate(lattice)
    end
    return [encrypted, what]
  end

  def generate_key length
    key = String.new
    srand Time.now.to_i
    length.times { key << rand(127).chr.encode("utf-8") }
    key
  end

  def generate_lattice size, empty_count
    lattice = Matrix.zero(size).to_a
    srand Time.now.to_i
    empty_count.times do
      i, j = rand(size), rand(size)
      while lattice[i][j] == 1.0 || i == j || lattice[j][size - 1 - i] == 1.0 ||
          lattice[size - 1 - i][size - 1 - j] == 1.0 || lattice[size - 1 - j][i] == 1.0
        i, j = rand(size), rand(size)
      end
      lattice[i][j] = 1.0 if lattice[i][j] == 0.0
    end
    return lattice
  end
  private :generate_lattice

  def generate_order size
    order = []
    srand Time.now.to_i
    size.times do
      to_add = rand(size)
      while order.detect { |e| e == to_add }
        to_add = rand(size)
      end
      order << to_add
    end
    return order
  end
  private :generate_order
    
  def lumren what
    order = generate_order what.size
    encrypted = ""
    decrypted = " " * what.size
    order.each do |i|
      encrypted.concat what[i]
    end
    order.each_with_index do |e, i|
      decrypted[e] = encrypted[i]
    end
    return [encrypted, decrypted]
  end

  def monoalphabetic what, shift
    encrypted = what.encode("cp1251").bytes.map { |b|
      ((1.0 * b + shift) % 256).to_i.chr.force_encoding("cp1251")
    }.join("").encode("utf-8")
    decrypted = encrypted.encode("cp1251").bytes.map { |b|
      ((256 + b - shift) % 256).to_i.chr.force_encoding("cp1251")
    }.join("").encode("utf-8")
    return [encrypted, decrypted]
  end

  def permutation what, order
    power = order.split(" ").size
    begin
      while what.size % power != 0
        what.concat " "
      end
    rescue Exception
      return [what, what]
    end
    encrypted = what.scan(/.{#{power}}/).map do |e|
      tmp = " " * power
      order.split(" ").each_with_index do |i, j|
        tmp[i.to_i - 1] = e[j]
      end
      tmp
    end.join ""
    decrypted = encrypted.scan(/.{#{power}}/).map do |e|
      tmp = " " * power
      order.split(" ").each_with_index do |i, j|
        tmp[j] = e[i.to_i - 1]
      end
      tmp
    end.join ""
    return [encrypted, decrypted]
  end

  def polyalphabetic what, key
    ar = []
    what.encode("cp1251").bytes.map { |b| b }.each_with_index { |b, i|
      ar << ((1.0 * b + key[i % key.size].encode("cp1251").bytes.first) % 256).to_i.chr.force_encoding("cp1251")
    }
    encrypted = ar.join("").encode("utf-8")
    ar = []
    encrypted.encode("cp1251").bytes.map { |b| b }.each_with_index { |b, i|
      ar << ((256 + b - key[i % key.size].encode("cp1251").bytes.first) % 256).to_i.chr.force_encoding("cp1251")
    }
    decrypted = ar.join("").encode("utf-8")
    return [encrypted, decrypted]
  end

  def rotate lattice
    size = lattice.size
    rotated = []
    lattice.each_index do |i|
      lattice[i].each_index do |j|
        rotated[j] ||= []
        rotated[j][size - 1 - i] = lattice[i][j]
      end
    end
    return rotated
  end
  private :rotate
end
