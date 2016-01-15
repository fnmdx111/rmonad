require_relative 'mods'

class String
  include Monoid
  def self.mempty
    ""
  end

  def mappend_(x)
    self + x
  end
end

class NilClass
  include Monoid
  def self.mempty
    nil
  end

  def mappend_(_)
    nil
  end
end

class Array
  include Monoid
  def self.mempty
    []
  end

  def mappend_(o)
    self + o
  end

  include Foldable
  def fold_each(&f)
    self.each(&f)
  end

  include Functor
  def fmap(&f)
    map(&f)
  end

  include Applicative
  def self.pure(x)
    [x]
  end

  def apply(x)
    self.map { |f| x.fmap(&f) }
  end

  include Traversable
  def traverse(&f)
    self.map(&f)
  end

  include Monad
  def bind(&f)
    self.map { |e| f.call(e) }.flatten(1)
  end

end
