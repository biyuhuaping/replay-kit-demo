//
//  ZYStabilizerAxisConfig.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/3/15.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStabilizerAxisConfig.h"

@implementation ZYStabilizerAxisConfig

-(NSString*) description
{
    return [NSString stringWithFormat:@"<ZYStabilizerAxisConfig:0x%x maxFollowRate=%.3fd/s; maxControlRate=%.3fd/s; maxAccelerate=(%.3fd/s^2, %ld); sharpturning=%.3f; deadArea=%.3f; antiDirection=%@>", (unsigned int)self, self.maxFollowRate, self.maxControlRate, self.maxAccelerate, self.smoothness, self.maxSharpTurning, self.deadArea, self.antiDiretion?@"YES":@"NO"];
}

-(void) setSmoothness:(NSUInteger)smoothness
{
    _smoothness = smoothness;
    _maxAccelerate = smoothness*2.0;
}

@end
