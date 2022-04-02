﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaProfilerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("LuaProfiler");
		L.RegFunction("Clear", Clear);
		L.RegFunction("GetID", GetID);
		L.RegFunction("BeginSample", BeginSample);
		L.RegFunction("EndSample", EndSample);
		L.RegVar("list", get_list, set_list);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			LuaProfiler.Clear();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetID(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			int o = LuaProfiler.GetID(arg0);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BeginSample(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes<string>(L, 1))
			{
				string arg0 = ToLua.ToString(L, 1);
				LuaProfiler.BeginSample(arg0);
				return 0;
			}
			else if (count == 1 && TypeChecker.CheckTypes<int>(L, 1))
			{
				int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
				LuaProfiler.BeginSample(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaProfiler.BeginSample");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EndSample(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			LuaProfiler.EndSample();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_list(IntPtr L)
	{
		try
		{
			ToLua.PushSealed(L, LuaProfiler.list);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_list(IntPtr L)
	{
		try
		{
			System.Collections.Generic.List<string> arg0 = (System.Collections.Generic.List<string>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.List<string>));
			LuaProfiler.list = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

