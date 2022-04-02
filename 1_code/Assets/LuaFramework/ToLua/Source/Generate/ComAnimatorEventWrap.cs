﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ComAnimatorEventWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ComAnimatorEvent), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("CallIntStr", CallIntStr);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("onCall", get_onCall, set_onCall);
		L.RegVar("onDestroy", get_onDestroy, set_onDestroy);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CallIntStr(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ComAnimatorEvent obj = (ComAnimatorEvent)ToLua.CheckObject<ComAnimatorEvent>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			obj.CallIntStr(arg0);
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

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onCall(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComAnimatorEvent obj = (ComAnimatorEvent)o;
			LuaInterface.LuaFunction ret = obj.onCall;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onCall on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDestroy(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComAnimatorEvent obj = (ComAnimatorEvent)o;
			LuaInterface.LuaFunction ret = obj.onDestroy;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onDestroy on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onCall(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComAnimatorEvent obj = (ComAnimatorEvent)o;
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.onCall = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onCall on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDestroy(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComAnimatorEvent obj = (ComAnimatorEvent)o;
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.onDestroy = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onDestroy on a nil value");
		}
	}
}
