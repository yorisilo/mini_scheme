# [:+, 1, 2] => 3

# [:+, [:+, 1, 2], [:+, 1, 3]] => 7

# [[:lam, [:x, :y], [:+, :x, :y]], 3, 2]

# v ::= x:int
# e ::= v | e + e

def _eval(exp, env)
  if list?(exp)
    if special_form?(exp)
      eval_special_form(exp, env) # [:lam, [:x, :y], [:+, :x, :y]], {} => [:closure, [:x, :y], [:+, :x, :y], {}]
    else
      fun = _eval(car(exp), env) # [[:lam, [:x, :y], [:+, :x, :y]], 3, 2] => [:closure, [:x, :y], [:+, :x, :y], {}]
      args = eval_list(cdr(exp), env) # [[:lam, [:x, :y], [:+, :x, :y]], 3, 2] => [3, 2]
      apply(fun, args) # [:closure, [:x, :y], [:+, :x, :y], {}], [3, 2] =>
    end
  else # exp := :x or :+ or 1
    if immediate_val?(exp) # 1
      exp
    else # :x or :+
      e = lookup_primitive_fun(exp) || lookup_var(exp, env)
      # :+ => [:prim, lambda { |x,y| x + y }]
      # :x, {x: 1, y: 2} => 1
    end
  end
end

def eval_list(exp, env)
  # exp.map(&:_eval)
  exp.map { |e| _eval(e, env) }
end

$primitive_fun_env = {
  :+ => [:prim, lambda { |x,y| x + y }]
}


# exp: :+
def lookup_primitive_fun(exp)
  $primitive_fun_env[exp]
end

# env : {x: 3, y: 4, ...}
def lookup_var(var, env)
  if env.key?(var)
    env[var]
  else
    raise "couldn't find value to variables: '#{var}'"
  end
end

def special_form?(exp)
  lambda?(exp) or let?(exp)
end

def eval_special_form(exp, env)
  if lambda?(exp)
    eval_lambda(exp, env) # [:lambda, [:x], [:x]], {x: 1}
  elsif let?(exp)
    eval_let(exp, env)
  end
end

# params := [:x,:y]
# args := [1,2]
# env := {x: 3, y: 5}
def extend_env(params, args, env)
  tuplelist = params.zip(args)
  tuplehash = tuplelist.to_h
  env.merge(tuplehash)
end

# [:lam, [:x, :y], [:+, :x, :y]]
# [:lam, [:x], [:x]]
def eval_lambda(exp, env)
  make_closure(exp, env)
end

def make_closure(exp, env)
  params, body = exp[1], exp[2]
  [:closure, params, body, env]
end

# params := [:x,:y,...]
def lambda_apply(closure, args) # [:closure, [:x, :y], [:+, :x, :y], {}], [3, 2] =>
  params, body, env = closure_to_params_body_env(closure)
  new_env = extend_env(params, args, env)
  _eval(body, new_env) # [:+, :x, :y], {x: 3, y: 2}
end

def closure_to_params_body_env(closure)
  [closure[1], closure[2], closure[3]]
end

def eval_let(exp, env)
  params, vals, body = let_to_params_vals_body(exp)
  new_exp = [[:lam, params, body]] + vals
  _eval(new_exp, env)
end

def let_to_params_vals_body(exp)
  [exp[1].map { |e| e[0] }, exp[1].map { |e| e[1] }, exp[2]]
end

def lambda?(exp)
  exp[0] == :lam
end

def let?(exp)
  exp[0] == :let
end

def list?(exp)
  exp.is_a?(Array)
end

def immediate_val?(exp)
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

def apply(fun, args) # fun := [:prim, lambda { |x,y| x + y }] or [:closure,...]
  if primitive_fun?(fun)
    apply_primitive_fun(fun, args)
  elsif immediate_val?(fun)
    fun
  else
    lambda_apply(fun, args)
  end
end

# fun := [:+, lambda{ |x,y| x+y }]
# args := [1,2]
def apply_primitive_fun(fun, args)
  fun[1].call(*args)
end

def primitive_fun?(exp)
  exp[0] == :prim
end

def test
  env = {}
  puts _eval([:+, 1, 2], env) == 3
  puts _eval([:+, [:+, 1, 2], [:+, 1, 3]], env) == 7
  puts _eval([[:lam, [:x, :y], [:+, :x, :y]], 3, 2], env) == 5
  puts _eval([:let, [[:x, 3], [:y, 2]], [:+, :x, :y]], env) == 5
  puts _eval([[:lam, [:x, :y], [:+, :x, :y]], [[:lam, [:x], [:x]], 2], 3], env) == 5
  puts _eval([[:lam, [:x], [:x]], 2], env) == 2
end
