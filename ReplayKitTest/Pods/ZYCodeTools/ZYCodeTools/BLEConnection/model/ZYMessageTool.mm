//
//  ZYMessageTool.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYMessageTool.h"
#import "SportCameraParamTools.h"
#import "ParamDef.h"

#import "ZYGOPROData.h"
using namespace zy::SportCamera;

@implementation SportCameraParamModel
@end

const NSUInteger workingMode_Video = Item_Current_Mode_Get_Value_Video;
const NSUInteger workingMode_Photo = Item_Current_Mode_Get_Value_Photo;
const NSUInteger workingMode_MultiShot = Item_Current_Mode_Get_Value_MultiShot;

@interface ZYMessageTool()
@property(nonatomic, readwrite, strong) NSArray<SportCameraParamModel*>* sportCameraParamInfoArray;
@property(nonatomic, readwrite, strong) NSDictionary* nameMappingDict;




@end

@implementation ZYMessageTool

static ZYMessageTool *_defaultTool = NULL;
+ (ZYMessageTool *)defaultTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTool = [[ZYMessageTool alloc] init];
//        zy::SportCameraParamTools::instance();
        _defaultTool->_goProData = [ZYGOPROData new];
        
    });
    return _defaultTool;
}

-(instancetype) init
{
    if ([super init]) {
        self.nameMappingDict = @{
                                 @(supportMode_Video):@{
                                         @"SubMode":@"Video_para_Sub_Mode",
                                         @(Catagory_Video_Resolution):@"Video_Resolution",
                                         @(Catagory_Frame_Rate):@"Frame_Rate",
                                         @(Catagory_FOV_video):@"FOV_video",
                                         @(Catagory_TimeLapse_Interval):@"Video_para_TimeLapse_Interval",
                                         @(Catagory_Looping_Interval):@"Looping_Interval",
                                         @(Catagory_Video_Interval):@"Video_Interval",
                                         @(Catagory_Low_Light):@"Low_Light",
                                         @(Catagory_Spot_Meter):@"Video_para_Spot_MeterPhoto_para_Spot_Meter",
                                         @(Catagory_Protune):@"Video_para_Protune",
                                         @(Catagory_White_Balance):@"Video_para_White_Balance",
                                         @(Catagory_Color):@"Video_para_Color",
                                         @(Catagory_Manual_Exposure):@"Manual_Exposure",
                                         @(Catagory_ISO_Mode):@"ISO_Mode",
                                         @(Catagory_ISO_Limit):@"Video_para_ISO_Limit",
                                         },
                                 @(supportMode_Photo):@{
                                         @(Catagory_FOV_video):@"FOV_video",
                                         @"SubMode":@"Photo_para_Sub_Mode",
                                         //@(Catagory_Megapixels):@"Photo_para_Megapixels",
                                         @(Catagory_Continuous_Rate):@"Continuous_Rate",
                                         @(Catagory_Shutter):@"Shutter",
                                         @(Catagory_Spot_Meter):@"Photo_para_Spot_Meter",
                                         @(Catagory_Protune):@"Photo_para_Protune",
                                         @(Catagory_White_Balance):@"Photo_para_White_Balance",
                                         @(Catagory_Color):@"Photo_para_Color",
                                         @(Catagory_Sharpness):@"Photo_para_Sharpness",
                                         @(Catagory_EV_Comp):@"Photo_para_EV_Comp",
                                         @(Catagory_ISO_Min):@"Photo_para_ISO_Min",
                                         @(Catagory_ISO_Limit):@"Photo_para_ISO_Limit",
                                         },
                                 @(supportMode_MultiShot):@{
                                         @(Catagory_FOV_video):@"FOV_video",
                                         @"SubMode":@"MultiShot_para_Sub_Mode",
                                         @(Catagory_Shutter_Exposure):@"Shutter_Exposure",
                                         //@(Catagory_Megapixels):@"MultiShot_para_Megapixels",
                                         @(Catagory_Burst_Rate):@"Burst_Rate",
                                         @(Catagory_TimeLapse_Interval):@"MultiShot_para_TimeLapse_Interval",
                                         @(Catagory_Spot_Meter):@"MultiShot_para_Spot_Meter",
                                         @(Catagory_Protune):@"MultiShot_para_Protune",
                                         @(Catagory_White_Balance):@"MultiShot_para_White_Balance",
                                         @(Catagory_Color):@"MultiShot_para_Color",
                                         @(Catagory_NightLapse_Interval):@"NightLapse_Interval",
                                         @(Catagory_Sharpness):@"MultiShot_para_Sharpness",
                                         @(Catagory_EV_Comp):@"MultiShot_para_EV_Comp",
                                         @(Catagory_ISO_Min):@"MultiShot_para_ISO_Min",
                                         @(Catagory_ISO_Limit):@"MultiShot_para_ISO_Limit",
                                         },
                                 @(supportMode_Other):@{
                                         @(Catagory_LCD_Display):@"LCD_Display",
                                         @(Catagory_Orientation):@"Orientation",
                                         @(Catagory_Default_Boot_Mode):@"Default_Boot_Mode",
                                         @(Catagory_Quick_Capture):@"Quick_Capture",
                                         @(Catagory_LED_status):@"LED_status",
                                         @(Catagory_Volume_beeps):@"Volume_beeps",
                                         //@(Catagory_Internal_Battery):@"Video_Format",
                                         @(Catagory_Screen_data):@"Screen_data",
                                         @(Catagory_LCD_Brightness):@"LCD_Brightness",
                                         @(Catagory_LCD_Lock):@"LCD_Lock",
                                         @(Catagory_LCD_sleep):@"LCD_sleep",
                                         @(Catagory_Auto_Power_Off):@"Auto_Power_Off",
                                         @(Catagory_Internal_Battery):@"Internal_Battery",
                                         @(Catagory_Battery_Level):@"Battery_Level",
                                         @(Catagory_Streaming_status):@"Processing_status",
                                         @(Catagory_Processing_status):@"Streaming_status",
                                         @(Catagory_SD_card):@"SD_card",
                                         @(Catagory_Number_of_clients):@"Number_of_clients",
                                         @(Catagory_Current_Mode):@"Current_Mode",
                                         @(Catagory_Current_SubMode):@"Current_SubMode",
                                         //Video_Duration;
                                         }
                                 };
    }
    return self;
}

-(void) activeSportCameraConfig:(NSString*)name withColor:(NSString*)color
{
//    zy::SportCameraParamTools::instance()->configDevice([name UTF8String], [color UTF8String]);
//    self.sportCameraParamInfoArray = [self queryCurConfig];
    [self.goProData activeSportCameraConfig:name];
//    self.goProType = name;
    
}

-(NSString*) getMappingName:(NSUInteger)mode type:(NSString*)type
{
    NSString* result = @"";
    NSDictionary* supportParamDict = [self.nameMappingDict objectForKey:@(mode)];
    if (supportParamDict) {
        NSString* mappingName = [supportParamDict objectForKey:type];
        if (mappingName) {
            result = mappingName;
        }
    }
    return result;
}

-(NSArray*) queryCurConfig
{
    NSMutableArray* paramInfoArray = [NSMutableArray array];
    std::vector<zy::SportCameraParamInfo> info;
    zy::SportCameraParamTools::instance()->getActiveConfig(info);
    for (int i = 0; i < info.size(); i++) {
        zy::SportCameraParamInfo& paramInfo = info[i];
        SportCameraParamModel* model = [[SportCameraParamModel alloc] init];
        model.queryCode = paramInfo.queryCode;
        model.queryVal = paramInfo.queryVal;
        model.setVal = paramInfo.setVal;
        model.supportMode = paramInfo.supportMode;
        model.name = @(paramInfo.name.c_str());
        model.type = @(paramInfo.type.c_str());
        model.mappingName = [self getMappingName:model.supportMode type:model.type];
        [paramInfoArray addObject: model];
    }
    return paramInfoArray;
}

-(NSArray<NSString*>*) activeParamCatagory:(NSUInteger)mode;
{
    NSMutableArray<NSString*>* catagoryArray = [NSMutableArray array];
    [self.sportCameraParamInfoArray enumerateObjectsUsingBlock:^(SportCameraParamModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.supportMode == mode && ![catagoryArray containsObject:obj.type]) {
            [catagoryArray addObject:obj.type];
        }
    }];
    return catagoryArray;
}

-(BOOL) validateValue:(NSUInteger)mode type:(NSString*)type value:(NSUInteger)value;
{
    __block BOOL returnValue = NO;
    [self.sportCameraParamInfoArray enumerateObjectsUsingBlock:^(SportCameraParamModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.supportMode == mode
            && [obj.type isEqualToString:type]) {
            if (value == obj.queryVal) {
                *stop = YES;
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}


-(NSArray*) querySpecificConfig:(NSUInteger)mode type:(NSString*)type name:(NSString*)name
{
    if (self.sportCameraParamInfoArray.count > 0) {
        
    }
    else{
        [self queryCurConfig];
    }
    
    if (name.length > 0) {
        for (SportCameraParamModel *model in self.sportCameraParamInfoArray) {
            if (model.supportMode == mode && [model.type isEqualToString:type] && [model.name isEqualToString:name]) {
                return @[model];
            }
        }
        return @[];
    }
    else if (type.length > 0){
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (SportCameraParamModel *model in self.sportCameraParamInfoArray) {
            if (model.supportMode == mode && [model.type isEqualToString:type]) {
                [array addObject:model];
            }
        }
        return array;
    }
    else{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (SportCameraParamModel *model in self.sportCameraParamInfoArray) {
            if (model.supportMode == mode) {
                [array addObject:model];
            }
        }
        return array;
        
    }
    return nil;
}
/*
 -(NSArray*) querySpecificConfig:(NSUInteger)mode type:(NSString*)type name:(NSString*)name
 {
 NSLog(@"%d %@ %@",mode,type,name);
 NSMutableArray* paramInfoArray = [NSMutableArray array];
 std::vector<zy::SportCameraParamInfo> info;
 zy::SportCameraParamTools::instance()->getSpecificSettings(info, (int)mode, [type UTF8String], [name UTF8String]);
 for (int i = 0; i < info.size(); i++) {
 zy::SportCameraParamInfo& paramInfo = info[i];
 SportCameraParamModel* model = [[SportCameraParamModel alloc] init];
 model.queryCode = paramInfo.queryCode;
 model.queryVal = paramInfo.queryVal;
 model.setVal = paramInfo.setVal;
 model.supportMode = paramInfo.supportMode;
 model.name = @(paramInfo.name.c_str());
 model.type = @(paramInfo.type.c_str());
 model.mappingName = [self getMappingName:model.supportMode type:model.type];
 [paramInfoArray addObject: model];
 }
 NSLog(@"%@",paramInfoArray);
 return paramInfoArray;
 }
 */

-(NSUInteger) workingModeToSupportMode:(NSUInteger)workingMode
{
    if (workingMode == workingMode_Video) {
        return supportMode_Video;
    } else if (workingMode == workingMode_Photo) {
        return supportMode_Photo;
    } else if (workingMode == workingMode_MultiShot) {
        return supportMode_MultiShot;
    } else {
        return supportMode_Other;
    }
}

/**
 主模式
 
 @return 主模式的对象
 */
-(SportCameraParamModel*)mainMode:(NSInteger)mode{
    NSString *name = nil;
    switch (mode) {
        case supportMode_Video:
        {
            name = @(Item_Current_Mode_Get_Name_Video);
            break;
        }
        case supportMode_Photo:
        {
            name = @(Item_Current_Mode_Get_Name_Photo);
            break;
        }
        case supportMode_MultiShot:
        {
            name = @(Item_Current_Mode_Get_Name_MultiShot);
            break;
        }
        case supportMode_Other:
        {
            break;
        }
        default:
            break;
    }
    if (name == nil) {
        return nil;
    }
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:supportMode_Other type:@(Catagory_Current_Mode) name:name];
    
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel*)mainMode:(NSInteger)mode subMode:(NSInteger)submode{
    NSString *name = nil;
    switch (mode) {
        case supportMode_Video:
        {
            switch (submode) {
                case 0:
                {
                    name = @(Item_SubMode_Get_Name_Video);
                    break;
                }
                case 1:
                {
                    name = @(Item_SubMode_Get_Name_TimeLapse_Video);
                    
                    break;
                }
                case 2:
                {
                    name = @(Item_SubMode_Get_Name_Video_Photo);
                    break;
                }
                case 3:
                {
                    name = @(Item_SubMode_Get_Name_Looping);
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case supportMode_Photo:
        {
            
            switch (submode) {
                case 0:
                {
                    NSLog(@"supportMode_Photo ");
                    //                    name = @(Item_SubMode_Get_Name_Single);
                    break;
                }
                case 1:
                {
                    name = @(Item_SubMode_Get_Name_Single);
                    
                    break;
                }
                case 2:
                {
                    name = @(Item_SubMode_Get_Name_Night);
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case supportMode_MultiShot:
        {
            
            switch (submode) {
                case 0:
                {
                    name = @(Item_SubMode_Get_Name_Burst);
                    break;
                }
                case 1:
                {
                    name = @(Item_SubMode_Get_Name_Timelapse);
                    
                    break;
                }
                case 2:
                {
                    name = @(Item_SubMode_Get_Name_NightLapse);
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case supportMode_Other:
        {
            break;
        }
        default:
            break;
    }
    if (name == nil) {
        return nil;
    }
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:mode type:@(Catagory_SubMode) name:name];
    
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

#define NotSupport @"not support"

- (SportCameraParamModel *)FPSType:(NSInteger)main_mode subType:(NSInteger)subType {
    
    NSString *settingName = nil;
    if (subType == 0) settingName = @(Item_Frame_Rate_Get_Name_240);
    else if (subType == 1) settingName = @(Item_Frame_Rate_Get_Name_120);
    else if (subType == 2) settingName = @(Item_Frame_Rate_Get_Name_100);
    else if (subType == 3) settingName = @(Item_Frame_Rate_Get_Name_90);
    else if (subType == 4) settingName = @(Item_Frame_Rate_Get_Name_80);
    else if (subType == 5) settingName = @(Item_Frame_Rate_Get_Name_60);
    else if (subType == 6) settingName = @(Item_Frame_Rate_Get_Name_50);
    else if (subType == 7) settingName = @(Item_Frame_Rate_Get_Name_48);
    else if (subType == 8) settingName = @(Item_Frame_Rate_Get_Name_30);
    else if (subType == 9) settingName = @(Item_Frame_Rate_Get_Name_25);
    else if (subType == 10) settingName = @(Item_Frame_Rate_Get_Name_24);
    else if (subType == 11) settingName = @(Item_Frame_Rate_Get_Name_15);
    else if (subType == 12) settingName = @(Item_Frame_Rate_Get_Name_12_5);
    else settingName = NotSupport;
    
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_Frame_Rate) name:settingName];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel*)FOVType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *settingName = nil;
    if (subType == 0) settingName = @(Item_FOV_video_Get_Name_Wide);
    else if (subType == 1 || subType == 8) settingName = @(Item_FOV_video_Get_Name_Medium);
    else if (subType == 4 || subType == 10) settingName = @(Item_FOV_video_Get_Name_Linear);
    else if (subType == 2 || subType == 9) settingName = @(Item_FOV_video_Get_Name_Narrow);
    else settingName = NotSupport;
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_FOV_video) name:settingName];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel*)LoopIntervalType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *settingName = nil;
    if (main_mode == supportMode_Video) {
        if (subType == 0) settingName = @(Item_Looping_Interval_Get_Name_Max);
        else if (subType == 1) settingName = @(Item_Looping_Interval_Get_Name_5_Minutes);
        else if (subType == 2) settingName = @(Item_Looping_Interval_Get_Name_20_Minutes);
        else if (subType == 3) settingName = @(Item_Looping_Interval_Get_Name_60_Minutes);
        else if (subType == 4) settingName = @(Item_Looping_Interval_Get_Name_120_Minutes);
        else settingName = NotSupport;
    } else settingName = NotSupport;
    
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_Looping_Interval) name:settingName];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}
-(SportCameraParamModel*)PhotoIntervalType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *settingName = nil;
    if (main_mode == supportMode_Video) {
        if (subType == 1) settingName = @(Item_Video_Interval_Get_Name_1_Photo___5_Seconds);
        else if (subType == 2) settingName = @(Item_Video_Interval_Get_Name_1_Photo___10_Seconds);
        else if (subType == 3) settingName = @(Item_Video_Interval_Get_Name_1_Photo___30_Seconds);
        else if (subType == 4) settingName = @(Item_Video_Interval_Get_Name_1_Photo___60_Seconds);
        else settingName = NotSupport;
    } else settingName = NotSupport;
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_Video_Interval) name:settingName];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}
-(SportCameraParamModel*)DelayIntervalType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *settingName = nil;
    if (main_mode == supportMode_Video) {
        if (subType == 0) settingName = @(Item_TimeLapse_Interval_Get_Name_1_2_Seconds);
        else if (subType == 1) settingName = @(Item_TimeLapse_Interval_Get_Name_1_Seconds);
        else if (subType == 2) settingName = @(Item_TimeLapse_Interval_Get_Name_2_Seconds);
        else if (subType == 3) settingName = @(Item_TimeLapse_Interval_Get_Name_5_Seconds);
        else if (subType == 4) settingName = @(Item_TimeLapse_Interval_Get_Name_10_Seconds);
        else if (subType == 5) settingName = @(Item_TimeLapse_Interval_Get_Name_30_Seconds);
        else if (subType == 6) settingName = @(Item_TimeLapse_Interval_Get_Name_60_Seconds);
    } else {
        if (subType == 0) settingName = @(Item_TimeLapse_Interval_Get_Name_1_2_Seconds);
        else if (subType == 1) settingName = @(Item_TimeLapse_Interval_Get_Name_1_Seconds);
        else if (subType == 2) settingName = @(Item_TimeLapse_Interval_Get_Name_2_Seconds);
        else if (subType == 5) settingName = @(Item_TimeLapse_Interval_Get_Name_5_Seconds);
        else if (subType == 10) settingName = @(Item_TimeLapse_Interval_Get_Name_10_Seconds);
        else if (subType == 30) settingName = @(Item_TimeLapse_Interval_Get_Name_30_Seconds);
        else if (subType == 60) settingName = @(Item_TimeLapse_Interval_Get_Name_60_Seconds);
    }
    settingName = settingName ?: NotSupport;
    
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_TimeLapse_Interval) name:settingName];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel*)DelayNightIntervalType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *setting = nil;
    if (subType == 0) setting = @(Item_NightLapse_Interval_Get_Name_Continuous);
    else if (subType == 4) setting = @(Item_NightLapse_Interval_Get_Name_4_Seconds);
    else if (subType == 5) setting = @(Item_NightLapse_Interval_Get_Name_5_Seconds);
    else if (subType == 10) setting = @(Item_NightLapse_Interval_Get_Name_10_Seconds);
    else if (subType == 15) setting = @(Item_NightLapse_Interval_Get_Name_15_Seconds);
    else if (subType == 20) setting = @(Item_NightLapse_Interval_Get_Name_20_Seconds);
    else if (subType == 30) setting = @(Item_NightLapse_Interval_Get_Name_30_Seconds);
    else if (subType == 60) setting = @(Item_NightLapse_Interval_Get_Name_1_Minute);
    else if (subType == 120) setting = @(Item_NightLapse_Interval_Get_Name_2_Minutes);
    else if (subType == 300) setting = @(Item_NightLapse_Interval_Get_Name_5_Minutes);
    else if (subType == 1800) setting = @(Item_NightLapse_Interval_Get_Name_30_Minutes);
    else if (subType == 3600) setting = @(Item_NightLapse_Interval_Get_Name_60_Minutes);
    else setting = NotSupport;
    
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_NightLapse_Interval) name:setting];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel *)RateType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *setting = nil;
    if (subType == 0) setting = @(Item_Burst_Rate_Get_Name_3_Photos___1_Second);
    else if (subType == 1) setting = @(Item_Burst_Rate_Get_Name_5_Photos___1_Second);
    else if (subType == 2) setting = @(Item_Burst_Rate_Get_Name_10_Photos___1_Second);
    else if (subType == 3) setting = @(Item_Burst_Rate_Get_Name_10_Photos___2_Second);
    else if (subType == 4) setting = @(Item_Burst_Rate_Get_Name_10_Photos___3_Second);
    else if (subType == 5) setting = @(Item_Burst_Rate_Get_Name_30_Photos___1_Second);
    else if (subType == 6) setting = @(Item_Burst_Rate_Get_Name_30_Photos___2_Second);
    else if (subType == 7) setting = @(Item_Burst_Rate_Get_Name_30_Photos___3_Second);
    else if (subType == 8) setting = @(Item_Burst_Rate_Get_Name_30_Photos___6_Second);
    else setting = NotSupport;
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_Burst_Rate) name:setting];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}
-(SportCameraParamModel *)shutterType:(NSInteger)main_mode subType:(NSInteger)subType{
    NSString *setting = nil;
    if (main_mode == supportMode_Video) {
        if (subType == 3) setting = @(Item_Manual_Exposure_Get_Name_24FPS_1_24);
        else if (subType == 6) setting = @(Item_Manual_Exposure_Get_Name_24FPS_1_48);
        else if (subType == 11) setting = @(Item_Manual_Exposure_Get_Name_24FPS_1_96);
        else if (subType == 5) setting = @(Item_Manual_Exposure_Get_Name_30FPS_1_30);
        else if (subType == 8) setting = @(Item_Manual_Exposure_Get_Name_30FPS_1_60);
        else if (subType == 13) setting = @(Item_Manual_Exposure_Get_Name_30FPS_1_120);
        else if (subType == 16) setting = @(Item_Manual_Exposure_Get_Name_48FPS_1_192);
        else if (subType == 18) setting = @(Item_Manual_Exposure_Get_Name_60FPS_1_240);
        else if (subType == 10) setting = @(Item_Manual_Exposure_Get_Name_90FPS_1_90);
        else if (subType == 15) setting = @(Item_Manual_Exposure_Get_Name_90FPS_1_180);
        else if (subType == 20) setting = @(Item_Manual_Exposure_Get_Name_90FPS_1_360);
        else if (subType == 22) setting = @(Item_Manual_Exposure_Get_Name_120FPS_1_480);
        else setting = NotSupport;
    } else {
        if (subType == 0) setting = @(Item_Shutter_Get_Name_Auto);
        else if (subType == 1) setting = @(Item_Shutter_Exposure_Get_Name_2s);
        else if (subType == 2) setting = @(Item_Shutter_Exposure_Get_Name_5s);
        else if (subType == 3) setting = @(Item_Shutter_Exposure_Get_Name_10s);
        else if (subType == 4) setting = @(Item_Shutter_Exposure_Get_Name_15s);
        else if (subType == 5) setting = @(Item_Shutter_Exposure_Get_Name_20s);
        else if (subType == 6) setting = @(Item_Shutter_Exposure_Get_Name_30s);
        else setting = NotSupport;
    }
    
    NSString *catagory = @(Catagory_Manual_Exposure);
    if (main_mode == supportMode_Video) catagory = @(Catagory_Manual_Exposure);
    else if (main_mode == supportMode_MultiShot) catagory = @(Catagory_Shutter_Exposure);
    else if (main_mode == supportMode_Photo) catagory = @(Catagory_Shutter_Exposure);
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:catagory name:setting];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel *)EVType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *setting = nil;
    if (subType == 0) setting = @(Item_EV_Comp_Get_Name_2);
    else if (subType == 1) setting = @(Item_EV_Comp_Get_Name_1_5);
    else if (subType == 2) setting = @(Item_EV_Comp_Get_Name_1);
    else if (subType == 3) setting = @(Item_EV_Comp_Get_Name_0_5);
    else if (subType == 4) setting = @(Item_EV_Comp_Get_Name_0);
    else if (subType == 5) setting = @(Item_EV_Comp_Get_Name__0_5);
    else if (subType == 6) setting = @(Item_EV_Comp_Get_Name__1);
    else if (subType == 7) setting = @(Item_EV_Comp_Get_Name__1_5);
    else if (subType == 8) setting = @(Item_EV_Comp_Get_Name__2);
    else setting = NotSupport;
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_EV_Comp) name:setting];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel *)ISOMaxType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *setting = nil;
    if (main_mode == supportMode_Video) {
        if (subType == 0) {
            setting = @(Item_ISO_Limit_Get_Name_6400);
        } else if (subType == 1 ) {
            setting = @(Item_ISO_Limit_Get_Name_1600);
        } else if (subType == 2 ) {
            setting = @(Item_ISO_Limit_Get_Name_400);
        } else if (subType == 3 ) {
            setting = @(Item_ISO_Limit_Get_Name_3200);
        } else if (subType == 4 ) {
            setting = @(Item_ISO_Limit_Get_Name_800);
        } else if (subType == 7 ) {
            setting = @(Item_ISO_Limit_Get_Name_200);
        } else if (subType == 8 ) {
            setting = @(Item_ISO_Limit_Get_Name_100);
        } else setting = NotSupport;
    } else {
        if (subType == 0) {
            setting = @(Item_ISO_Limit_Get_Name_800);
        } else if (subType == 1) {
            setting = @(Item_ISO_Limit_Get_Name_400);
        } else if (subType == 2) {
            setting = @(Item_ISO_Limit_Get_Name_200);
        } else if (subType == 3) {
            setting = @(Item_ISO_Limit_Get_Name_100);
        } else setting = NotSupport;
    }
    
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_ISO_Limit) name:setting];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}
-(SportCameraParamModel *)ISOMinType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *setting = nil;
    if (subType == 0) {
        setting = @(Item_ISO_Min_Get_Name_800);
    } else if (subType == 1) {
        setting = @(Item_ISO_Min_Get_Name_400);
    } else if (subType == 2) {
        setting = @(Item_ISO_Min_Get_Name_200);
    } else if (subType == 3) {
        setting = @(Item_ISO_Min_Get_Name_100);
    } else setting = NotSupport;
    
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_ISO_Min) name:setting];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel *)whiteBalanceType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *setting = nil;
    if (subType == 0) setting = @(Item_White_Balance_Get_Name_Auto);
    else if (subType == 1) setting = @(Item_White_Balance_Get_Name_3000k);
    else if (subType == 5) setting = @(Item_White_Balance_Get_Name_4000k);
    else if (subType == 6) setting = @(Item_White_Balance_Get_Name_4800k);
    else if (subType == 2) setting = @(Item_White_Balance_Get_Name_5500k);
    else if (subType == 7) setting = @(Item_White_Balance_Get_Name_6000k);
    else if (subType == 3) setting = @(Item_White_Balance_Get_Name_6500k);
    else if (subType == 4) setting = @(Item_White_Balance_Get_Name_Native);
    else setting = NotSupport;
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_White_Balance) name:setting];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
}

-(SportCameraParamModel *)resolutionType:(NSInteger)main_mode subType:(NSInteger)subType {
    NSString *name = nil;
    if (main_mode == supportMode_Video) {
        if (subType == 1) name = @(Item_Video_Resolution_Get_Name_4K);
        else if (subType == 2) name = @(Item_Video_Resolution_Get_Name_4K_SuperView);
        else if (subType == 4) name = @(Item_Video_Resolution_Get_Name_2_7K);
        else if (subType == 5) name = @(Item_Video_Resolution_Get_Name_2_7K_SuperView);
        else if (subType == 6) name = @(Item_Video_Resolution_Get_Name_2_7k_4_3);
        else if (subType == 7) name = @(Item_Video_Resolution_Get_Name_1440);
        else if (subType == 8) name = @(Item_Video_Resolution_Get_Name_1080_SuperView);
        else if (subType == 9) name = @(Item_Video_Resolution_Get_Name_1080);
        else if (subType == 10) name = @(Item_Video_Resolution_Get_Name_960);
        else if (subType == 11) name = @(Item_Video_Resolution_Get_Name_720_SuperView);
        else if (subType == 12) name = @(Item_Video_Resolution_Get_Name_720);
        else if (subType == 13) name = @(Item_Video_Resolution_Get_Name_WVGA);
    }
    name = name ? : NotSupport;
    
    NSArray<SportCameraParamModel*>* catagoryMaps = [[ZYMessageTool defaultTool] querySpecificConfig:main_mode type:@(Catagory_Video_Resolution) name:name];
    SportCameraParamModel* cameraParam = [catagoryMaps lastObject];
    return cameraParam;
    
}

-(NSInteger)shutter:(bool)shutter{
    if (shutter) {
        return Shutter_on;
    }
    else{
        return Shutter_off;
    }
}

-(SportCameraParamModel *)queryModelWithCode:(NSInteger)queryCode value:(NSInteger)queryVal{
    
    return [self.goProData queryModelWithCode:queryCode value:queryVal];
//    for (SportCameraParamModel *model in self.sportCameraParamInfoArray) {
//        if (model.queryVal == queryVal && model.queryCode == queryCode) {
//            return model;
//        }
//    }
//    return nil;
}
 
@end

