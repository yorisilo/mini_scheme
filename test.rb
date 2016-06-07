# [[:lambda, [:x,:y], [:+, :x, :y], 3,2]] とかがプログラムとなる

def list?(exp)
  exp.is_a?(Array)
end

def lookup_primitive_fun(exp)
  $primitive_fun_env[exp]
end

# 組み込み関数が要素のHash
$primitive_fun_env = {
  :+ => [:prim, lambda{ |x, y| x + y }],
  :- => [:prim, lambda{ |x, y| x - y }],
  :* => [:prim, lambda{ |x, y| x * y }]
}

def car(list)
  list[0]
end

def cdr(list)
  list[1..-1]
end

# def eval_list(exp)
#   exp.map {|e| _eval(e)}
# end

def immediate_val?(exp)
  num?(exp)
end

def num?(exp)
  exp.is_a?(Numeric)
end

# def apply(fun, args)
#   apply_primitive_fun(fun, args)
# end

def apply_primitive_fun(fun, args)
  fun_val = fun[1]
  p args
  fun_val.call(*args) # *args と書いてはいるものの *args は常に要素が2つの配列
end

# env は[{},{},...] みたいなもの．  hash のリスト
# 環境から variable の束縛された値を見つける
def lookup_var(var, env)
  h = env.find{ |h| h.key?(var) } # 最初に見つけたhashを取り出す．
  p h
  if h == nil
    raise "couldn't find value to variables: '#{var}'"
  end
  h[var]
end

# params = [:x, :y] 仮引数，args = [1,2] 実引数
# 環境の拡張
def extend_env(params, args, env)
  alist = params.zip(args)
  h = Hash.new
  alist.each { |k, v| h[k] = v }
  [h] + env
end

def eval_let(exp, env)
  params, args, body = let_to_params_args_body(exp)
  new_exp = [[:lambda, params, body]] + args
  _eval(new_exp, env)
end

# [:let, [[:x, 3], [:y, 2]],
#  [:+, :x, :y]]
# # <=>
# [[:lambda, [:x, :y], [:+, :x, :y]], 3, 2]

def let_to_params_args_body(exp)
  [exp[1].map { |e| e[0] }, exp[1].map { |e| e[1] }, exp[2]]
end

def let?(exp)
  exp[0] == :let
end

def eval_lambda(exp, env)
  make_closure(exp, env)
end

# [[:lambda, [:x],
#   [:+,
#      [[:lambda, [:y], :y], 2],
#    :x]], 1]


# [:lambda, [:x], [:+, [[:lambda, [:y], :y], 2], :x]]
def make_closure(exp, env)
  params, body = exp[1], exp[2]
  [:closure, params, body, env]
end
# [:closure, [:x], [:+, [[:lambda, [:y], :y], 2], :x]]

def lambda_apply(closure, args) # [:closure, [:x], [:+, [[:lambda, [:x], :x], 2], :x], [{:+=>[:prim, ...], :-=>[:prim, ...], :*=>[:prim, ...]}]] [1]
  params, body, env = closure_to_params_body_env(closure)
  new_env = extend_env(params, args, env)
  _eval(body, new_env)
end

def closure_to_params_body_env(closure)
  [closure[1], closure[2], closure[3]]
end

# 基本的には第一章の_evalと変わらない．
# exp = [[:lambda, [:x, :y], [:+, :x, :y]], 3, 2]
# exp = [[:lambda, [:x], [:+, [[:lambda, [:x], :x], 2], :x]], 1]
def _eval(exp, env)                # call-by-value
  if list?(exp)
    if special_form?(exp)
      puts "exp = #{exp}"
      puts "env = #{env}"
      p eval_special_form(exp, env)
    else
      fun = _eval(car(exp), env)  # [:closure, params, body, env] [:closure, [:x], [:+, [[:lambda, [:x], :x], 2], :x], [{:+=>[:prim, ...], :-=>[:prim, ...], :*=>[:prim, ...]}]]
      args = eval_list(cdr(exp), env) # [1]
      apply(fun, args)
    end
  else
    if immediate_val?(exp)
      exp
    else
      p "lookup var "
      p lookup_var(exp, env)
    end
  end
end

def special_form?(exp)
  lambda?(exp) or let?(exp)
end

def lambda?(exp)
  exp[0] == :lambda
end

def eval_special_form(exp, env)
  if lambda?(exp)
    eval_lambda(exp, env)
  elsif let?(exp)
    eval_let(exp, env)
  end
end

def eval_list(exp, env)
  exp.map { |e| _eval(e, env) }
end

def apply(fun, args) # [:closure, [:x], [:+, [[:lambda, [:x], :x], 2], :x], [{:+=>[:prim, ...], :-=>[:prim, ...], :*=>[:prim, ...]}]]
  if primitive_fun?(fun)
    apply_primitive_fun(fun, args)
  else
    lambda_apply(fun, args)
  end
end

def primitive_fun?(exp)
  exp[0] == :prim
end


$global_env = [$primitive_fun_env]

exp = [[:lambda, [:x, :y], [:+, :x, :y]], 3, 2]
puts _eval(exp, $global_env)
