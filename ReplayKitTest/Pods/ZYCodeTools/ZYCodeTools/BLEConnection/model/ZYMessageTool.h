//
//  ZYMessageTool.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>


//指令支持模式
enum {
    supportMode_Video       = 0x01,         //视频
    supportMode_Photo       = 0x01 << 1,    //照片
    supportMode_MultiShot   = 0x01 << 2,    //连拍
    supportMode_Other       = 0x01 << 3,    //其他
};

//工作模式
extern const NSUInteger workingMode_Video;          //视频
extern const NSUInteger workingMode_Photo;          //照片
extern const NSUInteger workingMode_MultiShot;      //连拍

@class ZYGOPROData;

@interface SportCameraParamModel : NSObject

/**
 查询编码
 */
@property (nonatomic, readwrite) NSInteger queryCode;

/**
 查询值
 */
@property (nonatomic, readwrite) NSInteger queryVal;

/**
 设置值
 */
@property (nonatomic, readwrite) NSInteger setVal;

/**
 支持模式  例如：supportMode_Video
 */
@property (nonatomic, readwrite) NSInteger supportMode;

/**
 支持的子模式有哪些
 */
@property (nonatomic, readwrite) NSArray *supportModeArray;


/**
 参数名 （参数）
 */
@property (nonatomic, readwrite, copy) NSString* name;

/**
 参数类型 （类型）catagory转换
 */
@property (nonatomic, readwrite, copy) NSString* type;

/**
 与ZYBlWiFiPhotoAllParamData对应的属性名
 */
@property (nonatomic, readwrite, copy) NSString* mappingName;
@end

@interface ZYMessageTool : NSObject

/**
 单例

 @return 返回对象
 */
+(instancetype) defaultTool;

@property (strong, nonatomic) ZYGOPROData *goProData;
///**
// goPro 的型号, HERO5 / HERO6
// */
//@property (copy, nonatomic) NSString *goProType;
//
//@property (copy, nonatomic) NSString *videoFormat;

/**
 根据机器类型和颜色设置指令列表

 @param name 机器类型
 @param color 颜色类型
 */
-(void) activeSportCameraConfig:(NSString*)name withColor:(NSString*)color;

/**
 查询支持的指令列表

 @param supportMode 支持模式
 @return 返回支持模式的列表
 */
-(NSArray<NSString*>*) activeParamCatagory:(NSUInteger)supportMode;

/**
 

 @param supportMode 支持模式
 @param type 指令类型
 @param value 查询值
 @return YES:有效范围内
 */
-(BOOL) validateValue:(NSUInteger)supportMode type:(NSString*)type value:(NSUInteger)value;

/**
 查询特定的指令信息

 @param supportMode 支持模式
 @param type 指令类型
 @param name 指令名称 (第二列)
 @return 适合的指令列表
 */
-(NSArray<SportCameraParamModel*>*) querySpecificConfig:(NSUInteger)supportMode type:(NSString*)type name:(NSString*)name;

/**
 通过工作模式转换成支持模式

 @param workingMode 工作模式
 @return 支持模式
 */
-(NSUInteger) workingModeToSupportMode:(NSUInteger)workingMode;


/**
 主模式

 @return 主模式的对象
 */
-(SportCameraParamModel*)mainMode:(NSInteger)mode;

-(SportCameraParamModel*)mainMode:(NSInteger)mode subMode:(NSInteger)submode;

-(SportCameraParamModel*)resolutionType:(NSInteger)main_mode subType:(NSInteger)subType ;

-(SportCameraParamModel*)FPSType:(NSInteger)main_mode subType:(NSInteger)subType ;

-(SportCameraParamModel*)FOVType:(NSInteger)main_mode subType:(NSInteger)subType ;

-(SportCameraParamModel*)LoopIntervalType:(NSInteger)main_mode subType:(NSInteger)subType ;
-(SportCameraParamModel*)PhotoIntervalType:(NSInteger)main_mode subType:(NSInteger)subType ;
-(SportCameraParamModel*)DelayIntervalType:(NSInteger)main_mode subType:(NSInteger)subType ;
-(SportCameraParamModel*)DelayNightIntervalType:(NSInteger)main_mode subType:(NSInteger)subType ;

-(SportCameraParamModel*)RateType:(NSInteger)main_mode subType:(NSInteger)subType ;

-(SportCameraParamModel*)shutterType:(NSInteger)main_mode subType:(NSInteger)subType ;

-(SportCameraParamModel*)EVType:(NSInteger)main_mode subType:(NSInteger)subType;

-(SportCameraParamModel*)ISOMaxType:(NSInteger)main_mode subType:(NSInteger)subType;

-(SportCameraParamModel *)ISOMinType:(NSInteger)main_mode subType:(NSInteger)subType;

-(SportCameraParamModel *)whiteBalanceType:(NSInteger)main_mode subType:(NSInteger)subType;


/**
 录像或拍照的指令

 @param shutter 是否是开始录像
 @return 录像或拍照的指令码
 */
-(NSInteger)shutter:(bool)shutter;

/**
 通过
 Data =     {
 paramId = 71;
 paramValue = 0;
 };

 @param queryCode paramId
 @param queryVal paramValue
 @return 对象
 */
-(SportCameraParamModel *)queryModelWithCode:(NSInteger)queryCode value:(NSInteger)queryVal;

////////////////




@end
