//
//  ZYAxisCalibrationLoop.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/2.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYAxisCalibrationLoop.h"
#import "ZYBleDeviceClient.h"
#import "SpaceBlocksHandle.h"

#define kMaxAngleValue 4096.0f

#define kMaxgyroStandardValue 100.0f

@interface ZYAxisCalibrationLoop(){
    NSArray *axisMap;
}
@property (nonatomic, copy) SpaceDelayedBlockHandle delayedBlockHandle;


@end

@implementation ZYAxisCalibrationLoop


-(instancetype)init{
    if (self = [super init]) {
        axisMap = @[
                    @[ @1.0f,  @0.0f,  @0.0f],
                    @[@-1.0f,  @0.0f,  @0.0f],
                    @[ @0.0f,  @1.0f,  @0.0f],
                    @[ @0.0f, @-1.0f,  @0.0f],
                    @[ @0.0f,  @0.0f,  @1.0f],
                    @[ @0.0f,  @0.0f, @-1.0f],
                    ];
    }
    return self;
}

-(void)loopQueryAnglesIsStandardWithCompleted:(void(^)(void))completed{
    @weakify(self)               

    [self queryValueWithQuaryCode:ZYBleInteractCodeIMUAX_R Completed:^() {

        @strongify(self)
        [self queryValueWithQuaryCode:ZYBleInteractCodeIMUAY_R Completed:^() {
            @strongify(self)
            
            [self queryValueWithQuaryCode:ZYBleInteractCodeIMUAZ_R Completed:^() {
                @strongify(self)
                [self queryValueWithQuaryCode:ZYBleInteractCodeGyroStandardDeviation_R Completed:^() {
                    @strongify(self)
                    if ([self calculateAxisMap]) {
                        BLOCK_EXEC(completed);
                        
                    }else{
                        
                        [self loopQueryAnglesIsStandardWithCompleted:completed];
                    }
                }];
            }];
        }];
    }];
}

-(BOOL)calculateAxisMap{
    float percentageX = self.x / kMaxAngleValue;
    float percentageY = self.y / kMaxAngleValue;
    float percentageZ = self.z / kMaxAngleValue;
    float percentageGyroStandard = self.gyroStandardDifference / kMaxgyroStandardValue;
    
    float mod = (float)sqrt(percentageX * percentageX + percentageY * percentageY + percentageZ * percentageZ);
    
    return ((fabsf(percentageGyroStandard) <= 0.3f) &&
            (fabsf(mod - 1.0f) <= 0.25f) &&
            (fabsf(percentageX - [axisMap[_axisMapindex][0] floatValue]) <= 0.3f) &&
            (fabsf(percentageY - [axisMap[_axisMapindex][1] floatValue]) <= 0.3f) &&
            (fabsf(percentageZ - [axisMap[_axisMapindex][2] floatValue]) <= 0.3f));
    
}

-(void)queryValueWithQuaryCode:(NSInteger)queryCode Completed:(void(^)())completed{
    
        ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
        @weakify(self)
        [self sendRequest:queryCode  completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            @strongify(self)
            if (state == ZYBleDeviceRequestStateResponse) {
                float value =client.dataCache.IMUAX ;
                switch (queryCode) {
                    case ZYBleInteractCodeIMUAX_R:
                        self.x = value = client.dataCache.IMUAX ;
                        break;
                    case ZYBleInteractCodeIMUAY_R:
                        self.y = value = client.dataCache.IMUAY ;
                        break;
                    case ZYBleInteractCodeIMUAZ_R:
                        self.z = value = client.dataCache.IMUAZ ;
                        
                        break;
                    case ZYBleInteractCodeGyroStandardDeviation_R:
                        self.gyroStandardDifference = value = client.dataCache.gyroStandardDeviation ;
                    default:
                        break;
                }
                BLOCK_EXEC(completed);
                
            }else{
                self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                    @strongify(self)
                    [self queryValueWithQuaryCode:queryCode Completed:completed];
                    self.delayedBlockHandle = nil;
                });
                
            }
        }];
}

-(void)closeLoop{
    if (nil != _delayedBlockHandle) {
        _delayedBlockHandle(YES);
    }
    _delayedBlockHandle = nil;
}
-(void) sendRequest:(NSUInteger)code completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:@(0)];
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    [[ZYBleDeviceClient defaultClient] sendBLERequest:request completionHandler:handler];
}

@end
