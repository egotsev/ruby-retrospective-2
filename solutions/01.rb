class Integer
  def prime_divisors
    2.upto(abs).select { |n| self % n == 0 and n.prime? }
  end

  def prime?
    2.upto(abs / 2).all? { |n| self % n != 0 }
  end
end

class Range
  def fizzbuzz
    map do |n|
      if n % 15 == 0 then :fizzbuzz
      elsif n % 3 == 0 then :fizz
      elsif n % 5 == 0 then :buzz
      else n
      end
    end
  end
end

class Hash
  def group_values
    keys.group_by { |key| self[key] }
  end
end

class Array
  def densities
    map { |element| count element }
  end
end
