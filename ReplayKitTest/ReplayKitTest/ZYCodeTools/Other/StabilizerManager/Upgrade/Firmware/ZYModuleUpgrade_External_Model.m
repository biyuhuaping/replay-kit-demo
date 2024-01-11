//
//  ZYModuleUpgrade_External_Model.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYModuleUpgrade_External_Model.h"
#import "ZYStablizerDefineENUM.h"
#define CheckBit(val, pos) ((val&(0x0001<<pos))==(0x0001<<pos))

@implementation ZYModuleUpgrade_External_Model


-(void)setTarget:(NSString *)target{
    _target = target;
    if (target.length) {
        NSArray *source = [target componentsSeparatedByString:@","];
        if (source.count > 0) {
            _name = [source objectAtIndex:0];
        }
        NSString *tempe = @"0";
        if (source.count > 1) {
                tempe = [source objectAtIndex:1];
        }
        NSUInteger tempIntegerValue = [tempe integerValue];
        if (CheckBit(tempIntegerValue, 0)) {
            _channel = ZYUpgradableChannelBle;
        }
        if (CheckBit(tempIntegerValue, 1)) {
            _channel = ZYUpgradableChannelWiFi;
        }
    }
}

@end
