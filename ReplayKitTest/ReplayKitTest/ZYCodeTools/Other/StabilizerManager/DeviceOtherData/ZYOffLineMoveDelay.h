//
//  ZYOffLineMoveDelay.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ZYOtheSynData.h"
extern NSString * _Nonnull  const ZYDCOffLineCapturing;

@class ZYDeviceStabilizer;
NS_ASSUME_NONNULL_BEGIN

@interface ZYOffLineMoveDelay : NSObject

/**
 进度数组
 */
@property (strong,nonatomic) NSArray *offlineMoveProgressArray;

/**
 移动延时摄影的进度
 */
@property (nonatomic) CGFloat offlineProgress;
/**
 移动延时摄影的总拍照个数
 */
@property (nonatomic) NSUInteger totalCaptureCount;
/**
 移动延时摄影的拍照张数
 */
@property (nonatomic) NSUInteger captureCount;


/**
 初始化

 @param stablizer 对象
 @return 返回的对象
 */
- (instancetype)initWith:(ZYDeviceStabilizer *)stablizer;

@end

NS_ASSUME_NONNULL_END
