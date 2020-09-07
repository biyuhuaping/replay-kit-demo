//
//  ZYOtheSynData.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/6/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYOtheSynData.h"

NSString *_Nullable const ZYOtherSynDataRecived =@"ZYOtherSynDataRecived";//支持ZYOtheSynData对应的参数
NSString *_Nullable const ZYOtherSynDataRecivedTpyeKey =@"type";//支持ZYOtheSynData对应的参数的key
NSString *_Nullable const ZYOtherSynDataOneStepCalibrationProgressNoti =@"ZYOtherSynDataOneStepCalibrationProgressNoti";//一键校准的noti
NSString *_Nullable const ZYOtherSynDataOneUpgradeOfTheWaitingNotifi =@"ZYOtherSynDataOneUpgradeOfTheWaitingNotifi";//升级进度的noti

NSString *_Nullable const ZYOtherSynDataAutoTrackPositionNoti =@"ZYOtherSynDataAutoTrackPositionNoti";//
NSString *_Nullable const ZYOtherSynDataOneStoryProgressNoti =@"ZYOtherSynDataOneStoryProgressNoti";//
NSString *_Nullable const ZYOtherSynDataMotorAutoProgressNoti =@"ZYOtherSynDataMotorAutoProgressNoti";//电机自动调参数

#pragma -mark 不要更改这个属性
NSString *_Nullable const ZYOtherSynDataProgress =@"progress";//
NSString *_Nullable const ZYOtherSynDataAutoTrackPositionX =@"ZYOtherSynDataAutoTrackPositionX";//
NSString *_Nullable const ZYOtherSynDataAutoTrackPositionY =@"ZYOtherSynDataAutoTrackPositionY";//

@implementation ZYOtheSynData

-(void)dealloc{
       [[NSNotificationCenter defaultCenter] removeObserver:self name:Device_State_Event_Notification_ResourceData object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
          [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventNotification:) name:Device_State_Event_Notification_ResourceData object:nil];
    }
    return self;
}

-(void)eventNotification:(NSNotification *)noti{
    NSDictionary* userInfo = [noti userInfo];
    if ([[userInfo objectForKey:@"type"] isEqualToString:NSStringFromClass([ZYBlOtherSyncData class]) ]) {
       
        [self doUpdateValueWith:(ZYBlOtherSyncData*)[noti object]];
    }
}

-(void)doUpdateValueWith:(ZYBlOtherSyncData *)data{    
    for (CCSConfigSynItem* item in data.configs) {
        [self updateValueWith:item];
    }
}

-(void)updateValueWith:(CCSConfigSynItem *)data{
    if (!data) {
        //        NSLog(@"no wifi data");
        return;
    }
    else{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifi" object:nil userInfo:@{@"key":data}];
        NSLog(@"syndata = %@",data);
    }
    NSString* modleValue = data.itemLists[0];
    BOOL needNoti = NO;
    switch ((ZYOtherSynDataCode)data.idx) {
        case ZYOtherSynDataCodeAll:{
            
            break;
        }
        case ZYOtherSynDataCodeConnectAccessory:{
            if (![self.connectAccessory isEqualToString:modleValue]) {
                self.connectAccessory = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYOtherSynDataCodePath:{
//            if (![self.offlineMoveProgress isEqualToString:modleValue]) {
//                
//              
//            }
            self.offlineMoveProgress = modleValue;
            needNoti = YES;
            break;
        }
        case ZYOtherSynDataCodeGambleMode:{
            
            break;
        }

        case ZYOtherSynDataCodeImageBoxWorkMode:{
            if (![self.imageBoxWorkMode isEqualToString:modleValue]) {
                self.imageBoxWorkMode = modleValue;
                needNoti = YES;
            }
            break;
        }
        case ZYOtherSynDataCodeUpgradeProgress:{
            if (![self.upgradeProgress isEqualToString:modleValue] ) {
                self.upgradeProgress = modleValue;
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYOtherSynDataOneUpgradeOfTheWaitingNotifi object:nil userInfo:@{ZYOtherSynDataProgress:modleValue}];
                needNoti = YES;
            }
            break;
        }
        case ZYOtherSynDataOneStepCalibration:{
            if (![self.oneStepCalibrationProgress isEqualToString:modleValue] ) {
                self.oneStepCalibrationProgress = modleValue;
                [[NSNotificationCenter defaultCenter] postNotificationName:ZYOtherSynDataOneStepCalibrationProgressNoti object:nil userInfo:@{ZYOtherSynDataProgress:modleValue}];
                needNoti = YES;
            }
            break;
        }
        case ZYOtherSynDataStoryProgress:{
                if (![self.storyProgress isEqualToString:modleValue] ) {
                    self.storyProgress = modleValue;
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZYOtherSynDataOneStoryProgressNoti object:nil userInfo:@{ZYOtherSynDataProgress:modleValue}];
                    needNoti = YES;
                }
                break;
        }
        case ZYOtherSynDataAutoTrackPosition:{
                if (![self.autoTrackPosition isEqualToString:modleValue] ) {
                    self.autoTrackPosition = modleValue;
                    if ([modleValue containsString:@","]) {
                        NSArray *array = [modleValue componentsSeparatedByString:@","];
                        if (array.count >= 2) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:ZYOtherSynDataAutoTrackPositionNoti object:nil userInfo:@{ZYOtherSynDataAutoTrackPositionX:array[0],ZYOtherSynDataAutoTrackPositionY:array[1]}];
                                           needNoti = YES;
                        }
                    }
               
                }
                break;
            }
        case ZYOtherSynDataMotorAutoProgress:{
                       if (![self.motorAutoProgress isEqualToString:modleValue] ) {
                           self.motorAutoProgress = modleValue;
                           [[NSNotificationCenter defaultCenter] postNotificationName:ZYOtherSynDataMotorAutoProgressNoti object:nil userInfo:@{ZYOtherSynDataProgress:modleValue}];
                           needNoti = YES;
                       }
                       break;
               }
        default:{
#ifdef DEBUG
            NSLog(@"%lu不支持OtherSyn的idx",(unsigned long)data.idx);
#endif
            break;
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //参数改变
        if (needNoti) {
#pragma -mark 记得提取@"ZYOtherSynDataRecived"
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYOtherSynDataRecived object:nil userInfo:@{ZYOtherSynDataRecivedTpyeKey:@(data.idx)}];
        }
        
    });
}

- (BOOL)imageBoxIsSubDevice{
    if ([self.imageBoxWorkMode isEqualToString:@"0"]) {
        return YES;
    }
    return NO;
}
@end
