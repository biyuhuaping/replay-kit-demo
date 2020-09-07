//
//  ZYStabilizerMotionManager.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/2/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZYBleProtocol.h"
#import "ZYSendRequest.h"

@class ZYStabilizerAxisConfig;
@class ZYParaCustomSettingModel;

typedef NS_ENUM(NSInteger,ZYBLEMoveDirection) {
    ZYBLEMoveDirectionPitch = 0,
    ZYBLEMoveDirectionYaw,
    ZYBLEMoveDirectionRoll
};

#define STABILIZER_AXIS_VALUE_NO_CHANGE 1000

/**
 控制稳定的转动过程
 */
@interface ZYStabilizerMotionManager : NSObject
@property (nonatomic, weak)   id <ZYSendRequest> sendDelegate;


/**
 当前设备的工作模式，目前只支持云鹤设备的主动通知
 */
@property (nonatomic, readonly)         ZYBleDeviceWorkMode  workMode;//数据改变时发送通知ZYDeviceWorkModeChangeNoti


/// 内部实现移动的类型，硬件移动需要，硬件V1.60版本以上才能使用.
/// @param softwareVersion 软件版本
/// @param modelNumberString 设备类型
-(void)configMotionControlTypeWithSoftWithsoftwareVersion:(NSString *)softwareVersion andModelNumberString:(NSString *)modelNumberString;

/**
 <#Description#>移动到指定点

 @param pitch 俯仰轴目标位置(-180, 180)
 @param roll  横滚轴目标位置(-180, 180)
 @param yaw   航向轴目标位置(-180, 180)
 @param handler 完成通知
 */
-(void) moveTo:(float)pitch roll:(float)roll yaw:(float)yaw compeletion:(void (^)(BOOL success))handler;
    
/**
 <#Description#>在指定时间内移动到指定点

 @param pitch 俯仰轴目标位置(-180, 180)
 @param roll 横滚轴目标位置(-180, 180)
 @param yaw 航向轴目标位置(-180, 180)
 @param totalTime 移动总耗时
 @param handler 完成通知
 */
-(void) moveTo:(float)pitch roll:(float)roll yaw:(float)yaw withInTime:(NSTimeInterval)totalTime compeletion:(void (^)(BOOL success))handler;

/**
 <#Description#>移动指定度数

 @param pitch 俯仰轴转动增量(-180, 180)
 @param roll  横滚轴转动增量(-180, 180)
 @param yaw   航向轴转动增量(-180, 180)
 @param times   重新测试的次数
 @param handler 完成通知
 */

-(void) moveBy:(float)pitch roll:(float)roll yaw:(float)yaw tryTimes:(NSUInteger)times compeletion:(void (^)(BOOL success))handler;

/**
 <#Description#>按速度比例移动
 
 @param pitch 俯仰轴转动速度比例(-1， 1)
 @param roll  横滚轴转动速度比例(-1， 1)
 @param yaw   航向轴转动速度比例(-1， 1)
 @param handler 完成通知
 */
-(void) moveWithDirectionFactor:(float)pitch roll:(float)roll yaw:(float)yaw directionFactor:(BOOL)Flag compeletion:(void (^)(BOOL success))handler;

/**
 体感

 @param pitch <#pitch description#>
 @param roll <#roll description#>
 @param yaw <#yaw description#>
 @param handler <#handler description#>
 */
- (void)motionMove:(float)pitch roll:(float)roll yaw:(float)yaw compeletion:(nullable void (^)(BOOL success))handler;

/**
 <#Description#>取消正在进行的移动
 */
-(void) cancelMove;


/**
 <#Description#>移动保持指定物体在屏幕中心范围

 @param xOffset 垂直方向上偏移
 @param yOffset 竖直方向上偏移
 */
-(void) moveWithCenterPoint:(float)xOffset y:(float)yOffset;

/**
 <#Description#>设置云台的工作模式指定那些轴可以运动

 @param mode mode 工作模式 设置成ZYBleDeviceWorkModeUnkown则返回当前模式
 @param handler 成功标记,上次的工作模式
 */
-(void) enableMotionMode:(ZYBleDeviceWorkMode)mode compeletion:(void (^)(BOOL success, ZYBleDeviceWorkMode originalMode))handler;

/**
 <#Description#>获取3个轴的位置

 @param handler 俯仰轴位置 横滚轴位置 航向轴位置
 */
-(void) queryCurrectAxisesPosition:(void (^)(float pitch, float roll, float yaw, BOOL success)) handler;

/**
 <#Description#>读取当前的配置信息

 @param handler 结果回调
 */
-(void) loadAxisConfiguration:(void (^)(BOOL success))handler;

/**
 <#Description#>读取当前的配置信息
 
 @param handler 结果回调
 */
-(void) loadAxisConfigurationModel:(void (^)(BOOL success,ZYParaCustomSettingModel *setting))handler;

/**
 <#Description#>设置配置信息

 @param axisConfigs 每个轴的信息
 @param handler 结果回调
 */
-(void) saveAxisConfiguration:(NSArray<ZYStabilizerAxisConfig*>*)axisConfigs compeletionHandler:(void (^)(BOOL success))handler;

/**
 <#Description#>设置配置信息

 @param setting 轴的全部配置
 @param handler 结果回调
 */
-(void) saveAxisCustomSetting:(ZYParaCustomSettingModel*)setting compeletionHandler:(void (^)(BOOL success))handler;

/**
 <#Description#>设置配置信息

 @param setting 轴的全部配置
 @param handler 结果回调
 */
-(void) saveAxisCustomSetting:(ZYParaCustomSettingModel*)setting exceptKeys:(NSArray *)exceptKeys compeletionHandler:(void (^)(BOOL success))handler;
/**
 结束循环.
 */
-(void) closeLoop;

/**
 检查当前轴的移动能否平滑
 */
-(BOOL) canMoveAxisSmoothly:(float)fromPosition toPosition:(float)toPosition inTime:(float)totalTime;

/**
 效率更高一些

 @param pitch <#pitch description#>
 @param roll <#roll description#>
 @param yaw <#yaw description#>
 @param totalTime <#totalTime description#>
 @param handler <#handler description#>
 */
-(void) moveInNoControlLocaltionSetPointPoweredTo:(float)pitch roll:(float)roll yaw:(float)yaw withInTime:(NSTimeInterval)totalTime compeletion:(void (^)(BOOL success))handler;

-(void)openLocationSetPoint:(void(^)(BOOL success))handler;

-(void)closeLocationSetPoint:(void(^)(BOOL success))handler;

-(void) beginAppControl;

-(void) endAppControl;


/**
 跟踪指令发送

 @param pitch
 @param yaw <#yaw description#>
 @param handler <#handler description#>
 */
- (void)tracckMove:(float)pitch yaw:(float)yaw compeletion:(nullable void (^)(BOOL success))handler;


/**
PositionMove发送
@param pitch 直接给角度
@param roll
@param yaw
@param duration 单位秒
@param handler
 */
- (void)storyPositionMove:(float)pitch roll:(float)roll yaw:(float)yaw duration:(float)duration compeletion:(nullable void (^)(BOOL success))handler;


/**
SpeedMove发送
速度参数[0, 2048, 4096] 对应 [负向最大控制速率, 零速, 正向最大控制速率]
 @param pitch
 @param roll
 @param yaw
 @param duration 单位秒
 @param handler
 */
- (void)storySpeedMove:(int)pitch roll:(int)roll yaw:(int)yaw duration:(float)duration compeletion:(nullable void (^)(BOOL success))handler;

#pragma mark - 保存设置
-(void)saveSettingsWithHandler:(void(^)(BOOL success))handler;
@end
