
class Module
  def require_instances(mods)
    mods.each do |m|
      raise "#{self.name} isn't an instance of #{m.name}!" unless self.include?(m)
    end
  end
end

module Functor
  def fmap(f)
  end
end

module Monoid
  def self.included(mod)
    mod.extend(MonoidClassMethod)
  end

  module MonoidClassMethod
    def mempty
    end
  end

  def mappend_(x)
  end

  def mappend(x)
    if x.nil?
      self
    else
      mappend_(x)
    end
  end
end

module Applicative
  def self.included(mod)
    mod.require_instances [Functor]

    mod.extend(ApplicativeClassMethod)
  end

  module ApplicativeClassMethod
    def pure(x)
    end
  end

  def apply(x)
  end
end

module Foldable
  def fold_each(&f)
  end
end

module Traversable
  def self.included(mod)
    mod.require_instances [Functor, Foldable]
  end

  def traverse(&f)
  end
end

module Monad
  _fold_m = proc do |init, xs, &f|
    acc = init
    xs.fold_each { |x| acc = f.call(x, acc) }
    acc
  end

  _seq_m = proc do |ms|
    ms.traverse { |m| m.bind { |x| m.class.unit(x) } }
  end

  REG_TABLE = {:fold_m => [[Foldable], _fold_m],
               :sequence => [[Traversable, Foldable], _seq_m]}

  def self.included(mod)
    mod.require_instances [Applicative]

    mod.extend(MonadClassMethod)

    REG_TABLE.each_pair do |k, v|
      if v[0].all? { |x| mod.include?(x) }
        mod.class.send(:define_method, k, &v[1])
      end
    end
  end

  module MonadClassMethod
    def unit(x)
      pure(x)
    end
  end

  def join
    self.bind { |t| t }
  end

  def bind_(&f)
    self.bind { |_| f.call }
  end

  def bind(&f)
  end
end
