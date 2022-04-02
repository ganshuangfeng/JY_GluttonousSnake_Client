using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public class RandomRoomWindow : EditorWindow
{
    public static bool IsInt(string value)
    {
        return Regex.IsMatch(value, @"^[+-]?\d*$");
    }

    public static List<PrefabData> prefabList;

    int index = 0;
    string wText = "1";
    string hText = "1";

    string stepwText = "0";
    string stephText = "0";
    
    public int toolbarInt = 0;
    public string[] toolbarStrings = new string[] {"矩形", "正三角形", "圆形"};
    void OnGUI()
    {
        int n = 0;
        while(n < prefabList.Count)
        {
            GUILayout.BeginHorizontal();
            for (int i = 0; i < 4; ++i)
            {
                if (n < prefabList.Count)
                {
                    if(GUILayout.Toggle(n == index, prefabList[n].imageTexture, new GUILayoutOption[]{GUILayout.Width(40), GUILayout.Height(40)}))
                        index = n;
                    n++;
                }
                else
                    break;
            }
            GUILayout.EndHorizontal();
        }

        toolbarInt = GUILayout.Toolbar(toolbarInt, toolbarStrings);

        if (toolbarInt == 0)
        {
            GUILayout.BeginHorizontal();
                GUILayout.Label("宽");
                wText = GUILayout.TextField(wText);
                GUILayout.Label("高");
                hText = GUILayout.TextField(hText);
            GUILayout.EndHorizontal();
        }
        else if (toolbarInt == 1)
        {
            GUILayout.BeginHorizontal();
                GUILayout.Label("边长");
                wText = GUILayout.TextField(wText);
            GUILayout.EndHorizontal();
        }
        else if (toolbarInt == 2)
        {
            GUILayout.BeginHorizontal();
                GUILayout.Label("半径");
                wText = GUILayout.TextField(wText);
                GUILayout.Label("物件个数");
                hText = GUILayout.TextField(hText);
            GUILayout.EndHorizontal();
        }

        if (toolbarInt != 2)
        {
            GUILayout.BeginHorizontal();
                GUILayout.Label("水平间距");
                stepwText = GUILayout.TextField(stepwText);
                GUILayout.Label("垂直间距");
                stephText = GUILayout.TextField(stephText);
            GUILayout.EndHorizontal();
        }

        if (GUILayout.Button("确定", GUILayout.Height(30)))
        {

            float sw = float.Parse(stepwText);
            float sh = float.Parse(stephText);
            if (toolbarInt == 0)
            {            
                if (IsInt(wText) && IsInt(hText))
                {
                    int w = int.Parse (wText);
                    int h = int.Parse (hText);
                    if (w < 1 || h < 1)
                    {
                        UnityEditor.EditorUtility.DisplayDialog("错误","不能配小于等于0的数字!","确认");
                        return;
                    }
                    GameObject obj1 = new GameObject();
                    obj1.name = "room";
                    PrefabData pd = prefabList[index];
                    RandomRoom.CreateRectangle(obj1.transform, pd.scale, Vector3.zero, w, h, pd.path, new Vector2(1.6f*pd.w + sw, 1.6f*pd.h + sh));
                }
            }
            else if (toolbarInt == 1)
            {
                int w = int.Parse (wText);
                if (w < 1)
                {
                    UnityEditor.EditorUtility.DisplayDialog("错误","不能配小于等于0的数字!","确认");
                    return;
                }
                GameObject obj1 = new GameObject();
                obj1.name = "room";
                PrefabData pd = prefabList[index];
                RandomRoom.CreateTriangle(obj1.transform, pd.scale, Vector3.zero, w, pd.path, new Vector2(1.6f*pd.w + sw, 1.6f*pd.h + sh));
            }
            else if (toolbarInt == 2)
            {
                int w = int.Parse (wText);
                int h = int.Parse (hText);
                if (w < 1 || h < 1)
                {
                    UnityEditor.EditorUtility.DisplayDialog("错误","不能配小于等于0的数字!","确认");
                    return;
                }
                GameObject obj1 = new GameObject();
                obj1.name = "room";
                PrefabData pd = prefabList[index];
                RandomRoom.CreateCircle(obj1.transform, pd.scale, Vector3.zero, w, h, pd.path, new Vector2(1.6f*pd.w, 1.6f*pd.h));
            }
        }
    }


    [MenuItem("Tools/Room/组件窗口 &r")]
    public static void CreateGame()
    {
        prefabList = RandomRoom.getPrefabPathList();

        //创建窗口
        Rect wr = new Rect(0, 0, 400, 400);
        RandomRoomWindow window = (RandomRoomWindow)EditorWindow.GetWindow(typeof(RandomRoomWindow), false, "房间组件", true);
        window.Show();
    }
}
