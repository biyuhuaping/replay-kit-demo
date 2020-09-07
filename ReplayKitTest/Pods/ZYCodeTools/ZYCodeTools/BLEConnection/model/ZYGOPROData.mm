//
//  ZYGOPROData.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/16.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYGOPROData.h"
#import "ZYMessageTool.h"
#include "ParamDef.h"
#import "ZYDeviceManager.h"

using namespace zy::SportCamera;

@interface ZYGOPROData()
/*!
 记录是HERO5 还是HER6
 */
@property (nonatomic, copy) NSString *name;

/*!
 video 相关
 
 */
@property (nonatomic, strong) NSMutableArray *videoSetArray;

@property (nonatomic, strong) NSMutableDictionary *resolutionAndFPSAndFOV;

@property (nonatomic, strong) NSMutableArray *manualExposureAndFPS;
/*!
 photo相关
 
 */
@property (nonatomic, strong) NSMutableArray *photoSetArray;
/*!
 multiShot相关
 
 */
@property (nonatomic, strong) NSMutableArray *multiShotSetArray;

@property (copy, nonatomic) NSArray *currentDatasource;

@end

@implementation ZYGOPROData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"HERO5";

    }
    return self;
}
-(void)activeSportCameraConfig:(NSString *)name{
    if (_name != name) {
        _videoSetArray = nil;
        _resolutionAndFPSAndFOV = nil;
        _manualExposureAndFPS = nil;
        _photoSetArray = nil;
        _multiShotSetArray = nil;
    }
    _name = name;

}

-(NSMutableArray *)videoSetArray{
    if (_videoSetArray == nil) {
       
        NSArray *array = [self geojsonWithName:@"VideoSet"];
        _videoSetArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in array) {
            SportCameraParamModel *model = [self supportModelWithDic:dic andSupportArray:@[@"WiFiVideo_para_Sub_ModeVideo",@"WiFiVideo_para_Sub_ModeVideo_Photo",@"WiFiVideo_para_Sub_ModeLooping",@"WiFiVideo_para_Sub_ModeTimeLapseVideo"]];
            [_videoSetArray addObject:model];
        }
    }
    return _videoSetArray;
}

-(NSMutableDictionary *)resolutionAndFPSAndFOV{
    if (_resolutionAndFPSAndFOV == nil) {
        NSDictionary *dic = [self geojsonWithName:@"ResolutionAndFPSFOV"];
        
        _resolutionAndFPSAndFOV = [[NSMutableDictionary alloc] initWithDictionary:dic];
    }
    return _resolutionAndFPSAndFOV;
}

-(NSMutableArray *)manualExposureAndFPS{
    if (_manualExposureAndFPS == nil) {
        NSArray *array = [self geojsonWithName:@"ManualExposureAndFPS"];
        
        _manualExposureAndFPS = [[NSMutableArray alloc] initWithArray:array];
    }
    return _manualExposureAndFPS;
}

-(NSMutableArray *)photoSetArray{
    if (_photoSetArray == nil) {
        
        NSArray *array = [self geojsonWithName:@"PhotoSet"];
        _photoSetArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in array) {
            SportCameraParamModel *model = [self supportModelWithDic:dic andSupportArray:@[@"WiFiPhoto_para_Sub_ModeSingle",@"WiFiPhoto_para_Sub_ModeNight"]];
            [_photoSetArray addObject:model];
        }
        
    }
    return _photoSetArray;
}

-(NSMutableArray *)multiShotSetArray{
    if (_multiShotSetArray == nil) {
        NSArray *array = [self geojsonWithName:@"MultiShotSet"];
        _multiShotSetArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in array) {
            SportCameraParamModel *model = [self supportModelWithDic:dic andSupportArray:@[@"WiFiMultiShot_para_Sub_Mode_Burst",@"WiFiMultiShot_para_Sub_Mode_TimeLapse",@"WiFiMultiShot_para_Sub_Mode_Night_TimeLapse"]];
            [_multiShotSetArray addObject:model];
        }
    }
    return _multiShotSetArray;
}

-(SportCameraParamModel *)supportModelWithDic:(NSDictionary *)dic andSupportArray:(NSArray *)supportArray{
    SportCameraParamModel *model = [[SportCameraParamModel alloc] init];
    model.queryVal = [dic[@"queryVal"] integerValue];
    model.queryCode = [dic[@"queryCode"] integerValue];
    model.type = dic[@"Catagory"];
    model.name = dic[@"content"];
    model.mappingName = model.name;
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    for (NSString *string in supportArray) {
        NSString *innstr = dic[string];
        if ([innstr isEqualToString:@"YES"]) {
            [mutArray addObject:string];
        }
    }
    
    model.supportModeArray = mutArray;
    return model;
}

-(id)geojsonWithName:(NSString *)name {
    NSString *strPath = [[NSBundle mainBundle] pathForResource:name ofType:@"geojson"];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:strPath] options:NSJSONReadingAllowFragments error:nil];
    
    return dic[_name];
}


/**
 支持的分辨率
 
 @param fps 在某个fps下面
 @param format 某个格式 NTSC/PAL
 @return 分辨率
 */
-(NSArray *)suportResolutionWithFPS:(NSString *)fps andFormat:(NSString *)format{
    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
    int idx = 0;
    if ([format isEqualToString:@"NTSC"]) {
        idx = 0;
    }
    else if ([format isEqualToString:@"PAL"]) {
        idx = 1;
    }
    for (NSDictionary *dic in self.resolutionAndFPSAndFOV) {
        NSString *str = dic[@"Catagory_Frame_Rate"];
        if (str) {
            NSArray *array = [str componentsSeparatedByString:@"/"];
            if (array.count == 2) {
                NSString *inPFS = array[idx];
                if ([inPFS isEqualToString:fps]) {
                    NSString *innResoluton = dic[@"Catagory_Video_Resolution"];
                    if (innResoluton && ![returnArr containsObject:innResoluton]) {
                        [returnArr addObject:innResoluton];

                    }
                }
            }
        }
    }
    return returnArr;
}

 -(NSArray *)suportFPSWithResolution:(NSInteger)resolution andFormat:(NSInteger)format subMode:(NSString *)modeName
{
    if (modeName == nil) {
        return @[];
    }
    if ([modeName isEqualToString:@"WiFiVideo_para_Sub_ModeVideo"] ||
        [modeName isEqualToString:@"WiFiVideo_para_Sub_ModeLooping"] ||
        [modeName isEqualToString:@"WiFiVideo_para_Sub_ModeVideo_Photo"]) {
        NSArray *array = self.resolutionAndFPSAndFOV[modeName];
        return [self suportFPSWithResolution:resolution andFormat:format withArray:array];
//        return [self suportFPSWithResolution:resolution andFormat:format withArray:array];
    }
    else if ([modeName isEqualToString:@"WiFiVideo_para_Sub_ModeTimeLapseVideo"]){
        
    }
    return @[];

}
/**
 支持的分辨率
 
 @param resolution 在某个resolution下面
 @param format 某个格式 NTSC/PAL
 @return fps
 */
-(NSArray *)suportFPSWithResolution:(NSInteger)resolution andFormat:(NSInteger)format withArray:(NSArray *)array{
    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
    NSInteger idx = 0;
    idx = format;
//    if ([format isEqualToString:@"NTSC"]) {
//        idx = 0;
//    }
//    else if ([format isEqualToString:@"PAL"]) {
//        idx = 1;
//    }
    
    NSLog(@"%@",self.resolutionAndFPSAndFOV);
    NSString *res = [self obtainContentUsingCode:SPCCatagoryQueryCode_videoResolution andQueryValue:resolution];
    for (NSDictionary *dic in array) {
        NSString *str = dic[@"Catagory_Video_Resolution"];
        if ([str isEqualToString:res]) {
            NSString *innFPS = dic[@"Catagory_Frame_Rate"];
            if (innFPS)
            {
                NSArray *array = [innFPS componentsSeparatedByString:@"/"];
                if (array.count == 2) {
                    NSString *inFPSS = array[idx];
                    if (inFPSS && ![returnArr containsObject:inFPSS]) {
                        [returnArr addObject:inFPSS];
                    }
                }
            }
        }
    }
    return returnArr;
}


/**
 支持的FOV
 
 @param resolution  分辨率
 @param fps fps
 @param format 某个格式 NTSC/PAL
 @return fovs
 */
-(NSArray *)suportFOVWithResolution:(NSInteger)resolution
                                FPS:(NSInteger)fps
                          andFormat:(NSInteger)format
                        subModeName:(NSString *)subModeName
{
//    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
//    NSInteger idx = format;
    NSString *videoSetResolution = resolution != -1 ? [self obtainContentUsingCode:SPCCatagoryQueryCode_videoResolution andQueryValue:resolution] :@"";
    NSString *videoSetFPS = fps != -1 ? [self obtainContentUsingCode:SPCCatagoryQueryCode_videoFrameRate andQueryValue:fps] : @"";
    
    if (![self.resolutionAndFPSAndFOV.allKeys containsObject:subModeName]) {
        SPCAssert(0);
        return @[];
    }
    NSArray *dataArr = self.resolutionAndFPSAndFOV[subModeName];
    
    for (NSDictionary *dic in dataArr) {
        
        NSString *resKey = @"", *fpsKey = @"", *fovKey = @"";
        NSArray *keys = dic.allKeys;
        for (int i = 0 ; i < keys.count; ++i) {
            NSString *Key = keys[i];
            if ( [Key containsString:@"Resolution"] ) resKey = Key;
            else if ([Key containsString:@"Frame_Rate"]) fpsKey = Key;
            else if ([Key containsString:@"FOV"]) fovKey = Key;
        }
        
        // 约束表中的拍照 fov
        if (resolution == -1 && fps == -1) {
            NSString *allFovs = dic[fovKey];
            if (![allFovs containsString:@"、"]) return @[allFovs];
            return [allFovs componentsSeparatedByString:@"、"];
        }
        // 延时录像的 fov res
        else if (fps == -1) {
            NSString *restrainResolution = dic[resKey];
            if (![restrainResolution isEqualToString:videoSetResolution]) continue;
            NSString *restrainFOV = dic[fovKey];
            if (![restrainFOV containsString:@"、"]) return @[restrainFOV];
            return [restrainFOV componentsSeparatedByString:@"、"];
        }
        // 视频模式的 fov  res + fps
        else {
            NSString *restrainResolution = dic[resKey];
            NSString *restrainFPS = dic[fpsKey];
            NSString *curFPS = [restrainFPS componentsSeparatedByString:@"/"][format];
            
            BOOL findResult = [restrainResolution isEqualToString:videoSetResolution];
            if (!findResult) continue;
            findResult = [curFPS isEqualToString:videoSetFPS];
            if (!findResult) continue;
            NSString *restrainFov = dic[fovKey];
            if (![restrainFov containsString:@"、"]) return @[restrainFov];
            return [restrainFov componentsSeparatedByString:@"、"];
        }
    }
    SPCAssert(0);
    return @[];
}

-(NSArray *)suportManualExposureWithFPS:(NSString *)fps{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in self.manualExposureAndFPS) {
        NSArray *array = dic.allKeys;
        for (NSString *innfps in array) {
            if ([innfps isEqualToString:[NSString stringWithFormat:@"FPS%@",fps]]) {
                NSString *support = [dic objectForKey:innfps];
                if ([support isEqualToString:@"YES"]) {
                    [returnArray addObject:dic[@"Catagory_Manual_Exposure"]];
                }
                break;
            }
        }
    }
    return returnArray;
}

-(SportCameraParamModel *)queryModelWithCode:(NSInteger)queryCode value:(NSInteger)queryVal {
    
    for (SportCameraParamModel *model in self.videoSetArray) {
        if (model.queryVal == queryVal && model.queryCode == queryCode) {
            return model;
        }
    }
    return nil;
}

- (NSInteger)obtainQueryValueUsingCode:(NSInteger)queryCode andContent:(NSString *)content {
    __block NSInteger value = 0;
    [self.currentDatasource enumerateObjectsUsingBlock:^(SportCameraParamModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.queryCode == queryCode && [content isEqualToString:obj.name]) {
            value = obj.queryVal;
            *stop = YES;
        }
    }];
    return value;
}

- (NSArray *)obtainTitlesUsingCode:(NSInteger)code
                       subModeName:(NSString *)subModeName
                       videoFormat:(NSInteger)format
                          mainMode:(NSInteger)index
                           subMode:(NSInteger)subMode
                        resolution:(NSInteger)resolutionValue
                               FPS:(NSInteger)fps
                           shutter:(NSInteger)shutter
{
    
    if (code == SPCCatagoryQueryCode_videoFrameRate) {
        NSArray *fpsArr = [self suportFPSWithResolution:resolutionValue andFormat:format subMode:subModeName];
        return fpsArr;
    }
    else if (code == SPCCatagoryQueryCode_videoFOV) {
        // 延时录像只需要 reslution 约束
        if (subMode == WiFisubMode_TLVideo_Continuous_TimeLapse) {
            fps = -1;
        }
        NSArray *fovArr = [self suportFOVWithResolution:resolutionValue FPS:fps andFormat:format subModeName:subModeName];
        return fovArr;
//        code == SPCCatagoryQueryCode_photoFOV ||
    }
    else if ( code == SPCCatagoryQueryCode_multiFOV || code == SPCCatagoryQueryCode_photoFOV) {
        return  [self suportFOVWithResolution:-1 FPS:-1 andFormat:format subModeName:subModeName];
    }
    else if (code == SPCCatagoryQueryCode_multiNightLapseInterval) {
        return [self p_intervalConstraintUsingShutter:shutter subModeName:subModeName];
    }
    else if (code == SPCCatagoryQueryCode_videoManualExposure) {
        NSString *fpsStr = [self obtainContentUsingCode:SPCCatagoryQueryCode_videoFrameRate andQueryValue:fps];
        return [self suportManualExposureWithFPS:fpsStr];
    }
    else if (code == SPCCatagoryQueryCode_photoShutterAuto) {
        
    }
    return [self obtainTitlesUsingCode:code withMainMode:index subMode:subMode subModeName:subModeName];
}

/// 获取夜景延时拍照模式下的 快门和间隔的约束关系 multiShotSet.geojson 中的
- (NSArray *)p_intervalConstraintUsingShutter:(NSInteger)shutter subModeName:(NSString *)subModeName{
    NSArray *array = self.resolutionAndFPSAndFOV[subModeName];
    for (NSDictionary *per in array) {
        NSString *shutterName = per[@"MultiShot_NightLapse_ExposureS"];
        NSString *curShutter = [self obtainContentUsingCode:SPCCatagoryQueryCode_multiShutter andQueryValue:shutter];
        if (![curShutter isEqualToString:shutterName]) continue;
        NSString *interval = per[@"Catagory_NightLapse_Interval"];
        if (![interval containsString:@"、"]) return @[interval];
        return [interval componentsSeparatedByString:@"、"];
    }
    SPCAssert(0);
    return @[];
}


- (NSArray *)obtainTitlesUsingCode:(NSInteger)queryCode
                      withMainMode:(NSInteger)index
                           subMode:(NSInteger)subMode
                       subModeName:(NSString *)subModeName
{
    __block NSMutableArray *names = @[].mutableCopy;
    
    [self.currentDatasource enumerateObjectsUsingBlock:^(SportCameraParamModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.queryCode == queryCode && [obj.supportModeArray containsObject:subModeName]) {
            [names addObject:obj.name];
        }
    }];
    SPCAssert(names.count);
    return names;
}

- (NSString *)obtainContentUsingCode:(NSInteger)queryCode andQueryValue:(NSInteger)queryValue {
    __block NSString *content = nil;
    [self.currentDatasource enumerateObjectsUsingBlock:^(SportCameraParamModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (queryCode == obj.queryCode && queryValue == obj.queryVal ) {
            content = obj.name;
            *stop = YES;
        }
    }];
    
//    SPCAssert(content.length);
    return content;
}

- (NSArray *)currentDatasource {
//    if (!_currentDatasource) {
        NSInteger index = WiFiManager.wifiData.Other_Current_Main_Mode;
        if (index == 0) self.currentDatasource = self.videoSetArray.copy;
        else if ( index == 1) self.currentDatasource = self.photoSetArray.copy;
        else if ( index == 2) self.currentDatasource = self.multiShotSetArray.copy;
//    }
    return _currentDatasource;
}

@end
