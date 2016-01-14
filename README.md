
Monads in Ruby
====

This project (or a set of Ruby source files) presents to you how monads could be
implemented in Ruby. And it also shows that the concept of monad is not unique
to Haskell, but all the languages that supports data abstraction and functions
as data, which in turn demonstrates the idea that monads are merely abstractions
for **actions**.

Structure
----

`mods.rb` defines the modules of `Functor`, `Applicative`, `Monad` and
`Monoid`, whereas `patches.rb` monkey-patches some of the modules to some of
the built-in data structures. And you can find some classic monads in action in
 `app.rb`, for example, the `Maybe` monad, and `Reader` monad.

However, I didn't implement the full aspect of monads due to my still limited
understandings on them.

Sources are licensed under public domain, just take them as you want.
