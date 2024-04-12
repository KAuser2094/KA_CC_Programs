# KA's CC Programs

A collection of programs I use for CC whether to just help me code (like how to clone my repository easily) or for actual usage.

## Installation

### Pastebin

You can run `pastebin run UMDCamCR` which is a copy of `install.lua` which downloads `git.lua` and runs the clone command on this repo.

### Manually

You can also just manually copy/download the `install.lua` to do the same thing.

## Basic Usage in terminal:

### install

Will download the `git.lua` file and clone this repo.

### git

Allows for limited git operations. (Currently just clone and help)

### help

`git help (optional <command>)`

#### clone

`git clone <owner> <repo> (optional <targetFolder>)` 

Note that this stores a `hash.lua` file after cloning. When you clone again it will check this file and abort if it detects it is the same as what is up on the api. (It can take a while for the api to update, this should save some api requests).

Also note that this will delete previous cloned repository at that directory and replace it with the most up to date according to api.

### get_info

Will get the documentation and list of methods of a peripheral at the `local networkName` variable in the file and save it to `info`
