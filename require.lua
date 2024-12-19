-- Custom directories to search
-- TODO: Make this work off a file
local search_paths = {
    "/KA_CC/?",
    "/KA_CC/?.lua",
    "/KA_CC/modules/?",
    "/KA_CC/modules/?.lua",

    "/KA_CC_Programs/?",
    "/KA_CC_Programs/?.lua",
    "/KA_CC_Programs/modules/?",
    "/KA_CC_Programs/modules/?.lua",
}

local function format_module_name(path, module_name)
    -- Replace '?' with the module name
    local filled_path = path:gsub("?", module_name)
    -- Remove the leading slash, then replace '/' with '.'
    local formatted = filled_path:gsub("^/", ""):gsub("/", "."):gsub("%.lua$", "")
    return formatted
end

-- Function to load modules from search paths
local function require_from_paths(module_name)
    local native_package_path = package.path
    local combinated_package_path = table.concat(search_paths, ";") .. ";" .. package.path
    package.path = combinated_package_path
    local success, result = pcall(require, module_name)
    package.path = native_package_path
    if success then
        return result
    else
        error("Module '" .. module_name .. "' not found. From: " .. combinated_package_path)
    end
end

local function require_from_paths_2(module_name)
    for _, path in ipairs(search_paths) do
        -- Create a valid module name by filling in the search path
        local formatted_name = format_module_name(path, module_name)

        -- Try requiring the module
        local success, result = pcall(require, formatted_name)
        if success then
            return result  -- Return the loaded module
        end
    end

    -- If all attempts fail, raise an error
    error("Module '" .. module_name .. "' not found in any search path.")
end

local use_1 = false

if use_1 then
    return require_from_paths
else 
    return require_from_paths_2
end
