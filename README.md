# KA's CC Programs

A collection of programs I use for CC whether to just help me code (like how to clone my repository easily) or for actual usage.

## Installation

### Pastebin

You can run `pastebin run UMDCamCR` which is a copy of `install.lua` which itself downloads `git.lua` and runs the clone command on this repo.

## git

Allows for limited git operations.

### help

`git help (optional <command>)`

### clone

`git clone <owner> <repo> (optional <targetFolder>)`

Note that this will delete previous cloned repository at that directory and replace it with the most up to date according to api.

### reclone

`git reclone <folder_of_repo>`

When `git clone` is ran, it will form a `redoCloneTree.lua` at `<folder_of_repo>/_git`. If your overall file structure hasn't changed (so no deletion, creation or renaming) then you should use this instead of clone to not waste api calls. (Or if you simply don't care about the deleted, created, or renamed files to clone them)

## inventory (module)

### Better Inventory

This is a wrapper around the normal peripheral/inventory api. It is a superset (so you can simply treat it as normal, using `:` instead of `.` to call functions) that adds functionality like searching and better mod support (looking at you IC2). You also don't need to grab the name for push/pull as you may pass in the Better Inventory object directly (and you are encouraged to do so as it adds extra functionality).

The original inventory api is stored at the `.api` field. If you really need it.

To start:

```lua
local invMod = require("inventory") -- You may want to use the tryRequire in `random_functions_to_remember.lua`
local perName = "insert inventory's network name here"
local per = invMod.createBetterInventory(perName)

per:printDocs() -- This will go item by item in the docs and print it out to console.
```

## ic2 (module)

### Better Reactor

Is just Better Inventory with some extra reactor specific stuff.

To start just run the same script as with Better Inventory and run `:printDocs()` to get the methods.
