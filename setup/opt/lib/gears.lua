#!/usr/bin/env lua

-- add this project's library path to the package path (assuming that the main
-- runtime will be from a lua file in the same directory as opt
package.path = "./opt/lib/?.lua" .. ";" .. package.path

local M = {}

local F     = require "F"
local posix = require "posix"
local sh    = require "sh"


--[[ function to retun the path of the current file --]]
function M.thisdir(level)
    local level = level or 2
    local pth = debug.getinfo(level).source:match("@?(.*/)")
    -- if this program is called within the current directory then the path
    -- won't contain '/', returning (nil)
    if pth == nil then
        return "."
    end
    -- remember to remove the traling slash
    return pth:sub(1, -2)
end


--[[ function to run `cmd` in directory with `dir` --]]
function M.run(dir, cmd)
    local handle = assert(io.popen(F"cd {dir}; {cmd} 2>&1", "r"))
    handle:flush()
    local output = handle:read("*all")
    local rc     = {handle:close()}

    return output, rc
end

function M.sh(dir, cmd)
    local output, rc = M.run(dir, cmd)
    print(output)
    return rc
end


function M.parse_version(version_str)
    local k = 0
    local t = {}

    for i in string.gmatch(version_str, '(%d+)') do
        t[k] = i
        k = k + 1
    end

    return t
end


function M.file_exists(name)
   local f = io.open(name, "r")

   if f == nil then
       return false
   end

   io.close(f)
   return true
end


function M.isdir(fn)
    return (posix.stat(fn, "type") == "directory")
end


function M.dir_exists(name)
    return M.isdir(name)
end


function M.ensure_dir(name)
    sh.mkdir("-p", name)
end


function M.mk_log_dir(self, dir, nr)
    -- lua has the same random seed every time it starts
    math.randomseed( os.time() )

    local rs = F"{dir}/logs/"
    for i = 1, nr do
        rs = rs .. string.char(math.random(97, 97 + 25))
    end
    self.ensure_dir(rs)
    self.LOG_DIR = rs
    return rs
end


function M.log_sh(self, name)
    local file = io.open(F"{self.LOG_DIR}/{name}.out", "a")
    file:write(sh.stdout(CMD))
    file:close()
    local file = io.open(F"{self.LOG_DIR}/{name}.err", "a")
    file:write(sh.stderr(CMD))
    file:close()
end

return M
