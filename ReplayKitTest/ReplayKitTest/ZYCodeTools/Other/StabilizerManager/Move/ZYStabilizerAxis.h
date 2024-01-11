//
//  ZYStabilizerAxis.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/2/24.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYStabilizerAxisConfig.h"
#import "ZYSendRequest.h"

@interface ZYStabilizerAxis : NSObject
@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;

/**
 <#Description#>轴的索引
 */
@property (nonatomic, readonly) NSUInteger idx;

/**
 <#Description#>控制指令代号
 */
@property (nonatomic, readonly) NSUInteger controlCode;

/**
 体感角度指令代号
 */
@property (nonatomic, readonly) NSUInteger motionAngleCode;

/**
 <#Description#>角度指令代号
 */
@property (nonatomic, readonly) NSUInteger angleCode;

/**
 <#Description#>轴的名称
 */
@property (nonatomic, readonly, copy) NSString* name;

/**
 <#Description#>轴的控制方向
 */
@property (nonatomic, readonly) NSInteger direction;

/**
 <#Description#>当前位置
 */
@property (nonatomic, readwrite) float curPosition;

/**
 <#Description#>上次位置
 */
@property (nonatomic, readwrite) float prePosition;

/**
 <#Description#>移动开始位置
 */
@property (nonatomic, readwrite) float startPosition;

/**
 <#Description#>移动结束位置
 */
@property (nonatomic, readwrite) float finishPosition;

/**
 <#Description#>当前速率比例
 */
@property (nonatomic, readwrite) NSUInteger rateFactor;

/**
<#Description#>移动的时间戳
*/
@property (nonatomic, readwrite) NSDate* startMoveTimeStamp;
    
/**
 移动的时间戳
 */
@property (nonatomic, readwrite) NSDate* lastMoveTimeStamp;
    
/**
 <#Description#>移动总时间
 */
@property (nonatomic, readwrite) NSTimeInterval totalTime;

/**
 <#Description#>移动全程平均速度估计
 */
@property (nonatomic, readwrite) float predictedAverageRate;

/**
 <#Description#>移动全程平均速度
 */
@property (nonatomic, readwrite) float acturalAverageRate;

/**
 <#Description#>当前轴配置信息
 */
@property (nonatomic, readonly) ZYStabilizerAxisConfig* curConfig;

-(instancetype) initWithIdx:(NSUInteger) idx;

-(void)loadConfigFromStabilizer:(void (^)(BOOL success))handler;

-(void)configurateStabilizer:(ZYStabilizerAxisConfig*)config compeletion:(void (^)(BOOL success))handler;

@end
