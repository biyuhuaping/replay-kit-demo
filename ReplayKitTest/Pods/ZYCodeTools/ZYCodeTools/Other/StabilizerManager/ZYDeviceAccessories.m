//
//  ZYDeviceAccessories.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/10/13.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceAccessories.h"
#import "ZYProductSupportFunctionManager.h"

@implementation ZYDeviceAccessories
-(void)setModelNumber:(NSUInteger)modelNumber{
    BOOL needInit = NO;
    if (_modelNumber != modelNumber) {
        needInit = YES;
    }
    _modelNumber = modelNumber;
    if (needInit) {
        _functionModel = [[ZYProductSupportFunctionManager defaultManager] modelWithProductId:modelNumber];
    }
    NSLog(@"----------------_%@",_modelNumberString);
}

@end
