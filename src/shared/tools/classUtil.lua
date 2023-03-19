local util = {}

function util:instanceOf(subject, super)
	super = tostring(super)
	local mt = getmetatable(subject)

	while true do
		if mt == nil then
			return false
		end
		if tostring(mt) == super then
			return true
		end

		mt = getmetatable(mt)
	end
end

return util
