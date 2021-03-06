//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class TalkingDataManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(TalkingDataManager), typeof(Manager));
		L.RegFunction("Init", Init);
		L.RegFunction("GetDeviceId", GetDeviceId);
		L.RegFunction("GetOAID", GetOAID);
		L.RegFunction("SetProfileName", SetProfileName);
		L.RegFunction("SetProfileType", SetProfileType);
		L.RegFunction("SetLevel", SetLevel);
		L.RegFunction("SetGender", SetGender);
		L.RegFunction("SetAge", SetAge);
		L.RegFunction("SetGameServer", SetGameServer);
		L.RegFunction("BeginMission", BeginMission);
		L.RegFunction("CompleteMission", CompleteMission);
		L.RegFunction("FailedMission", FailedMission);
		L.RegFunction("OnChargeRequest", OnChargeRequest);
		L.RegFunction("OnChargeSuccess", OnChargeSuccess);
		L.RegFunction("OnReward", OnReward);
		L.RegFunction("OnPurchase", OnPurchase);
		L.RegFunction("OnUse", OnUse);
		L.RegFunction("SetLocation", SetLocation);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Init(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			obj.Init(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDeviceId(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string o = obj.GetDeviceId();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetOAID(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string o = obj.GetOAID();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetProfileName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.SetProfileName(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetProfileType(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SetProfileType(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLevel(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SetLevel(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetGender(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SetGender(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetAge(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SetAge(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetGameServer(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.SetGameServer(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BeginMission(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.BeginMission(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CompleteMission(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.CompleteMission(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FailedMission(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			obj.FailedMission(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnChargeRequest(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 7);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			double arg2 = (double)LuaDLL.luaL_checknumber(L, 4);
			string arg3 = ToLua.CheckString(L, 5);
			double arg4 = (double)LuaDLL.luaL_checknumber(L, 6);
			string arg5 = ToLua.CheckString(L, 7);
			obj.OnChargeRequest(arg0, arg1, arg2, arg3, arg4, arg5);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnChargeSuccess(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.OnChargeSuccess(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnReward(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			obj.OnReward(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnPurchase(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
			double arg2 = (double)LuaDLL.luaL_checknumber(L, 4);
			obj.OnPurchase(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnUse(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
			obj.OnUse(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLocation(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			TalkingDataManager obj = (TalkingDataManager)ToLua.CheckObject<TalkingDataManager>(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 2);
			double arg1 = (double)LuaDLL.luaL_checknumber(L, 3);
			obj.SetLocation(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

