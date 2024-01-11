//
//  ZYDeviceStabilizer+BodySensation.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/19.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceStabilizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYDeviceStabilizer (BodySensation) // 体感

/**
 读取体感的 平滑度 和 最大速度

 @param direction 方向
 @param completionHandler 回调
 */
-(void)readSomatosenoryAndMaximumSpeedByStabilizerDirection:(ZYStabilizeAxis )direction  completionHandler:(void(^)(BOOL success,short somatosenory,short maximumSpeed))completionHandler;

/**
 一次读取3个轴的平滑度和最大速度
 */
- (void)getMotionSpeedAndSmoothWithComplete:(void (^)(BOOL success, _Nullable id info))complete;
/**
 写入体感的 平滑度 和 最大速度

 @param somatosenory 平滑度 0 - 50
 @param maxSpeed 最大速度  0 - 100
 @param direction 方向
 @param completionHandler 回调
 */
//-(void)WriteBodySensationBySomatosenory:(short)somatosenory maximumSpeed:(short)maxSpeed direction:(ZYStabilizeAxis )direction  completionHandler:(void (^)(ZYBleDeviceRequestState state, NSUInteger param,short somatosenory,short maximumSpeed))completionHandler;


/**
 设置体感最大速度和平滑度

 @param requestArray 格式化的指令参数数组
 @param complete 回调
 */
- (void)setMotionSpeedAndSmooth:(NSArray <NSDictionary *>*)requestArray complete:(void (^)(BOOL success))complete;

+ (NSDictionary *)formatMotionDict:(ZYStabilizeAxis)axis speed:(NSUInteger)speed smooth:(NSUInteger)smooth;

@end

NS_ASSUME_NONNULL_END
