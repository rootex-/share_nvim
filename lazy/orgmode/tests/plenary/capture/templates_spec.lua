local Template = require('orgmode.capture.template')
local Date = require('orgmode.objects.date')

describe('Capture template', function()
  it('should compile expression', function()
    ---Backup and restore the clipboard
    local clip_backup = vim.fn.getreg('+')
    vim.fn.setreg('+', 'test')
    local template = Template:new({
      template = '* TODO\n%<%Y-%m-%d>\n%t\n%T--%T\n%<%H:%M>\n%<%A>\n%x\n%(return string.format("hello %s", "world"))',
    })

    assert.are.same({
      '* TODO',
      os.date('%Y-%m-%d'),
      '<' .. os.date('%Y-%m-%d %a') .. '>',
      '<' .. os.date('%Y-%m-%d %a %H:%M') .. '>--<' .. os.date('%Y-%m-%d %a %H:%M') .. '>',
      os.date('%H:%M'),
      os.date('%A'),
      'test',
      'hello world',
    }, template:compile():wait())

    vim.fn.setreg('+', clip_backup)
  end)

  it('should escape the compiled content', function()
    ---Backup and restore the clipboard
    local clip_backup = vim.fn.getreg('+')
    vim.fn.setreg('+', 'nvim-orgmode%20is%20great!')
    local template = Template:new({
      template = '* TODO [[%x][]]\n',
    })

    assert.are.same({
      '* TODO [[nvim-orgmode%20is%20great!][]]',
      '',
    }, template:compile():wait())
    vim.fn.setreg('+', clip_backup)
  end)

  it('gets current date for datetree enabled with true', function()
    local template = Template:new({
      template = '* %?',
      datetree = true,
    })

    assert.are.same(Date.today():to_string(), template:get_datetree_opts().date:to_string())
  end)

  it('gets a proper date for datetree enabled as time prompt', function()
    local date = Date.today():subtract({ month = 2 })
    local template = Template:new({
      template = '* %?',
      datetree = {
        time_prompt = true,
        date = date,
      },
    })

    assert.are.same(date:to_string(), template:get_datetree_opts().date:to_string())
  end)

  it('should process custom compile hooks', function()
    local template = Template:new({
      template = '* This is a test {title} and {slug} in headline',
    })
    template:on_compile(function(content)
      content = content:gsub('{title}', 'Org Test')
      content = content:gsub('{slug}', 'org-test')
      return content
    end)
    assert.are.same({ '* This is a test Org Test and org-test in headline' }, template:compile():wait())
  end)

  it('should return nil if custom compile hooks return nil', function()
    local template = Template:new({
      template = '* This is a test {title} and {slug} in headline',
    })
    template:on_compile(function(content)
      content = content:gsub('{title}', 'Org Test')
      content = content:gsub('{slug}', 'org-test')
      return content
    end)
    template:on_compile(function()
      return nil
    end)
    assert.is.Nil(template:compile():wait())
  end)
end)
