;//
//  ZYBleWifiData.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/6/6.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleWifiData.h"
#import "ZYMessageTool.h"
#include "ParamDef.h"
#import "ZYDeviceManager.h"
#import "SPCCommandDefine.h"

using namespace zy::SportCamera;

@interface ZYBleWifiData()

@property (copy, nonatomic) NSDictionary *readModeDic;

@end
@implementation ZYBleWifiData

-(void)setSsid:(NSString *)ssid{
    _ssid = [ssid copy];
    NSLog(@"ssid = %@",ssid);
    [[NSNotificationCenter defaultCenter] postNotificationName:GPRWIFISSIDChange object:_ssid];
}

/*!
 更新参数
 
 @param allParamData ZYBlWiFiPhotoAllParamData 对象
 */
-(void)updateValueWithZYBlWiFiPhotoAllParamData:(ZYBlWiFiPhotoAllParamData *)allParamData{
    if (allParamData) {
        
        
        self.shutting = allParamData.Other_Processing_status;
        self.SDStatus = allParamData.Other_SD_card;
        self.SDEnough = allParamData.Other_Available_Space;
        self.battery  = (BatteryLevel)allParamData.Other_Battery_Level;
        self.batteryAvaliable = allParamData.Other_Internal_Battery;
        self.lcdSleep = (LCDSleep)allParamData.Other_LCD_Sleep;
        self.launchMainMode = (DefaultLaunchMainMode)allParamData.Other_Default_Boot_Mode;
        self.videoFormater = (VideoFormater)allParamData.Other_Video_Format;
        self.autoPowerOff = (AutoPowerOff)allParamData.Other_Auto_Power_Off;
        self.MultiShot_Capture_Rate = allParamData.MultiShot_Capture_Rate;
        self.Photo_Delay_Interval = allParamData.Photo_Delay_Interval;
        
        /////////////////
        _Video_Resolution = allParamData.Video_Resolution;
        _Video_Frame_Rate = allParamData.Video_Frame_Rate;
        _Video_FOV = allParamData.Video_FOV;
        _Video_AE = allParamData.Video_AE;
        _Video_White_Balance = allParamData.Video_White_Balance;
        _Video_ISO_Max = allParamData.Video_ISO_Max;
        _Video_ISO_Min = allParamData.Video_ISO_Min;
        _Video_ISO_limit = allParamData.Video_ISO_limit;
        _Video_AdvanceMode = allParamData.Video_AdvanceMode;
        _Video_Interval = allParamData.Video_Interval;
        _Video_Loop_Interval = allParamData.Video_Loop_Interval;
        _Video_Timelapse_Interval = allParamData.Video_Timelapse_Interval;
        _Video_Shutter = allParamData.Video_Shutter;
        _Video_Sub_Mode = allParamData.Video_Sub_Mode;
        
        _Photo_Fov = allParamData.Photo_Fov;
        _Photo_AE = allParamData.Photo_AE;
        _Photo_White_Balance = allParamData.Photo_White_Balance;
        _Photo_ISO_Max = allParamData.Photo_ISO_Max;
        _Photo_ISO_Min = allParamData.Photo_ISO_Min;
        _Photo_AdvanceMode = allParamData.Photo_AdvanceMode;
        _Photo_Shutter = allParamData.Photo_Shutter;
        _Photo_Night_Shutter = allParamData.Photo_Night_Shutter;
        _Photo_Sub_Mode = allParamData.Photo_Sub_Mode;
        
        _MultiShot_Fov = allParamData.MultiShot_Fov;
        _MultiShot_AE = allParamData.MultiShot_AE;
        _MultiShot_White_Balance = allParamData.MultiShot_White_Balance;
        _MultiShot_ISO_Max = allParamData.MultiShot_ISO_Max;
        _MultiShot_ISO_Min = allParamData.MultiShot_ISO_Min;
        _MultiShot_Interval = allParamData.MultiShot_Interval;
        _MultiShot_AdvanceMode = allParamData.MultiShot_AdvanceMode;
        _MultiShot_Shutter = allParamData.MultiShot_Shutter;
        _MultiShot_Sub_Mode = allParamData.MultiShot_Sub_Mode;
        _Other_RecordOrPhoto = allParamData.Other_RecordOrPhoto;
        
        self.Other_Current_Main_Mode = allParamData.Other_Current_Main_Mode;
        self.Other_Current_Sub_Mode = allParamData.Other_Current_Sub_Mode;
        
        // 第一次连接 - 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:GPRFirstConnected object:nil];
//        NSLog(@"%@",self);
    }
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goProChange:) name:Device_State_Event_Notification_ResourceData object:nil];
    }
    return self;
}

-(void)goProChange:(NSNotification *)noti{
    NSString *type = noti.userInfo[@"type"];
    if ( ![type isEqualToString:@"ZYBlWiFiPhotoNoticeData"] ) return;
    NSDictionary *dic = noti.userInfo[@"Data"];
    NSLog(@"接收到: %@-%@",dic[@"paramId"],dic[@"paramValue"]);
    //    return;
    if (dic) {
        NSNumber *code = dic[@"paramId"];
        NSNumber *value = dic[@"paramValue"];
        NSInteger queryCode = code.integerValue;
        NSInteger queryValue = value.integerValue;
        if (code && value) {

            [self setCode:queryCode value:queryValue];
        }
    }
}

- (void)setCode:(NSInteger)code value:(NSInteger)value {
    NSInteger queryCode = code, queryValue = value;
    if (queryCode == SPCCatagoryQueryCode_videoResolution) self.Video_Resolution = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoFrameRate) self.Video_Frame_Rate = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoFOV) self.Video_FOV = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoEVComp) self.Video_AE = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoWhiteBlance) self.Video_White_Balance = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoISOMax) self.Video_ISO_Max = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoISOMin) self.Video_ISO_Min = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoISOLimit) self.Video_ISO_limit = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoInterval) self.Video_Interval = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoLoopingInterval) self.Video_Loop_Interval = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoTimelapseInterval) self.Video_Timelapse_Interval = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_videoManualExposure ) self.Video_Shutter = queryValue;
    
    else if (queryCode == SPCCatagoryQueryCode_photoFOV) self.Photo_Fov = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_photoEVComp) self.Photo_AE = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_photoWhiteBlance) self.Photo_White_Balance = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_photoISOMax) self.Photo_ISO_Max = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_photoISOMin) self.Photo_ISO_Min = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_photoShutterAuto) self.Photo_Shutter = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_photoNightExposure) self.Photo_Night_Shutter = queryValue;
    
    else if (queryCode == SPCCatagoryQueryCode_multiFOV) self.MultiShot_Fov = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiEVComp) self.MultiShot_AE = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiWhiteBlance) self.MultiShot_White_Balance = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiISOMax) self.MultiShot_ISO_Max = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiISOMin) self.MultiShot_ISO_Min = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiShutter) self.MultiShot_Shutter= queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiNightLapseInterval) self.MultiShot_Interval = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiContinuousShootRate) self.MultiShot_Capture_Rate = queryValue;
    else if (queryCode == SPCCatagoryQueryCode_multiShotInterval) self.Photo_Delay_Interval = queryValue;
    
    else if (queryCode == WiFiInquireCodeMainMode) self.Other_Current_Main_Mode = queryValue;
    else if (queryCode == WiFiInquireCodeSubMode) self.Other_Current_Sub_Mode = queryValue;
    else if (queryCode == WiFiInquireCodeShutting) self.shutting = queryValue;
    else if (queryCode == WiFiInquireCodeSDStatus) self.SDStatus = queryValue;
    else if (queryCode == WiFiInquireCodeSDEnough) self.SDEnough = queryValue;
    else if (queryCode == WiFiInquireCodeBatteryLevel) self.battery = (BatteryLevel)queryValue;
    else if (queryCode == WiFiInquireCodeBatteryAvaliable) self.batteryAvaliable = queryValue;
    else if (queryCode == WiFiInquireCodeLCDSleep) self.lcdSleep = (LCDSleep)queryValue;
    else if (queryCode == WiFiInquireCodeLaunchMainMode) self.launchMainMode = (DefaultLaunchMainMode)queryValue;
    else if (queryCode == WiFiInquireCodeVideoFormater) self.videoFormater = (VideoFormater)queryValue;
    else if (queryCode == WiFiInquireCodeAutoPowerOff) self.autoPowerOff = (AutoPowerOff)queryValue;
    else if (queryCode == WiFiInquireCodeMaxPhotoCount) self.remainderMaxPhotoCount = queryValue;
    else if (queryCode == WiFiInquireCodeMaxVideoSecs) self.remainderMaxVideoSecs = queryValue;
    else if (queryCode == WiFiInquireCodeShootOrRecord) self.Other_RecordOrPhoto = queryValue;
    else {
        SPCLog(@"未处理的 code : %zd",queryCode);
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:GPRParameterChange object:nil userInfo:@{@(queryCode):@(queryValue)}];
}

- (void)setOther_Current_Sub_Mode:(NSUInteger)Other_Current_Sub_Mode {
    _Other_Current_Sub_Mode = Other_Current_Sub_Mode;
    [self p_gainWiFiMode];
}
- (void)setOther_Current_Main_Mode:(NSUInteger)Other_Current_Main_Mode {
    // 进入相册
    if (Other_Current_Main_Mode < 4) {
        _Other_Current_Main_Mode = Other_Current_Main_Mode;
        [[NSNotificationCenter defaultCenter] postNotificationName:GPRModeChange object:nil];
    } else if (Other_Current_Main_Mode == 4) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GPRIntoAlbum object:nil];
    }
    [self p_gainWiFiMode];
}

- (void)p_gainWiFiMode {
    
    NSDictionary *modeDic = self.readModeDic;
    NSString *code = [NSString stringWithFormat:@"%zd-%zd",_Other_Current_Main_Mode,_Other_Current_Sub_Mode];
//    NSLog(@"mode == %@",code);
    // 出现子模式跟子模式还没变过来的情况,如 03 -> 11中途先收到主模式通知1 03 -> 13 -> 11, 出现13时返回
    if (![modeDic.allKeys containsObject:code]) return;
    
    WiFiMode newMode = (WiFiMode)[modeDic[code] integerValue];
    _wifiMode = newMode;
    SPCLog(@"-- mode - %@",code);
}


- (NSString *)gainNameFromCatagoryName:(NSString *)catagory {
    return @"xxx";
}

-(void)dealloc{
#ifdef DEBUG
    
    NSLog(@"dealloc %@=%@",self,[self class]);
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - lazy load

- (NSDictionary *)readModeDic {
    if (!_readModeDic) {
        _readModeDic = @{WiFiModeInquireCommandVideo:@(WiFiModeVideo),
                         WiFiModeInquireCommandDelayRecording:@(WiFiModeDelayRecording),
                         WiFiModeInquireCommandVideoPhoto:@(WiFiModeVideoPhoto),
                         WiFiModeInquireCommandVideoLoop:@(WiFiModeVideoLoop),
                         WiFiModeInquireCommandPhoto:@(WiFiModePhoto),
                         WiFiModeInquireCommandPhotoNight:@(WiFiModePhotoNight),
                         WiFiModeInquireCommandPhotoContinuous:@(WiFiModePhotoContinuous),
                         WiFiModeInquireCommandDelayShoot:@(WiFiModeDelayShoot),
                         WiFiModeInquireCommandDelayNight:@(WiFiModeDelayNight)};
    }
    return _readModeDic;
}

@end
