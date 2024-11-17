local org = require('orgmode')
local utils = require('orgmode.utils')
local fs = require('orgmode.utils.fs')
local Url = require('orgmode.org.hyperlinks.url')
local Link = require('orgmode.org.hyperlinks.link')
local config = require('orgmode.config')
local Hyperlinks = {
  stored_links = {},
}

---@param url OrgUrl
local function get_file_from_url(url)
  local file_path = url:get_file()
  local canonical_path = file_path and fs.get_real_path(file_path)
  return canonical_path and org.files:get(canonical_path) or org.files:get_current_file()
end

---@param url OrgUrl
---@return string[]
function Hyperlinks.find_by_filepath(url)
  local filenames = org.files:filenames()
  local file_base = url:get_file()
  if not file_base then
    return {}
  end
  --TODO integrate with orgmode.utils.fs or orgmode.objects.url
  local valid_filenames = {}
  for _, f in ipairs(filenames) do
    if f:find('^' .. file_base) then
      if url.realpath then
        f = f:gsub(file_base, url.path)
      end
      table.insert(valid_filenames, f)
    end
  end

  local protocol = url.protocol
  local prefix = protocol and protocol == 'file' and 'file:' or ''

  return vim.tbl_map(function(path)
    return prefix .. path
  end, valid_filenames)
end

---@param url OrgUrl
---@return OrgHeadline[]
function Hyperlinks.find_by_custom_id_property(url)
  local custom_id = url:get_custom_id() or ''
  local file = get_file_from_url(url)
  return file:find_headlines_with_property_matching('CUSTOM_ID', custom_id)
end

---@param url OrgUrl
---@return fun(headlines: OrgHeadline[]): string[]
function Hyperlinks.as_custom_id_anchors(url)
  local prefix = url:is_file_custom_id() and url:get_file_with_protocol() .. '::' or ''
  return function(headlines)
    return vim.tbl_map(function(headline)
      ---@cast headline OrgHeadline
      local custom_id = headline:get_property('custom_id')
      return ('%s#%s'):format(prefix, custom_id)
    end, headlines)
  end
end

---@param url OrgUrl
---@param omit_prefix? boolean
---@return fun(headlines: OrgHeadline[]): string[]
function Hyperlinks.as_headline_anchors(url, omit_prefix)
  local prefix = url:is_file_headline() and url:get_file_with_protocol() .. '::' or ''
  return function(headlines)
    return vim.tbl_map(function(headline)
      local title = (omit_prefix and '' or '*') .. headline:get_title()
      return ('%s%s'):format(prefix, title)
    end, headlines)
  end
end

---@param url OrgUrl
---@return OrgHeadline[]
function Hyperlinks.find_by_title(url)
  local headline = url:get_headline()
  if not headline then
    return {}
  end
  local file = get_file_from_url(url)
  return file:find_headlines_by_title(headline)
end

function Hyperlinks.find_by_plain_title(url)
  local headline = url:get_plain()
  if not headline then
    return {}
  end
  return org.files:get_current_file():find_headlines_by_title(headline)
end

local function as_dedicated_anchor_pattern(anchor_str)
  return string.format('<<<?(%s[^>]*)>>>?', anchor_str):lower()
end

---@param url OrgUrl
---@return OrgHeadline[]
function Hyperlinks.find_by_dedicated_target(url)
  local anchor = url:get_plain()
  if not anchor then
    return {}
  end
  return org.files:get_current_file():find_headlines_matching_search_term(as_dedicated_anchor_pattern(anchor), true)
end

---@param url OrgUrl
---@return fun(headlines: OrgHeadline[]): string[]
function Hyperlinks.as_dedicated_targets(url)
  return function(headlines)
    local targets = {}
    local term = as_dedicated_anchor_pattern(url:get_plain())
    for _, headline in ipairs(headlines) do
      for m in headline:get_title():lower():gmatch(term) do
        table.insert(targets, m)
      end
      for _, content in ipairs(headline:content()) do
        for m in content:lower():gmatch(term) do
          table.insert(targets, m)
        end
      end
    end
    return targets
  end
end

---@param url OrgUrl
---@return fun(headlines: OrgHeadline[]): table<string>
function Hyperlinks.as_dedicated_anchors_or_internal_titles(url)
  return function(headlines)
    local dedicated_anchors = Hyperlinks.as_dedicated_targets(url)(headlines)
    local fuzzy_titles = Hyperlinks.as_headline_anchors(url, true)(headlines)
    return utils.concat(dedicated_anchors, fuzzy_titles, true)
  end
end

---@param url OrgUrl
---@return OrgHeadline[], fun(headline: OrgHeadline[]): string[]
function Hyperlinks.find_matching_links(url)
  local result = {}
  local mapper = function(item)
    return item
  end
  if not url then
    return result, mapper
  elseif url:is_custom_id() then
    result = Hyperlinks.find_by_custom_id_property(url)
    mapper = Hyperlinks.as_custom_id_anchors(url)
  elseif url:is_headline() then
    result = Hyperlinks.find_by_title(url)
    mapper = Hyperlinks.as_headline_anchors(url)
  elseif url:is_file_only() then
    result = Hyperlinks.find_by_filepath(url)
  elseif url:is_plain() then
    result = utils.concat(Hyperlinks.find_by_dedicated_target(url), Hyperlinks.find_by_plain_title(url))
    mapper = Hyperlinks.as_dedicated_anchors_or_internal_titles(url)
  end

  return result, mapper
end

---@param headline OrgHeadline
---@param path? string
function Hyperlinks.get_link_to_headline(headline, path)
  local title = headline:get_title()

  if config.org_id_link_to_org_use_id then
    local id = headline:id_get_or_create()
    if id then
      return ('id:%s::*%s'):format(id, title)
    end
  end

  path = path or utils.current_file_path()
  return ('file:%s::*%s'):format(path, title)
end

---@param file OrgFile
---@param path? string
function Hyperlinks.get_link_to_file(file, path)
  local title = file:get_title()

  if config.org_id_link_to_org_use_id then
    local id = file:id_get_or_create()
    if id then
      return ('id:%s::*%s'):format(id, title)
    end
  end

  path = path or file.filename
  return ('file:%s::*%s'):format(path, title)
end

---@param headline OrgHeadline
function Hyperlinks.store_link_to_headline(headline)
  local title = headline:get_title()
  Hyperlinks.stored_links[Hyperlinks.get_link_to_headline(headline)] = title
end

---@param arg_lead string
---@return string[]
function Hyperlinks.autocomplete_links(arg_lead)
  local url = Url:new(arg_lead)
  local result, mapper = Hyperlinks.find_matching_links(url)

  if url:is_file_only() or url:is_custom_id() or url:is_headline() then
    return mapper(result)
  end

  return vim.tbl_keys(Hyperlinks.stored_links)
end

---@return OrgLink|nil, table | nil
function Hyperlinks.get_link_under_cursor()
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.') or 0
  return Link.at_pos(line, col)
end

function Hyperlinks.insert_link(link_location)
  local selected_link = Link:new(link_location)
  local desc = selected_link.url:get_target_value()

  if selected_link.url:is_id() then
    link_location = ('id:%s'):format(selected_link.url:get_id())
  end

  local link_description = vim.trim(vim.fn.OrgmodeInput('Description: ', desc or ''))

  link_location = '[' .. vim.trim(link_location) .. ']'

  if link_description ~= '' then
    link_description = '[' .. link_description .. ']'
  end

  local insert_from
  local insert_to
  local target_col = #link_location + #link_description + 2

  -- check if currently on link
  local link, position = Hyperlinks.get_link_under_cursor()
  if link and position then
    insert_from = position.from - 1
    insert_to = position.to + 1
    target_col = target_col + position.from
  else
    local colnr = vim.fn.col('.')
    insert_from = colnr
    insert_to = colnr + 1
    target_col = target_col + colnr
  end

  local linenr = vim.fn.line('.') or 0
  local curr_line = vim.fn.getline(linenr)
  local new_line = string.sub(curr_line, 0, insert_from)
    .. '['
    .. link_location
    .. link_description
    .. ']'
    .. string.sub(curr_line, insert_to, #curr_line)

  vim.fn.setline(linenr, new_line)
  vim.fn.cursor(linenr, target_col)
end

return Hyperlinks
