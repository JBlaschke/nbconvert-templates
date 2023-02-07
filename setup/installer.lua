#!/usr/bin/env lua

local gears    = require "opt.lib.gears"
local lustache = require "lustache"
local sh       = require "sh"
local F        = require "F"

sh.__raise_errors = false

local function tolist(str)
    local t = {}
    for file in tostring(str):gmatch("[^\n]+") do
        table.insert(t, file)
    end
    return t
end


local home_dir = os.getenv("HOME")
local app_dir = sh.pushd("..") : pwd() : popd()
local jupyter_config_dir = F"{home_dir}/.jupyter"


local has_nbconvert_config_file = false
local config_files = sh.ls(jupyter_config_dir)
if config_files.__exitcode ~= 0 then
    print(F"Creating missing folder: {jupyter_config_dir}")
    sh.mkdir(jupyter_config_dir)
else
    for i, file in pairs(tolist(tostring(config_files))) do
        if file == "jupyter_nbconvert_config.py" then
            has_nbconvert_config_file = true
            break
        end
    end
end


if has_nbconvert_config_file then
    print(F"{jupyter_config_dir}/jupyter_nbconvert_config.py already exists")
    print(F"  => NOT creating symlink to {jupyter_config_dir}")
else
    sh.ln(
        "-s",
        F"{app_dir}/setup/var/jupyter_nbconvert_config.py",
        jupyter_config_dir
    )
end

print(F"Generating config in {app_dir}/setup/var")

-- read template file
local file = io.open(F"{app_dir}/setup/share/jupyter_nbconvert_config.py", "r")
local tmpl_file = file:read("*all")
file:close()

-- fill in script template
local tmpl_params = {
    MY_TEMPLATES = F"{app_dir}/templates"
}
local script = lustache:render(tmpl_file, tmpl_params)

-- save script file
local file = io.open(F"{app_dir}/setup/var/jupyter_nbconvert_config.py", "w")
file:write(script)
file:close()
