//
//  ZYStabilizerAxis.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/2/24.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStabilizerAxis.h"
#import "ZYBleDeviceClient.h"

#define ZYBleInteractCodeYawSharpTurning_R ZYBleInteractInvalid
#define Axis_Pitch  0
#define Axis_Roll   1
#define Axis_Yaw    2

#define valueOfMaxFollowRate        maxFollowRate(self.idx)
#define valueOfMaxControlRate       maxControlRate(self.idx)
#define valueOfSmoothness           smoothness(self.idx)
#define valueOfSharpTurning         sharpTurning(self.idx)
#define valueOfDeadArea             deadArea(self.idx)
#define valueOfAntiDirection        antiDirection(self.idx)

static float maxFollowRate(NSUInteger i)
{
    if (i == Axis_Pitch) {
        return [ZYBleDeviceClient defaultClient].dataCache.pitchFollowMaxRate;
    } else if (i == Axis_Roll) {
        return [ZYBleDeviceClient defaultClient].dataCache.rollFollowMaxRate;
    } else if (i == Axis_Yaw) {
        return [ZYBleDeviceClient defaultClient].dataCache.yawFollowMaxRate;
    }
    return 0;
}

static float maxControlRate(NSUInteger i)
{
    if (i == Axis_Pitch) {
        return [ZYBleDeviceClient defaultClient].dataCache.pitchControlMaxRate;
    } else if (i == Axis_Roll) {
        return [ZYBleDeviceClient defaultClient].dataCache.rollControlMaxRate;
    } else if (i == Axis_Yaw) {
        return [ZYBleDeviceClient defaultClient].dataCache.yawControlMaxRate;
    }
    return 0;
}

static float smoothness(NSUInteger i)
{
    if (i == Axis_Pitch) {
        return [ZYBleDeviceClient defaultClient].dataCache.pitchSmoothness;
    } else if (i == Axis_Roll) {
        return [ZYBleDeviceClient defaultClient].dataCache.rollSmoothness;
    } else if (i == Axis_Yaw) {
        return [ZYBleDeviceClient defaultClient].dataCache.yawSmoothness;
    }
    return 0;
}

static float sharpTurning(NSUInteger i)
{
    if (i == Axis_Pitch) {
        return [ZYBleDeviceClient defaultClient].dataCache.pitchSharpTurning;
    } else if (i == Axis_Roll) {
        return [ZYBleDeviceClient defaultClient].dataCache.rollSharpTurning;
    } else if (i == Axis_Yaw) {
        return 0;
    }
    return 0;
}

static float deadArea(NSUInteger i)
{
    if (i == Axis_Pitch) {
        return [ZYBleDeviceClient defaultClient].dataCache.pitchDeadArea;
    } else if (i == Axis_Roll) {
        return [ZYBleDeviceClient defaultClient].dataCache.rollDeadArea;
    } else if (i == Axis_Yaw) {
        return [ZYBleDeviceClient defaultClient].dataCache.yawDeadArea;
    }
    return 0;
}

static BOOL antiDirection(NSUInteger i)
{
    if (i == Axis_Pitch) {
        return [ZYBleDeviceClient defaultClient].dataCache.bControllerXAnti;
    } else if (i == Axis_Roll) {
        return [ZYBleDeviceClient defaultClient].dataCache.bControllerYAnti;
    } else if (i == Axis_Yaw) {
        return [ZYBleDeviceClient defaultClient].dataCache.bControllerZAnti;
    }
    return 0;
}

@interface ZYStabilizerAxis()


@property (nonatomic, readonly) NSUInteger maxFollowRateCode;
@property (nonatomic, readonly) NSUInteger maxControlRateCode;
@property (nonatomic, readonly) NSUInteger smoothnessCode;
//@property (nonatomic, readonly) NSUInteger sharpTurningCode;
@property (nonatomic, readonly) NSUInteger deadAreaCode;
@property (nonatomic, readonly) NSUInteger directionMask;

@property (nonatomic, readwrite) ZYStabilizerAxisConfig* curConfig;
@end

@implementation ZYStabilizerAxis

-(instancetype) initWithIdx:(NSUInteger) idx
{
    if ([self init]) {
        _idx = idx;
        if (_idx == 0) {
            _motionAngleCode = ZYBleInteractPitchMotionControl;
            _controlCode = ZYBleInteractPitchControl;
            _angleCode = ZYBleInteractCodePitchAngle_R;
            _maxFollowRateCode = ZYBleInteractCodePitchFollowMaxRate_R;
            _maxControlRateCode = ZYBleInteractCodePitchControlMaxRate_R;
            _smoothnessCode = ZYBleInteractCodePitchSmoothness_R;
//            _sharpTurningCode = ZYBleInteractCodePitchSharpTurning_R;
            _deadAreaCode = ZYBleInteractCodePitchDeadArea_R;
            _directionMask = self.idx;
        } else if (_idx == 1) {
            _motionAngleCode = ZYBleInteractRollMotionControl;
            _controlCode = ZYBleInteractRollControl;
            _angleCode = ZYBleInteractCodeRollAngle_R;
            _maxFollowRateCode = ZYBleInteractCodeRollFollowMaxRate_R;
            _maxControlRateCode = ZYBleInteractCodeRollControlMaxRate_R;
            _smoothnessCode = ZYBleInteractCodeRollSmoothness_R;
//            _sharpTurningCode = ZYBleInteractCodeRollSharpTurning_R;
            _deadAreaCode = ZYBleInteractCodeRollDeadArea_R;
            _directionMask = self.idx;
        } else if (_idx == 2) {
            _motionAngleCode = ZYBleInteractYawMotionControl;
            _controlCode = ZYBleInteractYawControl;
            _angleCode = ZYBleInteractCodeYawAngle_R;
            _maxFollowRateCode = ZYBleInteractCodeYawFollowMaxRate_R;
            _maxControlRateCode = ZYBleInteractCodeYawControlMaxRate_R;
            _smoothnessCode = ZYBleInteractCodeYawSmoothness_R;
//            _sharpTurningCode = ZYBleInteractCodeYawSharpTurning_R;
            _deadAreaCode = ZYBleInteractCodeYawDeadArea_R;
            _directionMask = self.idx;
        }
        _curConfig = [[ZYStabilizerAxisConfig alloc] init];
    }
    return self;
}

-(NSString*) name
{
    if (_idx == 0) {
        return @"Pitch";
    } else if (_idx == 1) {
        return @"Roll";
    } else if (_idx == 2) {
        return @"Yaw";
    }
    return @"Undefined Axis";
}

-(NSInteger) direction
{
    return _curConfig.antiDiretion?-1:1;
}

-(void)loadConfigFromStabilizer:(void (^)(BOOL success))handler
{
    NSUInteger configRequestCount = 4;
    __block NSUInteger configRespondCount = 0;
    __block BOOL result = YES;
    void(^requestCheck)(BOOL success) = ^(BOOL success) {
        result &= success;
        configRespondCount++;
        if (configRespondCount == configRequestCount) {
            BLOCK_EXEC(handler, result);
        }
    };
    
    
    @weakify(self)
    [self sendRequest:self.maxFollowRateCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            self.curConfig.maxFollowRate = valueOfMaxFollowRate;
            BLOCK_EXEC(requestCheck, YES);
        } else {
            BLOCK_EXEC(requestCheck, NO);
        }
        [self sendRequest:self.maxControlRateCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            @strongify(self)
            if (state == ZYBleDeviceRequestStateResponse) {
                self.curConfig.maxControlRate = valueOfMaxControlRate;
                BLOCK_EXEC(requestCheck, YES);
            } else {
                BLOCK_EXEC(requestCheck, NO);
            }
            [self sendRequest:self.smoothnessCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                @strongify(self)
                if (state == ZYBleDeviceRequestStateResponse) {
                    self.curConfig.smoothness = valueOfSmoothness;
                    BLOCK_EXEC(requestCheck, YES);
                } else {
                    BLOCK_EXEC(requestCheck, NO);
                }
                [self sendRequest:self.deadAreaCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    @strongify(self)
                    if (state == ZYBleDeviceRequestStateResponse) {
                        self.curConfig.deadArea = valueOfDeadArea;
                        BLOCK_EXEC(requestCheck, YES);
                    } else {
                        BLOCK_EXEC(requestCheck, NO);
                    }
                    [self sendRequest:ZYBleInteractCodeRockerDirectionConfig_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                        @strongify(self)

                        if (state == ZYBleDeviceRequestStateResponse) {
                            self.curConfig.antiDiretion = valueOfAntiDirection;
                            BLOCK_EXEC(requestCheck, YES);
                        } else {
                            BLOCK_EXEC(requestCheck, NO);
                        }
                    }];
                }];

            }];
            
        }];
    }];
    
   
    
  
    
//    [client sendRequest:_sharpTurningCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
//        if (state == ZYBleDeviceRequestStateResponse) {
//            self.curConfig.maxSharpTurning = valueOfSharpTurning;
//            BLOCK_EXEC(requestCheck, YES);
//        } else {
//            BLOCK_EXEC(requestCheck, self.sharpTurningCode == ZYBleInteractInvalid);
//        }
//    }];
    
    
  
}

-(void)sendMaxFollowRateCodeWithStabilizer:(ZYStabilizerAxisConfig*)config compeletion:(void (^)(BOOL success))requestCheck{
    if ([config.exceptKeys containsObject:@"maxFollowRate"]) {
        BLOCK_EXEC(requestCheck, YES);
    }
    else{
        @weakify(self)
        [self sendRequest:ZYBLEDataReadCodeToWriteCode(self.maxFollowRateCode) data:@(config.maxFollowRate) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                   @strongify(self)
                   if (state == ZYBleDeviceRequestStateResponse) {
                       self.curConfig.maxFollowRate = valueOfMaxFollowRate;
                       BLOCK_EXEC(requestCheck, YES);
                   } else {
                       BLOCK_EXEC(requestCheck, NO);
                   }
                   
               }];
    }
}

-(void)sendMaxControlRateCodeWithStabilizer:(ZYStabilizerAxisConfig*)config compeletion:(void (^)(BOOL success))requestCheck{
  if ([config.exceptKeys containsObject:@"maxControlRate"]) {
        BLOCK_EXEC(requestCheck, YES);
    }
    else{
        @weakify(self)
        [self sendRequest:ZYBLEDataReadCodeToWriteCode(self.maxControlRateCode) data:@(config.maxControlRate) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            @strongify(self)
            
            if (state == ZYBleDeviceRequestStateResponse) {
                self.curConfig.maxControlRate = valueOfMaxControlRate;
                BLOCK_EXEC(requestCheck, YES);
            } else {
                BLOCK_EXEC(requestCheck, NO);
            }
            
        }];
    }
}

-(void)sendSmoothnessCodeWithStabilizer:(ZYStabilizerAxisConfig*)config compeletion:(void (^)(BOOL success))requestCheck{
  if ([config.exceptKeys containsObject:@"smoothness"]) {
      BLOCK_EXEC(requestCheck, YES);
  }
  else{
      @weakify(self)

      [self sendRequest:ZYBLEDataReadCodeToWriteCode(self.smoothnessCode) data:@(config.smoothness) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
          @strongify(self)
          
          if (state == ZYBleDeviceRequestStateResponse) {
              self.curConfig.smoothness = valueOfSmoothness;
              BLOCK_EXEC(requestCheck, YES);
          } else {
              BLOCK_EXEC(requestCheck, NO);
          }
          
      }];
      
  }
}

-(void)sendDeadAreaCodeWithStabilizer:(ZYStabilizerAxisConfig*)config compeletion:(void (^)(BOOL success))requestCheck{
  if ([config.exceptKeys containsObject:@"deadArea"]) {
      BLOCK_EXEC(requestCheck, YES);
  }
  else{
      @weakify(self)
      [self sendRequest:ZYBLEDataReadCodeToWriteCode(self.deadAreaCode) data:@(config.deadArea) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
          @strongify(self)
          
          if (state == ZYBleDeviceRequestStateResponse) {
              self.curConfig.deadArea = valueOfDeadArea;
              BLOCK_EXEC(requestCheck, YES);
          } else {
              BLOCK_EXEC(requestCheck, NO);
          }
      }];
  }
}






-(void)configurateStabilizer:(ZYStabilizerAxisConfig*)config compeletion:(void (^)(BOOL success))handler
{
    NSUInteger configRequestCount = 4;
    __block NSUInteger configRespondCount = 0;
    __block BOOL result = YES;
    void(^requestCheck)(BOOL success) = ^(BOOL success) {
        result &= success;
        configRespondCount++;
        if (configRespondCount == configRequestCount) {
            if (result) {
                self.curConfig = config;
            }
            NSLog(@"%@ 配置%d", self.name, success);
            BLOCK_EXEC(handler, result);
        }
    };
    
    config = config?:_curConfig;
    
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:_maxFollowRateCode param:@(0)];
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    
    if (request.trasmissionType == ZYTrasmissionTypeWIFI) {
        
        @weakify(self)
        [self sendMaxFollowRateCodeWithStabilizer:config compeletion:^(BOOL success) {
            @strongify(self)

            BLOCK_EXEC(requestCheck, success);
            [self sendMaxControlRateCodeWithStabilizer:config compeletion:^(BOOL success) {
                @strongify(self)

                BLOCK_EXEC(requestCheck, success);
                [self sendSmoothnessCodeWithStabilizer:config compeletion:^(BOOL success) {
                    @strongify(self)

                    BLOCK_EXEC(requestCheck, success);
                    [self sendDeadAreaCodeWithStabilizer:config compeletion:requestCheck];

                }];

            }];
            
        }];
    }
    else{
        [self sendMaxFollowRateCodeWithStabilizer:config compeletion:requestCheck];
        [self sendMaxControlRateCodeWithStabilizer:config compeletion:requestCheck];
        [self sendSmoothnessCodeWithStabilizer:config compeletion:requestCheck];
        [self sendDeadAreaCodeWithStabilizer:config compeletion:requestCheck];

    }
    
    
    
//    NSUInteger sharpTurningCode = _sharpTurningCode == ZYBleInteractInvalid?ZYBleInteractInvalid:ZYBLEDataReadCodeToWriteCode(_sharpTurningCode);
//    [client sendRequest:sharpTurningCode data:@(config.maxSharpTurning) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
//        if (state == ZYBleDeviceRequestStateResponse) {
//            self.curConfig.maxSharpTurning = valueOfSharpTurning;
//            BLOCK_EXEC(requestCheck, YES);
//        } else {
//            BLOCK_EXEC(requestCheck, sharpTurningCode == ZYBleInteractInvalid);
//        }
//    }];
    
  
}

-(void) sendRequest:(NSUInteger)code completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    [self sendRequest:code data:@(0) completionHandler:handler];
}

-(void) sendRequest:(NSUInteger)code data:(NSNumber*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    request.mask = ZYBleDeviceRequestMaskMulty;
    [[ZYBleDeviceClient defaultClient] sendBLERequest:request completionHandler:handler];
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"<ZYStabilizerAxis: 0x%x %@ config= %@;>", (unsigned int)self, [self name], _curConfig];
}



@end
