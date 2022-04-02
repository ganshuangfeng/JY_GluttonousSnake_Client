using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;


public static class TXLayerSettings
{

    [MenuItem("Tools/TX/打印")]
    static void ShowTXLayer()
    {
        if (Selection.activeGameObject)
        {
            Debug.Log("activeGameObject=" + Selection.activeGameObject.name);
            GameObject obj = Selection.activeGameObject;
            Renderer[] list = obj.GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < list.Length; ++i)
            {
                Debug.Log("name:" + list[i].gameObject.name + "  " + list[i].sortingOrder);
            }
        }
    }
    [MenuItem("Tools/TX/加1")]
    static void AddTXLayer()
    {
        if (Selection.activeGameObject)
        {
            Debug.Log("activeGameObject=" + Selection.activeGameObject.name);
            GameObject obj = Selection.activeGameObject;
            Renderer[] list = obj.GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < list.Length; ++i)
            {
                list[i].sortingOrder = list[i].sortingOrder + 1;
            }
        }
    }
    [MenuItem("Tools/TX/减1")]
    static void DecTXLayer()
    {
        if (Selection.activeGameObject)
        {
            Debug.Log("activeGameObject=" + Selection.activeGameObject.name);
            GameObject obj = Selection.activeGameObject;
            Renderer[] list = obj.GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < list.Length; ++i)
            {
                list[i].sortingOrder = list[i].sortingOrder - 1;
            }
        }
    }


    //选中资源列表
    static private List<string> selectedAssetPath = new List<string>();    
    // 层级调整
    [MenuItem("Assets/批量修改层级/英雄和怪物上层", false, 62)]
    static void PLTXLayerTop1()
    {
        int referSortingOrder = 22000;
        PLTXLayer(referSortingOrder);
    }
    [MenuItem("Assets/批量修改层级/英雄和怪物之间", false, 62)]
    static void PLTXLayerTop2()
    {
        int referSortingOrder = 10500;
        PLTXLayer(referSortingOrder);
    }
    [MenuItem("Assets/批量修改层级/英雄的下层", false, 62)]
    static void PLTXLayerTop3()
    {
        int referSortingOrder = 500;
        PLTXLayer(referSortingOrder);
    }

    [MenuItem("Assets/批量修改层级/自动(按照100分为英雄上下) &c", false, 62)]
    static void PLTXLayerTop()
    {
        PLTXLayerTSNew();
    }

    [MenuItem("Assets/批量修改层级/根据标签修改层级", false, 62)]
    static void PLTXLayerTop5()
    {
        PLTXLayer22();
    }



    static void PLTXLayer(int referSortingOrder)
    {
        bool isUp = true;

        selectedAssetPath.Clear();
        foreach(var obj in Selection.objects)
        {
            string path = AssetDatabase.GetAssetPath(obj);
            //如果是文件夹
            if (Directory.Exists(path))
            {
                // Debug.Log("AAA = " + path);
                // string[] folder = new string[] { path };
                // //将文件夹下所有资源作为选择资源
                // string[] paths = AssetDatabase.FindAssets(null, folder);
                // foreach(var p in paths)
                // {
                //     Debug.Log("BBB = " + p);
                //     if ( !Directory.Exists(p) )
                //     {
                //         selectedAssetPath.Add(p);
                //     }                        
                // }
            }
            //如果是文件资源
            else
            {
                selectedAssetPath.Add(path);
            }
        }

        foreach (var path in selectedAssetPath)
        {
            if (path.EndsWith(".prefab")) 
            { 
                Debug.Log("预制体路径" + path); 
                GameObject obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject; 
                Debug.Log("obj的名字" + obj.name);

                UnityEngine.Renderer[] ps = obj.gameObject.GetComponentsInChildren<UnityEngine.Renderer>(true);
                int min = 9999999;
                int max = -9999999;
                foreach(UnityEngine.Renderer lab in ps)
                {
                    if (lab.sharedMaterial != null) // 存在材质表示在使用
                    {
                        if (max < lab.sortingOrder)
                            max = lab.sortingOrder;
                        if (min > lab.sortingOrder)
                            min = lab.sortingOrder;
                    }
                }

                if (isUp)
                    max = referSortingOrder - min + 1;
                else
                    max = referSortingOrder - max - 1;
                

                foreach(UnityEngine.Renderer lab in ps)
                {
                    lab.sortingOrder = lab.sortingOrder + max;
                }

                //通知你的编辑器 obj 改变了 
                EditorUtility.SetDirty(obj); 
                //保存修改 
                AssetDatabase.SaveAssets(); 
                AssetDatabase.Refresh(); 
            } 
        }
    }

    static void PLTXLayerTSNew()
    {
        selectedAssetPath.Clear();
        foreach(var obj in Selection.objects)
        {
            string path = AssetDatabase.GetAssetPath(obj);
            //如果是文件夹
            if (!Directory.Exists(path))
            {
                selectedAssetPath.Add(path);
            }
        }

        foreach (var path in selectedAssetPath)
        {
            if (path.EndsWith(".prefab")) 
            { 
                List<UnityEngine.Renderer> xia = new List<UnityEngine.Renderer>();
                List<UnityEngine.Renderer> shang = new List<UnityEngine.Renderer>();

                GameObject obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject; 

                UnityEngine.Renderer[] ps = obj.gameObject.GetComponentsInChildren<UnityEngine.Renderer>(true);
                int xiamin = 9999999;
                int xiamax = -9999999;

                int shangmin = 9999999;
                int shangmax = -9999999;
                foreach(UnityEngine.Renderer lab in ps)
                {
                    if (lab.sharedMaterial != null) // 存在材质表示在使用
                    {
                        if (lab.sortingOrder < 100)
                        {
                            xia.Add(lab);
                            if (xiamax < lab.sortingOrder)
                                xiamax = lab.sortingOrder;
                            if (xiamin > lab.sortingOrder)
                                xiamin = lab.sortingOrder;
                        }
                        else
                        {
                            shang.Add(lab);
                            if (shangmax < lab.sortingOrder)
                                shangmax = lab.sortingOrder;
                            if (shangmin > lab.sortingOrder)
                                shangmin = lab.sortingOrder;                        
                        }
                    }
                }

                xiamax = 500 - xiamin + 1;
                shangmax = 22000 - shangmin + 1;
                
                for (var i = 0; i < xia.Count; i++)  
                {
                    xia[i].sortingOrder = xia[i].sortingOrder + xiamax;
                }
                for (var i = 0; i < shang.Count; i++)  
                {
                    shang[i].sortingOrder = shang[i].sortingOrder + shangmax;
                }

                //通知你的编辑器 obj 改变了 
                EditorUtility.SetDirty(obj); 
                //保存修改 
                AssetDatabase.SaveAssets(); 
                AssetDatabase.Refresh(); 
            } 
        }
    }

    static void PLTXLayer22()
    {
        bool isUp = true;

        selectedAssetPath.Clear();
        foreach(var obj in Selection.objects)
        {
            string path = AssetDatabase.GetAssetPath(obj);
            //如果是文件夹
            if (Directory.Exists(path))
            {
                // Debug.Log("AAA = " + path);
                // string[] folder = new string[] { path };
                // //将文件夹下所有资源作为选择资源
                // string[] paths = AssetDatabase.FindAssets(null, folder);
                // foreach(var p in paths)
                // {
                //     Debug.Log("BBB = " + p);
                //     if ( !Directory.Exists(p) )
                //     {
                //         selectedAssetPath.Add(p);
                //     }                        
                // }
            }
            //如果是文件资源
            else
            {
                selectedAssetPath.Add(path);
            }
        }

        foreach (var path in selectedAssetPath)
        {
            if (path.EndsWith(".prefab")) 
            { 
                Debug.Log("预制体路径" + path); 
                GameObject obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject; 
                Transform[] obj_child = obj.gameObject.GetComponentsInChildren<Transform>();
                Debug.Log("obj的名字" + obj.name);
                int min = 9999999;
                int max = -9999999;

                for (int i = 0; i < obj_child.Length; ++i){
                    int layer_int = min;
                    UnityEngine.Renderer[] ps = obj_child[i].gameObject.GetComponentsInChildren<UnityEngine.Renderer>(true);

                    if(obj_child[i].gameObject.tag == "dimian"){
                        layer_int = -200;
                    }
                    else if(obj_child[i].gameObject.tag == "dimian_dise"){
                        layer_int = -199;
                    }
                    else if(obj_child[i].gameObject.tag == "dimian_huawen"){
                        layer_int = -100;
                    }
                    else if(obj_child[i].gameObject.tag == "dimian_zhuangshi"){
                        layer_int = -50;
                    }
                    else if(obj_child[i].gameObject.tag == "dimian_zhuangshi_up"){
                        layer_int = -49;
                    }
                    else if(obj_child[i].gameObject.tag == "qiangzhu"){
                        layer_int = 50;
                    }
                    else if(obj_child[i].gameObject.tag == "qiangtou"){
                        layer_int = 20100;
                    }   
                    else if(obj_child[i].gameObject.tag == "qiangtoucao"){
                        layer_int = 20200;
                    }
                    else if(obj_child[i].gameObject.tag == "qiangtouhua"){
                        layer_int = 21100;
                    }
                    foreach(UnityEngine.Renderer lab in ps)
                    {
                        if (layer_int != min){
                            lab.sortingOrder = layer_int;
                        }
                        
                    }
                }
                

                //通知你的编辑器 obj 改变了 
                EditorUtility.SetDirty(obj); 
                //保存修改 
                AssetDatabase.SaveAssets(); 
                AssetDatabase.Refresh(); 
            } 
        }
    }
}
