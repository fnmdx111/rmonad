require_relative 'mods'
require_relative 'patches'

class Maybe
  attr_reader :data

  def self.nothing
    Maybe.new(nil)
  end

  def self.just(x)
    Maybe.new(x)
  end

  def initialize(data)
    @data = data
  end

  def to_s
    return "Just #{@data.to_s}" unless @data.nil?
    "Nothing"
  end

  include Functor
  def fmap(&f)
    if !@data.nil?
      Maybe.just(f.call(@data))
    else
      Maybe.nothing
    end
  end

  include Applicative
  def self.pure(x)
    Maybe.just(x)
  end

  def apply(x)
    x.fmap(&@data)
  end

  include Monad
  def bind(&f)
    if @data.nil?
      Maybe.nothing
    else
      f.call(@data)
    end
  end
end

class Writer
  attr_reader :data, :log

  def initialize(x, l)
    raise('l should be an instance of Monoid!') unless l.class.include?(Monoid)

    @data = x
    @log = l
  end

  include Functor
  def fmap(&f)
    Writer.new(f.call(@data), @log)
  end

  include Applicative
  def self.pure(x)
    Writer.new(x, nil)
  end

  def apply(x)
    Writer.new(@data.call(x.data), @log.mappend(x.log))
  end

  include Monad
  def bind(&f)
    nwr = f.call(@data)
    Writer.new(nwr.data, @log.mappend(nwr.log))
  end

  def to_s
    "#{@data.to_s} with #{@log.to_s}"
  end
end

class Reader
  attr_reader :fun

  def initialize(&f)
    @fun = f
  end

  include Functor
  def fmap(&f)
    Reader.new { |r| f.call(@fun.call(r)) }
  end

  include Applicative
  def self.pure(f)
    Reader.new { |_| f }
  end

  def apply(x)
    Reader.new { |r| @fun.call(r).call(x.fun.call(r)) }
  end

  include Monad
  def bind(&f)
    Reader.new { |r| f.call(@fun.call(r)).call(r) }
  end

  def call(*args)
    @fun.call(*args)
  end
end

class State
  def run(s)
    @fn.call(s)
  end

  def initialize(&f)
    @fn = f
  end

  include Functor
  def fmap(&f)
    State.new do |s|
      a, ns = @fn.call(s)
      [f.call(a), ns]
    end
  end

  include Applicative
  def self.pure(x)
    State.new { |s| [x, s] }
  end

  def apply(os)
    State.new do |s|
      f, ns = os.run(s)
      v, nns = @fn.run(ns)
      [f.call(v), nns]
    end
  end

  include Monad
  def bind(&f)
    State.new do |s|
      v, ns = @fn.call(s)
      f.call(v).run(ns)
    end
  end
end

if __FILE__ == $0
  p [lambda {|x| x + 1}, lambda {|x| x + 3}].apply([3, 4])

  def log_n(n)
    Writer.new(n, ["got #{n}"])
  end

  puts log_n(1).bind {
      |a| log_n(2).bind {
        |b| Writer.unit(a + b)
    }
  }

  rr = Reader.new { |x| x * 2 }.bind {
      |a| Reader.new { |y| y + 3 }.bind {
        |b| Reader.unit(a + b) } }
  puts rr.call(5)

  p [1, 2, 3].bind { |x|
    [5, 6, 9].bind { |y|
      Array.unit(x + y)
    }
  }

  p Array.fold_m([[1], [2], [3]], [[4, 5, 6], [7, 8, 9]]) { |x, acc|
    x.bind { |a|
      acc.bind { |b|
        Array.unit(b + [a])
      }
    }
  }

  puts Maybe.just(Maybe.just(3)).join

  def push(t)
    State.new do |x|
      nx = x.dup
      nx << t
      [nil, nx]
    end
  end
  def pop
    State.new do |x|
      nx = x.dup
      v = nx.pop
      [v, nx]
    end
  end

  def joinable_stateful_computation
    State.new do |s|
      ss = s.dup
      ss << 1
      ss << 2
      # these are the modifications to the state
      [push(3), ss]
      # the value of these modifications (or, this stateful computation) is
      # another stateful compututaion, namely push(3)
    end
  end
  p joinable_stateful_computation.join.run [1, 2, 3]
  # by joining this single stateful computation, we combine this S.C. and the
  # other S.C. from the result of this S.C. together into a new S.C.

  some_stateful_computation = push(3).bind_ { push(2).bind_ { push(5) } }
  another_stateful_computation = pop.bind do |x|
    if x > 3
      push(x + 5).bind { pop }
    else
      push(x * 3)
    end
  end

  p some_stateful_computation.bind { another_stateful_computation }.run [1, 2, 3]

  p some_stateful_computation.run([1, 2, 3])
end
