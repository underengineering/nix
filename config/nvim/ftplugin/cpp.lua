vim.api.nvim_create_user_command("YankSignature", function(opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1, opts.line2, false)
    local pattern = {}
    for _, line in ipairs(lines) do
        local line_no_comment = line:gsub("//.*", "")
        local string = line_no_comment:match('"(.-)"')
        if string then 
            pattern[#pattern + 1] = string
            if string:sub(#string, #string) ~= " " then
                pattern[#pattern + 1] = " "
            end
        end
    end
    
    local result = table.concat(pattern, "")
    vim.fn.setreg("+", result)
end, {
    range = "%"
})