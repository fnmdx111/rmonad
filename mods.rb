
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
    raise("#{mod} didn't include Functor!") unless mod.include?(Functor)

    mod.extend(ApplicativeClassMethod)
  end

  module ApplicativeClassMethod
    def pure(x)
    end
  end

  def apply(x)
  end
end

module Monad
  def self.included(mod)
    raise("#{mod} didn't include Applicative!") unless mod.include?(Applicative)

    mod.extend(MonadClassMethod)
  end

  module MonadClassMethod
    def unit(x)
      pure(x)
    end

    def fold_m(init, xs, &f)
      raise("#{self.name} isn't foldable!") unless self.include?(Enumerable)
      acc = init
      xs.each { |x| acc = f.call(x, acc) }
      acc
    end
  end

  def bind_(&f)
    f.call
  end

  def bind(&f)
  end
end
