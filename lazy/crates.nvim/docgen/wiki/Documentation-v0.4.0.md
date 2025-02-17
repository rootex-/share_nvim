Documentation for `crates.nvim` `v0.4.0`

# Features
- Complete crate versions and features
- Completion sources for:
    - [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
    - [coq.nvim](https://github.com/ms-jpq/coq_nvim)
- [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)/[none-ls.nvim](https://github.com/nvimtools/none-ls.nvim) code actions
- Update crates to newest compatible version
- Upgrade crates to newest version
- Respect existing version requirements and update them in an elegant way (`smart_insert`)
- Automatically load when opening a `Cargo.toml` file (`autoload`)
- Live update while editing (`autoupdate`)
- Show version and upgrade candidates
    - Indicate if compatible version is a pre-release or yanked
    - Indicate if no version is compatible
- Open floating window with crate info
    - Open documentation, crates.io, repository and homepage urls
- Open floating window with crate versions
    - Select a version by pressing enter (`popup.keys.select`)
- Open floating window with crate features
    - Navigate the feature hierarchy
    - Enable/disable features
    - Indicate if a feature is enabled directly or transitively
- Open floating window with crate dependencies
    - Navigate the dependency hierarchy
    - Indicate if a dependency is optional

# Setup
## Auto completion
### [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source
Just add it to your list of sources.
```lua
require("cmp").setup {
    ...
    sources = {
        { name = "path" },
        { name = "buffer" },
        { name = "nvim_lsp" },
        ...
        { name = "crates" },
    },
}
```

<details>
<summary>Or add it lazily.</summary>

```lua
vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
    pattern = "Cargo.toml",
    callback = function()
        cmp.setup.buffer({ sources = { { name = "crates" } } })
    end,
})
```
</details>

### [coq.nvim](https://github.com/ms-jpq/coq_nvim) source
Enable it in the setup, and optionally change the display name.
```lua
require("crates").setup {
    ...
    src = {
        ...
        coq = {
            enabled = true,
            name = "crates.nvim",
        },
    },
}
```

## Code actions
### [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)/[none-ls.nvim](https://github.com/nvimtools/none-ls.nvim) source
Enable it in the setup, and optionally change the display name.
```lua
require("crates").setup {
    ...
    null_ls = {
        enabled = true,
        name = "crates.nvim",
    },
}
```

# Config

For more information about the type of some fields see [`teal/crates/config.tl`](teal/crates/config.tl).

## Default

The icons in the default configuration require a patched font.<br>
Any [Nerd Font](https://www.nerdfonts.com/font-downloads) should work.
```lua
require("crates").setup {
    smart_insert = true,
    insert_closing_quote = true,
    avoid_prerelease = true,
    autoload = true,
    autoupdate = true,
    autoupdate_throttle = 250,
    loading_indicator = true,
    date_format = "%Y-%m-%d",
    thousands_separator = ".",
    notification_title = "Crates",
    curl_args = { "-sL", "--retry", "1" },
    max_parallel_requests = 80,
    open_programs = { "xdg-open", "open" },
    disable_invalid_feature_diagnostic = false,
    text = {
        loading = "   Loading",
        version = "   %s",
        prerelease = "   %s",
        yanked = "   %s",
        nomatch = "   No match",
        upgrade = "   %s",
        error = "   Error fetching crate",
    },
    highlight = {
        loading = "CratesNvimLoading",
        version = "CratesNvimVersion",
        prerelease = "CratesNvimPreRelease",
        yanked = "CratesNvimYanked",
        nomatch = "CratesNvimNoMatch",
        upgrade = "CratesNvimUpgrade",
        error = "CratesNvimError",
    },
    popup = {
        autofocus = false,
        hide_on_select = false,
        copy_register = '"',
        style = "minimal",
        border = "none",
        show_version_date = false,
        show_dependency_version = true,
        max_height = 30,
        min_width = 20,
        padding = 1,
        text = {
            title = " %s",
            pill_left = "",
            pill_right = "",
            description = "%s",
            created_label = " created        ",
            created = "%s",
            updated_label = " updated        ",
            updated = "%s",
            downloads_label = " downloads      ",
            downloads = "%s",
            homepage_label = " homepage       ",
            homepage = "%s",
            repository_label = " repository     ",
            repository = "%s",
            documentation_label = " documentation  ",
            documentation = "%s",
            crates_io_label = " crates.io      ",
            crates_io = "%s",
            categories_label = " categories     ",
            keywords_label = " keywords       ",
            version = "  %s",
            prerelease = " %s",
            yanked = " %s",
            version_date = "  %s",
            feature = "  %s",
            enabled = " %s",
            transitive = " %s",
            normal_dependencies_title = " Dependencies",
            build_dependencies_title = " Build dependencies",
            dev_dependencies_title = " Dev dependencies",
            dependency = "  %s",
            optional = " %s",
            dependency_version = "  %s",
            loading = "  ",
        },
        highlight = {
            title = "CratesNvimPopupTitle",
            pill_text = "CratesNvimPopupPillText",
            pill_border = "CratesNvimPopupPillBorder",
            description = "CratesNvimPopupDescription",
            created_label = "CratesNvimPopupLabel",
            created = "CratesNvimPopupValue",
            updated_label = "CratesNvimPopupLabel",
            updated = "CratesNvimPopupValue",
            downloads_label = "CratesNvimPopupLabel",
            downloads = "CratesNvimPopupValue",
            homepage_label = "CratesNvimPopupLabel",
            homepage = "CratesNvimPopupUrl",
            repository_label = "CratesNvimPopupLabel",
            repository = "CratesNvimPopupUrl",
            documentation_label = "CratesNvimPopupLabel",
            documentation = "CratesNvimPopupUrl",
            crates_io_label = "CratesNvimPopupLabel",
            crates_io = "CratesNvimPopupUrl",
            categories_label = "CratesNvimPopupLabel",
            keywords_label = "CratesNvimPopupLabel",
            version = "CratesNvimPopupVersion",
            prerelease = "CratesNvimPopupPreRelease",
            yanked = "CratesNvimPopupYanked",
            version_date = "CratesNvimPopupVersionDate",
            feature = "CratesNvimPopupFeature",
            enabled = "CratesNvimPopupEnabled",
            transitive = "CratesNvimPopupTransitive",
            normal_dependencies_title = "CratesNvimPopupNormalDependenciesTitle",
            build_dependencies_title = "CratesNvimPopupBuildDependenciesTitle",
            dev_dependencies_title = "CratesNvimPopupDevDependenciesTitle",
            dependency = "CratesNvimPopupDependency",
            optional = "CratesNvimPopupOptional",
            dependency_version = "CratesNvimPopupDependencyVersion",
            loading = "CratesNvimPopupLoading",
        },
        keys = {
            hide = { "q", "<esc>" },
            open_url = { "<cr>" },
            select = { "<cr>" },
            select_alt = { "s" },
            toggle_feature = { "<cr>" },
            copy_value = { "yy" },
            goto_item = { "gd", "K", "<C-LeftMouse>" },
            jump_forward = { "<c-i>" },
            jump_back = { "<c-o>", "<C-RightMouse>" },
        },
    },
    src = {
        insert_closing_quote = true,
        text = {
            prerelease = "  pre-release ",
            yanked = "  yanked ",
        },
        coq = {
            enabled = false,
            name = "Crates",
        },
    },
    null_ls = {
        enabled = false,
        name = "Crates",
    },
    on_attach = function(bufnr) end,
}
```

## Plain text

Replace these fields if you don"t have a patched font.
```lua
require("crates").setup {
    text = {
        loading = "  Loading...",
        version = "  %s",
        prerelease = "  %s",
        yanked = "  %s yanked",
        nomatch = "  Not found",
        upgrade = "  %s",
        error = "  Error fetching crate",
    },
    popup = {
        text = {
            title = "# %s",
            pill_left = "",
            pill_right = "",
            created_label = "created        ",
            updated_label = "updated        ",
            downloads_label = "downloads      ",
            homepage_label = "homepage       ",
            repository_label = "repository     ",
            documentation_label = "documentation  ",
            crates_io_label = "crates.io      ",
            categories_label = "categories     ",
            keywords_label = "keywords       ",
            version = "%s",
            prerelease = "%s pre-release",
            yanked = "%s yanked",
            enabled = "* s",
            transitive = "~ s",
            normal_dependencies_title = "  Dependencies",
            build_dependencies_title = "  Build dependencies",
            dev_dependencies_title = "  Dev dependencies",
            optional = "? %s",
            loading = " ...",
        },
    },
    src = {
        text = {
            prerelease = " pre-release ",
            yanked = " yanked ",
        },
    },
}
```

## Functions
```lua
-- Setup config and auto commands.
require("crates").setup(cfg: Config)

-- Disable UI elements (virtual text and diagnostics).
require("crates").hide()
-- Enable UI elements (virtual text and diagnostics).
require("crates").show()
-- Enable or disable UI elements (virtual text and diagnostics).
require("crates").toggle()
-- Update data. Optionally specify which `buf` to update.
require("crates").update(buf: integer|nil)
-- Reload data (clears cache). Optionally specify which `buf` to reload.
require("crates").reload(buf: integer|nil)

-- Upgrade the crate on the current line.
-- If the `alt` flag is passed as true, the opposite of the `smart_insert` config
-- option will be used to insert the version.
require("crates").upgrade_crate(alt: boolean|nil)
-- Upgrade the crates on the lines visually selected.
-- See `crates.upgrade_crate()`.
require("crates").upgrade_crates(alt: boolean|nil)
-- Upgrade all crates in the buffer.
-- See `crates.upgrade_crate()`.
require("crates").upgrade_all_crates(alt: boolean|nil)

-- Update the crate on the current line.
-- See `crates.upgrade_crate()`.
require("crates").update_crate(alt: boolean|nil)
-- Update the crates on the lines visually selected.
-- See `crates.upgrade_crate()`.
require("crates").update_crates(alt: boolean|nil)
-- Update all crates in the buffer.
-- See `crates.upgrade_crate()`.
require("crates").update_all_crates(alt: boolean|nil)

-- Expand a plain crate declaration into an inline table.
require("crates").expand_plain_crate_to_inline_table()
-- Extract an crate declaration from a dependency section into a table.
require("crates").extract_crate_into_table()

-- Open the homepage of the crate on the current line.
require("crates").open_homepage()
-- Open the repository page of the crate on the current line.
require("crates").open_repository()
-- Open the documentation page of the crate on the current line.
require("crates").open_documentation()
-- Open the `crates.io` page of the crate on the current line.
require("crates").open_crates_io()

-- Returns whether there is information to show in a popup.
require("crates").popup_available(): boolean
-- Show/hide popup with crate details, all versions, all features or details about one feature.
-- If `popup.autofocus` is disabled calling this again will focus the popup.
require("crates").show_popup()
-- Same as `crates.show_popup()` but always show crate details.
require("crates").show_crate_popup()
-- Same as `crates.show_popup()` but always show versions.
require("crates").show_versions_popup()
-- Same as `crates.show_popup()` but always show features or features details.
require("crates").show_features_popup()
-- Same as `crates.show_popup()` but always show depedencies.
require("crates").show_dependencies_popup()
-- Focus the popup (jump into the floating window).
-- Optionally specify the line to jump to, inside the popup.
require("crates").focus_popup(line: integer|nil)
-- Hide the popup.
require("crates").hide_popup()
```

## Key mappings
Some examples of key mappings.
```lua
local crates = require("crates")
local opts = { silent = true }

vim.keymap.set("n", "<leader>ct", crates.toggle, opts)
vim.keymap.set("n", "<leader>cr", crates.reload, opts)

vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, opts)
vim.keymap.set("n", "<leader>cf", crates.show_features_popup, opts)
vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup, opts)

vim.keymap.set("n", "<leader>cu", crates.update_crate, opts)
vim.keymap.set("v", "<leader>cu", crates.update_crates, opts)
vim.keymap.set("n", "<leader>ca", crates.update_all_crates, opts)
vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, opts)
vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, opts)
vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, opts)

vim.keymap.set("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, opts)
vim.keymap.set("n", "<leader>cX", crates.extract_crate_into_table, opts)

vim.keymap.set("n", "<leader>cH", crates.open_homepage, opts)
vim.keymap.set("n", "<leader>cR", crates.open_repository, opts)
vim.keymap.set("n", "<leader>cD", crates.open_documentation, opts)
vim.keymap.set("n", "<leader>cC", crates.open_crates_io, opts)
```

<details>
<summary>In vimscript</summary>

```vim
nnoremap <silent> <leader>ct :lua require("crates").toggle()<cr>
nnoremap <silent> <leader>cr :lua require("crates").reload()<cr>

nnoremap <silent> <leader>cv :lua require("crates").show_versions_popup()<cr>
nnoremap <silent> <leader>cf :lua require("crates").show_features_popup()<cr>
nnoremap <silent> <leader>cd :lua require("crates").show_dependencies_popup()<cr>

nnoremap <silent> <leader>cu :lua require("crates").update_crate()<cr>
vnoremap <silent> <leader>cu :lua require("crates").update_crates()<cr>
nnoremap <silent> <leader>ca :lua require("crates").update_all_crates()<cr>
nnoremap <silent> <leader>cU :lua require("crates").upgrade_crate()<cr>
vnoremap <silent> <leader>cU :lua require("crates").upgrade_crates()<cr>
nnoremap <silent> <leader>cA :lua require("crates").upgrade_all_crates()<cr>

nnoremap <silent> <leader>cx :lua require("crates").expand_plain_crate_to_inline_table()<cr>
nnoremap <silent> <leader>cX :lua require("crates").extract_crate_into_table()<cr>

nnoremap <silent> <leader>cH :lua require("crates").open_homepage()<cr>
nnoremap <silent> <leader>cR :lua require("crates").open_repository()<cr>
nnoremap <silent> <leader>cD :lua require("crates").open_documentation()<cr>
nnoremap <silent> <leader>cC :lua require("crates").open_crates_io()<cr>
```
</details>

## Show appropriate documentation in `Cargo.toml`
How you might integrate `show_popup` into your `init.vim`.
```vim
nnoremap <silent> K :call <SID>show_documentation()<cr>
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (index(['man'], &filetype) >= 0)
        execute 'Man '.expand('<cword>')
    elseif (expand('%:t') == 'Cargo.toml' && luaeval('require("crates").popup_available()'))
        lua require('crates').show_popup()
    else
        lua vim.lsp.buf.hover()
    endif
endfunction
```

How you might integrate `show_popup` into your `init.lua`.
```lua
local function show_documentation()
    local filetype = vim.bo.filetype
    if vim.tbl_contains({ 'vim','help' }, filetype) then
        vim.cmd('h '..vim.fn.expand('<cword>'))
    elseif vim.tbl_contains({ 'man' }, filetype) then
        vim.cmd('Man '..vim.fn.expand('<cword>'))
    elseif vim.fn.expand('%:t') == 'Cargo.toml' and require('crates').popup_available() then
        require('crates').show_popup()
    else
        vim.lsp.buf.hover()
    end
end

vim.keymap.set('n', 'K', show_documentation, { silent = true })
```
