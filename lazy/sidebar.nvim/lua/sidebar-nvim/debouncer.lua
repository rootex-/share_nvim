local luv = vim.loop

local Debouncer = {}

function Debouncer:new(fn, delay)
    local o = { fn = fn, delay = delay, locked = false }

    setmetatable(o, self)
    self.__index = self

    return o
end

function Debouncer:start_timer()
    if self.timer then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
    end

    self.timer = luv.new_timer()
    self.timer:start(
        self.delay,
        0,
        vim.schedule_wrap(function()
            self.locked = false
            self.timer:stop()
            self.timer:close()
            self.timer = nil
        end)
    )
end

function Debouncer:call(...)
    local args = { ... }
    vim.schedule(function()
        if self.locked then
            return
        end

        self.locked = true
        self.fn(unpack(args))
        self:start_timer()
    end)
end

return Debouncer
