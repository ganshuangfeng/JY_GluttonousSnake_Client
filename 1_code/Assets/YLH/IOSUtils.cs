using System;
using System.Runtime.InteropServices;

public class IOSUtils
{
    public static void ShowView(IntPtr view)
    {
    	#if UNITY_IPHONE && !UNITY_EDITOR
        GDT_UnionPlatform_Ad_ShowAdView(view);
        #endif
    }
    
	#if UNITY_IPHONE && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern void GDT_UnionPlatform_Ad_ShowAdView(IntPtr adView);
    #endif
}