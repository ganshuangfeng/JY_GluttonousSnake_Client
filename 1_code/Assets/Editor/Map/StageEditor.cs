using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

using LitJson;		//引用LitJson
using System;
using System.Reflection;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System;

[CustomEditor(typeof(StageInfo))]
public class StageEditor : Editor
{
    private StageInfo stageInfo;
    private GameObject gameObject;
    private ReorderableList _playerItemArray;
    private string configName = "";
    private void OnEnable()
    {
        stageInfo = (StageInfo)target;
        gameObject = stageInfo.gameObject;
    }

    public override void OnInspectorGUI()
    {
        //show default variables of manager
        DrawDefaultInspector();

        EditorGUILayout.Space();
        EditorGUILayout.BeginHorizontal();

        //draw fish text label
        GUILayout.Label("Enter Config Name: ", GUILayout.Height(15));
        //display text field for creating a fish with that name
        configName = EditorGUILayout.TextField(configName, GUILayout.Height(15));

        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.Space();
        if (GUILayout.Button("Exprot Lua Config", GUILayout.Height(40)))
        {
            ExportLua();
        }
    }

    Dictionary<string, Dictionary<string, object>> GetDataInfo()
    {
        var reader = new TxtWriteAndRead();
        var luaUtility = new LuaUtility();
        var path = Application.dataPath + @"/Game/CommonPrefab/Lua/component_base_config.lua";
        var luaCfg = reader.ReadTxtFifth(path);
        Debug.Log("unity_component_config：" + luaCfg);
        var unity_component_config = LuaUtility.FromLua<Dictionary<string, List< Dictionary<string,object>>>>(luaCfg);
        Debug.Log(unity_component_config);
        foreach (var item in unity_component_config)
        {
            Debug.Log("????????????????????????????????????");
            Debug.Log(item.Key);
            Debug.Log(item.Value);
            // var o = item.Value as Dictionary<string, object>;
            foreach (var kv in item.Value)
            {
                Debug.Log(kv);
                Debug.Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                var v = kv;
                Debug.Log(v);
                foreach (var kv1 in v)
                {
                    Debug.Log(kv1.Key);
                    Debug.Log(kv1.Value);
                    if (kv1.Key == "data")
                    {
                        // var a = kv1.Value as Dictionary<string,string>;
                        Debug.Log("<color=red>???????????????</color>");

                        var obj = kv1.Value;
                        var type = obj.GetType();
                        var v1 = kv1.Value as Array;
                        Debug.Log(v1);
                        Debug.Log(type.IsClass);
                        foreach (var p in type.GetMembers())
                        {
                            Debug.Log(p);
                        }
                        foreach (var p in type.GetProperties())
                            Debug.Log("{0}:{1}" + p.Name + p.GetValue(obj, null));
                        foreach (var p in type.GetFields())
                            Debug.Log("{0}:{1}"+ p.Name+ p.GetValue(obj));
                    }
                }
                // Debug.Log(v.key);
                // Debug.Log(v.comType);
                // Debug.Log(v.name);
                // Debug.Log(v.data_id);
                Debug.Log("xxxxxxxxxxxxxxxxxxxxxxxxxx");
            }
        }

        // path = Application.dataPath + @"/Game/CommonPrefab/Lua/component_base_config.lua";
        // luaCfg = reader.ReadTxtFifth(path);
        // Debug.Log("component_base_config" + luaCfg);
        // var component_base_config = LuaUtility.FromLua<Dictionary<string, Dictionary<string, object>>>(luaCfg);
        // Debug.Log(component_base_config);
        // foreach (var item in component_base_config)
        // {
        //     Debug.Log(item.Key);
        //     Debug.Log(item.Value);
        //     foreach (var kv in item.Value)
        //     {
        //         Debug.Log(kv.Key);
        //         Debug.Log(kv.Value);
        //         Debug.Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        //         // Debug.Log(kv.Value.key);
        //         // Debug.Log(kv.Value.comType);
        //         // Debug.Log(kv.Value.name);
        //         // Debug.Log(kv.Value.data_id);
        //         // Debug.Log("xxxxxxxxxxxxxxxxxxxxxxxxxx");
        //     }
        // }



        Dictionary<string, Dictionary<string, object>> dataInfo = new Dictionary<string, Dictionary<string, object>>();
        var rooms = gameObject.GetComponentsInChildren<DataInfo>();
        for (int i = 0; i < rooms.Length; i++)
        {            
            Dictionary<string, object> roomInfo = new Dictionary<string, object>(); 
            roomInfo.Add("prefab", rooms[i].gameObject.name);
            for (int j = 0; j < rooms[i].infoList.Count; j++)
            {
                var info = rooms[i].infoList[j];
                roomInfo.Add(info.key,info.value);
            }
            var comDataInfo = rooms[i].GetComponentsInChildren<DataInfo>();
            //波次
            for (int j = 0; j < comDataInfo.Length; j++)
            {
                for (int k = 0; k < comDataInfo[j].infoList.Count; k++)
                {
                    
                }

            }
            //nextRom


            dataInfo.Add((i + 1).ToString(), roomInfo); 
        }
        return dataInfo;
    }

    void ExportLua()
    {
        Debug.Log(stageInfo.gameObject.name);
        var dataInfo = GetDataInfo();
        var lua = TileEditor.HELua.Encode(dataInfo);
        Debug.Log(lua);
        return;

        string cfg = Application.dataPath + @"/SWS/LuaFish.lua";
        StringBuilder builder = new StringBuilder();
        builder.Append("return ");
        builder.Append(lua);
        // builder.Append("'");

        //找到当前路径
        FileInfo file = new FileInfo(cfg);
        //判断有没有文件，有则打开文件，，没有创建后打开文件
        StreamWriter sw = file.CreateText();
        sw.Write(builder.ToString());		//写入数据
        sw.Close();		//关闭流
        sw.Dispose();		//销毁流
        AssetDatabase.Refresh();
    }
}
