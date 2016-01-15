
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

Pseudo-type checking
----

When including certain modules, the module being included will detect if the
current class meets its requirement, for example, `Monad` requires the class
which includes it to include `Applicative`, which in turns requires `Functor`.
If such chain of requirements is not satisfied, an exception will be raised.

Also, after certain modules are included, some methods may be extended to the
class including these modules. Again, the included modules will test if the
class meets the requirement for these methods. For example, module `Monad` only
defines `fold_m` for the class if the class includes `Foldable`, thus has the
required method `fold_each` for `fold_m`.

License
----

Sources are licensed under public domain, just take them as you want.
