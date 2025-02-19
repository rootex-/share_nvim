local M = {}
local utils = require("pets.utils")

M.paused = false
M.paused = false
M.idle = false

M.options = {
    row = 1, -- the row (height) to display the pet at
    col = 0, -- the column to display the pet at (set to high numeber to have it stay stil at the right)
    speed_multiplier = 1,
    default_pet = "dog",
    default_style = "brown",
    random = true,
    death_animation = true,
    popup = { width = "30%", winblend = 100, hl = { Normal = "Normal" }, avoid_statusline = false },
}

M.pets = {}

function M.setup(options)
    options = options or {}
    M.options = vim.tbl_deep_extend("force", M.options, options)

    -- popup opts
    local popup_opts = {
        position = {
            row = "100%",
            col = "100%",
        },
        relative = "editor",
        size = {
            width = M.options.popup.width,
            height = 10,
        },
        focusable = false,
        enter = false,
        win_options = {
            winblend = M.options.popup.winblend,
        },
    }
    if M.options.popup.avoid_statusline then
        local hl = utils.parse_popup_hl(M.options.popup.hl)
        popup_opts.position.row = "99%"
        popup_opts.win_options = { winhighlight = hl }
    end
    M.options.popup = popup_opts

    -- init hologram
    local ok = pcall(require, "hologram")
    if ok then
        require("hologram").setup({ auto_display = false })
    end

    require("pets.commands") -- init autocommands
end

-- create a Pet object and add it to the pets table
function M.create_pet(name, type, style)
    if M.pets[name] ~= nil then
        utils.warning('Name "' .. name .. '" already in use')
        return
    end
    local state = {
        paused = M.paused,
        hidden = M.paused,
        idle = M.idle,
    }
    local pet = require("pets.pet").Pet.new(name, type, style, M.options, state)
    pet:animate()
    M.pets[pet.name] = pet
end

function M.kill_pet(name)
    if M.pets[name] ~= nil then
        M.pets[name]:kill()
        M.pets[name] = nil
    else
        utils.warning("Couldn't find a pet named \"" .. name .. '"')
    end
end

function M.remove_pet(name)
    if M.pets[name] ~= nil then
        M.pets[name]:remove()
        M.pets[name] = nil
    else
        utils.warning("Couldn't find a pet named \"" .. name .. '"')
    end
end

function M.kill_all()
    for _, pet in pairs(M.pets) do
        pet:kill()
    end
    M.pets = {}
end

function M.remove_all()
    for _, pet in pairs(M.pets) do
        pet:remove()
    end
    M.pets = {}
end

function M.list()
    local empty = true
    for pet in pairs(M.pets) do
        print(pet)
        empty = false
    end
    if empty then
        print("You have no pets :(")
    end
end

function M.toggle_pause()
    M.paused = not M.paused
    for _, pet in pairs(M.pets) do
        pet:set_paused(M.paused)
    end
end

function M.toggle_hide()
    M.hidden = not M.hidden
    if M.hidden then -- Hiding relies on the pets being paused as well
        M.paused = true
    else
        M.paused = false
    end
    for _, pet in pairs(M.pets) do
        pet:set_hidden(M.paused)
    end
end

function M.toggle_idle()
    M.idle = not M.idle
    for _, pet in pairs(M.pets) do
        pet:set_idle(M.idle)
    end
end

function M.refresh()
    for _, pet in pairs(M.pets) do
        pet:refresh_popup()
    end
end

return M
