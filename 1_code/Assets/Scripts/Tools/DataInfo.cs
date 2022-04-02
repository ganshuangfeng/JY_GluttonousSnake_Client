using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using LitJson;		//引用LitJson

public class DataInfo : MonoBehaviour
{
    [SerializeField]
    public List<Info> infoList;

    [Serializable]
    public struct Info
    {
        [SerializeField]
        public string key;
        [SerializeField]
        public string value;
    }

    public Dictionary<string,string> GetDataInfo (){
        Dictionary<string,string> dic = new Dictionary<string, string>();
        for (int i = 0; i < infoList.Count; i++)
        {
            dic[infoList[i].key] = infoList[i].value;
        }

        JsonData jsonData = new JsonData();

        foreach (var item in dic)
        {
            jsonData[item.Key] = item.Value;
        }

        return dic;
    }

    public string GetDataInfoJson (){
        Dictionary<string,string> dic = GetDataInfo ();
        JsonData jsonData = new JsonData();

        foreach (var item in dic)
        {
            jsonData[item.Key] = item.Value;
        }
        string jsonStr = jsonData.ToJson();

        return jsonStr;
    }

}
