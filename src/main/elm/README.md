# Some notes on the Elm code

Here are a few notes on the Elm code.

1. Organization

I have organized the Elm modules in a somewhat non-idiomatic way.
For instance, instead of having a `Validation.elm` file with some
supporting files in a Validation folder, I put the Validation.elm
file itself in the Validation folder. This leads to some redundancy
in the module name (e.g. `import Validation.Validation' instead of
`import Validation`. However, I like have the whole module inside
a folder for a variety of reasons, so I do it that way.

2. Cyclic Dependencies

On my first try, I was bedevilled by cyclic module dependencies.
To avoid them, I eventually adopted two principles which work out
pretty well.

-- Lower-level modules should mostly ask for what they need in their
   function signatures, and let the call-site (in the higher-level
   modules) provide it.

-- Where lower-level modules really need to know something about the
   higher-level module, try to limit that knowledge to types, and
   possibly some very limited functions.

So, I often have a ModuleNameTypes.elm module as a kind of 'header'
file that can be referenced from lower-level modules, while the
'implementation' module should not be.

If you implemented principle #1 completely, you probably wouldn't
need principle #2 at all. But, sometimes principle #1 is a bit awkward.

3. How many signals

A somewhat related question is how many signals to use in the app.
At one extreme, every text box that could ever appear in the app
could be its own signal -- it is, after all, a value that changes
over time. However, this is probably impractical (I say 'probably'
because I haven't tried it). You could conceivably end up with
hundreds, or even thousands, of signals -- and they can't be created
dynamically, since the signal graph can't change. This probably is
impratical performance-wise, though it would be interesting if I 
were wrong about that.

What I do instead is create a single signal for the UI, and then
use the 'forwardTo' mechanism to supply addresses to lower-level
modules that they can use to send messages. I also create a signal
for each of the 'service-oriented' modules, so that they can be
addressed directly.

There actually is some logic to this division, in this sense.
A UI module could theoretically appear in multiple contexts in
the UI -- I don't have a case of that yet, but will eventually.
So, you really do need to 'address' it through its parents, not
through a single mailbox of its own. However, the service-oriented
modules are true singletons, so they may as well have their own
mailbox.
 
