#!/usr/bin/lua

require("nixio.util")
require("luci.http")
require("luci.sys")

local bridge = "br-lan"

function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

function getmodel()
	local cpuinfo =nixio.fs.readfile("/proc/cpuinfo")
	return string.match(cpuinfo,"machine%s+:%s([^\n]*)")
end

function getwirelessinfo()
	local uci = luci.model.uci.cursor()
	local channel = uci.get("wireless","ra0","channel")
	local txpower = uci.get("wireless","ra0","txpower")
	local ssid = uci:get_first("wireless","wifi-iface","ssid")
	return channel,txpower,ssid
end

function getipmac()
	local lan = luci.util.exec("ifconfig "..bridge)
	local mac = nixio.fs.readfile("/sys/devices/virtual/net/"..bridge.."/address")
	local ip = string.match(lan, "inet addr:(%d+.%d+.%d+.%d+)")
	local mac= string.upper(string.sub(string.gsub(mac,":",""),1,-2))
	return ip,mac
end


local machine = getmodel()
local ip,mac =getipmac()
local channel, txpower, ssid = getwirelessinfo()
print(txpower, channel, ssid,ip,mac)

local command={
	"wget -q -O - \"",
	"http://192.168.1.136/cgi-bin/apsync",
	"?MAC=", mac,
	"&TXPOWER=",txpower,
	"&CHANNEL=",channel,
	"&SSID=",urlencode(ssid),
	"&MODEL=",urlencode(machine),
	"&IP=",urlencode(ip),
	'"'
}
print(table.concat(command))
local response = luci.util.exec(table.concat(command))

print(response)