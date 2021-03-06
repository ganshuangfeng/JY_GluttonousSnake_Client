//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaFramework_LuaBehaviourScrollWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaFramework.LuaBehaviourScroll), typeof(View));
		L.RegFunction("GetLuaTable", GetLuaTable);
		L.RegFunction("AddClick", AddClick);
		L.RegFunction("RemoveClick", RemoveClick);
		L.RegFunction("ClearClick", ClearClick);
		L.RegFunction("AddEndEdit", AddEndEdit);
		L.RegFunction("RemoveEndEdit", RemoveEndEdit);
		L.RegFunction("ClearEndEdit", ClearEndEdit);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("luaTable", get_luaTable, set_luaTable);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLuaTable(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
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
	static int AddClick(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
				UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
				obj.AddClick(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
				UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
				LuaTable arg2 = ToLua.CheckLuaTable(L, 4);
				obj.AddClick(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.LuaBehaviourScroll.AddClick");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveClick(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
			obj.RemoveClick(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearClick(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
			obj.ClearClick();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddEndEdit(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
				UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
				obj.AddEndEdit(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
				UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
				LuaTable arg2 = ToLua.CheckLuaTable(L, 4);
				obj.AddEndEdit(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.LuaBehaviourScroll.AddEndEdit");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveEndEdit(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
			obj.RemoveEndEdit(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearEndEdit(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)ToLua.CheckObject<LuaFramework.LuaBehaviourScroll>(L, 1);
			obj.ClearEndEdit();
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
	static int get_luaTable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)o;
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
	static int set_luaTable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.LuaBehaviourScroll obj = (LuaFramework.LuaBehaviourScroll)o;
			LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
			obj.luaTable = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaTable on a nil value");
		}
	}
}

