-- mepholic's stuff
local toml = require("toml")

-- Read in YAML configuraion to a variable
local config_file = os.getenv("HOME") .. "/.config/awesome/config.toml"
local config_fd = io.open(config_file, "r")
io.input(config_fd)
local config_raw = io.read("*all")
io.close(config_fd)

-- Parse YAML config
local config = toml.parse(config_raw)

-- Default Profile
local default_profile = config.default_profile

-- Bind profile tables to default profile
bind_table = { }
bind_table.__index = function(t,k)
   return default_profile[k]
end

for p in pairs(config.profiles) do
   -- Bind the profiles
   setmetatable(config.profiles[p], bind_table)
end

-- Put together public interface
local tconfig = {}
tconfig.profile = config.profiles
--local tconfig = config
return tconfig
