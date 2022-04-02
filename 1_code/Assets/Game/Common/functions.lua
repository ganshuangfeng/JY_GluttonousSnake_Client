local basefunc = require "Game/Common/basefunc"

-- UnityEngine.Profiling.Profiler.BeginSample("225 SetDataContext");
-- // 耗时代码 ....balabala
-- UnityEngine.Profiling.Profiler.EndSample();

--查找对象--
function Find(str)
	return GameObject.Find(str);
end

function Destroy(obj)
    if IsEquals(obj) then
	   GameObject.Destroy(obj)
    end
end

function ClearUserData(tbl)
	for k, v in pairs(tbl) do
		if type(v) == "userdata" then
			tbl[k] = nil
		end
	end
end

function DestroyChildren(transform,not_destroy)
    if IsEquals(transform) then
    local count = transform.childCount;
    for i=0, count-1, 1 do
        local child = transform:GetChild(i);
        if not not_destroy or not not_destroy[child.name] then
            GameObject.Destroy(child.gameObject)
            end
        end
    end
end

function NewObject(prefab_name, parent_transform)
    local go_temp = nil;
    resMgr:LoadPrefab(
        {prefab_name},
        function(objs)
            go_temp = objs[0]
        end
    )
    local go = nil
	if parent_transform ~= nil then
		go = GameObject.Instantiate(go_temp, parent_transform)
		-- 预制体设置锚点的情况下，归零会出现错误；后期需要通过RectTransform尝试能否修正这个问题
		-- go.transform.localScale = Vector3.one;
		-- go.transform.localPosition = Vector3.zero;
	else
		go = GameObject.Instantiate(go_temp)
	end

	go.name  = go_temp.name
	return go
end

function GetPrefab(fileName)
    if type(fileName) == "table" then
        return resMgr:GetPrefabsSync(fileName)
    else
        return resMgr:GetPrefabSync(fileName)
    end
end

function GetTextureExtend(image, fileName, is_local_icon)
    if not is_local_icon or is_local_icon == 1 then
        image.sprite = GetTexture(fileName)
    else
        URLImageManager.UpdateWebImage(fileName, image)
    end
end

function GetTexture(fileName)
    if type(fileName) == "table" then
        return  resMgr:GetTexturesSync(fileName)
    else
        return resMgr:GetTextureSync(fileName)
    end
end

function Get3DTexture(fileName)
    if type(fileName) == "table" then
        return  resMgr:Get3DTexturesSync(fileName)
    else
        return resMgr:Get3DTextureSync(fileName)
    end
end

function GetMaterial(filename)
    return resMgr:GetMaterial(filename)
end

function GetAudio(fileName)
    if type(fileName) == "table" then
        return  resMgr:GetAudiosSync(fileName)
    else
        return resMgr:GetAudioSync(fileName)
    end
end

function GetFont(fileName)
    if type(fileName) == "table" then
        return  resMgr:GetFontsSync(fileName)
    else
        return resMgr:GetFontSync(fileName)
    end
end

function ClipUIParticle(transform)
	local shaderKey1 = "Particles/Additive"
	local shaderKey2 = "Particles/Alpha Blended Premultiply"
	local newShader = UnityEngine.Shader.Find("ParticleMask")
	local function TryChangeShader(material)
		if not material then return end
		if material.shader.name ~= shaderKey1 and material.shader.name ~= shaderKey2 then return end
		local new_material = GameObject.Instantiate(material)
		new_material.shader = newShader
		new_material:SetFloat("_StencilComp", 4)
		new_material:SetFloat("_Stencil", 1)

		return new_material
		--material.shader = newShader
		--material:SetFloat("_StencilComp", 4)
		--material:SetFloat("_Stencil", 1)
	end

	local renderers = transform:GetComponentsInChildren(typeof(UnityEngine.ParticleSystemRenderer), true)
	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]
		local new_material = TryChangeShader(renderer.trailMaterial)
		if new_material ~= nil then renderer.trailMaterial = new_material end
		new_material = TryChangeShader(renderer.sharedMaterial)
		if new_material ~= nil then renderer.sharedMaterial = new_material end
	end

	local newMaterial = GetMaterial("MaskUI")

	local images = transform:GetComponentsInChildren(typeof(UnityEngine.UI.Image), true)
	for i = 0, images.Length - 1 do
		local image = images[i]
		image.material = newMaterial
	end

	local texts = transform:GetComponentsInChildren(typeof(UnityEngine.UI.Text), true)
	for i = 0, texts.Length - 1 do
		local text = texts[i]
		text.material = newMaterial
	end
end

--[[
panel_name  界面名称
ab_name     资源所在的ab包名称（需要包含路径/）
callback    创建完成回调函数
is_cache    是否需要缓存界面，频繁开启关闭的可以考虑
]]
function CreatePanel(onwer,panel_name, callback, is_cache, params)
    panelMgr:CreatePanel(panel_name, callback, is_cache == true , params)
    return onwer
end

function Split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function string.utf8len(input)  
    local len  = string.len(input)  
    local left = len  
    local cnt  = 0  
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}  
    while left ~= 0 do  
        local tmp = string.byte(input, -left)  
        local i   = #arr  
        while arr[i] do  
            if tmp >= arr[i] then  
                left = left - i
                break  
            end  
            i = i - 1  
        end  
        cnt = cnt + 1  
    end  
    return cnt  
end

--[[获取表的values]]
function table.values(t)
    local _t = {}
    for k,v in pairs(t) do
        table.insert(_t, v)
    end
    return _t
end

---[[获取表的keys]]
function table.keys( t )
    local keys = {}
    for k, _ in pairs( t ) do
        keys[#keys + 1] = k
    end
    table.sort(keys);
    return keys
end

--[[modelData ：赛场的Modle数据， pSeatNum : 玩家位置
    默认播放男声
]]
function AudioBySex(modelData, pSeatNum)
	if modelData 
		and modelData.data
		and modelData.data.players_info
		and modelData.data.players_info[pSeatNum]
		and modelData.data.players_info[pSeatNum].sex
		and modelData.data.players_info[pSeatNum].sex == 0 then
		return "_0"
	else
		return "_1"
	end
end

--- add by wss
--- 安全的设置transform的属性
function SafaSetTransformPeoperty(node , typePer , value)
    if not IsEquals(node) then
        return
    end

    if not IsEquals(node.transform) then
        return
    end

    local mainKey = typePer
    local secondKey = string.find(typePer , "%.")
    --print("<color=yellow>----------- secondKey: ".. (secondKey or "nil") .." </color>")
    if secondKey then
        mainKey = string.sub(typePer , 1 , secondKey - 1)
        secondKey = string.sub(typePer , secondKey + 1 , -1)
    end
    --print("<color=yellow> ------------- mainKey , secondKey :" .. mainKey .. "---" .. (secondKey or "nil") .. " </color>")
    if not node.transform[mainKey] then
        return
    end

    if secondKey then
        node.transform[mainKey] = Vector3.New( secondKey == "x" and value or node.transform[mainKey].x , 
                                                secondKey == "y" and value or node.transform[mainKey].y ,
                                                    secondKey == "z" and value or node.transform[mainKey].z )
    else
        node.transform[mainKey] = value
    end
end

--添加 Canvas 组件并设置层级
function AddCanvasAndSetSort(obj, sorting)
    local canvas
    if IsEquals(obj) then
        canvas = obj.gameObject:AddComponent(typeof(UnityEngine.Canvas))
        if sorting and IsEquals(canvas) then
            canvas.overrideSorting = true
            canvas.sortingOrder = sorting
        end
    end
    return canvas
end

--移除 Canvas 组件
function RemoveCanvas(obj)
    if IsEquals(obj) then
        local canvas = obj.gameObject:GetComponent(typeof(UnityEngine.Canvas))
        if IsEquals(canvas) then
            Destroy(canvas)
        end
    end
end

function AdaptLayerParent(defaultLayerName, params)
	local parent = nil
	if params and params.parent and IsEquals(params.parent) then
		parent = params.parent
	else
		parent = GameObject.Find(defaultLayerName).transform
	end
	return parent
end

function SaveLua2Json(lua_data,file_name,path)
    if not lua_data then
        return
        print("save lua to json : lua_data error")
    end
    if not file_name or type(file_name) ~= "string" then
        print("save lua to json : file_name error")
        return
    end
    if not path or type(path) ~= "string" then 
        print("save lua to json : path error")
        return
    end
    local json_data = lua2json(lua_data)
    if not json_data then
        print("save lua to json : lua 2 json is nil")
        return
    end
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    File.WriteAllText(path .. "/" .. file_name .. ".txt", json_data)
end

function LoadJson2Lua(file_name,path)
    if not file_name or type(file_name) ~= "string" then
        print("load lua to json : file_name error")
        return
    end
    if not path or type(path) ~= "string" then 
        print("load lua to json : path error")
        return
    end

    local file_path = path .. "/" .. file_name .. ".txt"
    if File.Exists(file_path) then
        local json_data = File.ReadAllText(file_path)
        if not json_data then
            print("load lua to json : file is nil")
            return 
        end
        local lua_data = json2lua(json_data)
        if not lua_data then
            print("load lua to json : json 2 lua is nil")
        end

        local function filter(value)
            if type(value) ~= "table" then
                return value
            end
            local copedSet = {}
            local function _copy(src_)
                if type(src_) ~= "userdata" then
                    local ret = {}
                    copedSet[src_] = ret
                    for k, v in pairs(src_) do
                        if type(v) ~= "table" and type(v) ~= "userdata" then
                            ret[k] = v
                        elseif type(v) ~= "userdata" then
                            if copedSet[v] then
                                -- 重复表 仅仅引用
                                ret[k] = copedSet[v]
                            else
                                ret[k] = _copy(v)
                            end
                        end
                    end
                    return ret
                end
            end
            return _copy(value)
        end

        return filter(lua_data)
    else
        print("load lua to json : not find file" .. file_path)
    end
end

function TableIsNull (t)
    if t and next(t) then return false end
    return true
end

function ExtRequire(path)
    --package.loaded[path] = nil
    --return require(path)
    return HotUpdateConfig(path)
end

function HotUpdateConfig(path)
    package.loaded[path] = nil

    local strs = StringHelper.Split(path, ".")
    local cfg = HandleLoadChannelLua(strs[#strs]) or require (path)
    return cfg

    --[[if AppDefine.IsEDITOR() then
        cfg = require (path)
    else
        local strs = StringHelper.Split(path, ".")
        local hot_path = "localconfig/" .. strs[#strs] .. ".lua"
        cfg = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath(hot_path))
        if not cfg then cfg = require (path) end
    end
    return cfg]]--
end

function ExtRequireAudio(path,config_name)
    if not audio_config then
        audio_config = require "Game.CommonPrefab.Lua.audio_config"
    end
    if audio_config[config_name] then return end
    package.loaded[path] = nil
    local config = require (path)
    audio_config[config_name] = config[config_name]
end

local require = require
local string = string
local table = table

int64.zero = int64.new(0,0)
uint64.zero = uint64.new(0,0)

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

--重新require一个lua文件，替代系统文件。
function reimport(name)
    local package = package
    package.loaded[name] = nil
    package.preload[name] = nil
    return require(name)    
end

--[[
    @desc: 加载嵌入式脚本，如果是独立更新的脚本记得在上面的 alone_channel 中添加对应渠道
    author:{author}
    time:2019-12-09 11:42:23
    --@basic: 基类名字
	--@param: 基类参数（通常是基类自己）
	--@is_alone: 单独更新，不随主包更新
    @return:
]]
function HandleLoadChannelLua(basic, param,is_alone)
    local channel = gameMgr:getMarketChannel()
    local platform = gameMgr:getMarketPlatform()

    local file_path = "Game/Channel/Lua/" .. platform .. "/"
    local file_name = ""

    local function  loadfile()
        local result = reimport(file_name)
        if result and type(result) == "function" then
            return result(param)
        else
            return result
        end        
    end

    file_name = file_path .. basic ..  "_" .. channel
    --渠道有文件
    if (luaMgr:CheckExistFile(file_name)) then
        return loadfile()
    end

    file_name = file_path .. basic .. "_" .. platform
    --平台有文件
    if (luaMgr:CheckExistFile(file_name)) then
        return loadfile()
    end
end


function SetLayer(obj,layer)
	if not IsEquals(obj) or not layer then return end

    local objs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Transform), true)
    for i = 0, objs.Length - 1 do
        objs[i].gameObject.layer = LayerMask.NameToLayer(layer)
    end
end

function SetSortingLayer(obj,sorting_layer)
    if not IsEquals(obj) or not sorting_layer then return end

    local objs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    for i = 0, objs.Length - 1 do
        objs[i].sortingLayerID = UnityEngine.SortingLayer.NameToID(sorting_layer)
    end
end

function SetOrderInLayer(obj,sorting_order,is_add)
    if not IsEquals(obj) or not sorting_order then return end
    local objs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    for i = 0, objs.Length - 1 do
        if is_add then
            objs[i].sortingOrder =  objs[i].sortingOrder + sorting_order
        else
            objs[i].sortingOrder = sorting_order
        end
    end
end

function SetSortingGroupLayer(obj,sorting_order,is_add)
    if not IsEquals(obj) or not sorting_order then return end
    local objs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Rendering.SortingGroup), true)
    for i = 0, objs.Length - 1 do
        if is_add then
            objs[i].sortingOrder =  objs[i].sortingOrder + sorting_order
        else
            objs[i].sortingOrder = sorting_order
        end
    end
end

-- 修改特效层级 obj ui层级 调到上层还是下层
function ChangeRenderer(obj, base, isUp)
    if not IsEquals(obj) then
        return
    end
    local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    local min = 9999999
    local max = -9999999
    for i = 0, ps.Length - 1 do
        if max < ps[i].sortingOrder then
            max = ps[i].sortingOrder
        end
        if min > ps[i].sortingOrder then
            min = ps[i].sortingOrder
        end
    end
    if isUp then
        max = base - min + 1
    else
        max = base - max - 1
    end

    for i = 0, ps.Length - 1 do
        ps[i].sortingOrder = ps[i].sortingOrder + max
    end
end

--当天0点时间戳
function GetTodayTimeStamp()
    local cDateCurrectTime = os.date("*t")
    local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day, hour=0,min=0,sec=0})
    
    return cDateTodayTime
end

local WeekDayTable = {
    [0] = 7,
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
}
function GetWeekDay(offset_t)
    offset_t = offset_t or 0
    local week_day = os.date("%w",os.time() + offset_t)
    return WeekDayTable[tonumber(week_day)]
end

function SetTempParm(parm, gotoui, default)
    if not gotoui then
        return
    end
    default = default or "enter"
    parm.gotoui = gotoui[1]
    if #gotoui == 3 then
        parm.goto_type = gotoui[2]
        parm.goto_scene_parm = gotoui[3]
    else
        parm.goto_scene_parm = gotoui[2] or default
    end
end
function GetGotoUIParm(gotoui, default)
    if not gotoui then
        return
    end
    default = default or "enter"
    local parm = {}
    parm.gotoui = gotoui[1]
    if #gotoui == 3 then
        parm.goto_type = gotoui[2]
        parm.goto_scene_parm = gotoui[3]
    else
        parm.goto_scene_parm = gotoui[2] or default
    end
    return parm
end

-- 时间是否在范围内
function CheckTimeInRange(t, beginTime, endTime)
    if (not beginTime or beginTime == -1 or t >= beginTime)
        and (not endTime or endTime == -1 or t <= endTime) then
            return true
    end
    return false
end

-- 图片不存在不给sprite赋值
function SetTextureExtend(image, fileName)
    if GetTexture(fileName) then
        image.sprite = GetTexture(fileName)
    end
end

-- 深度监测
function DepthSupervise(tab, desc)
    desc = desc or "||||||||debug="
    local local_tab = {}
    local mt = {
        __index = function (t, k)
            print("[access]" .. desc .. tostring(k))
            print(debug.traceback())
            return local_tab[k]
        end,

        __newindex = function (t, k, v)
            print("[update]" .. desc .. tostring(k) .. "  v=" .. tostring(v))
            print(debug.traceback())
            local_tab[k] = v
            if type(v) == "table" then
                DepthSupervise(v)
            end
        end
    }
    setmetatable(tab, mt)
end

--Url转码
function UrlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

--Ur解码
function UrlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function BaseUnpack(tt, i)
    i = i or 1
    if tt.n and i <= tt.n then
        return tt[i],BaseUnpack(tt, i+1)
    else
        return nil
    end
end

-- <summary>
-- 用某个轴去朝向物体
-- </summary>
-- <param name="tr_self">朝向的本体</param>
-- <param name="lookPos">朝向的目标</param>
-- <param name="directionAxis">方向轴，取决于你用那个方向去朝向</param>
function AxisLookAt( tr_self,  lookPos,  directionAxis)
	local rotation = tr_self.rotation;
	local targetDir = lookPos - tr_self.position;
	--指定哪根轴朝向目标,自行修改Vector3的方向
	local fromDir = tr_self.rotation * directionAxis;
	--计算垂直于当前方向和目标方向的轴
	local axis = Vector3.Cross(fromDir, targetDir).normalized;
	--计算当前方向和目标方向的夹角
	local angle = Vector3.Angle(fromDir, targetDir);
	--将当前朝向向目标方向旋转一定角度，这个角度值可以做插值
	tr_self.rotation = Quaternion.AngleAxis(angle, axis) * rotation;
end

function GeneratingVar(transform,lua_table)
	local ret_table = lua_table or {}
	local search_func 
	search_func = function(transform)
		if transform then
			local transform_name = transform.gameObject.name
			if string.byte(transform_name) == 64 then
				local table_item = transform
				local var = string.split(transform_name,"_")
				local type_str = var[#var]
				if type_str == "btn" then
					table_item = transform:GetComponent("Button")
				elseif type_str == "img" then
					table_item = transform:GetComponent("Image")
					if not IsEquals(table_item) then
						table_item = transform:GetComponent("SpriteRenderer")
					end
				elseif type_str == "txt" then
					table_item = transform:GetComponent("Text")
					if not IsEquals(table_item) then
						table_item = transform:GetComponent("TMP_Text")
					end
				elseif type_str == "ipf" then
					table_item = transform:GetComponent("InputFiled")
				elseif type_str =="tge" then
					table_item = transform:GetComponent("Toggle")
				elseif type_str =="spr" then
					table_item = transform:GetComponent("SpriteRenderer")
                elseif type_str =="sbar" then
                    table_item = transform:GetComponent("Scrollbar")
                else
                    table_item = transform
				end
				local name = string.sub(transform.name,2)
				ret_table[name] = table_item
			end
			if transform and transform.childCount > 0 then
				for i = 0,transform.childCount - 1  do
					search_func(transform:GetChild(i))
				end
			end
		end
	end

	search_func(transform)
	return ret_table
end

function ClearTable(t)
    if not t then return end
    for k,v in pairs(t) do
		t[k] = nil
	end
	t = nil    
end

--！！！慎用 深度清空一个表，会value 和 value 引用的表都设置为空表，会清空引用的原表中的数据
function DeepClearTable(value)
    if type(value) ~= "table" then
        return
    end

	local deletedSet = {}

	local function delete(val)
		for k, v in pairs(val) do
			if type(v) ~= "table" then
				val[k] = nil
			else
				if deletedSet[v] then
                    val[k] = nil
                else
		            deletedSet[v] = v
					delete(v)
                    val[k] = nil
				end
			end
		end
	end

	delete(value)
    value = nil
end



--[[
    正方形范围随机，支持中空
    r1 > r2
]]
function RandomSquares(pos,r1,r2)
    r2 = r2 or 0

    local x = 0
    if math.random() > 0.5 then
        x = math.random(r2*100,r1*100)*0.01
    else
        x = math.random(-r1*100,-r2*100)*0.01
    end

    local y = 0
    if math.random() > 0.5 then
        y = math.random(r2*100,r1*100)*0.01
    else
        y = math.random(-r1*100,-r2*100)*0.01
    end

    return Vector3.New(pos.x+x,pos.y+y,0)
end



--[[
    正方形范围随机，支持中空，支持多个不重叠
    r1 > r2
]]
function RandomSquaresMul(pos,r1,r2,hd,ds)
    
    ds = ds or 2

    local n = 30
    
    local p = RandomSquares(pos,r1,r2)

    local dis = ds * ds

    for i=1,n do
            
        local ok = true
        for i,v in ipairs(hd) do
            if tls.pGetDistanceSqu(v,p) < dis then
                ok = false
                break
            end
        end

        if ok then
            break
        end
        
        p = RandomSquares(pos,r1,r2)
    end

    table.insert(hd,p)
    return p
end


function Get3Goto2IndexDir16(r)
    local d = math.floor( ( r % 360 + 11.25 ) / 22.5 ) % 16
    return d
end

function Get3Goto2IndexDir8(r)
    local d = math.floor( ( r % 360 + 22.5 ) / 45 ) % 8
    return d
end


function GetGameObjectDataInfo(info,gameObject)
    if not IsEquals(gameObject) then
        return
    end

    local bi = gameObject:GetComponent(typeof(DataInfo))
    if not IsEquals(bi) then
        return
    end

    local infoList = bi.infoList
    info = {}
    local kv

	for i = 0, infoList.Count - 1 do
        kv = infoList[i]
        info[kv.key] = kv.value
    end
    return info
end

function DataInfoToTable(info,gameObject)
    if not info or not next(info) then
        return
    end
    local dataInfo = {}

    for k, v in pairs(info) do
        if k == "size" then
            local str = string.split(v,",")
            dataInfo[k] = {w = tonumber(str[1]),h = tonumber(str[2])}
        elseif k == "passType"
            or k == "destroyType"
            or k == "itemType"
            or k == "gearName" 
            or k == "monsters" 
            or k == "props"
            or k == "r"
            or k == "pass_type" --波次通过类型
            then
                if string.match(v,",") then
                    local str = StringHelper.Split(v,",")
                    dataInfo[k] = {}
                    for index, value in ipairs(str) do
                        if tonumber(value) then
                            dataInfo[k][index] = tonumber(value)
                        else
                            dataInfo[k][index] = value
                        end
                    end
                else
                    if tonumber(v) then
                        dataInfo[k] = tonumber(v)
                        if k == "pass_type" then
                            dataInfo[k] = {tonumber(v)}
                        end
                    else
                        dataInfo[k] = v
                    end
                end
        elseif k == "layer"
            or k == "hp" then
                dataInfo[k] = tonumber(v)
        elseif k == "damage" then
            if tonumber(v) then 
                dataInfo[k] = tonumber(v)
            else
                local str = string.split(v,",")
                dataInfo[k] = {}
                for i = 1, #str,2 do
                    dataInfo[k][str[i]] = str[i + 1]
                end
            end
        else
            if tonumber(v) then 
                dataInfo[k] = tonumber(v)
            else
                dataInfo[k] = v
            end
        end
    end

    -- dump(dataInfo,"<color=yellow>GameObject DataInfo </color>")

    --房间，道路 尺寸改为格子个数
    if dataInfo.key == "road" then
        dataInfo.size = {w = dataInfo.size.w * 1.6,h = dataInfo.size.h * 1.6}
    elseif dataInfo.type == "room" then
        dataInfo.size = {w = dataInfo.size.w * 1.6,h = dataInfo.size.h * 1.6}
        local childDataInfos = gameObject:GetComponentsInChildren(typeof(DataInfo))
        local childGo
        local childDataInfo
        for i = 1, childDataInfos.Length - 1,1 do
            childGo = childDataInfos[i].gameObject
            childDataInfo = GetDataInfo(childGo)
            if childDataInfo.type == "map" then
                dataInfo.size = {w = childDataInfo.size.w * 1.6,h = childDataInfo.size.h * 1.6}
                break
            end
        end
    end

    return dataInfo
end

function DataInfoToConfig(dataInfo)
    local comCfg = GameConfigCenter.GetComponentConfig()
    if not comCfg then
        return
    end
    local sd = GameInfoCenter.GetStageData()

    dataInfo = dataInfo or {}
    for key, value in pairs(comCfg) do  -- main
        for k, v in pairs(value) do   --- k == Key
            if dataInfo.key == k then
                for k1, v1 in pairs(v) do  ----  v = { key = xx , comType = xx , data = {xxx} } 
                    dataInfo[k1] = dataInfo[k1] or basefunc.deepcopy(v1)
                end
            end
        end
    end

    if dataInfo.comType == "monster" then
        --怪
        dataInfo.level = dataInfo.level or 1

    end

    return dataInfo
end

---- 普通关卡总数据 附加
function NorStageFinalDataToDataInfo(dataInfo , _stage , _roomNo  )

    local stageData = GameInfoCenter.GetStageData()
    local stage = _stage or stageData.curLevel
    local roomNo = _roomNo or stageData.roomNo

     --- 不是nor关卡直接返回
    --[[if stageData.modelType ~= "normal" then
        return dataInfo
    end--]]

    local stage_cfg = GameConfigCenter.GetStageAllCfg()

    if not stage_cfg[dataInfo.keyType] then
        return dataInfo
    end

    --dump( { stageData , dataInfo , stage_cfg[dataInfo.keyType] } , "xxx----------NorStageFinalDataToDataInfo" )

    for i, v in ipairs(stage_cfg[dataInfo.keyType]) do
        --if v.key == dataInfo.key then
        if (dataInfo.keyType == "monster" and (dataInfo.data_id == v.use_id or dataInfo.use_id == v.use_id ) ) or 
            (dataInfo.data_id == v.id ) then

            local isMergeData = false

            if type(v.stage) == "table" then
                for j = 1, #v.stage,2 do
                    if stage >= v.stage[j] and stage <= v.stage[j+1] then
                        isMergeData = true
                        break
                    end
                end
            elseif type(v.stage) == "number" then
                if v.stage == stage then
                    isMergeData = true
                end
            end


            if isMergeData and roomNo == v.room then
                --print("xxx--------merge")
                v.no = nil
                v.stage = nil
                v.room = nil
                v.use_id = nil
                v.id = nil

                for key, value in pairs(v) do
                    dataInfo[key] = value
                end
            end

            break
        end
    end
    return dataInfo
end

--- 普通关卡的 数值系数处理
function NorStageValueFactorToDataInfo(dataInfo , _stage , _roomNo )
    local stageData = GameInfoCenter.GetStageData()
    local stage = _stage or stageData.curLevel
    local roomNo = _roomNo or stageData.roomNo
     --- 不是nor关卡直接返回
    --[[if stageData.modelType ~= "normal" then
        return dataInfo
    end--]]
    --print("xxxx---------------NorStageValueFactorToDataInfo 1")
    local stage_cfg = GameConfigCenter.GetStageMainCfg( stage )
    -- 获取每关的配置
    if not stage_cfg or not stage_cfg.valueFactorData then
        return dataInfo
    end
    local factorCfg = stage_cfg.valueFactorData

    local function dealFactor( _value , _factorVec )
        if type(_value) == "table" then
            for _k , _v in pairs(_value) do
                _value[_k] = dealFactor(_v , _factorVec)
            end
            return _value
        elseif type(_value) == "number" then
            local stageFactor = factorCfg[ _factorVec.stage ] or factorCfg.defaultStage
            local roomFactor = factorCfg[ _factorVec.room ] or factorCfg.defaultRoom

            return math.floor(_value*stageFactor*(1 + roomFactor * roomNo) )
        end
    end

    --print("xxxx---------------NorStageValueFactorToDataInfo 4")
    
    local changeMap = {
        { checkType = "keyType" , checkValue = "monster" , dealType = { "hp" } , factorKey = { stage = "monsterStage" , room = "monsterRoom" } } ,
        { checkType = "keyType" , checkValue = "building" , dealType = { "hp" } , factorKey = { stage = "buildingStage" , room = "buildingRoom" } } ,
        { checkType = "key" , checkValue = "goldCoin1" , dealType = { "data" } , factorKey = { stage = "goldStage" , room = "goldRoom" } } ,
        { checkType = "key" , checkValue = "goldCoin2" , dealType = { "data" } , factorKey = { stage = "goldStage" , room = "goldRoom" } } ,
        { checkType = "key" , checkValue = "goldCoin3" , dealType = { "data" } , factorKey = { stage = "goldStage" , room = "goldRoom" } } ,
    }   

    ---- 寻找要处理的 值的类型
    local dealType = nil
    local factorKey = nil
    for key , data in pairs(changeMap) do
        if dataInfo[ data.checkType ] == data.checkValue then
            dealType = data.dealType
            factorKey = data.factorKey
            break
        end
    end

    --dump( { factorCfg , stageData , dataInfo }  , "<color=yellow>xxx-----------factorCfg:</color> ")
    ---- 找到了就处理
    if dealType and factorKey then
        for key,_type in pairs(dealType) do
            if dataInfo[_type] then
                dataInfo[_type] = dealFactor( dataInfo[_type] , factorKey )
            end
        end
    end

    --dump( { factorCfg , stageData , dataInfo }  , "<color=yellow>xxx-----------factorCfg 22:</color> ")
    return dataInfo
end

function DataInfoTonConfigHandle(dataInfo,gameObject)
    if dataInfo.comType == "monster" or dataInfo.comType == "goodsGem" then
        local parentInfo = GetDataInfo(gameObject.transform.parent.gameObject)
        dataInfo.stageIndex = parentInfo.number
    end
end

function GetDataInfo(gameObject)
    --- unity中配置的数据转换
    local dataInfo
    dataInfo = GetGameObjectDataInfo(dataInfo,gameObject)
    --- unity 中配置的数据处理
    dataInfo = DataInfoToTable(dataInfo,gameObject)
    --- 处理 配置的id 对应 数据表
    dataInfo = DataInfoToConfig(dataInfo)
    DataInfoTonConfigHandle(dataInfo,gameObject)
    -- local stageData = GameInfoCenter.GetStageData()

    ---- 普通模式
    --if stageData.modelType == "normal" then
        --- 处理 normal_stage的 总表替换
        --dataInfo = NorStageFinalDataToDataInfo(dataInfo)

        ---- 做怪物，建筑的数值随关卡的 数值系数处理
        --dataInfo = NorStageFinalDataToDataInfo(dataInfo)
    --end

    

    return dataInfo
end

----- 根据某种规则附加属性值
--[[
    _org_data 原始数据, 
    _change_table 改变规则表 , 
    _change_key   规则key
    _rule_value  规则key的值

    _dealModle  处理模式，set 直接设置 , add 数值附加，表设置

--]]
function BaseChangeByRuleKey( _org_data , _rule_table , _rule_key , _rule_value , _dealModle )
    _dealModle = _dealModle or "add"

    if not _rule_table then
        return _org_data
    end
    --dump( _org_data , "xxx-------------_org_data:" .. _rule_key .. "," .. _rule_value )
    ----- 把所有 规则key的数据都找出来，并找到最大的 规则key
    local ruleDealTable = {}
    local max_value = 0
    for key,data in pairs(_rule_table) do
        local ruleKeyValue = data[ _rule_key ] 
        if ruleKeyValue then
            if ruleKeyValue > max_value then
                max_value = ruleKeyValue
            end
            ruleDealTable[ ruleKeyValue ] = data
        end
    end

    ---- 找到第一个大于自己等级值的改变数据表
    local findRuleData = function(rule_value)
        if rule_value > max_value then
            return nil
        end

        for i = rule_value , max_value do
            if ruleDealTable[i] then
                return ruleDealTable[i]
            end
        end
    end

    ---- 处理从 参数规则值 开始的每一级
    for i = _rule_value , 1 , -1 do
        local rule_data = findRuleData(i)

        ---- 如果找到对应的规则数据
        if rule_data then
            for key,data in pairs(rule_data) do
                if key ~= "no" and key ~= "id" and key ~= _rule_key then

                    if _dealModle == "set" then
                        --print("xxx--------set__" , key , data )
                        _org_data[key] = data
                        
                    elseif _dealModle == "add" then
                        if type(data) == "number" then
                            --print("xxx--------add__" , key , _org_data[key] , data )
                            _org_data[key] = (_org_data[key] or 0) + data
                        else
                            _org_data[key] = data
                        end
                    end

                end
            end
        end
    end

    return _org_data
end

---- 处理技能改变

function SkillChangeByRuleKey( _org_data , _rule_table , _rule_key , _rule_value )
    if not _rule_table then
        return _org_data
    end

    ----- 把所有 规则key的数据都找出来，并找到最大的 规则key
    local ruleDealTable = {}
    local max_value = 0
    --- 按顺序处理 ipairs
    for key,data in ipairs(_rule_table) do
        local ruleKeyValue = data[ _rule_key ] 
        if ruleKeyValue then
            if ruleKeyValue > max_value then
                max_value = ruleKeyValue
            end
            ruleDealTable[ ruleKeyValue ] = ruleDealTable[ ruleKeyValue ] or {} 
            local tar_data = ruleDealTable[ ruleKeyValue ] 

            tar_data[#tar_data + 1] = data
        end
    end

    ---- 找到第一个大于自己等级值的改变数据表
    local findRuleData = function(rule_value)
        if rule_value > max_value then
            return nil
        end

        for i = rule_value , max_value do
            if ruleDealTable[i] then
                return ruleDealTable[i]
            end
        end
    end

    ---- 处理从 参数规则值 开始的每一级
    for i = 1 , _rule_value do
        local rule_data = findRuleData(i)

        ---- 如果找到对应的规则数据
        if rule_data then
            for key,data in ipairs(rule_data) do
                local change_skill = data.skill_id

                if change_skill then
                    for key, skill_id in ipairs(change_skill) do
                        if skill_id < 0 then
                            --- 小于0的直接删除
                            _org_data.skill[ skill_id ] = nil
                        elseif skill_id > 0 then
                            --- 大于0 加上规则
                            _org_data.skill[ skill_id ] = type(_org_data.skill[ skill_id ]) == "table" and _org_data.skill[ skill_id ] or {}
                            local tar_data = _org_data.skill[ skill_id ]

                            if data.change_key and data.change_type and data.change_value then
                                tar_data[ data.change_key ] = data
                            end
                        end
                    end
                end

            end
        end
    end

    return _org_data
end

--[[
    从一个点查找范围内一个可行的点
]]
function FindRangeWorkablePos(_object , pos,d,r1,r2)

    for i=1,60 do
        local p = nil
        for i=1,10 do
            p = RandomSquares(pos,r1*d,r2*d)

            --local npd = GameInfoCenter.GetMapNotPassGridData()
            local npd = GetMapNotPassGridData(_object)
            local pk = GetMapNoByPos(_object , p)
            if not npd[pk] then
                break
            end

        end
        --dump( {  "4_dir" , pos , nil , p , {} } , "xxx-------GetGridMovePath 444" )
        if GetGridMovePath( _object , "4_dir" , pos , nil , p , {} , true ) then
            return p
        end

    end

end


-- 修改场景中的层级
local debugChangeLayer = false
function ChangeLayer(obj, referSortingOrder, isUp)
    local debugT
    if debugChangeLayer then
        debugT = {}
        debugT.objName = obj.gameObject.name
        debugT.referSortingOrder = referSortingOrder
    end

    -- local meshs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SpriteRenderer))
    local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    local min = 9999999
    local max = -9999999
    for i = 0, ps.Length - 1 do
        if debugChangeLayer then
            debugT.oldRend = debugT.oldRend or {}
            debugT.oldRend[#debugT.oldRend + 1] = {name=ps[i].gameObject.name, order=ps[i].sortingOrder}
        end
        if max < ps[i].sortingOrder then
            max = ps[i].sortingOrder
        end
        if min > ps[i].sortingOrder then
            min = ps[i].sortingOrder
        end
    end

    if debugChangeLayer then
        debugT.oldMin = min
        debugT.oldMax = max
    end

    if isUp then
        max = referSortingOrder - min + 1
    else
        max = referSortingOrder - max - 1
    end

    if debugChangeLayer then
        debugT.newMin = min
        debugT.newMax = max
    end

    for i = 0, ps.Length - 1 do
        if ps[i].sortingOrder + max > 32767 then -- 超过最大限制
            ps[i].sortingOrder = 32767
        else
            ps[i].sortingOrder = ps[i].sortingOrder + max
        end
    end
    if debugChangeLayer then
        if ps[0].sortingOrder < -500 then
            dump(debugT, "<color=red><size=16>======= AAAAAAA OOOOOOOOOOOOOO </size></color>")
        end
    end
end
-- 数据强转成表
function ForceToTable(data)
    if not data then
        return {}
    end
    if type(data) == "table" then
        return data
    else
        return {data}
    end
end