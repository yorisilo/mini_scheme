# mini scheme
* 記述言語 ： Ruby
* 対象言語 ： mini scheme

## 参考書籍
* [作って学ぶプログラミング言語](http://tatsu-zine.com/books/scheme-in-ruby)

# ver.0.1

## value, expression
```
v ::= x:int
e ::= v | e + e
```

## example
``` ruby
[:+, [:+, 1, 2], [:+, 1, 3]] => 7
[:+, 1, 2] => 3
```

# ver.0.2

* lambda abstract (multiple parameters)
* application

## value, expression, env
```
v ::= x:int | λx.e | λxy... .e
e ::= v | e1 e2 | e1 + e2 | let x = e1 in e2
env ::= {a: v,...}
```

## example
``` ruby
[[:lam, [:x, :y], [:+, :x, :y]], 3, 2] => 5

[:let, [[:x, 3], [:y, 2]], [:+, :x, :y]] => 5

[[:lam, [:x, :y], [:+, :x, :y]], [[:lam, [:x], [:x]], 2], 3] => 5
```
