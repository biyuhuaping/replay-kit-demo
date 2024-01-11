//
//  ZYStabilizerHardwareMotion.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/4/7.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYStabilizerHardwareMotion : NSObject
/**
 <#Description#>控制指令代号
 */
@property (nonatomic, assign) NSUInteger controlCode;

/**
 <#Description#>角度指令代号
 */
@property (nonatomic, assign) NSUInteger angleCode;

@property(nonatomic, assign) float angle ;

+(instancetype)stabilizerHardwareMotionAxisWithControlCode:(NSUInteger)controlCode angleCode:(NSUInteger)angleCode angle:(float)angle;

@end
