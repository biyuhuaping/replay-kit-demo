//
//  ZYBleDeviceMotorModel.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/17.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYBleDeviceMotorModel : NSObject

@property (nonatomic, readwrite) NSUInteger softwareVersion;

@property (nonatomic, readwrite) BOOL bOffLine;
@property (nonatomic, readwrite) BOOL bOverheat;
@property (nonatomic, readwrite) BOOL bPowerTrouble;
@property (nonatomic, readwrite) BOOL bZeroException;
@property (nonatomic, readwrite) BOOL bFeedbackException;
@property (nonatomic, readwrite) BOOL bWorking;
@property (nonatomic, readwrite) BOOL bReady;

@end
