--[[
    file: Dirman-Utils
    summary: A set of utilities for the `core.dirman` module.
    internal: true
    ---
This internal submodule implements some basic utility functions for [`core.dirman`](@core.dirman).
Currently the only exposed API function is `expand_path`, which takes a path like `$name/my/location` and
converts `$name` into the full path of the workspace called `name`.
--]]

local Path = require("pathlib")

local neorg = require("neorg.core")
local log, modules = neorg.log, neorg.modules

local module = neorg.modules.create("core.dirman.utils")

---@class core.dirman.utils
module.public = {
    ---Resolve `$<workspace>/path/to/file` and return the real path
    ---@param path string | PathlibPath # path
    ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path and append ".norg"
    ---@param host_file string | PathlibPath | nil file the link resides in, if the link is relative, this file is used instead of the current file
    ---@return PathlibPath?, boolean? # Resolved path. If path does not start with `$` or not absolute, adds relative from current file.
    expand_pathlib = function(path, raw_path, host_file)
        local relative = false
        if not host_file then
            host_file = vim.fn.expand("%:p")
        end
        local filepath = Path(path)
        -- Expand special chars like `$`
        local custom_workspace_path = filepath:match("^%$([^/\\]*)[/\\]")
        if custom_workspace_path then
            ---@type core.dirman
            local dirman = modules.get_module("core.dirman")
            if not dirman then
                log.error(table.concat({
                    "Unable to jump to link with custom workspace: `core.dirman` is not loaded.",
                    "Please load the module in order to get workspace support.",
                }, " "))
                return
            end
            -- If the user has given an empty workspace name (i.e. `$/myfile`)
            if custom_workspace_path:len() == 0 then
                filepath = dirman.get_current_workspace()[2] / filepath:relative_to(Path("$"))
            else -- If the user provided a workspace name (i.e. `$my-workspace/myfile`)
                local workspace = dirman.get_workspace(custom_workspace_path)
                if not workspace then
                    local msg = "Unable to expand path: workspace '%s' does not exist"
                    log.warn(string.format(msg, custom_workspace_path))
                    return
                end
                filepath = workspace / filepath:relative_to(Path("$" .. custom_workspace_path))
            end
        elseif filepath:is_relative() then
            relative = true
            local this_file = Path(host_file):absolute()
            filepath = this_file:parent_assert() / filepath
        else
            filepath = filepath:absolute()
        end
        -- requested to expand norg file
        if not raw_path then
            if type(path) == "string" and (path:sub(#path) == "/" or path:sub(#path) == "\\") then
                -- if path ends with `/`, it is an invalid request!
                log.error(table.concat({
                    "Norg file location cannot point to a directory.",
                    string.format("Current link points to '%s'", path),
                    "which ends with a `/`.",
                }, " "))
                return
            end
            filepath = filepath:add_suffix(".norg")
        end
        return filepath, relative
    end,

    ---Call attempt to edit a file, catches and suppresses the error caused by a swap file being
    ---present. Re-raises other errors via log.error
    ---@param path string
    edit_file = function(path)
        local ok, err = pcall(vim.cmd.edit, path)
        if not ok then
            -- Vim:E325 is the swap file error, in which case, a lengthy message already shows to
            -- the user, and we don't have to crash out of this function (which creates a long and
            -- misleading error message).
            if err and not err:match("Vim:E325") then
                log.error("Failed to edit file %s. Error:\n%s"):format(path, err)
            end
        end
    end,

    ---Resolve `$<workspace>/path/to/file` and return the real path
    -- NOTE: Use `expand_pathlib` which returns a PathlibPath object instead.
    ---
    ---\@deprecate Use `expand_pathlib` which returns a PathlibPath object instead. TODO: deprecate this <2024-03-27>
    ---@param path string|PathlibPath # path
    ---@param raw_path boolean? # If true, returns resolved path, otherwise, returns resolved path and append ".norg"
    ---@return string? # Resolved path. If path does not start with `$` or not absolute, adds relative from current file.
    expand_path = function(path, raw_path)
        local res = module.public.expand_pathlib(path, raw_path)
        return res and res:tostring() or nil
    end,
}

return module
