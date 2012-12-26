class Integer	
	def prime_divisors
		array = []
		pos_self = self.abs
		pos_self.downto(2) { |n| array << n if pos_self % n == 0 and n.prime? }
		array.sort!
		return array unless array.empty?
		nil
	end

	def prime?
		is_prime = true
		self.downto 2 do |n| 
			is_prime = false if self % n == 0 and n != self
		end
		is_prime
	end
end

class Range
	def fizzbuzz
		array = []
		self.each do |n|
			if n % 3 == 0 and n % 5 == 0
				array << :fizzbuzz
			elsif n % 3 == 0
				array << :fizz
			elsif n % 5 == 0 
				array << :buzz
			else
				array << n
			end
		end
		array
	end
end

class Hash
	def group_values
		values = Hash.new { |hash, key| hash[key]=[] }
		self.keys.each do |n|
			values[self[n]] << n
		end
		values
	end
end

class Array
	def densities
		self.collect do |item|
			if item.is_a? Integer
				return item
			end
			counter = 0
			self.each do |n| 
				if n == item
					counter+=1
				end
			end
			counter
		end
	end
end
