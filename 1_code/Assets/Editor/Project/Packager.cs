using UnityEditor;
using UnityEngine;
using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using LuaFramework;
using UnityEditor.Callbacks;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.Text.RegularExpressions;
using System.Runtime.CompilerServices;
using LuaInterface;

public class Packager
{
    public static string platform = string.Empty;
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();
    static List<AssetBundleBuild> maps = new List<AssetBundleBuild>();
	static Dictionary<string, string> AssetToBundleMap = new Dictionary<string, string>();
    ///-----------------------------------------------------------
    static string[] exts = { ".txt", ".xml", ".lua", ".assetbundle", ".json" };
    static bool CanCopy(string ext)
    {   //能不能复制
        foreach (string e in exts)
        {
            if (ext.Equals(e)) return true; 
        }
        return false;
    }

    /// <summary>
    /// 载入素材
    /// </summary>
    static UnityEngine.Object LoadAsset(string file)
    {
        if (file.EndsWith(".lua")) file += ".txt";
        return AssetDatabase.LoadMainAssetAtPath("Assets/LuaFramework/Examples/Builds/" + file);
    }

	static void AddBuildMap(string bundleName, string pattern, string path, bool isLua = false)
    {
        string[] files = Directory.GetFiles(path, pattern);
        if (files.Length == 0) return;

		string dictKey, dictValue;
        for (int i = 0; i < files.Length; i++)
        {
            files[i] = files[i].Replace('\\', '/');

			//lua做了特殊处理,忽视
			if(isLua) continue;

			dictKey = Path.GetFileName (files[i]);
			if(AssetToBundleMap.TryGetValue(dictKey, out dictValue)) {
				if(string.Compare(dictValue, bundleName) != 0)
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] AddBuildMap conflict: {0} : {1} - {2}", dictKey, dictValue, bundleName));
				continue;
			}
			AssetToBundleMap.Add(dictKey, bundleName);
        }

        AssetBundleBuild build = new AssetBundleBuild();
        build.assetBundleName = bundleName;
        build.assetNames = files;
        maps.Add(build);
    }

    /// <summary>
    /// 数据目录
    /// </summary>
    static string AppDataPath
    {
        get { return Application.dataPath.ToLower(); }
    }

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static void Recursive(string path)
    {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names)
        {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        foreach (string dir in dirs)
        {
            paths.Add(dir.Replace('\\', '/'));
            Recursive(dir);
        }
    }

    /// <summary>
    /// 编码lua文件
    /// </summary>
    /// <param name="srcFile"></param>
    /// <param name="outFile"></param>
    public static void EncodeLuaFile(string srcFile, string outFile)
    {
        if (!srcFile.ToLower().EndsWith(".lua"))
        {
            File.Copy(srcFile, outFile, true);
            return;
        }
        bool isWin = true;
        string luaexe = string.Empty;
        string args = string.Empty;
        string exedir = string.Empty;
        string currDir = Directory.GetCurrentDirectory();

		if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            isWin = true;
            luaexe = "luajit.exe";
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit/";
        }
        else if (Application.platform == RuntimePlatform.OSXEditor)
        {
            isWin = false;
            luaexe = "./luajit";
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit_mac/";
        }
		args = "-b " + srcFile + " " + outFile;
		
        Directory.SetCurrentDirectory(exedir);
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = luaexe;
        info.Arguments = args;
        info.WindowStyle = ProcessWindowStyle.Hidden;
        info.UseShellExecute = isWin;
        info.ErrorDialog = true;
        Util.Log(info.FileName + " " + info.Arguments);

        Process pro = Process.Start(info);
        pro.WaitForExit();
        Directory.SetCurrentDirectory(currDir);
    }

	private static string exportPath = string.Empty;
	private static string platformType = string.Empty;
	private static bool debugMode = false;
	private static string overrideList = string.Empty;
	private static string overrideData = string.Empty;
	private static string overrideGame = string.Empty;
	private static string overrideServer = string.Empty;
	private static string overrideVersion = string.Empty;
	private static string marketChannel = string.Empty;
	private static string marketPlatform = string.Empty;
	private static string sdkChannel = string.Empty;
	private static string productName = string.Empty;

	private static void ParseCommandLine() {
		Dictionary<string, Action<string>> cmdActions = new Dictionary<string, Action<string>> () {
			{
				"-exportPath", delegate(string arg) { exportPath = arg; }
			},
			{
				"-platformType", delegate(string arg) { platformType = arg; }
			},
			{
				"-debugMode", delegate(string arg) {
					if(string.Compare(arg, "true", true) == 0)
						debugMode = true;
					else
						debugMode = false;
					UnityEngine.Debug.Log("debugMode: " + arg);
				}
			},
			{
				"-overrideList", delegate(string arg) { overrideList = arg; }
			},
			{
				"-overrideData", delegate(string arg) { overrideData = arg; }
			},
			{
				"-overrideGame", delegate(string arg) { overrideGame = arg; }
			},
			{
				"-overrideServer", delegate(string arg) { overrideServer = arg; }
			},
			{
				"-overrideVersion", delegate(string arg) { overrideVersion = arg; }
			},
			{
				"-marketChannel", delegate(string arg) { marketChannel = arg; }
			},
			{
				"-marketPlatform", delegate(string arg) { marketPlatform = arg; }
			},
			{
				"-sdkChannel", delegate(string arg) {
					for(int idx = 0; idx < QUDAO_KEY.Length; ++idx) {
						if(string.Compare(arg, QUDAO_KEY[idx]) == 0) {
							sdkChannel = QUDAO_LIST[idx];
							UnityEngine.Debug.Log("Set SDKChannel:" + sdkChannel);
							break;
						}
					}
				}
			},
			{
				"-productName", delegate(string arg) { productName = arg; }
			}
		};
		Action<string> actionCache;
		string[] cmdArgs = Environment.GetCommandLineArgs ();
		for (int idx = 0; idx < cmdArgs.Length; ++idx) {
			if (cmdActions.ContainsKey (cmdArgs [idx])) {
				actionCache = cmdActions [cmdArgs [idx]];
				if (idx >= (cmdArgs.Length - 1) || cmdArgs [idx + 1].StartsWith ("-")) {
					UnityEngine.Debug.Log ("Single Param:" + cmdArgs [idx]);
					actionCache (string.Empty);
				} else {
					UnityEngine.Debug.Log ("Mutil Param:" + cmdArgs [idx] + "," + cmdArgs[idx + 1]);
					actionCache (cmdArgs [idx + 1]);
				}
			}
		}
	}

	private static bool CheckValidPlatform(string platform, out BuildTarget buildTarget) {
		buildTarget = BuildTarget.NoTarget;

		if(string.IsNullOrEmpty(platform))
			return false;
		
		if (platform == "Android") {
			buildTarget = BuildTarget.Android;
			return true;
		}
		if (platform == "IOS") {
			buildTarget = BuildTarget.iOS;
			return true;
		}
		if(platform == "Windows")
        {
			buildTarget = BuildTarget.StandaloneWindows64;
			return true;
        }

		return false;
	}
	public static void Export() {
		ParseCommandLine ();

		BuildTarget buildTarget;
		if (!CheckValidPlatform (platformType, out buildTarget)) {
			UnityEngine.Debug.LogError ("[Export] exception: invalid platformType: " + platformType);
			return;
		}
		if (string.IsNullOrEmpty (exportPath)) {
			UnityEngine.Debug.LogError ("[Export] exception: invalid exportPath: " + exportPath);
			return;
		}

		if (!string.IsNullOrEmpty (productName))
			PlayerSettings.productName = productName;

		if (!string.IsNullOrEmpty (sdkChannel))
			AppDefine.CurQuDao = sdkChannel;

		//build bundle
		buildAllBundles (buildTarget);

		BuildOptions buildOptions = BuildOptions.AcceptExternalModificationsToPlayer;
		if (debugMode) {
			buildOptions |= BuildOptions.Development;
			buildOptions |= BuildOptions.ConnectWithProfiler;
		}

		//export project
		if (buildTarget == BuildTarget.Android)
			ExportAndroid (buildOptions);
		else if (buildTarget == BuildTarget.iOS)
			ExportIOS (buildOptions);
		else
			ExportWindows(buildOptions);

		debugMode = false;
		overrideServer = string.Empty;
		overrideVersion = string.Empty;
	}

	static string[] GetBuildScenes() {
		List<string> scenes = new List<string> ();
		foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes) {
			if (e == null || !e.enabled)
				continue;
			scenes.Add (e.path);
		}
		return scenes.ToArray ();
	}
	[MenuItem("Packager/ExportAndroidProject")]
	public static void ExportAndroidProject() {
		ExportAndroid (BuildOptions.AcceptExternalModificationsToPlayer);
	}

	public static void ExportAndroid(BuildOptions options) {
		string exportDir = exportPath;
		if(string.IsNullOrEmpty(exportDir))
			exportDir = UnityEditor.EditorUtility.OpenFolderPanel ("选择目录", "", "AndroidProject");
		exportDir = exportDir.Replace ('\\', '/');

		if (string.IsNullOrEmpty (exportDir)) {
			UnityEngine.Debug.LogError ("[AssetBundle] ExportAndroid error: exportDir invalid");
			return;
		}

		if (!Directory.Exists (exportDir))
			Directory.CreateDirectory (exportDir);

		string dstSrc = exportDir + "/" + Application.productName;
		if (Directory.Exists (dstSrc))
			Directory.Delete (dstSrc, true);
		
		string dstCpy = exportDir + "/" + "jyddz";
		if (Directory.Exists (dstCpy))
			Directory.Delete (dstCpy, true);

		BuildPipeline.BuildPlayer (GetBuildScenes (), exportDir, BuildTarget.Android, options);

		AssetDatabase.Refresh ();

		UnityEngine.Debug.Log (string.Format("Export AndroidProject: {0} success", exportDir + "/" + Application.productName));

		Directory.Move (exportDir + "/" + Application.productName, exportDir + "/" + "jyddz");

		ClearUnextract (GetBuildConfigFileName(BuildTarget.Android), exportDir + "/jyddz/src/main/assets/");
		//ClearPluginDir ("Android");

		UnityEngine.Debug.Log (string.Format("Export AndroidProject: Please use {0}", exportDir + "/" + "jyddz"));
	}

	[MenuItem("Packager/ExportIOSProject")]
	public static void ExportIOSProject() {
		ExportIOS (BuildOptions.AcceptExternalModificationsToPlayer);
	}

	public static void ExportIOS(BuildOptions options) {
		string exportDir = exportPath;
		if(string.IsNullOrEmpty(exportDir))
			exportDir = UnityEditor.EditorUtility.OpenFolderPanel ("选择目录", "", "IOSProject");
		exportDir = exportDir.Replace ('\\', '/');
		
		BuildPipeline.BuildPlayer (GetBuildScenes (), exportDir, BuildTarget.iOS, options);

		AssetDatabase.Refresh ();

		ClearUnextract (GetBuildConfigFileName(BuildTarget.iOS), exportDir + "/Data/Raw/");

		UnityEngine.Debug.Log (string.Format("Export IOSProject: {0} success", exportDir));
	}

	[MenuItem("Packager/ExportWindows")]
	public static void ExportWindows() {
		ExportWindows (BuildOptions.AcceptExternalModificationsToPlayer);
	}
	public static void ExportWindows(BuildOptions options) {
		string exportDir = exportPath;
		if(string.IsNullOrEmpty(exportDir))
			exportDir = UnityEditor.EditorUtility.OpenFolderPanel ("选择目录", "", "Windows");
		exportDir = exportDir.Replace ('\\', '/');
		if(!exportDir.EndsWith("/"))
			exportDir += "/";

		string exeName = exportDir + PlayerSettings.productName + ".exe";
		BuildPipeline.BuildPlayer (GetBuildScenes (), exeName, BuildTarget.StandaloneWindows64, options);

		AssetDatabase.Refresh ();

		ClearUnextract (GetBuildConfigFileName(BuildTarget.StandaloneWindows64), exportDir + PlayerSettings.productName + "_Data/StreamingAssets/");

		UnityEngine.Debug.Log (string.Format("Export Windows: {0} success", exportDir));
	}

	#region new packager
	static void UpdateProgress(int progress, int progressMax, string desc)
	{
		string title = "Processing...[" + progress + " - " + progressMax + "]";
		float value = (float)progress / (float)progressMax;
		EditorUtility.DisplayProgressBar(title, desc, value);
	}

	static int CompareString(string x, string y)
	{
		if (x.Length > 0 && y.Length > 0)
		{
			if (x[0].CompareTo(y[0]) == 0)
			{
				return -x.CompareTo(y);
			}
		}
		return x.CompareTo(y);
	}
	public static int SearchFiles(string dir, string patternFilter, bool recursion, ref List<string> fileList) {
		if (!Directory.Exists (dir))
			return 0;
		
		string[] files = { };
		if (recursion)
			files = Directory.GetFiles (dir, patternFilter, SearchOption.AllDirectories);
		else
			files = Directory.GetFiles (dir, patternFilter, SearchOption.TopDirectoryOnly);

		for (int idx = 0; idx < files.Length; ++idx) {
			if (files [idx].EndsWith(".meta") ||
				files [idx].Contains(".DS_Store") ||
				files[idx].EndsWith(".cs") ||
				files[idx].EndsWith(".manifest"))
				continue;

			fileList.Add (files [idx].Replace('\\', '/'));
		}

		return fileList.Count;
	}

	[Serializable]
	internal class BundleContent {
		public string bundleName = string.Empty;
		public string dataPath = string.Empty;
		public string patternFilter = string.Empty;
		public bool recursionSearch = true;
		public bool autoSplitBundle = false;
		public bool isLua = false;

		public bool isVaild() {
			if (string.IsNullOrEmpty (bundleName) ||
				string.IsNullOrEmpty (dataPath) ||
				string.IsNullOrEmpty (patternFilter) ||
				(isLua && autoSplitBundle))
				return false;
			return true;
		}
	}

	[Serializable]
	internal class BundleGroup {
		public string groupName = string.Empty;
		public bool isExtract = false;
		public bool useBasicVersion = false;
		public List<string> dirList = new List<string> ();
		public List<BundleContent> bundleContents = new List<BundleContent>();
	}

	static string[] filePattern = new string[] {
		"*.tga", "*.png", "*.jpg", "*.prefab", "*.unity", "*.mp3","*.wav","*.ogg", "*.txt", "*.json" , "*.mat", "*.fontsettings", "*.lua", "*.controller","*.asset","*.anim","*.ttf"
	};
	private static void BuildAssetMapCore(string channelPath, ref Dictionary<string, string> map) {
		string dataPath = Application.dataPath + "/";
		string fileName = string.Empty;
		string key = string.Empty, value = string.Empty;
		List<string> fileList = new List<string> ();

		string path = dataPath + channelPath;
		for (int i = 0; i < filePattern.Length; ++i) {
			if (SearchFiles (path, filePattern [i], true, ref fileList) > 0) {
				for (int j = 0; j < fileList.Count; ++j) {
					fileName = fileList [j].Substring (dataPath.Length - "Assets/".Length);
					if (fileName.EndsWith ("udf.txt") || fileName.EndsWith ("file_list.txt"))
						continue;
					if (fileName.EndsWith ("readme.txt") || fileName.EndsWith ("BuildVersionConfig.json"))
						continue;
					//Assets/xxx/xxx.xxx
					key = Path.GetFileName (fileName).ToLower ();
					if (map.TryGetValue (key, out value)) {
						UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildAssetMap exception: key({0}) conflict({1}, {2})", key, value, fileName));
						continue;
					}
					map.Add (key, fileName);
				}
			}
			fileList.Clear ();
		}
	}

	private static void SaveAssetMap(string fileName, Dictionary<string, string> map) {
		FileStream fs = new FileStream (fileName, FileMode.Create);
		StreamWriter sw = new StreamWriter(fs);
		foreach (KeyValuePair<string, string> kv in map)
			sw.WriteLine (kv.Key + "|" + kv.Value); 
		sw.Close ();
		fs.Close ();
	}
	private static void BuildAssetMapCore(string channel, ref Dictionary<string, string> mainMap, ref Dictionary<string, string> channelMap) {
		string dataPath = Application.dataPath + "/";

		mainMap.Clear ();
		BuildAssetMapCore ("Game", ref mainMap);
		SaveAssetMap (dataPath + ResourceManager.NAME_TO_ASSET + ".txt", mainMap);

		int idx = 0;
		if (string.IsNullOrEmpty (channel)) {
			for (idx = 0; idx < QUDAO_LIST.Length; ++idx) {
				channelMap.Clear ();
				BuildAssetMapCore (QUDAO_PATH [idx], ref channelMap);
				SaveAssetMap (dataPath + ResourceManager.NAME_TO_ASSET + "_" + QUDAO_LIST[idx] + ".txt", channelMap);
			}
		} else {
			for (idx = 0; idx < QUDAO_LIST.Length; ++idx) {
				if (string.Compare (QUDAO_LIST [idx], channel) == 0) {
					channelMap.Clear ();
					BuildAssetMapCore (QUDAO_PATH [idx], ref channelMap);
					SaveAssetMap (dataPath + ResourceManager.NAME_TO_ASSET + "_" + QUDAO_LIST[idx] + ".txt", channelMap);
					break;
				}
			}
		}

		AssetDatabase.Refresh ();
	}

	[MenuItem("Packager/BuildAssetMap _F6")]
	public static void BuildAssetMap() {
		Dictionary<string, string> mainMap = new Dictionary<string, string> ();
		Dictionary<string, string> channelMap = new Dictionary<string, string> ();
		BuildAssetMapCore (string.Empty, ref mainMap, ref channelMap);
		UnityEngine.Debug.Log ("BuildAssetMap finish!");
	}
	
	public class GameInfoEquality : IEqualityComparer<GameInfo>
    {
        public bool Equals(GameInfo x, GameInfo y)
        {
            return string.Compare(x.Name, y.Name, true) == 0;
        }

        public int GetHashCode(GameInfo obj)
        {
            if (obj == null)
            {
                return 0;
            }
            else
            {
                return obj.ToString().GetHashCode();
            }
        }
    }

	public class GuideFileEquality : IEqualityComparer<GuideFile>
    {
        public bool Equals(GuideFile x, GuideFile y)
        {
            return string.Compare(x.Name, y.Name, true) == 0;
        }

        public int GetHashCode(GuideFile obj)
        {
            if (obj == null)
            {
                return 0;
            }
            else
            {
                return obj.ToString().GetHashCode();
            }
        }
    }

	[MenuItem("Packager/MergeVersionMap")]
	public static void MergeVersionMap()
    {
		string newVersionFile = UnityEditor.EditorUtility.OpenFilePanelWithFilters("Select New VersionMap", "", new string[]{ "txt", "txt" });
		string rawVersionFile = UnityEditor.EditorUtility.OpenFilePanelWithFilters("Select Raw VersionMap", "", new string[]{ "txt", "txt" });
		
		VersionMap newVM = new VersionMap();
		if (!Util.JsonHelper.LoadJson<VersionMap>(newVersionFile, out newVM))
		{
			UnityEngine.Debug.LogError("MergeVersionMap exception: load new versionmap failed:" + newVersionFile);
			return;
		}

		VersionMap rawVM = new VersionMap();
		if (!Util.JsonHelper.LoadJson<VersionMap>(rawVersionFile, out rawVM))
		{
			UnityEngine.Debug.LogError("MergeVersionMap exception: load raw versionmap failed:" + rawVersionFile);
			return;
		}

		var mergeGames = newVM.games.Except(rawVM.games, new GameInfoEquality());
		if(mergeGames.Count() > 0)
			rawVM.games.AddRange(mergeGames);

		var mergemd5s = newVM.md5s.Except(rawVM.md5s, new GuideFileEquality());
		if(mergemd5s.Count() > 0)
			rawVM.md5s.AddRange(mergemd5s);

		File.WriteAllText (rawVersionFile + ".new", JsonUtility.ToJson (rawVM, true));
    }

	[MenuItem("Packager/ResetParticleMaterial")]
	public static void ResetParticleMaterial() {
		string dataPath = Application.dataPath + "/";

		List<string> fileList = new List<string> ();
		if (SearchFiles (dataPath, "*.mat", true, ref fileList) > 0) {
			foreach (string file in fileList) {
				string fileName = "Assets/" + file.Replace (dataPath, string.Empty);

				Material material = AssetDatabase.LoadAssetAtPath<Material> (fileName);
				if (material == null) {
					UnityEngine.Debug.LogError ("[AssetBundle] ResetParticleMaterial failed. can't load material: " + fileName);
					continue;
				}
				if (material.name == "ParticleMask")
					continue;

				if (material.shader.name == "ParticleMask") {
					material.shader = Shader.Find ("Particles/Additive");
					UnityEngine.Debug.Log ("Reset: " + material.name);
				}
			}
		}
		AssetDatabase.SaveAssets ();
		AssetDatabase.Refresh ();
	}

	[Serializable]
	internal class BundleOption {
		public string rootDir = string.Empty;
		public bool useBasicVersion = false;
		public bool isExtract = false;
		public List<string> dependList = new List<string> ();
	}
	[Serializable]
	internal class BuildConfig {
		public List<string> svr_list = new List<string>();
		public List<string> svr_data = new List<string>();
		public List<string> svr_game = new List<string>();

		public string Version = "1.1.1";
		public List<BundleOption> options = new List<BundleOption>();
	}

	[Serializable]
	internal class ActivityContent {
		public string name = string.Empty;
		public bool enable = false;
	}
	[Serializable]
	internal class ActivityConfig {
		public List<ActivityContent> activities = new List<ActivityContent> ();
	}

	[Serializable]
	internal class VersionContent {
		public string dirName = string.Empty;
		public List<string> fileList = new List<string> ();
		public VersionContent(string dirName) {
			this.dirName = dirName;
		}
	}
		
	static bool FindBundleOption(BuildConfig buildCfg, string dirIdent, ref BundleOption bundleOption) {
		bundleOption = null;

		if (buildCfg == null)
			return false;

		string dirName = string.Empty;
		string[] item = { };
		foreach (BundleOption bo in buildCfg.options) {
			dirName = bo.rootDir.ToLower ();
			if (string.Compare (dirName, dirIdent, true) == 0) {
				bundleOption = bo;
				return true;
			}
		}
		return false;
	}

	static bool ParseSegments(string value, char split, ref List<string> result) {
		result.Clear ();

		string[] items = value.Split (split);
		if (items == null || items.Length <= 0) {
			UnityEngine.Debug.LogError (string.Format ("[AssetBundle] ParseSegments({0}, {1}) failed.", value, split));
			return false;
		}

		for (int idx = 0; idx < items.Length; ++idx) {
			if (string.IsNullOrEmpty (items [idx]))
				continue;
			result.Add (items [idx]);
		}

		return result.Count > 0;
	}

	const string BuildConfigFile = "VersionConfig/BuildVersionConfig";
	const string BuildConfigFileAndroid = "VersionConfig/Android/BuildVersionConfig";
	const string BuildConfigFileIOS = "VersionConfig/IOS/BuildVersionConfig";
	const string BuildActivityConfig = "VersionConfig/ActivityConfig";

	static string GetBuildConfigFileName(BuildTarget buildTarget) {
		string configFile = string.Empty;
		if (buildTarget == BuildTarget.Android)
			configFile = BuildConfigFileAndroid;
		else if (buildTarget == BuildTarget.iOS)
			configFile = BuildConfigFileIOS;
		else
			configFile = BuildConfigFile;
		
		string channelName = AppDefine.CurQuDao;
		string dataPath = Application.dataPath + "/";

		if (!string.IsNullOrEmpty (channelName) && string.Compare (channelName, "main", true) != 0) {
			string fullName = dataPath + configFile + "_" + channelName + ".json";
			if (File.Exists (fullName))
				return fullName;
		}
		return dataPath + configFile + ".json";
	}

	const string BASIC_BUNDLE = GameManager.BASIC_IDENT;
	const string LUA_TMP_DIR = "_LUA_";

	static List<AssetBundleBuild> buildBundleMaps = new List<AssetBundleBuild>();
	static Dictionary<string, string> buildAssetMaps = new Dictionary<string, string>();
	static Dictionary<string, VersionContent> versionDirs = new Dictionary<string, VersionContent> ();
	static HashSet<string> activityMaps = new HashSet<string> ();

	static string updVersion = string.Empty;
	static string netAddress = string.Empty;

	static string[] BASIC_DIR = new string[] {"common", "framework", "sproto", "loadingpanel"};
	static string EntrySceneName = "Entry.unity";

	public static ChannelConfig ChannelConfig = new ChannelConfig();

	static string[] QUDAO_LIST = {
		"main",
        "Local",
        "Loca2",
        "Loca3"
	};
	static string[] QUDAO_PATH = {
		"Channel/main/Assets",
		"Channel/Local1/Assets",
		"Channel/Local2/Assets",
		"Channel/Local3/Assets"
	};
	static string[] QUDAO_KEY = {
		"自营渠道",
        "Local1",
        "Local2",
        "Local3"
	};
	//static string[] QUDAO_SHARE_MAIN = {"caiyunmj_cpls", "aibianxian" };
	

	//主渠道根据平台来区分，目前有捕鱼、冲金鸡
	static string[] BY_SHARE_MAIN = { };
	static string[] CJJ_SHARE_MAIN = { };
	static string[] NONE_SHARE_MAIN = { };
	private static string[] getQuDaoShareMain(string channelName)
    {
		if (string.Compare(channelName, "main", true) == 0)
			return BY_SHARE_MAIN;
		else if (string.Compare(channelName, "cjj", true) == 0)
			return CJJ_SHARE_MAIN;
		return NONE_SHARE_MAIN;
	}
	private static bool IsMainChannel(string channelName)
    {
		if (string.IsNullOrEmpty(channelName) || string.Compare(channelName, "main", true) == 0)
			return true;
		else if (string.Compare(channelName, "cjj", true) == 0)
			return true;
		else
			return false;
    }

	private static bool SyncShareMainChannels(string channelName, ref BuildConfig buildCfg, ref Dictionary<string, string> revertFiles, ref List<string> deleteFiles) {
		if (!IsMainChannel(channelName))
			return false;

		string[] QuDaoShares = getQuDaoShareMain(channelName);
		for (int idx = 0; idx < QuDaoShares.Length; ++idx)
			SyncShareMainChannelFiles (QuDaoShares[idx], ref buildCfg, ref revertFiles, ref deleteFiles);

		return true;
	}

	private static bool SyncShareMainChannelFiles(string channelName, ref BuildConfig buildCfg, ref Dictionary<string, string> revertFiles, ref List<string> deleteFiles) {
		int revertCnt = revertFiles.Count;
		if (!SyncChannelFiles (channelName, ref buildCfg, ref revertFiles, ref deleteFiles))
			return false;
		return true;
	}

	private static bool SyncChannelFiles(string channelName, ref BuildConfig buildCfg, ref Dictionary<string, string> revertFiles, ref List<string> deleteFiles) {
		if (string.IsNullOrEmpty (channelName))
			return false;

		string rootPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string gamePath = Application.dataPath + "/" + "Game/";
		string channelPath = gamePath + channelName + "/";
		if (Directory.Exists (channelPath))
			Directory.Delete (channelPath, true);
		Directory.CreateDirectory (channelPath);
		AssetDatabase.Refresh();

		Dictionary<string, string> mainMap = new Dictionary<string, string> ();
		Dictionary<string, string> channelMap = new Dictionary<string, string> ();
		BuildAssetMapCore (channelName, ref mainMap, ref channelMap);
		if (channelMap.Count <= 0)
			return true;

		string tmpDir = rootPath + "_TMP_/";
		var replaceKeys = channelMap.Keys.Intersect (mainMap.Keys);
		var copyKeys = channelMap.Keys.Except (mainMap.Keys);
		string srcFile, dstFile, tmpFile;

		foreach (var key in replaceKeys) {
			srcFile = rootPath + channelMap [key];
			dstFile = rootPath + mainMap [key];

			tmpFile = tmpDir + mainMap [key];
			Util.CopyFile (dstFile, tmpFile);
			revertFiles.Add (tmpFile, dstFile);

			Util.CopyFile (srcFile, dstFile);

			if (dstFile.EndsWith(".prefab"))
			{
				AssetDatabase.ImportAsset(mainMap[key]);
			}

			UnityEngine.Debug.Log ("[Replace]:" + srcFile + " --> " + dstFile);
		}

		string sdkPath = "Assets/Channel/" + channelName + "/Assets/";
		string name = string.Empty;
		foreach (var key in copyKeys) {
			name = channelMap [key];
			srcFile = rootPath + name;
			dstFile = channelPath + name.Substring (sdkPath.Length);

			Util.MoveFile(srcFile, dstFile);
			revertFiles.Add(dstFile, srcFile);
			UnityEngine.Debug.Log("[Move]:" + srcFile + " --> " + dstFile);

			srcFile = srcFile + ".meta";
			dstFile = dstFile + ".meta";
			Util.MoveFile(srcFile, dstFile);
			revertFiles.Add(dstFile, srcFile);

			if (dstFile.EndsWith(".prefab"))
			{
				AssetDatabase.ImportAsset(mainMap[key]);
			}
		}

		BundleOption option = new BundleOption ();
		option.useBasicVersion = true;
		option.isExtract = true;
		option.rootDir = channelName;
		buildCfg.options.Add (option);

		return true;
	}

	private static void SetEntryScene(string sceneName) {
		List<EditorBuildSettingsScene> editorBuildSettingsScenes = new List<EditorBuildSettingsScene> (EditorBuildSettings.scenes);
		List<int> remList = new List<int> ();
		for (int i = 0; i < editorBuildSettingsScenes.Count; i++) {
			if (editorBuildSettingsScenes [i].path.EndsWith (EntrySceneName))
				remList.Add (i);
		}
		for (int idx = remList.Count - 1; idx >= 0; --idx)
			editorBuildSettingsScenes.RemoveAt (idx);

		editorBuildSettingsScenes.Insert (0, new EditorBuildSettingsScene (sceneName, true));
		EditorBuildSettings.scenes = editorBuildSettingsScenes.ToArray ();

		UnityEngine.Debug.Log ("SetEntryScene:" + sceneName);
	}

	private static void ChangeChannelScene(string channelName) {
		string sceneName = Application.dataPath + "/Entry/" + EntrySceneName;
		if(!string.IsNullOrEmpty(channelName) && string.Compare(channelName, "main", true) != 0)
			sceneName = Application.dataPath + "/Channel/" + channelName + "/" + EntrySceneName;
		
		if (File.Exists (sceneName)) {
			sceneName = sceneName.Substring (Application.dataPath.Length - 6);
			SetEntryScene (sceneName);
		} else {
			sceneName = "Assets/Entry/" + EntrySceneName;
			SetEntryScene (sceneName);
		}
	}
	private static void ResetEntryScene(string channelName) {
		string sceneName = Application.dataPath + "/Channel/" + channelName + "/" + EntrySceneName;
		if (File.Exists (sceneName)) {
			sceneName = sceneName.Substring (Application.dataPath.Length - 6);

			List<EditorBuildSettingsScene> editorBuildSettingsScenes = new List<EditorBuildSettingsScene>(EditorBuildSettings.scenes);
			int index = -1;
			for (int i = 0; i < editorBuildSettingsScenes.Count; i++) {
				if (editorBuildSettingsScenes [i].path == sceneName) {
					index = i;
					break;
				}
			}
			if(index >= 0)
				editorBuildSettingsScenes.RemoveAt (index);
			EditorBuildSettings.scenes = editorBuildSettingsScenes.ToArray();

			//SceneAsset theScene = AssetDatabase.LoadAssetAtPath<SceneAsset>(EditorBuildSettings.scenes[0].path);
			//EditorSceneManager.playModeStartScene = theScene;
		}
	}

	private static void updateBundles(BuildTarget buildTarget) {
		string streamingRoot = Application.streamingAssetsPath + "/";

		bool saveFile = false;

		//version.map
		VersionMap vm = null;
		if (!Util.JsonHelper.LoadJson<VersionMap>(streamingRoot + GameManager.VERSION_MAP, out vm))
		{
			UnityEngine.Debug.LogError("[Export] exception: open versionmap failed for no rebuild!");
			return;
		}

		//udf.txt
		UDF udf = GameManager.LoadUDF(streamingRoot + GameManager.UDF_FILE);
		if (udf == null)
        {
			UnityEngine.Debug.LogError("[Export] exception: invalid udf for no rebuild!");
			return;
        }

		if (!string.IsNullOrEmpty(overrideList))
        {
			UnityEngine.Debug.Log(string.Format("[AssetBundle] BuildBundles overrideList({0})", overrideList));

			List<string> urls = new List<string>();
			if (ParseSegments(overrideList, ';', ref urls))
            {
				vm.svr_list = urls;
				udf.svr_list = urls;
			}
				
			saveFile = true;
		}
		if (!string.IsNullOrEmpty(overrideData))
		{
			UnityEngine.Debug.Log(string.Format("[AssetBundle] BuildBundles overrideData({0})", overrideData));

			List<string> urls = new List<string>();
			if (ParseSegments(overrideData, ';', ref urls))
            {
				vm.svr_data = urls;
				udf.svr_data = urls;
			}
				
			saveFile = true;
		}

		if(!saveFile)
        {
			UnityEngine.Debug.LogError("[Export] exception: the urls aren't modify for no rebuild!");
			return;
        }

		File.WriteAllText(streamingRoot + GameManager.UDF_FILE, JsonUtility.ToJson(udf));

		saveFile = false;

		for(int idx = 0; idx < vm.md5s.Count; ++idx)
        {
			if(string.Compare(vm.md5s[idx].Name, GameManager.UDF_FILE, false) == 0)
            {
				vm.md5s[idx].MD5 = Util.md5file(streamingRoot + GameManager.UDF_FILE);
				vm.md5s[idx].Size = (int)(new FileInfo(streamingRoot + GameManager.UDF_FILE).Length);
				saveFile = true;
				break;
            }
        }

		if (!saveFile)
		{
			UnityEngine.Debug.LogError("[Export] exception: udf can't find in versionmap for no rebuild!");
			return;
		}

		File.WriteAllText(streamingRoot + GameManager.VERSION_MAP, JsonUtility.ToJson(vm, true));
		Util.CopyFile(streamingRoot + GameManager.VERSION_MAP, Application.dataPath + "/" + GameManager.VERSION_MAP);

		UnityEngine.Debug.Log("[Export] updateBundles OK");
	}

	private static void buildAllBundles(BuildTarget buildTarget) {
		string dataPath = Application.dataPath + "/";
		string rootDir = dataPath + "Game/";
		string channelName = AppDefine.CurQuDao;

		ClearEmptyFolder.IsLock = true;

		//change channel scene
		ChangeChannelScene(channelName);

		do {
			string streamingPath = Application.streamingAssetsPath;
			if (Directory.Exists (streamingPath))
				Directory.Delete (streamingPath, true);
			Directory.CreateDirectory (streamingPath);
			AssetDatabase.Refresh();
			AssetDatabase.SaveAssets();

			string configFile = GetBuildConfigFileName(buildTarget);
			UnityEngine.Debug.Log ("[AssetBundle] BuildBundles with " + configFile);

			if (!File.Exists (configFile)) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ConfigFile not exist");
				break;
			}

			string content = File.ReadAllText (configFile);
			if (string.IsNullOrEmpty (content)) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ConfigFile invalid.");
				break;
			}

			BuildConfig buildCfg = JsonUtility.FromJson<BuildConfig> (content);
			if (buildCfg == null) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ParseJson failed.");
				break;
			}

			if (!string.IsNullOrEmpty (overrideList)){
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideList({0})", overrideList));

				List<string> urls = new List<string> ();
				if (ParseSegments (overrideList, ';', ref urls))
					buildCfg.svr_list = urls;
			}
			if (!string.IsNullOrEmpty (overrideData)) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideData({0})", overrideData));

				List<string> urls = new List<string> ();
				if (ParseSegments (overrideData, ';', ref urls))
					buildCfg.svr_data = urls;
			}
			if (!string.IsNullOrEmpty (overrideGame)) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideGame({0})", overrideGame));

				List<string> urls = new List<string> ();
				if (ParseSegments (overrideGame, ';', ref urls))
					buildCfg.svr_game = urls;
			}

			if (!string.IsNullOrEmpty (overrideVersion)) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideVersion({0}) to ({1})", buildCfg.Version, overrideVersion));

				buildCfg.Version = overrideVersion;
			}
			updVersion = buildCfg.Version;

			//activity filter
			configFile = dataPath + BuildActivityConfig + "_" + channelName + ".json";
			if (!File.Exists(configFile))
				configFile = dataPath + BuildActivityConfig + ".json";
			UnityEngine.Debug.Log("[AssetBundle] BuildBundles activity config:" + configFile);

			if (File.Exists (configFile)) {
				ActivityConfig activityConfig = JsonUtility.FromJson<ActivityConfig> (File.ReadAllText (configFile));
				activityMaps.Clear ();
				foreach (ActivityContent it in activityConfig.activities) {
					if(!it.enable) continue;
					activityMaps.Add(it.name.ToLower());
				}
			}

			UnityEngine.Debug.Log ("BuildBundles Start...");

			string luaTmpDir = dataPath + LUA_TMP_DIR;
			if (Directory.Exists(luaTmpDir))
				Directory.Delete(luaTmpDir, true);
			Directory.CreateDirectory(luaTmpDir);
			AssetDatabase.Refresh ();

			buildBundleMaps.Clear ();
			buildAssetMaps.Clear ();
			versionDirs.Clear ();

			string tmpDir = Application.dataPath + "/_TMP_";
			if (Directory.Exists(tmpDir))
				Directory.Delete(tmpDir, true);
			Directory.CreateDirectory (tmpDir);

			Dictionary<string, string> revertFiles = new Dictionary<string, string>();
			List<string> deleteFiles = new List<string>();
			SyncChannelFiles (channelName, ref buildCfg, ref revertFiles, ref deleteFiles);
			SyncShareMainChannels(channelName, ref buildCfg, ref revertFiles, ref deleteFiles);

			AssetDatabase.Refresh ();
			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh ();

			//special dir
			//tolua framework
			if(!BuildBundleLua("lua", dataPath + "LuaFramework/ToLua/Lua/", dataPath + "LuaFramework/ToLua/Lua/")) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. BuildToLua failed.");
				break;
			}

			//project share
			string[,] ShareLuaDir = new string[2,2] {
				{"common/common", "Common"},
				{"framework/framework", "Framework"}
			};
			for (int idx = 0; idx < ShareLuaDir.GetLength(0); ++idx) {
				if(!BuildBundleLua(ShareLuaDir[idx,0], rootDir + ShareLuaDir[idx,1], dataPath)) {
					UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundles failed. BuildShareLua({0},{1}) failed.", ShareLuaDir[idx,0], ShareLuaDir[idx,1]));
					break;
				}
			}

			AssetDatabase.Refresh ();

			//netconfig
			string netConfigFile = luaTmpDir + "/" + "framework/framework/Game@Framework@NetConfig.lua.bytes";
			if (!string.IsNullOrEmpty (overrideServer)) {
				content = string.Format ("NetConfig = {{}}\n\nfunction NetConfig.NetConfigInit()\n\tAppConst.SocketAddress = \"{0}\"\nend\n", overrideServer);
				File.WriteAllText (netConfigFile, content);

				netAddress = overrideServer;
			} else {
				if(File.Exists(netConfigFile))
				{
					foreach (string line in File.ReadAllLines (netConfigFile)) {
						content = line.Trim();
						if (string.IsNullOrEmpty (content))
							continue;
						if (content.StartsWith ("AppConst.SocketAddress")) {
							netAddress = content;
							break;
						}
					}
				}
			}

			string dirIdent = string.Empty;

			bool skipDir = false;
			string[] dirs = Directory.GetDirectories (rootDir);
			foreach (string dir in dirs) {
				dirIdent = dir.Substring (rootDir.Length).ToLower();
				versionDirs.Add (dirIdent, new VersionContent(dirIdent));
				if(dirIdent.StartsWith("activity"))
					continue;

				skipDir = false;
				for (int idx = 0; idx < ShareLuaDir.GetLength(0); ++idx) {
					if (dir.EndsWith (ShareLuaDir [idx,1])) {
						skipDir = true;
						break;
					}
				}
				if (skipDir)
					continue;

				//UnityEngine.Debug.Log ("Build for " + dir);

				if (!BuildBundleDir (dirIdent.ToLower(), dir)) {
					UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundles failed. BuildBundleDir({0}) failed.", dir));
					break;
				}
			}

			//activity
			foreach(string it in activityMaps) {
				if (!BuildBundleDir ("activity", rootDir + it)) {
					UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundles failed. BuildBundleDir({0}) failed.", rootDir + it));
					break;
				}
			}

			AssetDatabase.Refresh ();

			if (true) {

				BuildPipeline.BuildAssetBundles(Application.streamingAssetsPath,
					buildBundleMaps.ToArray(),
					BuildAssetBundleOptions.None,
					buildTarget);
				AssetDatabase.Refresh ();

				if (AppConst.UseXTEA) {
					if (!EncryptAssetBundles ()) {
						UnityEngine.Debug.LogError ("[AssetBundle] EncryptAssetBundles failed.");
						break;
					}
				}
			}

			//atb
			BuildATB ();

			//cinematic
			List<string> mp4List = new List<string>();

			if (SearchFiles(dataPath + "Entry/LogoAnimation", "*.mp4", false, ref mp4List) > 0)
            {
				foreach (var mp4File in mp4List)
					Util.CopyFile(mp4File, Application.streamingAssetsPath + "/" + Path.GetFileName(mp4File));
			}

			//try replace main's mp4
			{
				mp4List.Clear();
				if (SearchFiles(dataPath + "Channel/" + AppDefine.CurQuDao + "/LogoAnimation", "*.mp4", false, ref mp4List) > 0)
                {
					foreach(var mp4File in mp4List)
						Util.CopyFile(mp4File, Application.streamingAssetsPath + "/" + Path.GetFileName(mp4File));
                }
			}
			
			//share channel's mp4
			string channelVideoName = string.Empty;
			string[] QuDaoShares = getQuDaoShareMain(AppDefine.CurQuDao);
			for (int idx = 0; idx < QuDaoShares.Length; ++idx)
			{
				mp4List.Clear();
				if(SearchFiles(dataPath + "Channel/" + QuDaoShares[idx] + "/LogoAnimation", "*.mp4", false, ref mp4List) > 0)
                {
					foreach (var mp4File in mp4List)
						Util.CopyFile(mp4File, Application.streamingAssetsPath + "/" + Path.GetFileName(mp4File));
				}
			}

			//icon
			File.Copy(dataPath + "AppIcons/" + AppConst.AppIcon, Application.streamingAssetsPath + "/" + "AppIcon.png", true);

			//channel file
			{
				ChannelConfig.platform = marketPlatform;
				ChannelConfig.channel = marketChannel;
				File.WriteAllText(Application.streamingAssetsPath + "/" + GameManager.CHANNEL_FILE, JsonUtility.ToJson(ChannelConfig));
			}

			AssetDatabase.Refresh ();

			//filelist & udf
			if (!BuildVersions (buildCfg)) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. BuildVersions failed.");
				break;
			}

			//extract
			BuildExtract(buildCfg);

			//VersionMap
			BuildVersionMap(buildCfg, buildTarget);

			//MainVersion
			string[] items = buildCfg.Version.Split('.');
			if (string.Compare (MainVersion.Version, items [0], true) != 0) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] Attention: MainVersion Upgrade({0} --> {1})", MainVersion.Version, items[0]));

				MainVersion.Version = items [0];

				string mainVersionFile = dataPath + "LuaFramework/Scripts/ConstDefine/MainVersion.cs";
				string mainVersionText = string.Format ("public class MainVersion\n{{\n\tstatic public string Version = \"{0}\";\n\n\tstatic public string baseVersion = \"{1}\";}}", MainVersion.Version, updVersion);
				File.WriteAllText (mainVersionFile, mainVersionText);
			}

			AssetDatabase.Refresh ();

			UnityEngine.Debug.Log (string.Format("Use NetConfig({0}), UpdateVersion({1})", netAddress, updVersion));

			//CheckAssetBundles ();

			foreach(KeyValuePair<string, string> kv in revertFiles) {
				Util.CopyFile(kv.Key, kv.Value);
				File.Delete(kv.Key);
			}
			revertFiles.Clear();
			foreach(string deleteFile in deleteFiles) {
				if(File.Exists(deleteFile))
					File.Delete(deleteFile);
				else
					UnityEngine.Debug.Log("[AssetBundle] clear file, but file not exist:" + deleteFile);
			}
			deleteFiles.Clear();

			if(Directory.Exists(tmpDir))
				Directory.Delete(tmpDir, true);

			string channelDir = Application.dataPath + "/Game/" + channelName;
			if(Directory.Exists(channelDir))
				Directory.Delete (channelDir, true);

			AssetDatabase.Refresh ();
			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh ();

			UnityEngine.Debug.Log ("BuildBundles Success!");

		} while(false);

		ClearEmptyFolder.IsLock = false;
	}

	[MenuItem("Packager/BuildBundles _F9")]
	public static void BuildAllBundles() {
		buildAllBundles (EditorUserBuildSettings.activeBuildTarget);
	}

	static bool BuildBundleLua(string bundleName, string dirName, string cutoff) {
		string tmp_dir = Application.dataPath + "/" + LUA_TMP_DIR + "/";
		string bundleDir = tmp_dir + bundleName + "/";

		if (!Directory.Exists (bundleDir))
			Directory.CreateDirectory (bundleDir);

		List<string> fileList = new List<string> ();
		if (SearchFiles (dirName, "*.lua", true, ref fileList) <= 0) {
			UnityEngine.Debug.LogWarning (string.Format("BuildBundleLua({0}, {1}) is empty.", bundleName, dirName));
			return true;
		}

		List<string> newList = new List<string> ();
		string srcFile, dstFile, fileName;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			srcFile = fileList [idx];
			fileName = srcFile.Substring (cutoff.Length);
			fileName = fileName.Replace ('/', '@');

			dstFile = bundleDir + fileName + ".bytes";

			if (AppConst.LuaByteMode)
				EncodeLuaFile (srcFile, dstFile);
			else
				File.Copy (srcFile, dstFile, true);

			dstFile = dstFile.Substring (Application.dataPath.Length - 6);
			newList.Add (dstFile);

			string dictKey = Path.GetFileName (dstFile).ToLower();
			string dictValue = string.Empty;
			if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
				if (string.Compare (dictValue, bundleName) != 0)
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleLua conflict: {0} : {1} - {2}", fileList [idx], dictValue, bundleName));
				else
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleLua conflict: {0} : {1}", fileList [idx], dictValue));
				//return false;
			}
			buildAssetMaps.Add (dictKey, bundleName);
		}

		AssetBundleBuild bundleBuild = new AssetBundleBuild ();
		bundleBuild.assetBundleName = bundleName + AppConst.ExtName;
		bundleBuild.assetNames = newList.ToArray();
		buildBundleMaps.Add (bundleBuild);

		return true;
	}

	static bool BuildBundleDir(string ident, string dir) {
		dir = dir.Replace ('\\', '/');

		string dataPath = Application.dataPath + "/";
		string rootPath = dataPath.Replace ("Assets/", string.Empty);
			
		string rootDir = dataPath + "Game/";
		string relateDir = dir.Substring (rootDir.Length).ToLower();

		string bundleName = string.Empty;
		if (string.Compare (ident, relateDir, true) == 0)
			bundleName = ident + "/" + ident;
		else
			bundleName = ident + "/" + relateDir.Replace ('/', '_');
		bundleName = bundleName.ToLower ();

		if (dir.EndsWith ("/Lua"))
			return BuildBundleLua (bundleName, dir, dataPath);
		else {
			foreach (string subdir in Directory.GetDirectories (dir)) {
				if (!BuildBundleDir (ident, subdir)) {
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleDir({0}, {1}) failed: build subDir({2}) failed.", ident, dir, subdir));
					return false;
				}
			}

			//split unity & others
			string sceneBundleName = bundleName + "_scene";
			List<string> sceneFiles = new List<string>();

			List<string> fileList = new List<string> ();
			if (SearchFiles (dir, "*.*", false, ref fileList) <= 0) {
				UnityEngine.Debug.LogWarning (string.Format("[AssetBundle] BuildBundleDir({0}, {1}) is empty.", ident, dir));
				return true;
			}

			string dictKey, dictValue;
			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileList [idx] = fileList [idx].Replace (rootPath, string.Empty);
				dictKey = Path.GetFileName (fileList [idx]).ToLower();

				//skip unity
				if (dictKey.EndsWith (".unity")) {
					sceneFiles.Add (fileList [idx]);
					continue;
				}

				if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
					if (string.Compare (dictValue, bundleName) != 0)
						UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1} - {2}", fileList [idx], dictValue, bundleName));
					else
						UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1}", fileList [idx], dictValue));
					//return false;
				}
				buildAssetMaps.Add (dictKey, bundleName);
			}

			if (sceneFiles.Count > 0) {
				for (int idx = 0; idx < sceneFiles.Count; ++idx) {
					fileList.Remove (sceneFiles [idx]);

					dictKey = Path.GetFileName (sceneFiles [idx]).ToLower();
					if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
						if (string.Compare (dictValue, sceneBundleName) != 0)
							UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1} - {2}", fileList [idx], dictValue, sceneBundleName));
						else
							UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1}", fileList [idx], dictValue));
						//return false;
					}
					buildAssetMaps.Add (dictKey, sceneBundleName);
				}

				AssetBundleBuild sceneBundleBuild = new AssetBundleBuild ();
				sceneBundleBuild.assetBundleName = sceneBundleName + AppConst.ExtName;
				sceneBundleBuild.assetNames = sceneFiles.ToArray();
				buildBundleMaps.Add (sceneBundleBuild);
			}

			AssetBundleBuild bundleBuild = new AssetBundleBuild ();
			bundleBuild.assetBundleName = bundleName + AppConst.ExtName;
			bundleBuild.assetNames = fileList.ToArray();
			buildBundleMaps.Add (bundleBuild);
		}

		return true;
	}

	//map
	static void BuildATB() {
		string streamingPath = Application.streamingAssetsPath;
		string fileName = streamingPath + "/" + ResourceManager.ASSET_TO_BUNDLE;
		if (File.Exists (fileName))
			File.Delete (fileName);

		FileStream fs = new FileStream (fileName, FileMode.CreateNew);
		StreamWriter sw = new StreamWriter(fs);

		foreach (KeyValuePair<string, string> kv in buildAssetMaps) {
			sw.WriteLine (kv.Key + "|" + kv.Value);
		}

		sw.Close ();
		fs.Close ();
	}

	static bool BuildVersions(BuildConfig buildCfg) {
		string streamingRoot = Application.streamingAssetsPath + "/";
		List<string> fileList = new List<string> ();

		//udf
		UDF udf;
		List<string> basicDependList = new List<string> ();
		basicDependList.AddRange (BASIC_DIR);
		basicDependList.Add("game_loding");
		basicDependList.Add("game_login");

		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			fileList.Clear ();
			SearchFiles (streamingRoot + kv.Key, "*.*", false, ref fileList);
			if (fileList.Count <= 0)
				continue;

			udf = new UDF ();
			udf.ident = kv.Key;
			udf.version = buildCfg.Version;
			if (!BASIC_DIR.Contains (kv.Key))
				udf.dirList.AddRange (BASIC_DIR);
			
			BundleOption bundleOption = null;
			if (FindBundleOption (buildCfg, kv.Key, ref bundleOption)) {
				for (int idx = 0; idx < bundleOption.dependList.Count; ++idx) {
					if (udf.dirList.Contains (bundleOption.dependList [idx].ToLower()))
						continue;
					udf.dirList.Add (bundleOption.dependList [idx].ToLower ());
				}

				if (bundleOption.useBasicVersion)
				{
					if (!basicDependList.Contains(kv.Key.ToLower()))
						basicDependList.Add(kv.Key.ToLower());
					for (int idx = 0; idx < bundleOption.dependList.Count; ++idx) {
						if (basicDependList.Contains (bundleOption.dependList [idx].ToLower ()))
							continue;
						basicDependList.Add(bundleOption.dependList [idx].ToLower ());
					}
				}
			}

			File.WriteAllText (streamingRoot + kv.Key + "/" + GameManager.UDF_FILE, JsonUtility.ToJson (udf));
		}

		//channel & qudao & activity
		{
			string[] dependList = new string[] {
				"channel", AppDefine.CurQuDao.ToLower (), "activity"
			};

			string dependName = string.Empty;
			for (int idx = 0; idx < dependList.Length; ++idx) {
				dependName = dependList [idx];
				fileList.Clear ();
				if (SearchFiles(streamingRoot + dependName, "*.unity3d", false, ref fileList) > 0) {
					if (!basicDependList.Contains (dependName))
						basicDependList.Add(dependName);
				}
			}
		}


		//basic udf
		versionDirs.Add (BASIC_BUNDLE, new VersionContent (BASIC_BUNDLE));

		fileList.Clear ();
		SearchFiles (streamingRoot, "*.*", false, ref fileList);
		if (fileList.Count <= 0) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildVersions failed: BasicUDF fileList is Empty");
			return false;
		}

		udf = new UDF ();
		udf.ident = BASIC_BUNDLE;
		udf.svr_list = buildCfg.svr_list;
		udf.svr_data = buildCfg.svr_data;
		udf.svr_game = buildCfg.svr_game;
		udf.version = buildCfg.Version;
		udf.dirList.AddRange (basicDependList);
		File.WriteAllText (streamingRoot + GameManager.UDF_FILE, JsonUtility.ToJson (udf));

		BundleOption option = new BundleOption ();
		option.useBasicVersion = true;
		option.isExtract = true;
		option.rootDir = BASIC_BUNDLE;
		option.dependList.AddRange (basicDependList);
		buildCfg.options.Add (option);

		string manifestFile = Application.streamingAssetsPath + "/" + "StreamingAssets";
		AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestFile);
		if (assetBundle == null)
		{
			UnityEngine.Debug.LogError("[AssetBundle] BuildVersions failed: load StreamingAssets failed");
			return false;
		}
		AssetBundleManifest manifest = assetBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
		assetBundle.Unload(false);

		//filelist
		string fileName, fileMD5, fileSize;
		FileInfo fileInfo;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			fileList.Clear ();
			if (kv.Key == BASIC_BUNDLE)
            {
				SearchFiles(streamingRoot, "*.*", false, ref fileList);
				//remove channel config
				RemoveChannelFileFromList(ref fileList);
			}
			else
				SearchFiles (streamingRoot + kv.Key, "*.*", false, ref fileList);

			if (fileList.Count <= 0) {
				UnityEngine.Debug.LogWarning (string.Format ("[AssetBundle] BuildVersions warning: {0} is empty", kv.Key));
				continue;
			}

			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileName = fileList [idx];
				fileInfo = new FileInfo(fileName);
				fileMD5 = Util.md5file (fileName);
				fileName = fileName.Replace (streamingRoot, string.Empty);
				if (fileName.EndsWith(GameManager.UDF_FILE))
					continue;
				
				if(fileName.EndsWith(AppConst.ExtName))
					kv.Value.fileList.Add(fileName + "|" + fileMD5 + "|" + manifest.GetAssetBundleHash(fileName) + "|" + fileInfo.Length.ToString());
				else
					kv.Value.fileList.Add(fileName + "|" + fileMD5 + "|" + "#" + "|" + fileInfo.Length.ToString());
			}
		}

		//save filelist
		FileStream fs;
		StreamWriter sw;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			if (kv.Value.fileList.Count <= 0)
				continue;

			if (string.Compare (kv.Key, BASIC_BUNDLE) == 0)
				fs = new FileStream(streamingRoot + GameManager.FILE_LIST, FileMode.Create);
			else
				fs = new FileStream(streamingRoot + kv.Key + "/" + GameManager.FILE_LIST, FileMode.Create);

			sw = new StreamWriter(fs);

			for (int idx = 0; idx < kv.Value.fileList.Count; ++idx)
				sw.WriteLine (kv.Value.fileList [idx]);

			sw.Close ();
			fs.Close ();
		}

		return true;
	}

	static void RemoveChannelFileFromList(ref List<string> list)
    {
		foreach (string it in list)
		{
			if (it.EndsWith(GameManager.CHANNEL_FILE))
			{
				list.Remove(it);
				break;
			}
		}
	}

	static void BuildExtract(BuildConfig buildCfg) {
		string streamingRoot = Application.streamingAssetsPath + "/";

		BundleOption bundleOption = null;

		Dictionary<string, bool> extractFilter = new Dictionary<string, bool> ();
		string dictKey = string.Empty;
		bool dictValue = false;
		for (int idx = 0; idx < buildCfg.options.Count; ++idx) {
			bundleOption = buildCfg.options [idx];

			dictKey = bundleOption.rootDir.ToLower ();
			if (extractFilter.TryGetValue (dictKey, out dictValue)) {
				if (dictValue)
					continue;
				extractFilter [dictKey] = bundleOption.isExtract;
			} else
				extractFilter.Add (dictKey, bundleOption.isExtract);

			foreach (string depend in bundleOption.dependList) {
				dictKey = depend.ToLower ();
				if (extractFilter.TryGetValue (dictKey, out dictValue)) {
					if (dictValue)
						continue;
					extractFilter [dictKey] = bundleOption.isExtract;
				} else
					extractFilter.Add (dictKey, bundleOption.isExtract);
			}
		}

		List<string> fileList = new List<string> ();

		List<string> dirList = new List<string> ();
		dirList.AddRange (BASIC_DIR);
		foreach (KeyValuePair<string, bool> kv in extractFilter) {
			if (kv.Value && !dirList.Contains (kv.Key))
				dirList.Add (kv.Key);
		}
		for (int idx = 0; idx < dirList.Count; ++idx) {
			dictKey = dirList [idx];
			if(dictKey == BASIC_BUNDLE)
            {
				SearchFiles(streamingRoot, "*.*", false, ref fileList);
				//remove channel config
				RemoveChannelFileFromList(ref fileList);
			}
			else
				SearchFiles (streamingRoot + dictKey, "*.*", false, ref fileList);
		}

		FileStream fs = new FileStream (Application.streamingAssetsPath + "/" + GameManager.EXTRACT_FILE, FileMode.Create);
		StreamWriter sw = new StreamWriter(fs);

		for (int idx = 0; idx < fileList.Count; ++idx)
			sw.WriteLine (fileList [idx].Substring(streamingRoot.Length));

		sw.Close ();
		fs.Close ();
	}

	static int GetSizeByFileList(string root) {
		string fileName = root + "/" + GameManager.FILE_LIST;
		if (!File.Exists (fileName))
			return 0;
		string[] lines = File.ReadAllLines (fileName);
		if (lines == null || lines.Length <= 0) {
			UnityEngine.Debug.LogError (string.Format ("[AssetBundle] GetSizeByFileList({0}) failed: filelist is empty.", root));
			return 0;
		}

		int totalSize = 0;

		string[] item = { };
		foreach (string line in lines) {
			item = line.Split ('|');
			if (item == null || item.Length != 4) {
				UnityEngine.Debug.LogError (string.Format ("[AssetBundle] GetSizeByFileList({0}) failed: filelist line({1}) invalid.", root, line));
				return 0;
			}
			totalSize += int.Parse (item [3]);
		}

		return totalSize;
	}
	static void BuildVersionMap(BuildConfig buildCfg, BuildTarget buildTarget) {
		VersionMap versionMap = new VersionMap ();
		versionMap.svr_list = buildCfg.svr_list;
		versionMap.svr_data = buildCfg.svr_data;
		versionMap.svr_game = buildCfg.svr_game;
		versionMap.last_version = buildCfg.Version;
		//versionMap.config_version = buildCfg.Version;

		string dictKey = string.Empty;
		GameInfo gameInfo;
		BundleOption bundleOption = null;
		for (int idx = 0; idx < buildCfg.options.Count; ++idx) {
			bundleOption = buildCfg.options [idx];

			if (string.Compare (bundleOption.rootDir, BASIC_BUNDLE, true) == 0)
				continue;
			
			dictKey = bundleOption.rootDir.ToLower ();
			gameInfo = new GameInfo ();
			gameInfo.Name = bundleOption.rootDir;
			gameInfo.Size = GetSizeByFileList (Application.streamingAssetsPath + "/" + dictKey);
			if (gameInfo.Size == 0)
				UnityEngine.Debug.LogError ("[AssetBundle] BuildVersionMap Find empty dir:" + dictKey);

			/*
			foreach (string depend in bundleOption.dependList) {
				gameInfo.Size += GetSizeByFileList (Application.streamingAssetsPath + "/" + depend);
			}
			*/

			versionMap.games.Add (gameInfo);
		}

		//file list md5
		string streamingRoot = Application.streamingAssetsPath + "/";
		List<string> fileList = new List<string> ();
		SearchFiles(streamingRoot, GameManager.UDF_FILE, true, ref fileList);
		SearchFiles(streamingRoot, GameManager.FILE_LIST, true, ref fileList);

		if (fileList.Count > 0) {
			string fileName = string.Empty;
			FileInfo fileInfo;
			string fileMD5;
			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileName = fileList [idx];
				fileInfo = new FileInfo(fileName);
				fileMD5 = Util.md5file (fileName);
				versionMap.md5s.Add (new GuideFile (fileName.Substring (streamingRoot.Length), fileMD5, (int)fileInfo.Length));
			}
		}

		string saveDir = string.Empty;
		if (buildTarget == BuildTarget.Android)
			saveDir = Application.dataPath + "/VersionConfig/Android";
		else if (buildTarget == BuildTarget.iOS)
			saveDir = Application.dataPath + "/VersionConfig/IOS";
		else
			saveDir = Application.dataPath + "/VersionConfig";

		//saveDir += "/" + buildCfg.Version;
		//if(Directory.Exists(saveDir))
		//	Directory.Delete (saveDir, true);
		//Directory.CreateDirectory (saveDir);

		File.WriteAllText (saveDir + "/version_map.txt", JsonUtility.ToJson (versionMap, true));
		Util.CopyFile(saveDir + "/version_map.txt", Application.streamingAssetsPath + "/version_map.txt");
	}

	static bool EncryptAssetBundles() {
		List<string> fileList = new List<string> ();
		if (SearchFiles (Application.streamingAssetsPath, "*.unity3d", true, ref fileList) <= 0) {
			UnityEngine.Debug.LogError ("EncryptAssetBundles assetbundle is empty.");
			return false;
		}

		ResourceManager.SetXTEAKey(AppConst.xtea, AppConst.PubXTEA);
		byte[] xtea_key = ResourceManager.GetXTEAKey ();
		if (xtea_key == null || xtea_key.Length != 16) {
			UnityEngine.Debug.LogError ("EncryptAssetBundles xtea_key invalid:" + System.Text.Encoding.Default.GetString(xtea_key));
			return false;
		}

		byte[] datas = null;
		foreach (string file in fileList) {
			datas = File.ReadAllBytes (file);
			if (datas == null || datas.Length <= 0) {
				UnityEngine.Debug.LogError ("EncryptAssetBundles file data is empty:" + file);
				return false;
			}
			LuaInterface.LuaDLL.xtea_encrypt (datas, datas.Length, xtea_key);
			File.WriteAllBytes (file, datas);
		}
		return true;
	}

	static void ClearPluginDir(string tagName) {
		string rootDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string pluginDir = "/Plugins/" + tagName + "/";
		string srcDir = rootDir + "Channel/" + AppDefine.CurQuDao + pluginDir;
		string dstDir = Application.dataPath + pluginDir;

		string srcFile = string.Empty, dstFile = string.Empty;
		string[] files = Directory.GetFiles (srcDir, "*.*", SearchOption.AllDirectories);
		foreach (string file in files) {
			srcFile = file.Replace ('\\', '/');
			dstFile = dstDir + srcFile.Substring (srcDir.Length);
			File.Delete (dstFile);
		}
		AssetDatabase.Refresh ();
	}

	static void ClearUnextract(string cfgFile, string assetRoot) {
		string configFile = cfgFile;
		if (!File.Exists (configFile)) {
			UnityEngine.Debug.LogError ("[AssetBundle] ClearUnextract failed. cfgFile not exist");
			return;
		}

		string content = File.ReadAllText (configFile);
		if (string.IsNullOrEmpty (content)) {
			UnityEngine.Debug.LogError ("[AssetBundle] ClearUnextract failed. ConfigFile invalid.");
			return;
		}

		BuildConfig buildCfg = JsonUtility.FromJson<BuildConfig> (content);
		if (buildCfg == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] ClearUnextract failed. ParseJson failed.");
			return;
		}

		string[] dependList = new string[] {
			"channel", AppDefine.CurQuDao.ToLower (), "activity"
		};

		string dictKey = string.Empty;
		bool dictValue = false;
		Dictionary<string, bool> extractFilter = new Dictionary<string, bool> ();

		BundleOption bundleOption = null;
		for (int idx = 0; idx < buildCfg.options.Count; ++idx) {
			bundleOption = buildCfg.options [idx];

			dictKey = bundleOption.rootDir.ToLower ();
			if (extractFilter.TryGetValue (dictKey, out dictValue)) {
				if (dictValue)
					continue;
				extractFilter [dictKey] = bundleOption.isExtract;
			} else
				extractFilter.Add (dictKey, bundleOption.isExtract);

			foreach (string depend in bundleOption.dependList) {
				dictKey = depend.ToLower ();
				if (extractFilter.TryGetValue (dictKey, out dictValue)) {
					if (dictValue)
						continue;
					extractFilter [dictKey] = bundleOption.isExtract;
				} else
					extractFilter.Add (dictKey, bundleOption.isExtract);
			}
		}

		List<string> remDirs = new List<string> ();

		string channelName = AppDefine.CurQuDao.ToLower ();
		bool activityEnable = false;

		string rootDir = Application.dataPath + "/" + "Game/";
		string[] dirs = Directory.GetDirectories (rootDir);
		foreach (string dir in dirs) {
			dictKey = dir.Substring (rootDir.Length).ToLower ();

			if (BASIC_DIR.Contains (dictKey))
				continue;
			
			if (dictKey == "game_loding" || dictKey == "game_login")
				continue;

			if (dependList.Contains (dictKey))
				continue;

			if (extractFilter.TryGetValue (dictKey, out dictValue)) {
				if (dictValue)
					continue;
			}

			remDirs.Add (dictKey);

			UnityEngine.Debug.Log ("Clear " + dictKey);
		}

		dirs = Directory.GetDirectories (assetRoot);
		foreach (string dir in dirs) {
			dictKey = dir.Substring (assetRoot.Length).ToLower ();
			if (remDirs.Contains (dictKey)) {
				Directory.Delete (dir, true);
				UnityEngine.Debug.Log ("rootDir : " + dir);
			}
			else
				UnityEngine.Debug.Log ("rootDir : " + dictKey);
		}
	}

	[MenuItem("Packager/CheckMissing")]
	public static void CheckMissing() {
		string dataPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);

		List<string> fileList = new List<string> ();
		if (SearchFiles (Application.dataPath + "/Game", "*.prefab", true, ref fileList) <= 0)
			return;

		UnityEngine.Debug.Log ("CheckPrefabCount:" + fileList.Count);

		string fileName = string.Empty;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			fileName = fileList [idx].Replace (dataPath, string.Empty);
			GameObject go = AssetDatabase.LoadAssetAtPath<GameObject> (fileName);
			if (go == null) {
				UnityEngine.Debug.LogError ("[AssetBundle] CheckMissing failed. can't load prefab: " + fileName);
				continue;
			}

			Component[] components = go.GetComponents<Component> ();
			foreach (Component component in components) {
				if (component == null)
					UnityEngine.Debug.LogError ("Missing Component:" + FullObjectPath (go));
				else {
					SerializedObject so = new SerializedObject (component);
					SerializedProperty sp = so.GetIterator ();
					while (sp.NextVisible (true)) {
						if (sp.propertyType != SerializedPropertyType.ObjectReference)
							continue;
						if (sp.objectReferenceValue == null && sp.objectReferenceInstanceIDValue != 0)
							ShowError(FullObjectPath(go), sp.name);
					}
				}
			}

		}
	}
	private static void ShowError(string objectName, string propertyName)
	{
		UnityEngine.Debug.LogError("Missing reference found in: " + objectName + ", Property : " + propertyName);
	}
	private static string FullObjectPath(GameObject go)
	{
		return go.transform.parent == null ? go.name : FullObjectPath(go.transform.parent.gameObject) + "/" + go.name;
	}

	[MenuItem("Packager/FindReference _F4")]
	public static void FindReference() {
		string dataPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string rootDir = Application.dataPath + "/Game/";
		string dirName = string.Empty, fileName = string.Empty;

		if (Selection.activeObject == null)
			return;
		
		string findIdent = AssetDatabase.GetAssetPath (Selection.activeObject).ToLower();
		findIdent = Path.GetFileName (findIdent);

		List<string> fileList = new List<string> ();
		if (SearchFiles (rootDir, "*.prefab", true, ref fileList) <= 0)
			return;
		
		for (int idx = 0; idx < fileList.Count; ++idx) {
			fileName = fileList [idx].Replace (dataPath, string.Empty);

			GameObject go = AssetDatabase.LoadAssetAtPath<GameObject> (fileName);
			if (go == null) {
				UnityEngine.Debug.LogError ("[AssetBundle] FindReference failed. can't load prefab: " + fileName);
				continue;
			}

			UnityEngine.Object[] depends = EditorUtility.CollectDependencies(new UnityEngine.Object[]{go});
			foreach (UnityEngine.Object depend in depends) {
				string fullName = AssetDatabase.GetAssetPath (depend).ToLower ();
				if (fullName.EndsWith (findIdent)) {
					UnityEngine.Debug.Log (depend.name + ":" + fileName);
				}
			}
		}
	}



	static string[] ISOLATE_TBL = new string[] {"loadingpanel/"};
	private static bool AdaptIsolate(string key, out string value) {
		value = string.Empty;
		for (int idx = 0; idx < ISOLATE_TBL.Length; ++idx) {
			if (key.StartsWith (ISOLATE_TBL [idx])) {
				value = ISOLATE_TBL [idx];
				return true;
			}
		}
		return false;
	}

	static string[] SHARE_TBL = new string[] {"common/", "framework/", "sproto/", "loadingpanel/", "commonprefab/", "game_hall/"};
	private static bool AdaptShare(string key, out string value) {
		value = string.Empty;
		for (int idx = 0; idx < SHARE_TBL.Length; ++idx) {
			if (key.StartsWith (SHARE_TBL [idx])) {
				value = SHARE_TBL [idx];
				return true;
			}
		}

		string channelTag = AppDefine.CurQuDao + "/";
		if (key.StartsWith (channelTag)) {
			value = channelTag;
			return true;
		}

		return false;
	}

	static string[] PAIR_TBL = new string[] {"game_ddz", "normal_ddz_common/", "game_mj", "normal_mj_common/", "game_fishing", "normal_fishing_common/", "game_eliminate", "normal_xxl_common/"};
	private static bool AdaptPair(string key, string value) {
		int index = 0;
		for (int idx = 0; idx < PAIR_TBL.Length / 2; ++idx) {
			index = idx * 2;
			if (!key.StartsWith (PAIR_TBL [index]))
				continue;
			if (value.StartsWith (PAIR_TBL [index + 1]))
				return true;
		}

		return false;
	}

	private static bool IsStartWith(string[] tbl, string key)
	{
		foreach(string it in tbl)
		{
			if (key.StartsWith(it))
				return true;
		}
		return false;
	}

	private static void CheckAssetBundle(AssetBundleManifest manifest, string bundleName, ref List<string> dependList) {
		dependList.Clear ();

		string[] dependencies = manifest.GetAllDependencies(bundleName);
		if (dependencies.Length <= 0)
			return;

		string adapt_value = string.Empty;
		string share_value = string.Empty;

		if (AdaptIsolate (bundleName, out adapt_value)) {
			foreach (string dependency in dependencies) {
				if (dependency.StartsWith (adapt_value))
					continue;
				
				if (AdaptShare (dependency, out share_value))
					continue;

				dependList.Add (dependency);
				//UnityEngine.Debug.Log ("[ISOLATE] " + bundleName + " -- outrange --> " + dependency);
			}

			return;
		}

		if (AdaptShare (bundleName, out share_value)) {
			foreach (string dependency in dependencies) {
				if (AdaptShare (dependency, out adapt_value))
					continue;

				dependList.Add (dependency);
				//UnityEngine.Debug.Log ("[SHARE] " + bundleName + " -- outrange --> " + dependency);
			}

			return;
		}

		{
			int idx = bundleName.IndexOf ('/');
			if (idx <= 0)
				adapt_value = Path.GetFileNameWithoutExtension (bundleName);
			else
				adapt_value = bundleName.Substring (0, idx + 1);
			foreach (string dependency in dependencies) {
				if (AdaptShare (dependency, out share_value))
					continue;

				if (dependency.StartsWith (adapt_value))
					continue;

				if (AdaptPair (adapt_value, dependency))
					continue;

				dependList.Add (dependency);
				//UnityEngine.Debug.Log ("[NORMAL] " + bundleName + " -- outrange --> " + dependency);
			}
		}
	}

	private static void ParseManifestValue(string[] lines, int offset, ref List<string> values) {
		int idx = offset;
		string line = string.Empty;
		while (idx < lines.Length) {
			line = lines [idx++];
			if (line.StartsWith ("- "))
				values.Add (line.Substring(2));
			else
				break;
		}
	}
	private static void ParseManifestKey(string[] lines, string key, ref List<string> values, bool revert) {
		if (revert) {
			for (int idx = lines.Length - 1; idx >= 0; --idx) {
				if (lines [idx].StartsWith (key)) {
					ParseManifestValue (lines, idx + 1, ref values);
					break;
				}
			}
		} else {
			for (int idx = 0; idx < lines.Length; ++idx) {
				if (lines [idx].StartsWith (key)) {
					ParseManifestValue (lines, idx + 1, ref values);
					break;
				}
			}
		}
	}
	const string GUID_KEY = "guid: ";
	private static void CollectGUID(string[] lines, ref HashSet<string> values) {
		int index = 0;
		for (int idx = 0; idx < lines.Length; ++idx) {
			index = lines [idx].IndexOf (GUID_KEY);
			if (index >= 0)
				values.Add (lines [idx].Substring (index + GUID_KEY.Length, 32));
		}
	}

	const string MANIFEST_SUFFIX = ".manifest";
	private static void BatchConvertGUID(string[] bundles, ref Dictionary<string, HashSet<string>> guidsMap, ref HashSet<string> guids) {
		string streamingDir = Application.streamingAssetsPath + "/";
		string fileName = string.Empty;
		List<string> assets = new List<string> ();
		HashSet<string> guidSet;

		for (int idx = 0; idx < bundles.Length; ++idx) {
			if (!guidsMap.TryGetValue (bundles [idx], out guidSet)) {
				fileName = streamingDir + bundles [idx] + MANIFEST_SUFFIX;

				assets.Clear ();
				ParseManifestKey (File.ReadAllLines (fileName), "Assets:", ref assets, true);

				guidSet = new HashSet<string> ();
				for (int jdx = 0; jdx < assets.Count; ++jdx)
					guidSet.Add (AssetDatabase.AssetPathToGUID (assets [jdx]));
				guidsMap.Add (bundles [idx], guidSet);
			}

			guids.UnionWith (guidSet);
		}
	}

	private static void AnalyseAssetBundle(string key, string[] values, ref Dictionary<string, HashSet<string>> guidsMap, ref Dictionary<string, string[]> traceMap) {
		string dataDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string streamingDir = Application.streamingAssetsPath + "/";

		string manifestFile = streamingDir + key + MANIFEST_SUFFIX;
		string[] lines = File.ReadAllLines (manifestFile);
		if (lines == null || lines.Length <= 0)
			return;

		List<string> assets = new List<string> ();
		ParseManifestKey (lines, "Assets:", ref assets, true);

		List<string> objects = new List<string> ();
		for (int idx = 0; idx < assets.Count; ++idx) {
			if (assets [idx].EndsWith (".prefab") || assets [idx].EndsWith (".mat") || assets [idx].EndsWith (".unity"))
				objects.Add (assets [idx]);
		}
		if (objects.Count <= 0)
			return;

		HashSet<string> dependGuids = new HashSet<string> ();
		BatchConvertGUID (values, ref guidsMap, ref dependGuids);

		HashSet<string> guidTbl = new HashSet<string> ();
		for (int idx = 0; idx < objects.Count; ++idx) {
			guidTbl.Clear ();
			CollectGUID (File.ReadAllLines (dataDir + objects [idx]), ref guidTbl);
			guidTbl.IntersectWith (dependGuids);

			if (guidTbl.Count > 0) {
				traceMap.Add (objects [idx], guidTbl.ToArray());
			}
		}
	}

	private static void AutoAdjustAssets(Dictionary<string, string[]> traceMap) {
		if (traceMap.Count <= 0)
			return;
		
		Dictionary<string, int> levelMap = new Dictionary<string, int> ();

		string fileName = string.Empty;
		string memberName = string.Empty;
		int memberLevel = 0;
		foreach (KeyValuePair<string, string[]> kv in traceMap) {
			fileName = kv.Key;
			for (int idx = 0; idx < kv.Value.Length; ++idx) {
				memberName = kv.Value [idx];
				memberLevel = 0;

				if (AdaptPair (fileName, memberName)) {
				}

			}


		}
	}

	[MenuItem("Packager/CheckAssetBundles")]
	public static void CheckAssetBundles() {
		string manifestFile = Application.streamingAssetsPath + "/" + "StreamingAssets";

		AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestFile);
		if (assetBundle == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] CheckAssetBundle failed: load StreamingAssets failed");
			return;
		}
		AssetBundleManifest manifest = assetBundle.LoadAsset<AssetBundleManifest> ("AssetBundleManifest");
		assetBundle.Unload (false);

		string configFile = GetBuildConfigFileName(BuildTarget.Android);
		if (!File.Exists(configFile))
		{
			UnityEngine.Debug.LogError("[AssetBundle] CheckAssetBundle failed. ConfigFile not exist");
			return;
		}

		string content = File.ReadAllText(configFile);
		if (string.IsNullOrEmpty(content))
		{
			UnityEngine.Debug.LogError("[AssetBundle] CheckAssetBundle failed. ConfigFile is empty.");
			return;
		}

		BuildConfig buildCfg = JsonUtility.FromJson<BuildConfig>(content);
		if (buildCfg == null)
		{
			UnityEngine.Debug.LogError("[AssetBundle] CheckAssetBundle failed. ParseJson failed.");
			return;
		}

		Dictionary<string, string[]> exceptionMap = new Dictionary<string, string[]>();
		StringBuilder sb = new StringBuilder();
		for (int idx = 0; idx < buildCfg.options.Count; ++idx)
		{
			CheckAssetBundle(manifest, buildCfg.options[idx], ref exceptionMap);
			if (exceptionMap.Count <= 0)
				continue;

			UnityEngine.Debug.Log("<============================================================>");

			sb.Clear();
			sb.AppendLine("\t" + buildCfg.options[idx].rootDir + ":");
			foreach (KeyValuePair<string, string[]> kv in exceptionMap)
			{
				sb.AppendLine("\t\t" + kv.Key + ":");
				foreach(string it in kv.Value)
					sb.AppendLine("\t\t\t" + it);
			}
			UnityEngine.Debug.Log(sb.ToString());
		}
	}

	private static void CheckAssetBundle(AssetBundleManifest manifest, BundleOption option, ref Dictionary<string, string[]> exceptionMap)
	{
		exceptionMap.Clear();

		List<string> rootDirs = new List<string>();
		rootDirs.Add(option.rootDir.ToLower());
		foreach (string depend in option.dependList)
			rootDirs.Add(depend.ToLower());
		string[] rootDirArray = rootDirs.ToArray();

		string baseDir = Application.streamingAssetsPath + "/";
		string baseName = string.Empty;
		string baseValue = string.Empty;
		List<string> fileList = new List<string>();
		foreach (string dir in rootDirs)
		{
			if (SearchFiles(baseDir + dir, "*" + AppConst.ExtName, true, ref fileList) <= 0)
				continue;

			foreach(string bundleName in fileList)
			{
				baseName = bundleName.Substring(baseDir.Length);
				string[] dependList = manifest.GetAllDependencies(baseName);
				if (dependList.Length <= 0) continue;

				List<string> newList = new List<string>();
				foreach(string depend in dependList)
				{
					if (depend.StartsWith("activity/"))
						continue;

					if (IsStartWith(SHARE_TBL, depend))
						continue;

					if (IsStartWith(rootDirArray, depend))
						continue;

					newList.Add(depend);
				}
				if (newList.Count > 0)
					exceptionMap.Add(baseName, newList.ToArray());
			}

			fileList.Clear();
		}
	}

	[MenuItem("Packager/ListAssetBundle")]
	public static void ListAssetBundle() {
		string fileName = UnityEditor.EditorUtility.OpenFilePanelWithFilters ("Select AssetBundle", Application.streamingAssetsPath, new string[]{"unity3d", "unity3d"});
		string manifestFile = Application.streamingAssetsPath + "/" + "StreamingAssets";

		AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestFile);
		if (assetBundle == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] ListAssetBundle failed: load StreamingAssets failed");
			return;
		}
		AssetBundleManifest manifest = assetBundle.LoadAsset<AssetBundleManifest> ("AssetBundleManifest");
		assetBundle.Unload (false);

		assetBundle = AssetBundle.LoadFromFile (fileName);
		if (assetBundle == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] ListAssetBundle failed: load assetbundle failed " + fileName);
			return;
		}

		UnityEngine.Debug.Log ("Count:" + assetBundle.GetAllAssetNames().Length);
		foreach (string item in assetBundle.GetAllAssetNames())
			UnityEngine.Debug.Log ("\t" + item);

		assetBundle.Unload (true);
	}

	private static bool InsertGCCode(string fileName)
	{
		if (!File.Exists (fileName)) {
			UnityEngine.Debug.Log (string.Format ("InsertGCCode({0}) failed. file not exit!", fileName));
			return false;
		}

		string context = File.ReadAllText (fileName);
		if (string.IsNullOrEmpty (context)) {
			UnityEngine.Debug.Log (string.Format ("InsertGCCode({0}) failed. file is empty!", fileName));
			return false;
		}

		Regex headRgx = new Regex ("function [ A-Za-z0-9]+:MyExit()");
		MatchCollection headMC = headRgx.Matches (context);
		if (headMC.Count != 1) {
			UnityEngine.Debug.Log (string.Format ("InsertGCCode({0}) failed. mc count = {1}!", fileName, headMC.Count));
			return false;
		}

		Regex tailRgx = new Regex ("\\nend");
		Match tailMC = tailRgx.Match (context, headMC [0].Index);

		int startIdx = headMC [0].Index;
		int endIdx = tailMC.Index + tailMC.Length;

		int insertIdx = tailMC.Index;
		string headContext = context.Substring (0, insertIdx);
		string endContext = context.Substring (insertIdx);
		File.WriteAllText (fileName, headContext + "\n\n\tUtil.ClearMemory()" + endContext, new UTF8Encoding(false));

		return true;
	}

	//[MenuItem("Packager/CheckLuaPrefabPanel")]
	public static void CheckLuaPrefabPanel() {
		string dataPath = Application.dataPath.Substring(0, Application.dataPath.Length - 6);

		List<string> fileList = new List<string>();
		SearchFiles(Application.dataPath + "/Game", "*.prefab", true, ref fileList);
		SearchFiles(Application.dataPath + "/Channel", "*.prefab", true, ref fileList);

		string fileName = string.Empty;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			fileName = fileList [idx].Replace (dataPath, string.Empty);
			if (!fileName.EndsWith ("panel.prefab", StringComparison.OrdinalIgnoreCase))
				continue;
			
			GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(fileName);
			if (go == null)
			{
				UnityEngine.Debug.LogError("[AssetBundle] CheckLuaPrefabPanel failed. can't load prefab: " + fileName);
				continue;
			}

			if (go.GetComponent<LuaBehaviour> ())
				continue;
		}
        AssetDatabase.SaveAssets();
	}

	public static void SetAppIcon(string iconName, BuildTarget buildTarget) {
		if (buildTarget == BuildTarget.iOS) {
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Application);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Spotlight);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Settings);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Notification);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Marketing);
		} else if (buildTarget == BuildTarget.Android) {
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Adaptive, 0);
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Adaptive, 1);
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Round);
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Legacy);
		}
	}

	private static Texture2D[] GetIcons(string iconName, BuildTargetGroup target, PlatformIconKind iconKind, PlatformIcon[] icons, int layer) {
		if (Path.HasExtension(iconName))
			iconName = Path.GetFileNameWithoutExtension(iconName);

		Texture2D[] textures = new Texture2D[icons.Length];
		string folder = iconKind.ToString ().Split (' ') [0];
		string filename;
		for (int idx = 0; idx < textures.Length; ++idx) {
			int iconSize = icons [idx].width;
			filename = string.Format("Assets/AppIcons/{0}_{1}_{2}.png", iconName, iconSize, layer);
			textures [idx] = AssetDatabase.LoadAssetAtPath<Texture2D> (filename);
		}
		return textures;
	}
	private static void SetIcons(string iconName, BuildTargetGroup target, PlatformIconKind iconKind, int layer = 0) {
		string defaultIconName = iconName;
		if (!Path.HasExtension(defaultIconName))
			defaultIconName += ".png";
		Texture2D defaultTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/AppIcons/" + defaultIconName);

		PlatformIcon[] icons = PlayerSettings.GetPlatformIcons(target, iconKind);
		Texture2D[] textures = GetIcons(iconName, target, iconKind, icons, layer);

		for (int idx = 0; idx < icons.Length; ++idx)
		{
			if (textures[idx] == null)
				icons[idx].SetTexture(defaultTexture, layer);
			else
				icons[idx].SetTexture(textures[idx], layer);
		}

		PlayerSettings.SetPlatformIcons (target, iconKind, icons);
	}

	private static string MakeBundleName(string bundleName, string[] childs) {
		for (int idx = 0; idx < childs.Length - 1; ++idx)
			bundleName += "_" + childs [idx];
		return bundleName;
	}
	#endregion
}
