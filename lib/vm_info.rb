module VMInfo
  def vm_info_to_hash(raw_info)
    # remove whatever's outside the future JSON data
    raw_info = /(\{.*\})/m.match(raw_info)[1]

    # replace the (vim.vm.Description) kind of stuff
    raw_info = raw_info.gsub(/\(vim.*\)/, "")

    # replace the equals sign with a colon
    raw_info = raw_info.tr("=", ":")

    # replace <unset> with null
    raw_info = raw_info.gsub(/<unset>/, "null")

    # make sure JSON keys are surrounded by quotation marks
    raw_info = raw_info.gsub(/(^[^a-zA-Z0-9"]*\b)(\w*)(\b\s*:)/, '\1"\2"\3')

    # replace single quotes with double quotes for values
    raw_info = raw_info.gsub(/'(.*)'/, '"\1"')

    # remove (string) before string arrays
    raw_info = raw_info.gsub(/\(string\)/, "")

    # remove trailing commas
    raw_info = raw_info.gsub(/,\s*\}/, '}')

    JSON.parse(raw_info)
  end
end
