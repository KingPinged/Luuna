local t = {}

--TODO: mix this up and make it more readable
function t:concat(tbl, str)
	if type(tbl) == "table" and tbl.toString then
		return tbl:toString()
	end
	local mt = getmetatable(tbl)
	if mt and mt.__concat then
		return mt.__concat(tbl, "")
	end
	local t = {}
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			t[i] = concat(v, str)
		elseif type(v) == "userdata" then
			t[i] = "userdata"
		elseif v == nil then
			t[i] = "nil"
		else
			t[i] = v
		end
	end
	return table.concat(t, str)
end

return t
