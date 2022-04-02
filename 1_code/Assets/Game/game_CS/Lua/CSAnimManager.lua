-- 创建时间:2021-06-23

CSAnimManager = {}

function CSAnimManager.PlayDebugFX(parent, pos, txt)
	local object = GameObject.Instantiate(GetPrefab("CSDebugPrefab"), parent)
	object.transform.localPosition = pos
	local t = object.transform:Find("Text"):GetComponent("Text")
	t.text = txt

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:OnForceKill(function ()
		Destroy(object)
	end)
end

