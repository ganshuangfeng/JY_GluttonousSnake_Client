--[[
网络请求的菊花功能
NetSendJHPanel
接口：
1、创建 int Create(desc)
	返回唯一ID
	第一个创建的菊花延迟1秒显示黑色遮罩，后面的菊花前一个消失立即补上
2、清除所有 void RemoveAll()
3、清除自定ID void RemoveById(id)
--]]
local basefunc = require "Game.Common.basefunc"
NetJH = basefunc.class()
local C = NetJH
local jhTags = {}
local jhPrefab = nil
local auto_id = 1
local function getID()
	local id = auto_id
	auto_id = auto_id + 1
	if auto_id > 100000000 then
		auto_id = 1
	end
	return "this_jh_" .. id
end

function C.Create(msg, id, parent)
	if not jhPrefab or not IsEquals(jhPrefab.gameObject) then
		jhPrefab = C.New(msg, parent)
	end
	id = id or getID()
	jhTags[#jhTags + 1] = {id = id, msg = msg, parent = parent}
    return id
end

function C.GetIndexByID(id)
    for k,v in ipairs(jhTags) do
    	if id == v.id then
    		return k
    	end
    end
end
function C.RemoveById(id)
	if not id then
		return
	end
	local index = C.GetIndexByID(id)
	if index then
		table.remove(jhTags, index)
	end
	if #jhTags > 0 then
		if jhPrefab and IsEquals(jhPrefab.gameObject) then
			jhPrefab.descText.text = jhTags[1].msg or ""
		else
			C.RemoveAll()
		end
	else
		C.RemoveAll()
	end
end


--移除所有菊花
function C.RemoveAll()
    jhTags = {}
    if jhPrefab and IsEquals(jhPrefab.gameObject) then
    	jhPrefab:Exit()
    end
    jhPrefab = nil
end

function C:Ctor(msg, parent)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv50")
		if not parent then
			parent = GameObject.Find("Canvas/LayerLv5")
		end
	end

	self.gameObject = NewObject("FullSceneJHPrefab", parent.transform)
	self.descText = self.gameObject.transform:Find("MBBG/Text"):GetComponent("Text")
	self.jhImage = self.gameObject.transform:Find("MBBG").gameObject
	self.descText.text = msg

	self.jhImage:SetActive(false)
    self.updateTimer = Timer.New(function ()
    	if self.jhImage and not self.jhImage:Equals(nil) then
			self.jhImage:SetActive(true)
	    end
    end, 1)
    self.updateTimer:Start()
end

--移除
function C:Exit()
	if self.updateTimer then
		self.updateTimer:Stop()
	end
	self.updateTimer = nil
	Destroy(self.gameObject)
end