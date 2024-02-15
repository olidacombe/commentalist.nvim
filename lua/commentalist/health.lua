local health = vim.health or require("health")
table.unpack = table.unpack or unpack

local M = {}

-- format here is {
--     binary_name = { ... additional required binaries }
-- }
local optional_binaries = {
	-- boxes
	boxes = {},
	-- cowsay
	cowsay = {},
	-- figlet: requires also `figlist` for getting fonts
	figlet = { "figlist" },
}

-- check whether all binaries are found, returning a global
-- boolean and individual booleans per binary
local check_binaries = function(bins)
	local ok = true
	local findings = {}
	for _, bin in ipairs(bins) do
		if vim.fn.executable(bin) == 1 then
			findings[bin] = true
		else
			findings[bin] = false
			ok = false
		end
	end
	return ok, findings
end

-- simply return bool for whether or not `bin` and all extras
-- for that binary are found
M.check_binaries = function(bin)
	local binaries = { bin, table.unpack(optional_binaries[bin] or {}) }
	local ok, _ = check_binaries(binaries)
	return ok
end

-- return which optional binary packages have been found present
M.installed_packages = function()
	local packages = {}
	for bin, _ in pairs(optional_binaries) do
		if M.check_binaries(bin) then
			table.insert(packages, bin)
		end
	end
	return packages
end

-- use check_binaries for all in `optional_binaries` to generate
-- a healthcheck report
local bin_report = function()
	for bin, extra in pairs(optional_binaries) do
		local _, findings = check_binaries({ bin, table.unpack(extra) })
		for bin, found in pairs(findings) do
			if found then
				health.ok(("`%s` found"):format(bin))
			else
				health.warn(("`%s` not found"):format(bin))
			end
		end
	end
end

local function lualib_installed(lib_name)
	local res, _ = pcall(require, lib_name)
	return res
end

local required_plugins = {
	{ lib = "plenary", optional = false },
	{ lib = "telescope", optional = false },
}

M.check = function()
	health.start("Checking for required plugins")
	for _, plugin in ipairs(required_plugins) do
		if lualib_installed(plugin.lib) then
			health.ok(plugin.lib .. " installed.")
		else
			local lib_not_installed = plugin.lib .. " not found."
			if plugin.optional then
				health.warn(("%s %s"):format(lib_not_installed, plugin.info))
			else
				health.error(lib_not_installed)
			end
		end
	end
	health.start("Checking for default renderers")
	bin_report()
end

return M
