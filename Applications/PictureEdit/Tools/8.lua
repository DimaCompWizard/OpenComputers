
local image = require("image")
local tool = {}

------------------------------------------------------

tool.shortcut = "Fl"
tool.keyCode = 34
tool.about = "Fill tool allows you to automatically fill areas with selected primary color just like in Paint. Oh God, where is my RAM...?"

local function check(x, y, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS)
	if x >= 1 and x <= picture[1] and y >= 1 and y <= picture[2] then
		local currentB, currentF, currentA, currentS = image.get(picture, x, y)
		if
			currentB == sourceB
			and
			currentB ~= newB
		then
			image.set(picture, x, y, newB, newF, newA, newS)
			return true
		end
	end
end

local function pizda(x, y, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS)
	if check(x, y - 1, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) then pizda(x, y - 1, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) end
	if check(x + 1, y, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) then pizda(x + 1, y, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) end
	if check(x, y + 1, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) then pizda(x, y + 1, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) end
	if check(x - 1, y, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) then pizda(x - 1, y, picture, sourceB, sourceF, sourceA, sourceS, newB, newF, newA, newS) end
end

tool.eventHandler = function(mainContainer, object, eventData)
	if eventData[1] == "touch" then
		local x, y = eventData[3] - mainContainer.image.x + 1, eventData[4] - mainContainer.image.y + 1
		local sourceB, sourceF, sourceA, sourceS = image.get(mainContainer.image.data, x, y)
		pizda(x, y, mainContainer.image.data, sourceB, sourceF, sourceA, sourceS, mainContainer.primaryColorSelector.color, 0x0, 0, " ")
		
		mainContainer:drawOnScreen()
	end
end


------------------------------------------------------

return tool