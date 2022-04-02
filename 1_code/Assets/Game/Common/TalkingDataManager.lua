-- 创建时间:2021-09-06

TalkingDataManager = {}
local M = TalkingDataManager
local is_on_off = true
local login_id
local login_qd

function M.Init()
	if not is_on_off then return end
	-- local function GetLocalLoginData(name)
	-- 	local path
	-- 	if AppDefine.IsEDITOR() then
	-- 		path = Application.dataPath .. "/" .. name .. ".txt"
	-- 	else
	-- 		path = AppDefine.LOCAL_DATA_PATH .. "/" .. name .. ".txt"
	-- 	end
	-- 	if File.Exists(path) then
	-- 		return File.ReadAllText(path)
	-- 	else
	-- 		return ""
	-- 	end
	-- end
	
	-- --获取登录数据
	-- local function GetLoginIDAndQD()
	-- 	-- 游客 微信 手机号
	-- 	local login_qd = {"phone", "wechat", "youke"}
	-- 	local login_id
	-- 	local cur_qd = nil
	-- 	for k,v in pairs(login_qd) do
	-- 		cur_qd = v
	-- 		login_id = GetLocalLoginData(v)
	-- 		if login_id and login_id ~= "" then
	-- 			break
	-- 		end
	-- 	end
	-- 	return login_id,cur_qd
	-- end
	-- login_id,login_qd = GetLoginIDAndQD()

end

function M.OnLogin()
	if not is_on_off then return end
	local userInfo = MainModel.UserInfo
	if userInfo then
		talkingDataMgr:Init(userInfo.user_id,"normal")
		talkingDataMgr:SetProfileName(userInfo.name)
		talkingDataMgr:SetProfileType(0)
		talkingDataMgr:SetGameServer("normal")
	end
end

function M.BeginMission(missitonName)
	if not is_on_off then return end
	talkingDataMgr:BeginMission(missitonName)
end

function M.CompleteMission(missitonName)
	if not is_on_off then return end
	talkingDataMgr:CompleteMission(missitonName)
end

function M.FailedMission(missitonName,failedCause)
	if not is_on_off then return end
	failedCause = failedCause or ""
	talkingDataMgr:FailedMission(missitonName,failedCause)
end
--[[
	请求充值
	data = {
		orderId = "订单号",
		iapId = "iapId",
		currencyAmount = 648,
		currencyType = "CNY",
		virtualCurrencyAmount = 10000,
		paymentType = "UnionPay"
	}
]]
function M.OnChargeRequest(data)
	if not is_on_off then return end
	if not data.orderId then
		dump("<color=red>ChargeRequest没有订单id</color>")
		return
	end
	data.iapId = data.iapId or "unknown"
	data.paymentType = data.paymentType or "unknown"
	talkingDataMgr:OnChargeRequest(
		data.orderId,
		data.iapId,
		data.currencyAmount,
		data.currencyType,
		data.virtualCurrencyAmount,
		data.paymentType)
end
function M.OnChargeSuccess(orderId)
	if not is_on_off then return end
	talkingDataMgr:OnChargeSuccess(orderId)
end

function M.OnReward(virtualCurrencyAmount,reason)
	if not is_on_off then return end
	talkingDataMgr:OnReward(virtualCurrencyAmount,reason)
end

--购买道具
function M.OnPurchase(item,itemNumber,priceInVirtualCurrency)
	if not is_on_off then return end
	talkingDataMgr:OnPurchase(item,itemNumber,priceInVirtualCurrency)
end

--使用道具
function M.OnUse(item,itemNumber)
	if not is_on_off then return end
	talkingDataMgr:OnUse(item,itemNumber)
end