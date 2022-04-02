using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TalkingDataManager : Manager
{
    private TDGAProfile profile;
    public void Init(string login_id,string cur_channel)
    {
        
        TalkingDataGA.BackgroundSessionEnabled();
        TalkingDataGA.OnStart("063B2F04C97F4CC9AEBF52708F54B4D4", cur_channel);
        profile = TDGAProfile.SetProfile("User" + login_id);
#if TDGA_PUSH
#if UNITY_IPHONE
        UnityEngine.iOS.NotificationServices.RegisterForNotifications(
            UnityEngine.iOS.NotificationType.Alert |
            UnityEngine.iOS.NotificationType.Badge |
            UnityEngine.iOS.NotificationType.Sound);
#endif
#endif
    }

    public string GetDeviceId()
    {
        return TalkingDataGA.GetDeviceId();
    } 

    //获取安卓机匿名id
    public string GetOAID()
    {
        return TalkingDataGA.GetOAID();
    }
    //设置玩家昵称
    public void SetProfileName(string name)
    {
        profile.SetProfileName(name);
    }

    //设置玩家类型
    public void SetProfileType(int profileType)
    {
        profile.SetProfileType((ProfileType)profileType);
    }

    //设置玩家等级
    public void SetLevel(int level)
    {
        profile.SetLevel(level);
    }

    //设置性别
    public void SetGender(int gender)
    {
        profile.SetGender((Gender)gender);
    }

    //设置年龄
    public void SetAge(int age)
    {
        profile.SetAge(age);
    }

    //设置区服
    public void SetGameServer(string serverName)
    {
        profile.SetGameServer(serverName);
    } 

    //开始任务(用于记录关卡等)
    public void BeginMission(string missionName)
    {
        TDGAMission.OnBegin(missionName);
    }

    //任务完成
    public void CompleteMission(string missionName)
    {
        TDGAMission.OnCompleted(missionName);
    }

    //任务失败(可传入失败原因)
    public void FailedMission(string missionName,string failedCause)
    {
        TDGAMission.OnFailed(missionName,failedCause);
    }

    /*
    orderId : 订单号
    iapId : 接入点id
    currencyAmount : 货币面值
    currencyType : 货币类型（人民币 美元）
    virtualCurrencyAmount : 虚拟货币价值
    paymentType ：支付方式
    */
    public void OnChargeRequest(string orderId, string iapId, double currencyAmount, string currencyType, double virtualCurrencyAmount, string paymentType)
    {
        TDGAVirtualCurrency.OnChargeRequest(orderId, iapId, currencyAmount, currencyType, virtualCurrencyAmount, paymentType);
    }

    //支付成功
    public void OnChargeSuccess(string orderId)
    {
        TDGAVirtualCurrency.OnChargeSuccess(orderId);
    }

    //奖励虚拟货币
    public void OnReward(double virtualCurrencyAmount,string reason)
    {
        TDGAVirtualCurrency.OnReward(virtualCurrencyAmount,reason);
    }

    //购买
    public void OnPurchase(string item,int itemNumber,double priceInVirtualCurrency)
    {
        TDGAItem.OnPurchase(item, itemNumber,priceInVirtualCurrency);
    }

    public void OnUse(string item,int itemNumber)
    {
        TDGAItem.OnUse(item,itemNumber);
    }

    //设置localtion（用途不明）
    public void SetLocation(double latitude, double longitude)
    {
        TalkingDataGA.SetLocation(latitude, longitude);
    }
}
