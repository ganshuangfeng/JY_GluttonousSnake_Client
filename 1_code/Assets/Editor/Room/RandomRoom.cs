using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;

[Serializable]
public class PrefabData
{
	public string name = "";
	public string path = "";
	public string image = "Assets/Game/game_CS/Image/map2d/2D_map_xiangzi_01.png";
    public Texture imageTexture;
	public string desc = "";
	public float w;
	public float h;
	public float scale;
}

[Serializable]
public class MapPrefabData
{
    public string name = "";
    public string path = "";
    public string image = "Assets/Game/game_CS/Image/map2d/2D_map_xiangzi_01.png";
    public Texture imageTexture;
    public string desc = "";
    public float w;
    public float h;
    public float scale;
}

[Serializable]
public class RoomConfig
{
    public List<PrefabData> prefab = new List<PrefabData>();
}

[Serializable]
public class MapConfig
{
    public List<MapPrefabData> map_data = new List<MapPrefabData>();
}

public class RandomRoom
{	

	public static List<PrefabData> getPrefabPathList()
	{
		List<PrefabData> data = new List<PrefabData>();
		PrefabData pd;
  		//   	string[] paths = Directory.GetFiles("Assets/Game/game_CS/Image/map2d/map1/wj_one", "*.prefab", SearchOption.AllDirectories);
		// for (int i = 0; i < paths.Length; i++)
		// {
		// 	Debug.Log(paths[i]);
		// 	PrefabData pd = new PrefabData();
		// 	pd.path = paths[i];
		// 	data.Add(pd);
		// }

		string fileName = "Assets/Editor/Room/room_prefab.json";
		RoomConfig prefabConfig = JsonUtility.FromJson<RoomConfig>(File.ReadAllText(fileName));
		data = prefabConfig.prefab;

		Debug.Log("长度=" + prefabConfig.prefab.Count);
        foreach (PrefabData it in prefabConfig.prefab)
        {
            it.imageTexture = AssetDatabase.LoadAssetAtPath(EditorFileUtility.GetRelativeAssetPath(it.image), typeof(Texture)) as Texture;
        }
		return data;
	}

	static GameObject CreatePrefab(string path)
	{
        GameObject prefabObj = AssetDatabase.LoadAssetAtPath(EditorFileUtility.GetRelativeAssetPath(path), typeof(GameObject)) as GameObject;
        GameObject obj = PrefabUtility.InstantiatePrefab(prefabObj) as GameObject;
        return obj;
	}

	static Vector2 gridSize = new Vector2(1.6f, 1.6f);

    [MenuItem("Tools/Room/随机房间")]
    static void RunRandomRoom()
    {
    	// GameObject room = CreatePrefab("Assets/Game/game_CS/Image/map2d/map1/mapTest.prefab");

    	List<PrefabData> data = getPrefabPathList();
    	System.Random rd = new System.Random();

    	// for (int i = 1; i < 10; ++i)
    	// {
     //    	GameObject obj = CreatePrefab(data[1 + rd.Next() % data.Count].path);
     //    	obj.transform.parent = room.transform;
     //    	obj.transform.localPosition = new Vector3(rd.Next() % 13 - 6.5f, rd.Next() % 20 - 10f, 0);
    	// }

    	// foreach(PrefabData pd in data)			
     //    {
     //    	GameObject obj = CreatePrefab(pd.path);
     //    	obj.transform.parent = room.transform;
     //    }

        // PrefabUtility.SaveAsPrefabAsset(room, "Assets/Editor/parent.prefab");
        // DestroyImmediate(room);


    	for (int i = 1; i < 10; ++i)
    	{
	    	GameObject obj1 = new GameObject();
	    	obj1.name = "room"+i;
    		PrefabData pd = data[rd.Next() % data.Count];
	    	CreateRectangle(obj1.transform, pd.scale, Vector3.zero, 2, 5, pd.path, new Vector2(1.6f*pd.w, 1.6f*pd.h));
    	}
    }
    // 矩形
    public static void CreateRectangle(Transform parent, float s, Vector3 pos, int w, int h, string path, Vector2 size, bool isFill = false)
    {
    	Debug.Log(path);
    	Vector2 beginPos = new Vector2(pos.x-0.5f*(w-1)*size.x, pos.y+0.5f*(h-1)*size.y);
    	for(int i = 0; i < w; ++i)
    	{
    		for(int j = 0; j < h; ++j)
    		{
	        	GameObject obj = CreatePrefab(path);
	        	obj.transform.parent = parent;
	        	obj.transform.localPosition = new Vector3(beginPos.x+size.x*(i-1), beginPos.y-size.y*(j-1), 0);
	        	obj.transform.localScale = new Vector3(s, s, 1);
                SpriteRenderer spr = obj.transform.GetComponent<SpriteRenderer>();
                if (spr)
                    spr.sortingOrder = spr.sortingOrder + j;
    		}
    	}
    }

    // 正三角形
    public static void CreateTriangle(Transform parent, float s, Vector3 pos, int len, string path, Vector2 size, bool isFill = false)
    {
        Debug.Log(path);
        Vector2 beginPos = new Vector2(pos.x, pos.y+0.5f*(len-1)*size.y);
        for(int i = 0; i < len; ++i)
        {
            for(int j = 0; j <= i; ++j)
            {
                GameObject obj = CreatePrefab(path);
                obj.transform.parent = parent;
                obj.transform.localPosition = new Vector3(beginPos.x-0.5f*(i-1)*size.x+size.x*(j-1), beginPos.y-size.y*(i-1), 0);
                obj.transform.localScale = new Vector3(s, s, 1);
                SpriteRenderer spr = obj.transform.GetComponent<SpriteRenderer>();
                if (spr)
                    spr.sortingOrder = spr.sortingOrder + j;
            }
        }
    }

    // 圆形
    public static void CreateCircle(Transform parent, float s, Vector3 pos, int r, int num, string path, Vector2 size, bool isFill = false)
    {
        Debug.Log(path);
        float a = 360f / num;
        a = (a * (Mathf.PI)) / 180f;
        float py = 0f;
        if (num % 2 == 1)
            py = (90 * (Mathf.PI)) / 180f;
        for(int i = 0; i < num; ++i)
        {
            GameObject obj = CreatePrefab(path);
            obj.transform.parent = parent;
            obj.transform.localPosition = new Vector3(pos.x+r * Mathf.Cos(a * i + py), pos.y+r * Mathf.Sin(a * i + py), 0);
            obj.transform.localScale = new Vector3(s, s, 1);
            // SpriteRenderer spr = obj.transform.GetComponent<SpriteRenderer>();
            // spr.sortingOrder = spr.sortingOrder + j;
        }
    }
    






    // -----------------------------------
    // 地图相关
    // -----------------------------------
    public static List<MapPrefabData> getMapPrefabDataList()
    {
        List<MapPrefabData> data = new List<MapPrefabData>();
        MapPrefabData pd;

        string fileName = "Assets/Editor/Room/editor_map_config.json";
        MapConfig prefabConfig = JsonUtility.FromJson<MapConfig>(File.ReadAllText(fileName));
        data = prefabConfig.map_data;

        Debug.Log("长度=" + prefabConfig.map_data.Count);
        foreach (MapPrefabData it in prefabConfig.map_data)
        {
            it.imageTexture = AssetDatabase.LoadAssetAtPath(EditorFileUtility.GetRelativeAssetPath(it.image), typeof(Texture)) as Texture;
        }
        return data;
    }


    [MenuItem("Tools/Room/随机地图 &e")]
    static void RunRandomMap()
    {
        RunRandomCD(10, 10);
    }
    static void RunRandomCD(int w, int h)
    {
        List<MapPrefabData> data = getMapPrefabDataList();
        float x = 0f;
        float y = 0f;

        System.Random rd = new System.Random();

        GameObject parent = new GameObject();
        parent.name = "Map";

        for (int i = 1; i < w; ++i)
        {
            x = 0f;
            MapPrefabData pd = data[rd.Next() % data.Count];
            for (int j = 1; j < h; ++j)
            {
                GameObject obj = new GameObject();
                obj.transform.parent = parent.transform;
                SpriteRenderer spr = obj.AddComponent<SpriteRenderer>();

                spr.sprite = AssetDatabase.LoadAssetAtPath(EditorFileUtility.GetRelativeAssetPath(pd.image), typeof(Sprite)) as Sprite;

                obj.transform.localPosition = new Vector3(x, y, 0);
                x += pd.w;
            }
            y += pd.h;
        }
    }
}
