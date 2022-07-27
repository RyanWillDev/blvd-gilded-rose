# The Gilded Rose

Hi and welcome to team Gilded Rose.

As you know, we are a small inn with a prime location in a prominent
city ran by a friendly innkeeper named Allison. We also buy and sell
only the finest goods. Unfortunately, our goods are constantly
degrading in quality as they approach their sell by date.

We have a system in place that updates our inventory for us. It was
developed by a no-nonsense type named Leeroy, who has moved on to new
adventures. Your task is to add the new feature to our system so that
we can begin selling a new category of items.

First an introduction to our system:

- All items have a _sell_in_ value which denotes the number of days we
  have to sell the item

- All items have a _quality_ value which denotes how valuable the
  item is

- At the end of each day our system lowers both values for every item

Pretty simple, right? Well this is where it gets interesting:

- Once the _sell_in_ days is less then zero, _quality_ degrades twice
  as fast

- The _quality_ of an item is never negative

- "Aged Brie" actually increases in _quality_ the older it gets

- The _quality_ of an item is never more than 50

- "Sulfuras", being a legendary item, never has to be sold nor does
  it decrease in _quality_

- "Backstage passes", like aged brie, increases in _quality_ as it's
  _sell_in_ value decreases; _quality_ increases by 2 when there are 10
  days or less and by 3 when there are 5 days or less but _quality_
  drops to 0 after the concert

We have recently signed a supplier of conjured items. This requires
an update to our system:

- "Conjured" items degrade in _quality_ twice as fast as normal items

Feel free to make any changes to the _updateQuality_ method and add
any new code as long as everything still works correctly. However, do
not alter the _Item_ module as that belongs to the goblin in the
corner who will insta-rage and one-shot you as he doesn't believe in
shared code ownership.

Just for clarification, an item can never have its _quality_ increase
above 50, however "Sulfuras" is a legendary item and as such its
_quality_ is 80 and it never alters.

## Boulevard Instructions

Consider this an exercise in refactoring a legacy system to make your
feature easier to implement, and leave things in a more maintainable
state than you found them in.

As with most legacy systems, we can't count on this one to fully
follow the spec, and we should consider the possibility that it
contains bugs that other systems compensate for and therefore depend
on. Even though this example is small, let's pretend it's a
legitimate legacy system that would be impractical to rewrite.

To complete the exercise, perform a gradual, step by step
refactoring, showing your work with micro-commits at each step.
Implement "Conjured" items when the code has improved enough to make it
easy and clear. Aside from the point at which you implement the
"Conjured" items spec, preserve all existing legacy behavior at each
step/commit.

You'll need to initialize a new git repository to start:

```
git init
git add -A
git commit -m "Initial commit"
```

And you can package up a bundle of your completed work with:

```
git bundle create your_name.bundle master
```

## Solution Reflections

### The Problem

Aside from the absurdly nested conditionals, the real issue with the legacy
update functionality was its reliance on inspecting the names of the items to
determine the type of updates that should be applied. This is not ideal for many
reasons least of which is the one to one correspondence of new item types to special cases.
For any new item that did not meet the criteria of what I called a "generic" item,
you would have to hardcode the name into the update function in order to treat it differently.

Even though, the code in the example was purposefully obscure, it is not hard to imagine how
something approximating this code could result from this design in a real-world scenario.

## My Solution

In order to avoid inspecting the names of the items to determine how to update
them, I introduced a simple interface via a [protocol](lib/gilded_rose/inventory/item.ex).
Protocols provide polymorphism via type-based dispatch on the first argument.
This means I could define a different "type", via a struct, for each "class" of
item in the system.

With that in place, I could begin implementing the protocol for each existing
"class" of item which moves the special case handling of their quality updates
to a single location. Further, adding a different "class" of item is a simple process of
implementing the protocol for the new type of item. This is exactly the process
that was taken to implement the Conjured class of items.

This approach does include some duplicated or nearly identical code, the struct
definitions for most items for instance, but I think it is justified by the
overall flexibility the approach provides by allowing the interface to be
defined and implemented separately from it's data representation.
See this [paper](https://dl.acm.org/doi/pdf/10.1145/942572.807045) and this
[talk](https://www.youtube.com/watch?v=fhheJ5zsXBQ) for a better explanation.

For example, when implementing the [Legendary items](lib/gilded_rose/inventory/items/legendary.ex)
I chose to not add a `sell_in` value to the struct and to hardcode the
`quality` to `80` since that was the simplest way to meet the requirements of the spec.
Since Legendary items effectively represent the null or empty case, the
protocol implementation was as simple as just returning the item as is.

Another aspect I'd like to call attention to is the concurrency issues that were
resolved by replacing the various calls to `Agent`'s `get` and `update` with
a single call `get_and_update` which is an atomic operation. This prevents
concurrent operations from causing unspecified behavior by queuing the in the process's mailbox.

For example, if the API was extended to include a delete operation and it was
called concurrently with `update_quality`, the index's used in the old code's
call to `Agent.update` and `Agent.get` could not exist or represent items other
than those associated with the index when the first call to `Agent.get`
occurred.
