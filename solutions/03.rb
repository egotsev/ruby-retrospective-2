class Expr
  def self.build(expression)
    case expression[0]
      when :number then Number.new(expression[1])
      when :variable then Variable.new(expression[1])
      when :+ then Addition.new(build(expression[1]), build(expression[2]))
      when :* then Multiplication.new(build(expression[1]), build(expression[2]))
      when :- then Negation.new(build(expression[1]))
      when :sin then Sine.new(build(expression[1]))
      when :cos then Cosine.new(build(expression[1]))
     end
  end

  def *(other)
    if self == Number::ZERO || other == Number::ZERO
      Number.new(0)
    elsif self == Number::ONE
      other
    elsif other == Number::ONE
      self
    else
      Multiplication.new(self, other)
    end
  end

  def +(other)
    if self == Number::ZERO
      other
    elsif other == Number::ZERO
      self
    else
      Addition.new(self, other)
    end
  end

  def -@
    if self == Number::ZERO
      @parameter
    else
      Negation.new(self)
    end
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
    @parameter1.exact? & @parameter2.exact?
  end
end

class Number < Unary
  ZERO = Number.new(0)
  ONE = Number.new(1)

  def evaluate(environment = {})
    @parameter
  end

  def simplify
    self
  end

  def exact?
    true
  end

  def derive(variable)
    Number.new(0)
  end

  def to_s
    @parameter.to_s
  end
end

class Addition < Binary
  def evaluate(environment = {})
    @parameter1.evaluate(environment) + @parameter2.evaluate(environment)
  end

  def simplify
    if exact?
      Number.new(evaluate)
    else
      @parameter1.simplify + @parameter2.simplify
    end
  end

  def derive(variable)
    (@parameter1.derive(variable) + @parameter2.derive(variable)).simplify
  end

  def to_s
    "(#{@parameter1} + #{@parameter2})"
  end
end

class Negation < Unary
  def evaluate(environment = {})
    -@parameter.evaluate(environment)
  end

  def simplify
    if exact?
      Number.new(evaluate)
    else
      -@parameter.simplify
    end
  end

  def derive(variable)
    (-@parameter.derive(variable)).simplify
  end

  def to_s
    "-#{@parameter}"
  end
end

class Multiplication < Binary
  def evaluate(environment = {})
    @parameter1.evaluate(environment) * @parameter2.evaluate(environment)
  end

  def simplify
    if exact?
      Number.new(evaluate)
    else
      @parameter1.simplify * @parameter2.simplify
    end
  end

  def derive(variable)
    result = @parameter1.derive(variable) * @parameter2 + @parameter1 * @parameter2.derive(variable)
    result.simplify
  end

  def to_s
    "(#{@parameter1} * #{@parameter2})"
  end
end

class Variable < Unary
  def evaluate(environment = {})
    environment.values_at(@parameter)[0]
  end

  def simplify
    self
  end

  def exact?
    false
  end

  def derive(variable)
    if variable == @parameter
      Number.new(1)
    else
      Number.new(0)
    end
  end

  def to_s
    @parameter.to_s
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

  def derive(variable)
    (@parameter.derive(variable) * Cosine.new(@parameter)).simplify
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

  def derive(variable)
    (@parameter.derive(variable) * (- Sine.new(@parameter))).simplify
  end

  def to_s
    "cos(#{@parameter})"
  end
end
