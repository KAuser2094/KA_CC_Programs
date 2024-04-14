# How the heck does CC (Computer Craft) work with LP (Logistics Pipes)?

## Requesters

You are going to want to connect to a requester type pipe as this will give you the best methods to work with.

### getAvailableItems()

This method will return an array (well an index based table) of "ItemIdentifiers" for each item type in your system.

## ItemIdentifierStack

Are these a minecraft thing or an LP thing? I don't know, doesn't matter. 

## Github

- CC implementation `https://github.com/RS485/LogisticsPipes/blob/b616f29b749c2391bca8cf1b4a0be989bd432b18/common/logisticspipes/proxy/computers/objects/CCItemIdentifierStack.java`
- Actual implementation `https://github.com/RS485/LogisticsPipes/blob/b616f29b749c2391bca8cf1b4a0be989bd432b18/common/logisticspipes/utils/item/ItemIdentifierStack.java`

## getValue1()

Gives you the actual ItemIdentifier. This method is actually the `getItem()`

## getValue2()

Just returns how many of said item is in the system. This method should actually be the `getStackSize()`

## Where is getName() ?

I don't know either.

## getType1()

Just returns "Pair" (Which is just table) as in...the getValue1() returns a table

## getType2()

What do you think -_-. It returns Integer (specifically the java one).

## ItemIdentifier

Go read `itemIdentifier.lua` in the same folder as this.
