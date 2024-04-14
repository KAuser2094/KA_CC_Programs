# How the heck does CC (Computer Craft) work with LP (Logistics Pipes)?

## Requesters

You are going to want to connect to a requester type pipe as this will give you the best methods to work with.

### getAvailableItems()

This method will return an array (well an index based table) of "ItemIdentifiers" for each item type in your system.

## "Wrapped" ItemIdentifiers

Are these a minecraft thing or an LP thing? I don't know, doesn't matter.

## getValue1()

Gives you another "object" (table with methods) with MANY more methods to use, I am calling this "Inner" ItemIdentifier and this one "Wrapped" ItemIdentifier, because this one is mostly useless and seems to simply wrap around the actual table with useful methods.

## getValue2()

Just returns how many of said item is in the system.

## getType1()

Just returns "Pair" (Which is just table) as in...the getValue1() returns a table

## getType2()

What do you think -_-. It returns Integer (specifically the java one which is weird).

## "Inner" ItemIdentifier


