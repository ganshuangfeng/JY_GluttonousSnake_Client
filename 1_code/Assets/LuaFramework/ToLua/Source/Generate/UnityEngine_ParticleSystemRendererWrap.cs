//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_ParticleSystemRendererWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.ParticleSystemRenderer), typeof(UnityEngine.Renderer));
		L.RegFunction("GetMeshes", GetMeshes);
		L.RegFunction("SetMeshes", SetMeshes);
		L.RegFunction("SetActiveVertexStreams", SetActiveVertexStreams);
		L.RegFunction("GetActiveVertexStreams", GetActiveVertexStreams);
		L.RegFunction("BakeMesh", BakeMesh);
		L.RegFunction("BakeTrailsMesh", BakeTrailsMesh);
		L.RegFunction("New", _CreateUnityEngine_ParticleSystemRenderer);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("mesh", get_mesh, set_mesh);
		L.RegVar("meshCount", get_meshCount, null);
		L.RegVar("activeVertexStreamsCount", get_activeVertexStreamsCount, null);
		L.RegVar("alignment", get_alignment, set_alignment);
		L.RegVar("renderMode", get_renderMode, set_renderMode);
		L.RegVar("sortMode", get_sortMode, set_sortMode);
		L.RegVar("lengthScale", get_lengthScale, set_lengthScale);
		L.RegVar("velocityScale", get_velocityScale, set_velocityScale);
		L.RegVar("cameraVelocityScale", get_cameraVelocityScale, set_cameraVelocityScale);
		L.RegVar("normalDirection", get_normalDirection, set_normalDirection);
		L.RegVar("shadowBias", get_shadowBias, set_shadowBias);
		L.RegVar("sortingFudge", get_sortingFudge, set_sortingFudge);
		L.RegVar("minParticleSize", get_minParticleSize, set_minParticleSize);
		L.RegVar("maxParticleSize", get_maxParticleSize, set_maxParticleSize);
		L.RegVar("pivot", get_pivot, set_pivot);
		L.RegVar("flip", get_flip, set_flip);
		L.RegVar("maskInteraction", get_maskInteraction, set_maskInteraction);
		L.RegVar("trailMaterial", get_trailMaterial, set_trailMaterial);
		L.RegVar("enableGPUInstancing", get_enableGPUInstancing, set_enableGPUInstancing);
		L.RegVar("allowRoll", get_allowRoll, set_allowRoll);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_ParticleSystemRenderer(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.ParticleSystemRenderer obj = new UnityEngine.ParticleSystemRenderer();
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.ParticleSystemRenderer.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetMeshes(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
			UnityEngine.Mesh[] arg0 = ToLua.CheckObjectArray<UnityEngine.Mesh>(L, 2);
			int o = obj.GetMeshes(arg0);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMeshes(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh[] arg0 = ToLua.CheckObjectArray<UnityEngine.Mesh>(L, 2);
				obj.SetMeshes(arg0);
				return 0;
			}
			else if (count == 3)
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh[] arg0 = ToLua.CheckObjectArray<UnityEngine.Mesh>(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				obj.SetMeshes(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystemRenderer.SetMeshes");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetActiveVertexStreams(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
			System.Collections.Generic.List<UnityEngine.ParticleSystemVertexStream> arg0 = (System.Collections.Generic.List<UnityEngine.ParticleSystemVertexStream>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.List<UnityEngine.ParticleSystemVertexStream>));
			obj.SetActiveVertexStreams(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetActiveVertexStreams(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
			System.Collections.Generic.List<UnityEngine.ParticleSystemVertexStream> arg0 = (System.Collections.Generic.List<UnityEngine.ParticleSystemVertexStream>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.List<UnityEngine.ParticleSystemVertexStream>));
			obj.GetActiveVertexStreams(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BakeMesh(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				obj.BakeMesh(arg0);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes<UnityEngine.Camera>(L, 3))
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				UnityEngine.Camera arg1 = (UnityEngine.Camera)ToLua.ToObject(L, 3);
				obj.BakeMesh(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes<bool>(L, 3))
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				obj.BakeMesh(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				UnityEngine.Camera arg1 = (UnityEngine.Camera)ToLua.CheckObject(L, 3, typeof(UnityEngine.Camera));
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				obj.BakeMesh(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystemRenderer.BakeMesh");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BakeTrailsMesh(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				obj.BakeTrailsMesh(arg0);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes<UnityEngine.Camera>(L, 3))
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				UnityEngine.Camera arg1 = (UnityEngine.Camera)ToLua.ToObject(L, 3);
				obj.BakeTrailsMesh(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes<bool>(L, 3))
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				obj.BakeTrailsMesh(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystemRenderer));
				UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
				UnityEngine.Camera arg1 = (UnityEngine.Camera)ToLua.CheckObject(L, 3, typeof(UnityEngine.Camera));
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				obj.BakeTrailsMesh(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystemRenderer.BakeTrailsMesh");
			}
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
	static int get_mesh(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Mesh ret = obj.mesh;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index mesh on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_meshCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			int ret = obj.meshCount;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index meshCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_activeVertexStreamsCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			int ret = obj.activeVertexStreamsCount;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index activeVertexStreamsCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_alignment(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.ParticleSystemRenderSpace ret = obj.alignment;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index alignment on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_renderMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.ParticleSystemRenderMode ret = obj.renderMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index renderMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sortMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.ParticleSystemSortMode ret = obj.sortMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sortMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_lengthScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.lengthScale;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index lengthScale on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_velocityScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.velocityScale;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index velocityScale on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cameraVelocityScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.cameraVelocityScale;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index cameraVelocityScale on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_normalDirection(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.normalDirection;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index normalDirection on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_shadowBias(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.shadowBias;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index shadowBias on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sortingFudge(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.sortingFudge;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sortingFudge on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minParticleSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.minParticleSize;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index minParticleSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maxParticleSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float ret = obj.maxParticleSize;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxParticleSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pivot(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Vector3 ret = obj.pivot;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index pivot on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_flip(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Vector3 ret = obj.flip;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index flip on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maskInteraction(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.SpriteMaskInteraction ret = obj.maskInteraction;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maskInteraction on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_trailMaterial(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Material ret = obj.trailMaterial;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index trailMaterial on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_enableGPUInstancing(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			bool ret = obj.enableGPUInstancing;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index enableGPUInstancing on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_allowRoll(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			bool ret = obj.allowRoll;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index allowRoll on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mesh(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckObject(L, 2, typeof(UnityEngine.Mesh));
			obj.mesh = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index mesh on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_alignment(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.ParticleSystemRenderSpace arg0 = (UnityEngine.ParticleSystemRenderSpace)LuaDLL.luaL_checknumber(L, 2);
			obj.alignment = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index alignment on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_renderMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.ParticleSystemRenderMode arg0 = (UnityEngine.ParticleSystemRenderMode)LuaDLL.luaL_checknumber(L, 2);
			obj.renderMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index renderMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sortMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.ParticleSystemSortMode arg0 = (UnityEngine.ParticleSystemSortMode)LuaDLL.luaL_checknumber(L, 2);
			obj.sortMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sortMode on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_lengthScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.lengthScale = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index lengthScale on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_velocityScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.velocityScale = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index velocityScale on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cameraVelocityScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.cameraVelocityScale = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index cameraVelocityScale on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_normalDirection(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.normalDirection = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index normalDirection on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_shadowBias(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.shadowBias = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index shadowBias on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sortingFudge(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.sortingFudge = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index sortingFudge on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_minParticleSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.minParticleSize = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index minParticleSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maxParticleSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.maxParticleSize = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxParticleSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pivot(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.pivot = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index pivot on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_flip(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.flip = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index flip on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maskInteraction(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.SpriteMaskInteraction arg0 = (UnityEngine.SpriteMaskInteraction)LuaDLL.luaL_checknumber(L, 2);
			obj.maskInteraction = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maskInteraction on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_trailMaterial(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			UnityEngine.Material arg0 = (UnityEngine.Material)ToLua.CheckObject<UnityEngine.Material>(L, 2);
			obj.trailMaterial = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index trailMaterial on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_enableGPUInstancing(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.enableGPUInstancing = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index enableGPUInstancing on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_allowRoll(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystemRenderer obj = (UnityEngine.ParticleSystemRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.allowRoll = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index allowRoll on a nil value");
		}
	}
}

