return {
  docs = {
    getMetadata = "function():table -- Get metadata about this object",
    listParts = "function():table -- Get a list of all parts in the multipart.",
    listSlottedParts = "function():table -- Get a lookup of slot to parts.",
    getDocs = "function([name: string]):string|table -- Get the documentation for all functions or the function specified. Errors if the function cannot be found.",
    getSlottedPartMeta = "function(slot:string):table|nil -- Get the metadata of the part in the specified slot.",
    getSlottedPart = "function(slot:string):table|nil -- Get a reference to the part in the specified slot.",
  },
  commandHelp = {
    "---------------------------------\
Command: getChassieSize\
Parameter: NONE\
Return Type: java.lang.Integer\
Description: \
Returns the size of this Chassis pipe",
    "---------------------------------\
Command: getModuleInSlot\
Parameter: \
Double\
Return Type: logisticspipes.modules.LogisticsModule\
Description: \
Returns the LogisticsModule for the given slot number starting by 1",
    "---------------------------------\
Command: canAccess\
Parameter: NONE\
Return Type: boolean\
Description: \
Returns true if the computer is allowed to interact with the connected pipe.",
    "---------------------------------\
Command: sendMessage\
Parameter: \
Double, Object\
Return Type: void\
Description: \
Sends a message to the given computerId over the LP network. Event: LP_MESSAGE",
    "---------------------------------\
Command: getLogisticsModule\
Parameter: NONE\
Return Type: logisticspipes.modules.LogisticsModule\
Description: \
Returns the Internal LogisticsModule for this pipe",
    "---------------------------------\
Command: hasLogisticsModule\
Parameter: NONE\
Return Type: boolean\
Description: \
Returns true if the pipe has an internal module",
    "---------------------------------\
Command: getRouterId\
Parameter: NONE\
Return Type: int\
Description: \
Returns the Router UUID as an integer; all pipes have a unique ID (runtime stable)",
    "---------------------------------\
Command: getLP\
Parameter: NONE\
Return Type: java.lang.Object\
Description: \
Returns the global LP object which is used to access general LP methods.",
    "---------------------------------\
Command: getRouterUUID\
Parameter: \
Double\
Return Type: java.lang.String\
Description: \
Returns the Router UUID for the givvin router Id",
    "---------------------------------\
Command: getRouterUUID\
Parameter: NONE\
Return Type: java.lang.String\
Description: \
Returns the Router UUID; all pipes have a unique ID (lifetime stable)",
    "---------------------------------\
Command: sendBroadcast\
Parameter: \
String\
Return Type: void\
Description: \
Sends a broadcast message to all Computer connected to this LP network. Event: LP_BROADCAST",
    "---------------------------------\
Command: getPipeForUUID\
Parameter: \
String\
Return Type: java.lang.Object\
Description: \
Returns the access to the pipe of the given router UUID",
    "---------------------------------\
Command: getTurtleConnect\
Parameter: NONE\
Return Type: boolean\
Description: \
Returns the TurtleConnect targeted for this Turtle on this LogisticsPipe",
    "---------------------------------\
Command: setTurtleConnect\
Parameter: \
Boolean\
Return Type: void\
Description: \
Sets the TurtleConnect targeted for this Turtle on this LogisticsPipe",
    "No command with that index",
  },
  methods = {
    "getChassieSize",
    "getLP",
    "sendBroadcast",
    "getMetadata",
    "getSlottedPart",
    "getSlottedPartMeta",
    "listSlottedParts",
    "getTurtleConnect",
    "sendMessage",
    "setTurtleConnect",
    "listParts",
    "commandHelp",
    "getDocs",
    "help",
    "getLogisticsModule",
    "getModuleInSlot",
    "getType",
    "hasLogisticsModule",
    "canAccess",
    "getRouterId",
    "getPipeForUUID",
    "getRouterUUID",
  },
}