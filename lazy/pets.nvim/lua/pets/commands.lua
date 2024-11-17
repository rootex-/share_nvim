local pets = require("pets")
local utils = require("pets.utils")

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    callback = function()
        pets.refresh()
    end,
})

vim.api.nvim_create_user_command("PetsNew", function(input)
    local pet, style = pets.options.default_pet, pets.options.default_style

    -- validate the pets and style options
    if not utils.validate_type_style(pet, style) then
        return
    end

    if pets.options.random then
        local pet_types = {}
        for k in pairs(utils.available_pets) do
            table.insert(pet_types, k)
        end
        pet = pet_types[math.random(#pet_types)]
        local styles = utils.available_pets[pet]
        style = styles[math.random(#styles)]
    end

    pets.create_pet(input.args, pet, style)
end, { nargs = 1 })

vim.api.nvim_create_user_command("PetsNewCustom", function(input)
    local args = vim.split(input.args, " ", { trimempty = true })
    if #args ~= 3 then
        utils.warning("Inccorect number of arguments!\nUSAGE: PetsNewCustom {type} {style} {name}")
        return
    end
    local type, style, name = args[1], args[2], args[3]
    if not utils.validate_type_style(type, style) then
        return
    end
    pets.create_pet(name, type, style)
end, { nargs = 1, complete = utils.complete_typestyle })

vim.api.nvim_create_user_command("PetsKillAll", function()
    pets.kill_all()
end, {})
vim.api.nvim_create_user_command("PetsRemoveAll", function()
    pets.remove_all()
end, {})

vim.api.nvim_create_user_command("PetsKill", function(input)
    pets.kill_pet(input.args)
end, {
    nargs = 1,
    complete = utils.complete_name,
})
vim.api.nvim_create_user_command("PetsRemove", function(input)
    pets.remove_pet(input.args)
end, {
    nargs = 1,
    complete = utils.complete_name,
})

vim.api.nvim_create_user_command("PetsList", function()
    pets.list()
end, {})

vim.api.nvim_create_user_command("PetsPauseToggle", function()
    pets.toggle_pause()
end, {})

vim.api.nvim_create_user_command("PetsHideToggle", function()
    pets.toggle_hide()
end, {})

vim.api.nvim_create_user_command("PetsIdleToggle", function()
    pets.toggle_idle()
end, {})
vim.api.nvim_create_user_command("PetsSleepToggle", function()
    pets.toggle_idle()
end, {})
