-- 创建时间:2021-06-08

GameToolManager = {}
local M = GameToolManager

--[[
 ******************************
 ScrollRect 滑动UI分段加载代码
 sr 组件ScrollRect
 SendCreate 请求创建
 CreateCell 创建
 step 每次创建的数量

 ClearCell 删除一个Cell
 maxPage 同时生成的最大分页数
 ******************************
--]]
function M.ScrollRect(sr, SendCreate, CreateCell, step, ClearCell, maxPage)
	local tt = {}
	tt.sr = sr
	tt.step = step or 20
	tt.minIndex = nil
	tt.maxIndex = nil
	tt.cellList = {}
	tt.SendCreate = SendCreate
	tt.CreateCell = CreateCell
	tt.ClearCell = ClearCell
	tt.maxPage = maxPage

	tt.ClearByIndex = function (index)
		if tt.ClearCell then
			local bi = (index - 1) * tt.step + 1
			local ei = index * tt.step
			for i = bi, ei do
				tt.ClearCell(i)
			end
		end
	end
	
	tt.CreateByIndex = function (index)
		local isLeft = false -- 是否是向左创建
		if tt.minIndex then
			if (tt.minIndex - 1) == index then
				tt.minIndex = index
				isLeft = true
			end
		else
			tt.minIndex = index
		end

		if tt.maxIndex then
			if (tt.maxIndex + 1) == index then
				tt.maxIndex = index
			end
		else
			tt.maxIndex = index
		end

		local bi = (index - 1) * tt.step + 1
		local ei = index * tt.step
		if isLeft then
			for i = ei, bi, -1 do
				local obj = tt.CreateCell(i)
				obj.transform:SetAsFirstSibling()
			end
		else
			for i = bi, ei do
				local obj = tt.CreateCell(i)
			end
		end

		if tt.maxPage then
			while ( (tt.maxIndex - tt.minIndex + 1) > tt.maxPage ) do
				if isLeft then
					tt.ClearByIndex(tt.maxIndex)
					tt.maxIndex = tt.maxIndex - 1
				else
					tt.ClearByIndex(tt.minIndex)
					tt.minIndex = tt.minIndex + 1
				end
			end
		end
	end

	EventTriggerListener.Get(sr.gameObject).onEndDrag = function()
    	local NP = 0.5
    	if sr.horizontal then
	    	NP = sr.horizontalNormalizedPosition
    	elseif sr.vertical then
    		NP = sr.verticalNormalizedPosition
    	end

    	if NP <= 0 then
    		if tt.minIndex then
				tt.SendCreate(tt.minIndex - 1)
    		else
    			tt.SendCreate(1)
			end
		end
		if NP >= 1 then
			if tt.maxIndex then
				tt.SendCreate(tt.maxIndex + 1)
			else
				tt.SendCreate(1)
			end
		end
	end

	return tt
end
