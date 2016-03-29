-- mepholic's stuff
local toml = require("toml")

-- Read in YAML configuraion to a variable
local config_file = os.getenv("HOME") .. "/.config/awesome/config.toml"
local config_fd = io.open(config_file, "r")
io.input(config_fd)
local config_raw = io.read("*all")
io.close(config_fd)

-- Parse YAML config
config = toml.parse(config_raw)

-- Put together public interface
local tconfig = {}
tconfig.profile = config.profiles
return tconfig
