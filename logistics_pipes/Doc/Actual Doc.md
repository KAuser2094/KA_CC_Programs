# How the heck does CC (Computer Craft) work with LP (Logistics Pipes)?

## Requesters

You are going to want to connect to a requester type pipe as this will give you the best methods to work with.

### getAvailableItems()

This method will return an array (well an index based table) of `Pair<ItemIdentifier,Integer>` for each item type in your system.

## Pair

Are these a minecraft thing or an LP thing? I don't know, doesn't matter.

## getValue1()

Gives you the actual ItemIdentifier.

## getValue2()

Just returns how many of said item is in the system.

## getType1()

Just returns "Pair" which this is in fact is.

## getType2()

Why does this return integer?

## ItemIdentifier

Go read `itemIdentifier.lua` in the same folder as this.
