require 'lib/interface'
require 'pp'

class Application
  include Interface
  
  def initialize
    @window = CyWindow.new self
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

  def generate_key length
    key = String.new
    srand Time.now.to_i
    length.times { key << rand(127).chr.encode("utf-8") }
    key
  end
end
