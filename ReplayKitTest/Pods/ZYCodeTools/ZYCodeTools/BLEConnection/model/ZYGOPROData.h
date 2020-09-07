//
//  ZYGOPROData.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/16.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SportCameraParamModel;

@interface ZYGOPROData : NSObject



/**
 激活是HERO5还是HERO6

 @param name HERO5还是HERO6
 */
-(void) activeSportCameraConfig:(NSString*)name;

/**
 支持的分辨率

 @param fps 在某个fps下面
 @param format 某个格式 NTSC/PAL
 @return 分辨率
 */
-(NSArray *)suportResolutionWithFPS:(NSString *)fps andFormat:(NSString *)format;

/**
 支持的分辨率
 
 @param resolution 在某个resolution下面
 @param format 某个格式 NTSC/PAL
 @param mode 子模式
 @return fps
 */
//-(NSArray *)suportFPSWithResolution:(NSString *)resolution andFormat:(NSString *)format subMode:(NSString *)mode;
-(NSArray *)suportFPSWithResolution:(NSInteger)resolution andFormat:(NSInteger)format subMode:(NSString *)modeName;

/**
 支持的FOV

 @param resolution  分辨率
 @param fps fps
 @param format 某个格式 NTSC/PAL
 @return fovs
 */
//-(NSArray *)suportFOVWithResolution:(NSString *)resolution FPS:(NSString *)fps andFormat:(NSString *)format;
-(NSArray *)suportFOVWithResolution:(NSInteger)resolution FPS:(NSInteger)fps andFormat:(NSInteger)format subModeName:(NSString *)subModeName;

/**
 fps 支持的曝光时间

 @param fps fps
 @return 支持的manualExposure
 */
-(NSArray *)suportManualExposureWithFPS:(NSString *)fps;


/**
 查询单条指令信息

 @param queryCode <#queryCode description#>
 @param queryVal <#queryVal description#>
 @return <#return value description#>
 */
-(SportCameraParamModel *)queryModelWithCode:(NSInteger)queryCode value:(NSInteger)queryVal;



/**
 通过分类名和设置的名字获取设置的值

 @param catagory 需要的分类名
 @param content 需要的设置名
 @return 需要的设置值, 格式:@"code-value"
 */

- (NSInteger)obtainQueryValueUsingCode:(NSInteger)queryCode andContent:(NSString *)content;


- (NSArray *)obtainTitlesUsingCode:(NSInteger)queryCode withMainMode:(NSInteger)index subMode:(NSInteger)subMode subModeName:(NSString *)subModeName;

- (NSArray *)obtainTitlesUsingCode:(NSInteger)code
                       subModeName:(NSString *)subModeName
                       videoFormat:(NSInteger)format
                          mainMode:(NSInteger)index
                           subMode:(NSInteger)subMode
                        resolution:(NSInteger)resolutionValue
                               FPS:(NSInteger)fps
                           shutter:(NSInteger)shutter;


- (NSString *)obtainContentUsingCode:(NSInteger)queryCode andQueryValue:(NSInteger)queryValue;


#pragma -mark photo相关


@end
