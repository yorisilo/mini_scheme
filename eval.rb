# [:+, 1, 2] => 3

# [:+, [:+, 1, 2], [:+, 1, 3]] => 7

# v ::= x:int
# e ::= v | e + e

def _eval(exp)
  if list?(exp)
    fun = _eval(car(exp))
    args = _eval_list(cdr(exp))
    apply(fun, args)
  else
    if val?(exp)
      exp
    else
      lookup_primitive_fun(exp)
    end
  end
end

def _eval_list(exp)
  # exp.map(&:_eval)
  exp.map { |e| _eval(e) }
end

$primitive_fun_env = {
  :+ => lambda { |x,y| x + y }
}

def lookup_primitive_fun(exp)
  $primitive_fun_env[exp]
end

def list?(exp)
  exp.is_a?(Array)
end

def val?(exp)
  num?(exp)
end

def num?(exp)
  exp.is_a?(Numeric)
end

def car(list)
  list[0]
end

def cdr(list)
  list[1..-1]
end

def apply(fun, args)
  fun.(*args)
end

def test
  e1 = _eval([:+, 1, 2]) == 3
  e2 = _eval([:+, [:+, 1, 2], [:+, 1, 3]]) == 7
  [e1: e1,e2: e2]
end
