local M = {}
M.Animation = {}
M.Animation.__index = M.Animation

-- lines to insert in the buffer to avoid image stretching
local lines = {}

local utils = require("pets.utils")
local listdir = utils.listdir

-- @param sourcedir the full path for the media directory
-- @param type,style type and style of the pet
-- @param popup the popup where the pet is displayed
-- @param user_opts table with user options
-- @param state table with the current plugin state (idle, paused, hidden)
-- @return a new animation instance
function M.Animation.new(sourcedir, type, style, popup, user_opts, state)
    local instance = setmetatable({}, M.Animation)
    instance.type = type
    instance.style = style
    instance.frame_counter = 1
    instance.actions = listdir(sourcedir)
    instance.frames = {}
    instance.popup = popup
    instance.state = state

    for _ = 1, instance.popup._.layout.size.height do
        table.insert(lines, " ")
    end

    -- user options
    instance.speed_multiplier = user_opts.speed_multiplier
    if user_opts.col > popup.win_config.width - 8 then
        M.base_col = popup.win_config.width - 8
    else
        M.base_col = user_opts.col
    end
    instance.row, instance.col = user_opts.row, math.random(M.base_col, popup.win_config.width - 8)

    -- setup frames
    for _, action in pairs(instance.actions) do
        local current_frames = {}
        for _, file in pairs(listdir(sourcedir .. action)) do
            local image = require("hologram.image"):new(sourcedir .. action .. "/" .. file)
            table.insert(current_frames, image)
        end
        instance.frames[action] = current_frames
    end

    -- setup pet-specific values
    -- extend the table to not get errors when something is not specified (i.e. left movements)
    local pet = vim.tbl_deep_extend("keep", require("pets.pets." .. type), utils.default_pet_table)
    instance.next_actions = pet.next_actions
    instance.idle_actions = pet.idle_actions
    instance.movements = pet.movements
    instance.first_action = pet.first_action
    instance.get_death_animation = pet.get_death_animation

    return instance
end

function M.Animation:start_timer()
    if self.timer ~= nil then
        self:stop_timer()
    end
    self.timer = vim.loop.new_timer()
    self.timer:start(0, 1000 / (self.speed_multiplier * 8), function()
        vim.schedule(function()
            M.Animation.next_frame(self)
        end)
    end)
end

function M.Animation:stop_timer()
    if self.timer == nil then
        return
    end
    self.timer:stop()
    self.timer:close()
    self.timer = nil
end

-- @param bufnr buffer number of the popup
-- @function start the animation
function M.Animation:start()
    if self.timer ~= nil then -- reset timer
        self.timer = nil
    end
    self.repetitions = 0

    if self.state.idle then
        self.current_action = self.idle_actions[math.random(#self.idle_actions)]
    else
        self.current_action = self.current_action or self.first_action
    end

    if not self.state.paused and not self.state.hidden then
        M.Animation.start_timer(self)
    elseif self.state.paused and not self.state.hidden then
        vim.schedule(function()
            M.Animation.next_frame(self)
        end)
    end
end

function M.Animation:stop()
    if self.current_image then
        self.current_image:delete(0, { free = false })
    end
    self:stop_timer()
end

-- @function called on every tick from the timer, go to the next frame
function M.Animation:next_frame()
    -- pouplate the buffer with spaces to avoid image distortion
    if self.popup.bufnr == nil or not vim.api.nvim_buf_is_valid(self.popup.bufnr) then
        return
    end
    vim.api.nvim_buf_set_lines(self.popup.bufnr, 0, -1, false, lines)
    if not self.current_image then
        self.frame_counter = 1
    else
        self.current_image:delete(0, { free = false })
    end
    if self.frame_counter > #self.frames[self.current_action] then -- what to do when current frames end
        self.repetitions = self.repetitions + 1
        -- if the animation has less than 2 frames loop it until it lasted 8 frames
        if #self.frames[self.current_action] > 2 or self.repetitions * #self.frames[self.current_action] >= 8 then
            M.Animation.set_next_action(self)
            self.repetitions = 0
        end
        if self.dead then
            self:stop()
            return
        end
        self.frame_counter = 1 -- reset the frame counter
    end
    -- the frames table contains the images for every action
    local image = self.frames[self.current_action][self.frame_counter]
    M.Animation.set_next_col(self)
    local ok = pcall(image.display, image, self.row, self.col, self.popup.bufnr, {})
    if not ok then
        self:stop()
        if self.popup then
            self.popup:unmount()
        end
        if self.current_image then
            self.current_image:delete()
        end
        if not self.hidden then
            self.popup:mount()
            self:start()
        end
    end
    self.current_image = image
    self.frame_counter = self.frame_counter + 1
end

-- @function decide which action comes after the current_action
function M.Animation:set_next_action()
    if self.dying then
        if vim.startswith(self.current_action, "die") or vim.endswith(self.current_action, "die") then
            self.dead = true
            M.Animation.stop(self)
            self.popup:unmount()
        end
        self.current_action = self.get_death_animation(self.current_action)
        return
    end
    if self.state.idle then
        -- If the animation isn't currently a idle animtion, put the pet in it, otherwise loop the animation
        if not vim.tbl_contains(self.idle_actions, self.current_action) then
            self.current_action = self.idle_actions[math.random(#self.idle_actions)]
        end
    else
        if math.random() < 0.5 then -- 50% chance to keep doing the current action
            self.current_action =
                self.next_actions[self.current_action][math.random(#self.next_actions[self.current_action])]
        else
            self.current_action = self.next_actions[self.current_action][1]
        end
    end
end

-- @function set horizontal movement per frame based on current action
function M.Animation:set_next_col()
    local width = self.popup.win_config.width
    if vim.tbl_contains(self.movements.right.normal, self.current_action) then
        if self.col < width - 8 then
            self.col = self.col + 1
        else
            self.col = M.base_col
        end
    elseif vim.tbl_contains(self.movements.right.fast, self.current_action) then
        if self.col < width - 8 then
            self.col = self.col + 2
        else
            self.col = M.base_col
        end
    elseif vim.tbl_contains(self.movements.right.slow, self.current_action) then
        if self.col < width - 8 then
            if #self.frames[self.current_action] <= 2 then -- if there is only one frame in the current action
                if self.repetitions % 2 == 0 then -- then use repetitions as a counter
                    self.col = self.col + 1
                end
            else
                if self.frame_counter % 2 == 0 then
                    self.col = self.col + 1
                end
            end
        else
            self.col = M.base_col
        end
    elseif vim.tbl_contains(self.movements.left.normal, self.current_action) then
        if self.col > M.base_col then
            self.col = self.col - 1
        else
            self.col = width - 8
        end
    elseif vim.tbl_contains(self.movements.left.fast, self.current_action) then
        if self.col > M.base_col then
            self.col = self.col - 2
        else
            self.col = width - 8
        end
    elseif vim.tbl_contains(self.movements.left.slow, self.current_action) then
        if self.col > M.base_col then
            if #self.frames[self.current_action] < 2 then -- if there is only one frame in the current action
                if self.repetitions % 2 == 0 then -- then use repetitions as a counter
                    self.col = self.col - 1
                end
            else
                if self.frame_counter % 2 == 0 then
                    self.col = self.col - 1
                end
            end
        else
            self.col = width - 8
        end
    end
end

function M.Animation:set_state(new_state)
    for key, value in pairs(new_state) do
        self.state[key] = value
    end

    if new_state.hidden ~= nil then
        if self.state.hidden then
            self:stop_timer()
            if self.current_image then
                self.current_image:delete(0, { free = false })
            end
            self.popup:unmount()
        else
            self.popup:mount()
            self:start()
        end
    elseif new_state.paused ~= nil then
        if self.state.paused then
            self:stop_timer()
        else
            if self.current_image then
                self.current_image:delete(0, { free = false })
            end
            self:start()
        end
    end
end

return M
