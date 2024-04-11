# KA's CC Programs

A collection of programs I use for CC whether to just help me code (like how to clone my repository easily) or for actual usage.

## Installation

### Pastebin

You can run `pastebin run UMDCamCR` which will just run a shell command to the lua file.

### Wget directly

You can also just run the wget command directly with `wget run https://raw.githubusercontent.com/KAuser2094/KA_CC_Programs/master/clone_this_repo.lua`

## Usage in terminal:

### clone_this_repo

Is actually just a copy of `git_clone` but instead of accepting command line arguments it directly calls the function with this repo.
Note that because this will delete the old folder before cloning it essentially also works as a pull (although the github api takes a bit to update)

### git_clone

This allows you to clone git repos into your CC computer. Just type `git_clone (Username) (RepoName)` and it will clone to the home directory.

### hello_world

This is self explanatory, just here to be a file you know should work.

## Usage in code

This is more of a general CC tip, but given this is in a module folder, simply type `local *var_name* = KA_CC_Programs.*path to lua file*` to use the functions in your code.
