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

return require_from_paths