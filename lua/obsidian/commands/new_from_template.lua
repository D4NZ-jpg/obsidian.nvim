local Note = require "obsidian.note"
local util = require "obsidian.util"
local log = require "obsidian.log"

---@param client obsidian.Client
return function(client, data)
  if not client:templates_dir() then
    log.err "Templates folder is not defined or does not exist"
    return
  end

  local picker = client:picker()
  if not picker then
    log.err "No picker configured"
    return
  end

  local target_frontmatter = client:opts_for_workspace().templates.output_dir_key
  picker:find_templates {
    callback = function(name)
      local template_frontmatter = Note.from_file(name):frontmatter()

      ---@type obsidian.Note
      local note
      if data.args and data.args:len() > 0 then
        if template_frontmatter[target_frontmatter] ~= nil then
          data.args = template_frontmatter.target_dir .. "/" .. data.args
        end

        note = client:create_note { title = data.args, no_write = true }
      else
        local title = util.input("Enter title or path (optional): ", { completion = "file" })
        if not title then
          log.warn "Aborted"
          return
        elseif title == "" then
          title = nil
        elseif template_frontmatter[target_frontmatter] ~= nil then
          title = template_frontmatter[target_frontmatter] .. "/" .. title
        end

        note = client:create_note { title = title, no_write = true }
      end

      -- Open the note in a new buffer.
      client:open_note(note, { sync = true })

      client:write_note_to_buffer(note, { template = name })
    end,
  }
end
