local re = utils.Regex.new("(?<username>[a-z]+?)@(?<domain>[a-z]+?\\.com)")
local test = "helloworld@gmail.com"
print(re:is_match(test))

---@diagnostic disable-next-line: param-type-mismatch
utils.print_table(re:find(test))

---@diagnostic disable-next-line: param-type-mismatch
utils.print_table(re:captures(test))

print(re:replace_all(test, "My username is $1 on $2"))
print(re:replace_all(test, function(caps)
    print("Got caps")
    utils.print_table(caps)

    return "My username is " .. caps[2].str .. " on " .. caps[3].str
end))
