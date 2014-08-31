--[[
LuCI - Lua Configuration Interface

Copyright 2014 bywayboy <bywayboy@qq.com>

]]--

module("luci.controller.jmlicense", package.seeall)

function index()
	
	local page

	page = entry({"admin", "system", "licensekey"}, call("action_licensekey"), _("License Key"))
	page.dependent = true

end

function action_licensekey()
	local sys = require "luci.sys"
	local fs  = require "luci.fs"
	local license_file = "/etc/licensekey"
	local license_key_value = luci.http.formvalue("license_key")
	
	if license_key_value then
		-- write to file
		nixio.fs.writefile(license_file, license_key_value);
	else
		license_key_value=nixio.fs.readfile(license_file)
	end

	local expires = nixio.fs.readfile("/etc/licenseconfig")	
	luci.template.render("admin_system/licensekey", {
		license_key   = license_key_value,
		expired	=	expires
	});
end

