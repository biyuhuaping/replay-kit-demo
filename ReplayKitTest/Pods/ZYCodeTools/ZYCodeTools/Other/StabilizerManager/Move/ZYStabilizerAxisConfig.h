//
//  ZYStabilizerAxisConfig.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/3/15.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYStabilizerAxisConfig : NSObject
/**
需要去除的设置的keys
*/
@property (nonatomic, strong) NSArray *exceptKeys;


/**
 <#Description#>最大跟随速率
 */
@property (nonatomic, readwrite) float maxFollowRate;

/**
 <#Description#>最大控制速率
 */
@property (nonatomic, readwrite) float maxControlRate;

/**
 <#Description#>加速度
 */
@property (nonatomic, readonly) float maxAccelerate;

/**
 <#Description#>平滑度
 */
@property (nonatomic, readwrite) NSUInteger smoothness;

/**
 <#Description#>微调
 */
@property (nonatomic, readwrite) float maxSharpTurning;

/**
 <#Description#>死区
 */
@property (nonatomic, readwrite) float deadArea;

/**
 <#Description#>控制反向
 */
@property (nonatomic, readwrite) BOOL antiDiretion;

@end
