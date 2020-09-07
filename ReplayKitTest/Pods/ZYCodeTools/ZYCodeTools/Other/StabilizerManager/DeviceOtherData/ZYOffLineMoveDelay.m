//
//  ZYOffLineMoveDelay.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYOffLineMoveDelay.h"
#import "ZYDeviceStabilizer.h"
#import "ZYDeviceStabilizer+OfflineMoveDelay.h"

NSString * _Nonnull  const ZYDCOffLineCapturing = @"ZYDCOffLineCapturing";


@interface ZYOffLineMoveDelay()

@property (weak,nonatomic) ZYDeviceStabilizer *stablizer;

@end

@implementation ZYOffLineMoveDelay
- (instancetype)initWith:(ZYDeviceStabilizer *)stablizer
{
    self = [super init];
    if (self) {
        _stablizer = stablizer;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherSynDataRecived:) name:ZYOtherSynDataRecived object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZYOtherSynDataRecived object:nil];
}

-(void)otherSynDataRecived:(NSNotification *)noti{
    if ([noti.name isEqualToString:ZYOtherSynDataRecived]) {
        NSNumber *value = [noti.userInfo objectForKey:ZYOtherSynDataRecivedTpyeKey];
        if (value) {
            ZYOtherSynDataCode codeType = (ZYOtherSynDataCode )[value unsignedIntegerValue];
            if (codeType == ZYOtherSynDataCodePath && self.stablizer.supportOffLineMoveDelay) {
                if ([self.stablizer.otherSynData.offlineMoveProgress isEqualToString:@"0"]) {
                    
                    [self.stablizer queryJsonFileIfFormatAvalueble:ZYBlOtherCustomFileDataFormatPathPoint complete:^(BOOL success, id info) {
                        if (success) {
                            if ([info isKindOfClass:[NSArray class]]) {
                                self.offlineMoveProgressArray = info;
                                NSLog(@"-llll--%@",self.offlineMoveProgressArray);
                                
                            }
                            [self.stablizer setOffMovelineWithStatus:ZYBlOtherCmdMoveLineStatueTypeBegain Cmd:^(BOOL success, ZYBlOtherCmdMoveLineStatueData *info) {
                                if (success) {
                                    
                                }
                            }];
                        }
                    }];
                    
                    
                }
                else{
                    if (self.offlineMoveProgressArray == nil) {
                        [self.stablizer queryJsonFileIfFormatAvalueble:ZYBlOtherCustomFileDataFormatPathPoint complete:^(BOOL success, id info) {
                            if (success) {
                                if ([info isKindOfClass:[NSArray class]]) {
                                    
                                    self.offlineMoveProgressArray = info;
                                    NSLog(@"----%@",self.offlineMoveProgressArray);

                                }
                            }
                        }];
                    }
                    if (self.totalCaptureCount > 0) {
                        self.captureCount = [self.stablizer.otherSynData.offlineMoveProgress integerValue];
                        self.offlineProgress = (self.captureCount * 1.0) / self.totalCaptureCount;
                        [[NSNotificationCenter defaultCenter] postNotificationName:ZYDCOffLineCapturing object:nil userInfo:@{@"total":@(self.totalCaptureCount),@"num":@(self.captureCount)}];
                    }
                    NSLog(@"offlineProgress =%f",self.offlineProgress);
                }
            }
            
        }
    }
}

-(void)setOfflineMoveProgressArray:(NSArray *)offlineMoveProgressArray{
    _offlineMoveProgressArray = offlineMoveProgressArray;
    NSInteger totalCount = 0;
    for (NSString *value in offlineMoveProgressArray) {
        NSInteger valuess = [value integerValue];
        totalCount += fabs(valuess);

    }
    self.totalCaptureCount = totalCount;
}
@end
