using UnityEditor;
using UnityEngine;

public class ProjectMenu : EditorWindow
{
    const string NEWGAMEMENU = "Assets/新建游戏";
    const string SETCURRENTMENU = "Assets/设置为当前项目";

    /// <summary>
    /// 项目名称
    /// </summary>
    private string gameName = "";
    //绘制窗口时调用
    void OnGUI()
    {
        gameName = GUILayout.TextField(gameName, GUILayout.Height(50));
        if (GUILayout.Button("确定", GUILayout.Height(30)))
        {
            if (gameName != "")
            {
                ProjectEditUtility.CreateGameTemplateForlders(gameName);
                this.Close();
            }
            else
            {
                Debug.Log("<color=red>项目名不能为空！！！</color>");
            }
        }
    }
    [MenuItem(NEWGAMEMENU, true, 60)]
    public static bool CreateGameValidate()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
            return AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]) == "Assets";

        return false;
    }
    // 新建游戏
    [MenuItem(NEWGAMEMENU, false, 60)]
    public static void CreateGame()
    {
        //创建窗口
        Rect wr = new Rect(0, 0, 400, 200);
        ProjectMenu window = (ProjectMenu)EditorWindow.GetWindowWithRect(typeof(ProjectMenu), wr, true, "新建游戏名");
        window.Show();
    }

    // 设置为当前项目目录
    [MenuItem(SETCURRENTMENU, false, 61)]
    public static void SetCurrentProject()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
            AppDefine.CurrentProjectPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]);
    }

    [MenuItem(SETCURRENTMENU, true, 61)]
    public static bool SelectProjectFounderValidate()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
        {
            string path = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);
            return path == "Assets/Hall" || (path.Split('/').Length == 3 && path.Contains("Assets/Game"));
        }

        return false;
    }
    
    const string kSimulateAssetBundlesMenu = "Dev/模拟AssetBundles";

    [MenuItem(kSimulateAssetBundlesMenu, false, 1)]
    public static void ToggleSimulateAssetBundle()
    {
        AppDefine.IsLuaBundleMode = !AppDefine.IsLuaBundleMode;
    }

    [MenuItem(kSimulateAssetBundlesMenu, true, 1)]
    public static bool ToggleSimulateAssetBundleValidate()
    {
        Menu.SetChecked(kSimulateAssetBundlesMenu, AppDefine.IsLuaBundleMode);
        return true;
    }

    const string kSimulateDebug = "Dev/Debug开关";

    [MenuItem(kSimulateDebug, false, 1)]
    public static void ToggleSimulateDebug()
    {
        AppDefine.IsDebug = !AppDefine.IsDebug;
    }

    [MenuItem(kSimulateDebug, true, 1)]
    public static bool ToggleSimulateDebugValidate()
    {
        Menu.SetChecked(kSimulateDebug, AppDefine.IsDebug);
        return true;
    }

    const string kSimulateForceOpenYK = "Dev/强制打开游客登录";

    [MenuItem(kSimulateForceOpenYK, false, 1)]
    public static void ToggleSimulateForceOpenYK()
    {
        AppDefine.IsForceOpenYK = !AppDefine.IsForceOpenYK;
    }

    [MenuItem(kSimulateForceOpenYK, true, 1)]
    public static bool ToggleSimulateForceOpenYKValidate()
    {
        Menu.SetChecked(kSimulateForceOpenYK, AppDefine.IsForceOpenYK);
        return true;
    }


    const string kSimulateOffLine = "Dev/是否离线模式";

    [MenuItem(kSimulateOffLine, false, 1)]
    public static void ToggleSimulateOffLine()
    {
        AppDefine.IsOffLine = !AppDefine.IsOffLine;
    }

    [MenuItem(kSimulateOffLine, true, 1)]
    public static bool ToggleSimulateOffLineValidate()
    {
        Menu.SetChecked(kSimulateOffLine, AppDefine.IsOffLine);
        return true;
    }

    const string kSimulateStageEditor = "Dev/关卡编辑模式";

    [MenuItem(kSimulateStageEditor, false, 1)]
    public static void ToggleSimulateStageEditor()
    {
        AppDefine.IsStageEditor = !AppDefine.IsStageEditor;
    }

    [MenuItem(kSimulateStageEditor, true, 1)]
    public static bool ToggleSimulateStageEditorValidate()
    {
        Menu.SetChecked(kSimulateStageEditor, AppDefine.IsStageEditor);
        return true;
    }


    // 渠道选项卡
    const string kLocal1Menu = "Dev/渠道/Local1";
    [MenuItem(kLocal1Menu, false, 101)]
    public static void ToggleLocal1()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local1");
        AppDefine.CurQuDao = "Local1";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal1Menu, true, 101)]
    public static bool ToggleLocal1Validate()
    {
        if ("Local1" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal1Menu, true);
        else
            Menu.SetChecked(kLocal1Menu, false);
        return true;
    }

    const string kLocal2Menu = "Dev/渠道/Local2";
    [MenuItem(kLocal2Menu, false, 102)]
    public static void ToggleLocal2()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local2");
        AppDefine.CurQuDao = "Local2";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal2Menu, true, 102)]
    public static bool ToggleLocal2Validate()
    {
        if ("Local2" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal2Menu, true);
        else
            Menu.SetChecked(kLocal2Menu, false);
        return true;
    }

    const string kLocal3Menu = "Dev/渠道/Local3";
    [MenuItem(kLocal3Menu, false, 103)]
    public static void ToggleLocal3()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local3");
        AppDefine.CurQuDao = "Local3";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal3Menu, true, 103)]
    public static bool ToggleLocal3Validate()
    {
        if ("Local3" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal3Menu, true);
        else
            Menu.SetChecked(kLocal3Menu, false);
        return true;
    }

    const string kQudao1Menu = "Dev/渠道/自营渠道";
    [MenuItem(kQudao1Menu, false, 104)]
    public static void ToggleQuDao1()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("自营渠道");
        AppDefine.CurQuDao = "main";  // 渠道标识
        AppDefine.CurResPath = AppDefine.CurQuDao;  // 资源路径
    }
    [MenuItem(kQudao1Menu, true, 104)]
    public static bool ToggleQuDao1Validate()
    {
        if ("main" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao1Menu, true);
        else
            Menu.SetChecked(kQudao1Menu, false);
        return true;
    }
}
