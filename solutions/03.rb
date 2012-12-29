class Expr
  def self.build(expression)
    case expression[0]
      when :number   then Number.new         expression[1]
      when :variable then Variable.new       expression[1]
      when :+        then Addition.new       build(expression[1]), build(expression[2])
      when :*        then Multiplication.new build(expression[1]), build(expression[2])
      when :-        then Negation.new       build(expression[1])
      when :sin      then Sine.new           build(expression[1])
      when :cos      then Cosine.new         build(expression[1])
     end
  end

  def derive(variable)
    derivative(variable).simplify
  end

  def *(other)
    Multiplication.new self, other
  end

  def +(other)
    Addition.new self, other
  end

  def -@
    Negation.new self
  end
end

class Unary < Expr
  attr_accessor :parameter

  def initialize(parameter)
    @parameter = parameter
  end

  def ==(other)
    if other.class == self.class
      @parameter == other.parameter
    end
  end

  def exact?
    @parameter.exact?
  end
end

class Binary < Expr
  attr_accessor :parameter1, :parameter2

  def initialize(parameter1, parameter2)
    @parameter1, @parameter2 = parameter1, parameter2
  end

  def ==(other)
    if other.class == self.class
      @parameter1 == other.parameter1 && @parameter2 == other.parameter2
    end
  end

  def exact?
    @parameter1.simplify.exact? & @parameter2.simplify.exact?
  end
end

class Number < Unary
  def evaluate(environment = {})
    @parameter
  end

  def simplify
    self
  end

  def exact?
    true
  end

  def derivative(variable)
    Number.new 0
  end

  def to_s
    @parameter.to_s
  end

  def self.zero
    Number.new 0
  end

  def self.one
    Number.new 1
  end
end

class Variable < Unary
  def evaluate(environment = {})
    environment.fetch @parameter
  end

  def simplify
    self
  end

  def exact?
    false
  end

  def derivative(variable)
    if variable == @parameter
      Number.new 1
    else
      Number.new 0
    end
  end

  def to_s
    @parameter.to_s
  end
end

class Negation < Unary
  def evaluate(environment = {})
    -@parameter.evaluate(environment)
  end

  def simplify
    if exact?
      Number.new(evaluate)
    elsif
      -@parameter.simplify
    end
  end

  def derivative(variable)
    -@parameter.derivative(variable)
  end

  def to_s
    "-#{@parameter}"
  end
end

class Addition < Binary
  def evaluate(environment = {})
    @parameter1.evaluate(environment) + @parameter2.evaluate(environment)
  end

  def simplify
    if exact? then Number.new(@parameter1.simplify.evaluate + @parameter2.simplify.evaluate)
    elsif @parameter1 == Number.zero then @parameter2.simplify
    elsif @parameter2 == Number.zero then @parameter1.simplify
    else Addition.new @parameter1.simplify, @parameter2.simplify
    end
  end

  def derivative(variable)
    @parameter1.derivative(variable) + @parameter2.derivative(variable)
  end

  def to_s
    "(#{@parameter1} + #{@parameter2})"
  end
end

class Multiplication < Binary
  def evaluate(environment = {})
    @parameter1.evaluate(environment) * @parameter2.evaluate(environment)
  end

  def simplify
    if exact? then Number.new(@parameter1.simplify.evaluate * @parameter2.simplify.evaluate)
    elsif @parameter1 == Number.zero || @parameter2 == Number.zero then Number.new(0)
    elsif @parameter1 == Number.one then @parameter2.simplify
    elsif @parameter2 == Number.one then @parameter1.simplify
    else Multiplication.new @parameter1.simplify, @parameter2.simplify
    end
  end

  def derivative(variable)
    @parameter1.derivative(variable) * @parameter2 + @parameter1 * @parameter2.derivative(variable)
  end

  def to_s
    "(#{@parameter1} * #{@parameter2})"
  end
end

class Sine < Unary
  def evaluate(environment = {})
    Math.sin @parameter.evaluate(environment)
  end

  def simplify
    if @parameter.exact?
      Number.new(evaluate)
    else
      Sine.new(@parameter.simplify)
    end
  end

  def derivative(variable)
    @parameter.derivative(variable) * Cosine.new(@parameter)
  end

  def to_s
    "sin(#{@parameter})"
  end
end

class Cosine < Unary
  def evaluate(environment = {})
    Math.cos @parameter.evaluate(environment)
  end

  def simplify
    if @parameter.exact?
      Number.new(evaluate)
    else
      Cosine.new(@parameter.simplify)
    end
  end

  def derivative(variable)
    @parameter.derivative(variable) * (- Sine.new(@parameter))
  end

  def to_s
    "cos(#{@parameter})"
  end
end
