# KA's CC Programs

A collection of programs I use for CC whether to just help me code (like how to clone my repository easily) or for actual usage.

## Installation

### Pastebin

You can run `pastebin run UMDCamCR` which will just run a shell command to run the `install.lua` file.
You can also run `pastebin get UMDCamCR install` which will download the `install.lua` file.

### Wget directly

You can also just run the wget command directly with `wget run https://raw.githubusercontent.com/KAuser2094/KA_CC_Programs/master/install.lua"`
Oce again, replace run with get if you want to just install the file so you can run later.

## Basic Usage in terminal:

### install

Will delete and clone this repo into the home directory.

### git

Allows for limited git operations. (Currently just clone)

#### clone

`git.lua clone <owner> <repo> (optional <targetFolder>)`

### get_info

Will get the documentation and list of methods of a peripheral at the `local networkName` variable in the file and save it to `info`
