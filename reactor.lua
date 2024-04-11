--[[
	Reactor Chamber:
	suck: Suck item from ground
	getReactorCore: gets table refrence of reactor core
	getDocs: ....
	getItemMeta(slotNum): gets meta data, 1 index.
	getMetaData: gets meta data of the chamber.
	pullItems(string,int): pulls item from another inv, returns amount pulled.
	getTransferLocations: list of all available objects that can transfer to or from
	drop(slot,direction*): drop to floor, returns how many dropped
	pushItems(stringName,Slot): pushes item to another inv reutnr amount
	list: list all items in inv.
	getItem(slot): gets item in slot
	size: size of inv
]]

local chamber = peripheral.wrap("back")
local docString = textutils.serialize(chamber.getDocs())
textutils.pagedPrint(docString)
