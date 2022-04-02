-- by lyx 2021-8-13

local LF = {}


-- 得到字符 表示的状态
function LF.get_char_status(_status_str,_index)
    _index = tonumber(_index)
    if not _index or _index < 1 then
        print.char_status_lib( "get_char_status____error 1 :" , _status_str , _index , debug.traceback() )
        return false
    end

    if "string" ~= type(_status_str) then
        return false
    end

    local _len = string.len(_status_str)
    if _len  < 1 then
        return false
    end

    -- 未压缩的字符串
    if string.sub(_status_str,1,1) ~= "+" then
        if _len  < _index then
            return false
        end
        
        return string.sub(_status_str,_index,_index) == "1"
    end

    -- 压缩的字符串

    local _curPos = 2
    local _curIndex = 0   -- 当前状态序号
    local _zip_left = nil

    while true do
        local char = string.sub(_status_str, _curPos , _curPos )
        if char ~= "[" and char ~= "]" and not _zip_left then
            _curIndex = _curIndex + 1
            if _curIndex == _index then
                return char == "1"
            end
        end

        if char == "[" then
            _zip_left = _curPos
        end

        if char == "]" then
            ---- 出错判断
            if not _zip_left or _curPos + 1 > _len then
                return false
            end

            local num = tonumber( string.sub( _status_str, _zip_left + 1 , _curPos - 1 ) )
            _zip_left = nil
            
            _curIndex = _curIndex + num
            if _index <= _curIndex then
                --- 用 "]"后面一个字符
                return string.sub( _status_str, _curPos + 1 , _curPos + 1 ) == "1"
            end
            --- 多跳一个
            _curPos = _curPos + 1
        end

        _curPos = _curPos + 1
        if _curPos > _len then
            return false
        end
    end
end

-- 得到字符 表示的状态（通过 解析出来的表结果）
function LF.get_table_char_status(_status_table,_index)
    if type(_status_table) ~= "table" then
        return false
    end

    local _curIndex = 1 -- 当前状态序号
    for i,v in ipairs(_status_table) do

        -- 当前 v 表示的状态数量
        local _c = v.c and v.c or #v
        
        if _index < _curIndex + _c then
            if v.c then
                return v.v
            else
                return v[_index-_curIndex+1]
            end
        end

        _curIndex = _curIndex + _c
    end

    return false
end

-- 压缩 字符表示的状态表 ， 返回新的表
function LF.zip_table_char_status(_status_table)
    if type(_status_table) ~= "table" or not _status_table[1] then
        return {}
    end

    local _ret = {}

    -- 当前连续的 状态 和个数
    local _cur_v = nil
    local _cur_c = 0

    -- 插入当前的
    local function append_cur()
        if _cur_c == 1 then -- 如果是 1 ，就不用压缩方式了， 以便和其他的独立状态合成一个表： {true,false,false,...}
            if _ret[#_ret] and not _ret[#_ret].c then
                table.insert(_ret[#_ret],_cur_v)
            else
                _ret[#_ret+1] = {_cur_v}
            end
        else
            _ret[#_ret+1] = {v=_cur_v,c=_cur_c}
        end
    end

    -- 遍历
    for i,v in ipairs(_status_table) do
        if v.c then
            if _cur_v == nil then
                _cur_v = v.v
                _cur_c = v.c
            else
                if _cur_v == v.v then
                    _cur_c = _cur_c + v.c
                else
                    append_cur()
                    _cur_v = v.v
                    _cur_c = v.c
                end
            end
        else
            for j,v2 in ipairs(v) do
                if _cur_v == nil then
                    _cur_v = v2
                    _cur_c = 1
                else
                    if _cur_v == v2 then
                        _cur_c = _cur_c + 1
                    else
                        append_cur()
                        _cur_v = v2
                        _cur_c = 1
                    end
                end
            end
        end
    end

    -- 最后一个
    if _cur_v ~= nil then
        append_cur()
    end

    return _ret
end

-- 设置字符 表示的状态（通过 解析出来的表结果）
-- 返回： 如果 _status_table 是表，则修改他并返回；否则创建新表并设置
-- 注意：设置完后，可能不再是最优方案，在适当的时候 应该调用 zip_table_char_status 进行压缩
function LF.set_table_char_status(_status_table,_index,_value)

    _value = _value and true or false -- 转换为为标准的 true/false

    if type(_status_table) ~= "table" then
        if _value == false then
            return {} -- 空值 默认为 false
        end

        if _index == 1 then
            return {{true}}
        end

        -- 中间 要补 false
        return {{v=false,c=_index-1},{true}}
    end


    local _curIndex = 1 -- 当前状态序号
    for i,v in ipairs(_status_table) do

        -- 当前 v 表示的状态数量
        local _c = v.c and v.c or #v
        
        if _index < _curIndex + _c then -- 目标序号 落在范围内
            local _offset = _index - _curIndex + 1 -- 目标在当前分组中的偏移     

            -- 数组模式的，直接设置
            if not v.c then
                v[_offset] = _value
                return _status_table
            end

            if _value ~= v.v then -- 不相同，拆分（最多 三部分）

                if v.c == 1 then                -- ★ 只有一个，直接改
                    v.v = _value
                else
                    if _offset == 1 then        -- ★ 是第一个，插入到前面
                        v.c = v.c - 1 
                        table.insert(_status_table,i,{_value})
                    elseif _offset == v.c then  -- ★ 是最后一个，插入到后面
                        v.c = v.c - 1 
                        table.insert(_status_table,i+1,{_value})
                    else                        -- ★ 在中间
                        v.c = _offset - 1 -- 原始的直接作为第一个
                        table.insert(_status_table,i+1,{_value})
                        table.insert(_status_table,i+2,{v=v.v,c=_c-_offset})
                    end
                end
            end

            return _status_table
        end

        _curIndex = _curIndex + _c
    end

    -- 超过尾部
    if _curIndex == _index then
        table.insert(_status_table,{_value})
    elseif _value == false then
        table.insert(_status_table,{v=_value,c=_index-_curIndex+1})
    else
        table.insert(_status_table,{v=false,c=_index-_curIndex}) -- 中间补 false 
        table.insert(_status_table,{_value})
    end

    return _status_table
end

-- 将字符表示的状态 解析为 表结构：
--      连续不同的表示为 {true,false,...}；
--      连续相同的表示为 {v=value,c=count}
function LF.parse_char_status(_status_str)
    if type(_status_str) ~= "string" then
        return _status_str
    end

    local _len = string.len(_status_str)

    -- 源串 还无内容
    if _len < 1 then
        return {}
    end

    local _ret = {}

    -- 未压缩的字符串
    if string.sub(_status_str,1,1) ~= "+" then
        for i=1,_len do
            _ret[#_ret+1] = "1" == string.sub(_status_str,i,i) and true or false
        end

        return {_ret}
    end

    -- 压缩的字符串

    local _charPos = 2 -- 当前位置的字符序号
    while _charPos <= _len do
        local _kh1 = string.find(_status_str,"[",_charPos,true) -- 左括号 "["
        if _kh1 then

            -- 处理未压缩 序列（"["前面的）
            if _kh1 - _charPos > 0 then
                local _tmp = {}
                for i=_charPos,_kh1-1 do
                    _tmp[#_tmp+1] = "1" == string.sub(_status_str,i,i) and true or false
                end

                _ret[#_ret+1] = _tmp
            end

            -- 处理压缩序列

            local _kh2 = string.find(_status_str,"]",_kh1+1,true) -- 右括号 "]"

            -- 没找到 合法 的右括号，则处理结束： 默认为 0 
            if not _kh2 or (_kh2 - _kh1 == 1) or (_len < _kh2 + 1) then
                return _ret
            end

            _ret[#_ret+1] = {
                v = "1" == string.sub(_status_str,_kh2+1,_kh2+1) and true or false,
                c = tonumber(string.sub(_status_str,_kh1+1,_kh2-1))
            }

            _charPos = _kh2+2 -- 跳过最后一个数字
        else
            local _tmp = {}
            for i=_charPos,_len do
                _tmp[#_tmp+1] = "1" == string.sub(_status_str,i,i) and true or false
            end
            _ret[#_ret+1] = _tmp

            return _ret
        end
    end    

    return _ret
end

function LF.table_status_tostring(_status_table,_do_zip)

    if type(_status_table) ~= "table" or not _status_table[1] then
        return ""
    end

    if _do_zip then
        _status_table = LF.zip_table_char_status(_status_table)
    end

    local _strs = {"+"}
    local _stmp = {}   -- 可重复利用的表
    for i,v in ipairs(_status_table) do
        if v.c then
            if v.c > 5 then
                _strs[#_strs+1] = "[" .. tonumber(v.c) .. "]" .. (v.v and "1" or "0")
            else
                _strs[#_strs+1] = string.rep(v.v and "1" or "0",v.c)
            end
        else
            if next(v) then
                for j,v2 in ipairs(v) do
                    _stmp[j] = v2 and "1" or "0"
                    _stmp[j+1] = nil
                end
                _strs[#_strs+1] = table.concat(_stmp)
            end
        end
    end

    return table.concat(_strs)
end

return LF