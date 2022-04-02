﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaFramework_ColliderBehaviourWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaFramework.ColliderBehaviour), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("OnTriggerEnter", OnTriggerEnter);
		L.RegFunction("OnTriggerExit", OnTriggerExit);
		L.RegFunction("OnTriggerStay", OnTriggerStay);
		L.RegFunction("GetLuaTable", GetLuaTable);
		L.RegFunction("SetLuaTable", SetLuaTable);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("luaTableName", get_luaTableName, set_luaTableName);
		L.RegVar("luaTable", get_luaTable, set_luaTable);
		L.RegVar("collisionStay2D", get_collisionStay2D, set_collisionStay2D);
		L.RegVar("collisionStay", get_collisionStay, set_collisionStay);
		L.RegVar("triggerStay2D", get_triggerStay2D, set_triggerStay2D);
		L.RegVar("triggerStay", get_triggerStay, set_triggerStay);
		L.RegVar("isDebug", get_isDebug, set_isDebug);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnTriggerEnter(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)ToLua.CheckObject<LuaFramework.ColliderBehaviour>(L, 1);
			UnityEngine.Collider arg0 = (UnityEngine.Collider)ToLua.CheckObject<UnityEngine.Collider>(L, 2);
			obj.OnTriggerEnter(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnTriggerExit(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)ToLua.CheckObject<LuaFramework.ColliderBehaviour>(L, 1);
			UnityEngine.Collider arg0 = (UnityEngine.Collider)ToLua.CheckObject<UnityEngine.Collider>(L, 2);
			obj.OnTriggerExit(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnTriggerStay(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)ToLua.CheckObject<LuaFramework.ColliderBehaviour>(L, 1);
			UnityEngine.Collider arg0 = (UnityEngine.Collider)ToLua.CheckObject<UnityEngine.Collider>(L, 2);
			obj.OnTriggerStay(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLuaTable(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)ToLua.CheckObject<LuaFramework.ColliderBehaviour>(L, 1);
			LuaInterface.LuaTable o = obj.GetLuaTable();
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLuaTable(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)ToLua.CheckObject<LuaFramework.ColliderBehaviour>(L, 1);
			LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
			obj.SetLuaTable(arg0);
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
	static int get_luaTableName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			string ret = obj.luaTableName;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaTableName on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_luaTable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			LuaInterface.LuaTable ret = obj.luaTable;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaTable on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_collisionStay2D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool ret = obj.collisionStay2D;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index collisionStay2D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_collisionStay(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool ret = obj.collisionStay;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index collisionStay on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_triggerStay2D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool ret = obj.triggerStay2D;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index triggerStay2D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_triggerStay(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool ret = obj.triggerStay;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index triggerStay on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isDebug(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool ret = obj.isDebug;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isDebug on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_luaTableName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.luaTableName = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaTableName on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_luaTable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
			obj.luaTable = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaTable on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_collisionStay2D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.collisionStay2D = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index collisionStay2D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_collisionStay(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.collisionStay = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index collisionStay on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_triggerStay2D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.triggerStay2D = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index triggerStay2D on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_triggerStay(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.triggerStay = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index triggerStay on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isDebug(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.ColliderBehaviour obj = (LuaFramework.ColliderBehaviour)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.isDebug = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isDebug on a nil value");
		}
	}
}
