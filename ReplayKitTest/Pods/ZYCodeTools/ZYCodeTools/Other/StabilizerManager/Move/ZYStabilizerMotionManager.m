//
//  ZYStabilizerMotionManager.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/2/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStabilizerMotionManager.h"
#import "ZYStabilizerAxis.h"
#import "ZYBleDeviceClient.h"
#import "ZYParaCustomSettingModel.h"
#import "ZYStabilizerHardwareMotion.h"
#import "ZYBlRdisData.h"
#import "ZYBlTrackData.h"
#import "ZYStablizerDefineENUM.h"
#import "SpaceBlocksHandle.h"
#import "ZYBlStoryCtrlPositionData.h"
#import "ZYBlStoryCtrlSpeedData.h"
#import "ZYProductSupportFunctionModel.h"

typedef NS_ENUM(NSInteger,ZYBLEMotionControlType) {
    ZYBLEMotionControlTypeSoftware = 0,
    ZYBLEMotionControlTypeHareware = 1
};
#define PitchIndex  0
#define RollIndex   1
#define YawIndex    2
#define MAX_AXIS_COUNT      3
#define MOVE_INTERVAL       0.15

#define START_ANGLE_NOINIT               STABILIZER_AXIS_VALUE_NO_CHANGE
#define FINISH_ANGLE_NOINIT              STABILIZER_AXIS_VALUE_NO_CHANGE+1000
#define FINISH_ANGLE_NOINIT_MINVALUE     FINISH_ANGLE_NOINIT-180

#define VALUE_THREASHOLD        (1.0)
#define DEGREE_IS_EQUAL(a, b)   (fabs(a-b)<VALUE_THREASHOLD)
#define sign(v)                 (((v)>=0)?1:-1)

#define MAX_SPEED   2048

#define PitchAxis   [self.axisArray objectAtIndex:0]
#define RollAxis    [self.axisArray objectAtIndex:1]
#define YawAxis     [self.axisArray objectAtIndex:2]


#define Axis(Idx)   [self.axisArray objectAtIndex:Idx]
#define AxisReached(Idx) [self isAxisReached:[self.axisArray objectAtIndex:Idx]]

#define kLoopTimeTnterval 0.1f
#define kCheckTimeTnterval 1.0f



typedef NS_ENUM(NSInteger,ZYHardwareMotionStep) {
    ZYHardwareMotionStep_SetWorkModel= 0,

    //    ZYHardwareMotionStep_LocationSetPointClean,
    ZYHardwareMotionStep_LocationSetOpenEanble ,
    ZYHardwareMotionStep_SetMotionAxis,
    ZYHardwareMotionStep_SetDurationTime,
    ZYHardwareMotionStep_startLocaltionSetPointControl ,

    ZYHardwareMotionStep_MindLocationControlRegisterToCompleted,
    ZYHardwareMotionStep_CloseLocationSetEanble
};

//typedef NS_ENUM(NSInteger,ZYLocationSetPointRegisterState) {
//    ZYLocationSetPointRegisterState
//};
static float AxisDegree(NSUInteger i)
{
    if (i == 0) {
        return [ZYBleDeviceClient defaultClient].dataCache.pitchAngle;
    } else if (i == 1) {
        return [ZYBleDeviceClient defaultClient].dataCache.rollAngle;
    } else if (i == 2) {
        return [ZYBleDeviceClient defaultClient].dataCache.yawAngle;
    }
    return 0;
}

static int minDistanceDirection(float startPos, float endPos)
{
    if (fabs(endPos - startPos) > 180) {
        return -sign(endPos - startPos);
    } else {
        return sign(endPos - startPos);
    }
}

static float minDistance(float startPos, float endPos)
{
    float dis = fabs(endPos - startPos);
    return dis > 180 ? 360-dis : dis;
}

@interface ZYStabilizerMotionManager ()
@property (nonatomic, copy) SpaceDelayedBlockHandle delayedBlockHandle;
@property(nonatomic, readwrite) BOOL isMoving;
@property(nonatomic, readwrite, strong) NSArray<ZYStabilizerAxis*>* axisArray;
@property(nonatomic, readwrite, copy) void (^compeletionHandler)(BOOL success);

@property(nonatomic, assign)ZYHardwareMotionStep harewareMotionStep ;

@property(nonatomic, strong)NSMutableArray *movtionAxis;

@property(nonatomic, assign)int movtionDuration ;

@property(nonatomic, assign)BOOL isCancel ;

@property(nonatomic, assign)NSTimeInterval downTimerSeconds ;

@property(nonatomic, strong)NSTimer *timeoutTimer;

@property(nonatomic, assign)BOOL isNoControlLocaltionSetPointPowered ;

/**
 当前设备的工作模式,
 */
@property (nonatomic, readwrite)         ZYBleDeviceWorkMode  workMode;


/**
 内部实现移动的类型，
 硬件移动需要，硬件V1.60版本以上才能使用.
 */
@property(nonatomic, assign)ZYBLEMotionControlType MotionControlType ;

@end

@implementation ZYStabilizerMotionManager

-(void)setSendDelegate:(id<ZYSendRequest>)sendDelegate{
    _sendDelegate = sendDelegate;
    for (ZYStabilizerAxis *axis in self.axisArray) {
        axis.sendDelegate = sendDelegate;
    }
}

-(instancetype) init
{
    self = [super init];
    if (self) {
        ZYStabilizerAxis *pitchAxis = [[ZYStabilizerAxis alloc] initWithIdx:0];
        ZYStabilizerAxis *rollAxis = [[ZYStabilizerAxis alloc] initWithIdx:1];
        ZYStabilizerAxis *yawAxis = [[ZYStabilizerAxis alloc] initWithIdx:2];

        self.axisArray = [NSArray arrayWithObjects:pitchAxis, rollAxis, yawAxis, nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceBLEOffLine:) name:Device_BLEOffLine object:nil];
        _workMode = ZYBleDeviceWorkModeUnkown;
        _MotionControlType = ZYBLEMotionControlTypeHareware;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraParaChange:) name:Device_State_Event_Notification_ResourceData object:nil];
    }
    return self;
}

+(BOOL)p_softwareMoveWithModelNumberString:(NSString *)modelString{
     if ([@[modelNumberPround,
              modelNumberEvolution,
              modelNumberSmooth,
              modelNumberSmooth2,
              modelNumberSmoothQ,
              modelNumberRider,
              modelNumberRiderM,
              modelNumberCrane,
              modelNumberCraneM,
              modelNumberCraneS,
              modelNumberCraneL,
              modelNumberCraneH,
              modelNumberCranePlus,
              modelNumberShining,
              modelNumberUnknown]
            containsObject:modelString]) {
           return YES;
     }
     else{
         return NO;
     }
    
}

-(void)configMotionControlTypeWithSoftWithsoftwareVersion:(NSString *)softwareVersion andModelNumberString:(NSString *)modelNumberString{
    if ([[self class] p_softwareMoveWithModelNumberString:modelNumberString]) {
         if ([softwareVersion   compare: @"160"]  == NSOrderedDescending || [softwareVersion   compare: @"160"]  == NSOrderedSame) {
               self.MotionControlType = ZYBLEMotionControlTypeHareware ;
          }else{
              self.MotionControlType = ZYBLEMotionControlTypeSoftware ;
          }
    }else{
        self.MotionControlType = ZYBLEMotionControlTypeHareware ;
    }
}

-(void)setWorkMode:(ZYBleDeviceWorkMode)workMode{
    if (_workMode != workMode) {
        _workMode = workMode;
        [[NSNotificationCenter defaultCenter] postNotificationName:ZYDeviceWorkModeChangeNoti object:@(workMode)];
    }
}

-(void) moveInNoControlLocaltionSetPointPoweredTo:(float)pitch roll:(float)roll yaw:(float)yaw withInTime:(NSTimeInterval)totalTime compeletion:(void (^)(BOOL success))handler
{
    pitch = [self p_fixValue:pitch];
    roll = [self p_fixValue:roll];
    yaw =  [self p_fixValue:yaw];
    _isNoControlLocaltionSetPointPowered = YES;
    if (self.MotionControlType == ZYBLEMotionControlTypeHareware) {
        [self byHardwareControlMovePitch:pitch roll:roll yaw:yaw durartion:totalTime completion:handler];
        return;
    }

    float input[MAX_AXIS_COUNT] = {pitch, roll, yaw};


    for (int i = 0; i < MAX_AXIS_COUNT; i++) {
        if (STABILIZER_AXIS_VALUE_NO_CHANGE == input[i]) {
            Axis(i).startPosition = input[i];
            Axis(i).finishPosition = input[i];
            continue;
        }

        Axis(i).finishPosition = input[i];
        Axis(i).rateFactor = MAX_SPEED;
        Axis(i).totalTime = totalTime;
        if (!self.isMoving) {
            Axis(i).startPosition = START_ANGLE_NOINIT;
            //[self queryAxisMaxControlRate:Axis(i) compeletion:nil];
            //[self queryAxisMaxAccelerate:Axis(i) compeletion:nil];
        }
        [self moveAxisIfNotReached:Axis(i) compeletion:nil];
    }

    self.isMoving = YES;
    BLOCK_EXEC(self.compeletionHandler, NO);

    self.compeletionHandler = handler;
    [self checkReached:MOVE_INTERVAL];
    self.isCancel = NO;

}

-(void) moveTo:(float)pitch roll:(float)roll yaw:(float)yaw compeletion:(void (^)(BOOL success))handler
{
    
    [self moveTo:pitch roll:roll yaw:yaw withInTime:0 compeletion:handler];
}

-(float)p_fixValue:(float)value{
    if (value  >= FINISH_ANGLE_NOINIT_MINVALUE) {
        return value;
    }
    if (value != STABILIZER_AXIS_VALUE_NO_CHANGE) {
        if (value <= -180) {
            value = value + 360;
        }
        else if (value > 180){
            value = value - 360;
        }
    }
    
    return value;
}

-(void) moveTo:(float)pitch roll:(float)roll yaw:(float)yaw withInTime:(NSTimeInterval)totalTime compeletion:(void (^)(BOOL success))handler
{
    pitch = [self p_fixValue:pitch];
    roll = [self p_fixValue:roll];
    yaw =  [self p_fixValue:yaw];
    
    _isNoControlLocaltionSetPointPowered = NO;

    if (self.MotionControlType == ZYBLEMotionControlTypeHareware) {
        [self byHardwareControlMovePitch:pitch roll:roll yaw:yaw durartion:totalTime completion:handler];
        return;
    }
    float input[MAX_AXIS_COUNT] = {pitch, roll, yaw};


    for (int i = 0; i < MAX_AXIS_COUNT; i++) {
        if (STABILIZER_AXIS_VALUE_NO_CHANGE == input[i]) {
            Axis(i).startPosition = input[i];
            Axis(i).finishPosition = input[i];
            continue;
        }

        Axis(i).finishPosition = input[i];
        Axis(i).rateFactor = MAX_SPEED;
        Axis(i).totalTime = totalTime;
        if (!self.isMoving) {
            Axis(i).startPosition = START_ANGLE_NOINIT;
            //[self queryAxisMaxControlRate:Axis(i) compeletion:nil];
            //[self queryAxisMaxAccelerate:Axis(i) compeletion:nil];
        }
        [self moveAxisIfNotReached:Axis(i) compeletion:nil];
    }

    self.isMoving = YES;
    BLOCK_EXEC(self.compeletionHandler, NO);

    self.compeletionHandler = handler;
    [self checkReached:MOVE_INTERVAL];
    self.isCancel = NO;
}
-(void) moveByHareware:(float)pitchh roll:(float)rollh yaw:(float)yawh tryTimes:(NSUInteger)times compeletion:(void (^)(BOOL success))handler
{
    if (self.MotionControlType == ZYBLEMotionControlTypeHareware) {
        __block NSUInteger requestTimes = times;
        @weakify(self)

        [self queryCurrectAxisesPosition:^(float p, float r, float y, BOOL success) {
            @strongify(self);
            if (success) {
                float pitchVal = pitchh == 0 ? STABILIZER_AXIS_VALUE_NO_CHANGE : pitchh + p;
                float rollVal = rollh == 0 ? STABILIZER_AXIS_VALUE_NO_CHANGE : rollh + r;
                float yawVal = yawh == 0 ? STABILIZER_AXIS_VALUE_NO_CHANGE : yawh + y;
                [self moveTo:pitchVal roll:rollVal yaw:yawVal compeletion:handler];

            }
            else{
                if (requestTimes != 0) {
//                    //NSLog(@"--------------============----%d",requestTimes);
                    [self moveByHareware:pitchh roll:rollh yaw:yawh tryTimes:requestTimes - 1 compeletion:handler];
                }
                else{
                    handler(NO);
                }
            }
        }];
    }
}
-(void) moveBy:(float)pitch roll:(float)roll yaw:(float)yaw tryTimes:(NSUInteger)times compeletion:(void (^)(BOOL success))handler
{
    if (self.MotionControlType == ZYBLEMotionControlTypeHareware) {
        [self moveByHareware:pitch roll:roll yaw:yaw tryTimes:times compeletion:handler];

        return;
    }
    float pitchVal = pitch == 0 ? STABILIZER_AXIS_VALUE_NO_CHANGE : FINISH_ANGLE_NOINIT+pitch;
    float rollVal = roll == 0 ? STABILIZER_AXIS_VALUE_NO_CHANGE : FINISH_ANGLE_NOINIT+roll;
    float yawVal = yaw == 0 ? STABILIZER_AXIS_VALUE_NO_CHANGE : FINISH_ANGLE_NOINIT+yaw;
    [self moveTo:pitchVal roll:rollVal yaw:yawVal compeletion:handler];
}

-(void) moveWithDirectionFactor:(float)pitch roll:(float)roll yaw:(float)yaw directionFactor:(BOOL)Flag compeletion:(void (^)(BOOL success))handler
{
    _isNoControlLocaltionSetPointPowered = NO;

    float axisSpeedScale[3];
    axisSpeedScale[0] = pitch;
    axisSpeedScale[1] = roll;
    axisSpeedScale[2] = yaw;

    NSMutableArray* arrayRequests = [NSMutableArray array];

    for (int i = 0; i < 3; i++) {
        if (axisSpeedScale[i] != STABILIZER_AXIS_VALUE_NO_CHANGE) {
            NSInteger speed = MAX_SPEED*axisSpeedScale[i]*(Flag?Axis(i).direction:1);
            ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:Axis(i).controlCode param:@(speed)];
            if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
                [self.sendDelegate configEncodeAndTransmissionForRequest:request];
            }
            [arrayRequests addObject:request];
        }
    }

    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    [client sendRequests:arrayRequests completionHandler:handler];
}

- (void)motionMove:(float)pitch roll:(float)roll yaw:(float)yaw compeletion:(nullable void (^)(BOOL success))handler{
    _isNoControlLocaltionSetPointPowered = NO;
    NSMutableArray* arrayRequests = [NSMutableArray array];
    
//    CGFloat valueAreaArr[3] = {90, 45, 180};
//    CGFloat valueArr[3] = {pitch, roll, yaw};
    for (int idx = 0; idx < 3; idx++) {
//        CGFloat angle = valueArr[idx];
//        CGFloat valueArea = valueAreaArr[idx];
//
//        angle = MIN(angle, valueArea);
//        angle = MAX(angle, -valueArea);
        
//        ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:Axis(idx).motionAngleCode param:@(angle)];
        CGFloat theParam = (idx == 0)?pitch:(idx == 1)?roll:yaw;
        ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:Axis(idx).motionAngleCode param:@(theParam)];
        request.mask = ZYBleDeviceRequestMaskUpdate;
        if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
            [self.sendDelegate configEncodeAndTransmissionForRequest:request];
        }
        [arrayRequests addObject:request];
    }
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    void (^ tempBlock)(BOOL success);
    if (handler) {
        tempBlock = handler;
    } else {
        tempBlock = ^(BOOL success){};
    }
    [client sendRequests:arrayRequests completionHandler:tempBlock];
}



-(void) cancelMove
{
//    //NSLog(@"cancelMove cancelMove cancelMove cancelMove cancelMove !!!!!!!!!");
    _isCancel = YES;
    [self closeLoop];
    [self endAppControl];
    if (self.MotionControlType == ZYBLEMotionControlTypeHareware) {
        if ([self.movtionAxis count]) {
            [self.movtionAxis removeAllObjects];
            [self stopLocaltionSetPointControlHandler:^(BOOL success) {
                [self closeLocationSetPointEnable:^(BOOL success) {
                    if (self.isMoving) {
                        self.isMoving = NO;
                    }
                    void(^compeletionHandler)(BOOL success) = self.compeletionHandler;
                    self.compeletionHandler = nil;

                    BLOCK_EXEC(compeletionHandler,NO);
                }];
            }];

        }
        return;
    }
    if (self.isMoving) {
        self.isMoving = NO;
    }
}

-(void) moveWithCenterPoint:(float)xOffset y:(float)yOffset
{
    ZYBlTrackData *innerData = [[ZYBlTrackData alloc] init];
    innerData.xOffset = xOffset*32767;
    innerData.yOffset = yOffset*32767;
    [innerData createRawData];
    ZYBleMutableRequest* trackRequest = [[ZYBleMutableRequest alloc] initWithZYControlData:innerData];
    [self sendMutableRequest:trackRequest completionHandler:nil];
}

#pragma 辅助方案

-(BOOL) moveAxis:(ZYStabilizerAxis*)axis
{
    //    int sign = sign(axis.finishPosition-axis.startPosition);
    //    float curPosiition = axis.curPosiition;
    //    if (sign > 0) {
    //        //判断是否上次移动超过了180
    //        if ((fabs(180 - axis.prePosiition)+180) < fabs(180 - axis.curPosiition)) {
    //            //正向移动超过180后 将当前角度从[-180,0]映射到[180, 360];
    //            curPosiition+=360;
    //        }
    //        if (axis.prePosiition < axis.finishPosition
    //            && axis.finishPosition < curPosiition
    //            && fabs(axis.finishPosition - axis.prePosiition) < fabs(axis.finishPosition - curPosiition)) {
    //            axis.rateFactor /= 2;
    //            axis.rateFactor = MAX(axis.rateFactor, 1);
    //        }
    //    } else {
    //        //判断是否上次移动超过了-180
    //        if ((fabs(-180 - axis.prePosiition)+180) < fabs(-180 - axis.curPosiition)) {
    //            //负向移动超过-180后 将当前角度从[0,180]映射到[-360, -180];
    //            curPosiition-=360;
    //        }
    //        if (axis.curPosiition < axis.finishPosition
    //            && axis.finishPosition < axis.prePosiition
    //            && fabs(axis.finishPosition - axis.prePosiition) < fabs(axis.finishPosition - curPosiition)) {
    //            axis.rateFactor /= 2;
    //            axis.rateFactor = MAX(axis.rateFactor, 1);
    //        }
    //    }
    //
    //    if (!DEGREE_IS_EQUAL(curPosiition, axis.finishPosition)) {
    //        NSInteger speed = sign(axis.finishPosition-curPosiition)*axis.rateFactor;
    //
    //        ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    //        //ZY//NSLog(@"移动%@", axis.name);
    //        [self sendRequest:axis.controlType data:@(speed) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
    //            if (state == ZYBleDeviceRequestStateResponse) {
    //                //NSLog(@"移动%@ 速度%ld 当前角度%.2f(%.2f) 上次角度%.2f 当前距离%.2f 上次距离%.2f", axis.name, speed, axis.curPosiition, curPosiition, axis.prePosiition, fabs(axis.finishPosition - curPosiition), fabs(axis.finishPosition - axis.prePosiition));
    //            } else {
    //                //NSLog(@"%@速度控制失败", axis.name);
    //            }
    //        }];
    //        return YES;
    //    }

    float distanceLeft = minDistance(axis.finishPosition, axis.curPosition);
    if (!DEGREE_IS_EQUAL(distanceLeft, 0)) {
        int normalDirection = sign(axis.finishPosition-axis.startPosition);
        int minDirection = minDistanceDirection(axis.curPosition, axis.finishPosition);

        //预估距离
        NSDate* now = [NSDate date];
        NSTimeInterval timePiece = [[NSDate date] timeIntervalSinceDate:axis.lastMoveTimeStamp];
        float curDistance = minDistance(axis.prePosition, axis.curPosition);
        float actualSpeed = curDistance/timePiece;
        axis.lastMoveTimeStamp = now;
        float actualAccelerate = (actualSpeed - (1.0*minDirection*axis.rateFactor*axis.direction)/MAX_SPEED)/timePiece;

        float leftDistance = minDistance(axis.finishPosition, axis.curPosition);

        //总时间为0时启用最大速度移动
        NSTimeInterval timeElapse = [now timeIntervalSinceDate:axis.startMoveTimeStamp];
        float timeLeft = axis.totalTime - timeElapse;
        if (axis.totalTime != 0 && timeLeft > 0) {
            float avgRate = distanceLeft/timeLeft;
            //float expectedRate = (distanceLeft/timeLeft+(axis.maxAccelerate)*timeLeft/2);


            float movedDistance = minDistance(axis.startPosition, axis.finishPosition) - leftDistance;
            axis.acturalAverageRate = movedDistance/timeElapse;

            if (leftDistance > 5) {
                if (axis.acturalAverageRate/axis.predictedAverageRate > 0.5) {
                    avgRate += (axis.predictedAverageRate - axis.acturalAverageRate);
                }
            }

            axis.rateFactor = MIN((avgRate/axis.curConfig.maxControlRate)*MAX_SPEED, MAX_SPEED);

        } else if (leftDistance < 20) {
            axis.rateFactor = MAX_SPEED*leftDistance/20;  //1024
        }

        if (normalDirection != minDirection) {
            //已经超出目标点 需要反向移动减速
            //axis.rateFactor /= 2;
            //axis.rateFactor = MAX(axis.rateFactor, 1);
        }
        NSInteger speed = minDirection*axis.rateFactor*axis.direction;

        //ZY//NSLog(@"移动%@", axis.name);
        [self sendRequest:axis.controlCode data:@(speed) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                //NSLog(@"移动%@ 速度%ld(%.2f %.2f %.2f) 实际速度%d(%.2f %.2f %.2f) 当前角度%.2f(%.2f) 上次角度%.2f 当前距离%.2f 上次距离%.2f 剩余移动时间%.2f", axis.name, speed, axis.curConfig.maxControlRate*speed/MAX_SPEED, axis.predictedAverageRate, axis.curConfig.maxAccelerate, minDistanceDirection(axis.prePosition, axis.curPosition), actualSpeed, axis.acturalAverageRate, actualAccelerate, axis.curPosition, axis.curPosition, axis.prePosition, leftDistance, minDistance(axis.finishPosition ,axis.prePosition), timeLeft);

            } else {
                //NSLog(@"%@速度控制失败", axis.name);
            }
        }];
        return YES;
    }

    //当前位置不需要移动的轴依然需要通知稳定器控制在线 移动速度为0
    [self sendRequest:axis.controlCode data:@(0) completionHandler:nil];

    //NSLog(@"结束移动%@ 速度%d 当前角度%.2f(%.2f) 上次角度%.2f 当前距离%.2f 上次距离%.2f 剩余移动时间N/A", axis.name, 0, axis.curPosition, axis.curPosition, axis.prePosition, distanceLeft, minDistance(axis.finishPosition ,axis.prePosition));
    return NO;
}

-(void) moveAxisIfNotReached:(ZYStabilizerAxis*)axis compeletion:(void (^)(BOOL move))handler
{
    if (DEGREE_IS_EQUAL(axis.startPosition, axis.finishPosition)) {
        //初始位置不需要移动的轴直接返回 依然需要通知稳定器控制在线 移动速度为0
        [self sendRequest:axis.controlCode data:@(0) completionHandler:nil];
        BLOCK_EXEC(handler, NO);
        return;
    }

    [self sendRequest:axis.angleCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ////NSLog(@"%@角度 %.2f", axis.name, AxisDegree(axis.idx));
            axis.prePosition = axis.curPosition;
            axis.curPosition = AxisDegree(axis.idx);
            if (axis.startPosition == START_ANGLE_NOINIT) {
                //记录起点位置
                axis.startPosition = axis.curPosition;
                axis.prePosition = axis.startPosition;
                axis.startMoveTimeStamp = [NSDate date];
                if (axis.finishPosition >= FINISH_ANGLE_NOINIT_MINVALUE) {
                    axis.startPosition = axis.curPosition;
                    axis.prePosition = axis.startPosition;
                    //计算出moveBy的终点位置
                    axis.finishPosition -= FINISH_ANGLE_NOINIT;
                    axis.finishPosition += axis.curPosition;
                    //可以移动到的点的值域为(-180, 180]
                    if (axis.finishPosition <= -180) {
                        axis.finishPosition += 360;
                    } else if (axis.finishPosition > 180){
                        axis.finishPosition -= 360;
                    }
                }
                if (axis.totalTime > 0) {
                    axis.predictedAverageRate = minDistance(axis.startPosition, axis.finishPosition)/axis.totalTime;
                }
                //NSLog(@"%@起始位置%.2f 结束位置%.2f", axis.name, axis.startPosition, axis.finishPosition);
            }
        } else {
            //NSLog(@"%@角度获取失败", axis.name);
        }

        BOOL move = [self moveAxis:axis];
        BLOCK_EXEC(handler, move);
    }];
}

-(void) queryAxisAngle:(ZYStabilizerAxis*)axis compeletion:(void (^)(BOOL success))handler
{
    [self sendRequest:axis.angleCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            axis.curPosition = AxisDegree(axis.idx);
            BLOCK_EXEC(handler, YES);
        } else {
            BLOCK_EXEC(handler, NO);
        }
    }];
}

//-(void) queryAxisMaxControlRate:(ZYStabilizerAxis*)axis compeletion:(void (^)(BOOL success))handler
//{
//    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
//
//    [self sendRequest:axis.maxControlRateCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
//        if (state == ZYBleDeviceRequestStateResponse) {
//            axis.maxControlRate = maxControlRate(axis.idx);
//            BLOCK_EXEC(handler, YES);
//        } else {
//            BLOCK_EXEC(handler, NO);
//        }
//    }];
//}
//
//-(void) queryAxisMaxAccelerate:(ZYStabilizerAxis*)axis compeletion:(void (^)(BOOL success))handler
//{
//    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
//
//    [self sendRequest:axis.smoothnessCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
//        if (state == ZYBleDeviceRequestStateResponse) {
//            axis.maxAccelerate = maxAccerate(axis.idx);
//            BLOCK_EXEC(handler, YES);
//        } else {
//            BLOCK_EXEC(handler, NO);
//        }
//    }];
//}

-(BOOL) isAxisReached:(ZYStabilizerAxis*)axis
{
    return DEGREE_IS_EQUAL(axis.curPosition, axis.finishPosition);
}

-(void) checkReached:(NSTimeInterval)delayInSeconds
{
    if (!self.isMoving) {
        void (^compeletionHandler)(BOOL success) = self.compeletionHandler;
        self.compeletionHandler = nil;
        BLOCK_EXEC(compeletionHandler, NO);
        return;
    }
    ////NSLog(@"检查是否移动到位置");
    __block int axisCheckedCount = 0;
    __block int axisReachedCheckedCount = 0;

    @weakify(self)

    //检查所有轴的角度
    void(^checkAxisNextMove)(BOOL move) = ^(BOOL move) {
        ////NSLog(@"第%d个轴检查完成", axisCheckedCount);
        axisCheckedCount++;
        if (!move) {
            axisReachedCheckedCount++;
        };

        if (axisCheckedCount==MAX_AXIS_COUNT) {
            //全部检查过以后 看是否全部移动完毕
            BOOL allReached = axisReachedCheckedCount == MAX_AXIS_COUNT;
            if (!allReached) {
                //没有移动完毕且还在继续移动 0.2秒后继续检查
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self)
                    [self checkReached:MOVE_INTERVAL];
                });
                ////NSLog(@"继续移动");
            } else {
                //结束移动
                ////NSLog(@"结束移动");
                self.isMoving = NO;
                void (^compeletionHandler)(BOOL success) = self.compeletionHandler;
                self.compeletionHandler = nil;
                BLOCK_EXEC(compeletionHandler, allReached);
            }
        }
    };

    for (int i = 0; i < MAX_AXIS_COUNT; i++) {
        [self moveAxisIfNotReached:Axis(i) compeletion:checkAxisNextMove];
    }
}

-(void) checkMotionMode:(ZYBleDeviceWorkMode)mode compeletion:(void (^)(BOOL success, ZYBleDeviceWorkMode originalMode))handler
{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    ZYBleDeviceDataModel* value = client.dataCache;
    [self sendRequest:ZYBleInteractCodeWorkMode_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler, YES, value.workMode)
        } else {
            BLOCK_EXEC(handler, NO, ZYBleDeviceWorkModeUnkown);
        }
    }];
}

-(void) enableMotionMode:(ZYBleDeviceWorkMode)mode compeletion:(void (^)(BOOL success, ZYBleDeviceWorkMode originalMode))handler
{
    [self checkMotionMode:mode compeletion:^(BOOL success, ZYBleDeviceWorkMode originalMode) {
        if (mode == ZYBleDeviceWorkModeUnkown) {
            //查询当前工作模式直接返回
            BLOCK_EXEC(handler, success, originalMode)
        } else {
            if (originalMode == mode) {
                //当前模式已经是设置值
                BLOCK_EXEC(handler, success, originalMode);
            } else {
                //设置期望的模式
                [self sendRequest:ZYBleInteractCodeWorkMode_W data:@(mode) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    if (state == ZYBleDeviceRequestStateResponse) {
                        BLOCK_EXEC(handler, YES, originalMode);
                    } else {
                        BLOCK_EXEC(handler, NO, originalMode);
                    }
                }];
            }
        }
    }];
}


-(void) sendRequest:(NSUInteger)code retryTimes:(NSUInteger)times complete:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler{
    __block NSUInteger retryTiems = times;
    __block NSUInteger innerCode = code;
    @weakify(self);
    [self sendRequest:code completionHandler:^(ZYBleDeviceRequestState stateInner, NSUInteger paramInner) {
        @strongify(self);
        if (paramInner == ZYBleDeviceRequestStateResponse) {
            handler(stateInner,paramInner);
        } else {
            if (retryTiems <= 0) {
                handler(stateInner,paramInner);
            }
            else{
#ifdef DEBUG
                
//                //NSLog(@"第%ld次获取失败", retryTiems);
#endif


                retryTiems --;
                [self sendRequest:innerCode retryTimes:retryTiems complete:handler];
            }

        }
    }];
}



-(void) queryCurrectAxisesPosition:(void (^)(float pitch, float roll, float yaw, BOOL success))handler
{
    __block int axisCheckedCount = 0;
    __block BOOL result = YES;

    void(^queryAngle)(BOOL success) = ^(BOOL success) {
        //NSLog(@"第%d个轴获取完成", axisCheckedCount);
        axisCheckedCount++;
        result &= success;
        if (axisCheckedCount == MAX_AXIS_COUNT) {
            BLOCK_EXEC(handler, AxisDegree(0), AxisDegree(1), AxisDegree(2), result);
        };
    };

    for (int i = 0; i < MAX_AXIS_COUNT; i++) {
        [self sendRequest:Axis(i).angleCode completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
            if (state == ZYBleDeviceRequestStateResponse) {
                BLOCK_EXEC(queryAngle, YES);
            } else {
                BLOCK_EXEC(queryAngle, NO);
            }
        }];
    }
}

-(void) onDeviceBLEOffLine:(NSNotification*)notification
{
    [self cancelMove];
}

-(void)cameraParaChange:(NSNotification *)noti{
    NSDictionary* userInfo = [noti userInfo];
    if ([[userInfo objectForKey:@"type"] isEqualToString:NSStringFromClass([ZYBlRdisData class]) ]) {
        ZYBlRdisData* data = (ZYBlRdisData*)[noti object];

        if (data) {
            self.workMode = data.rdisData.workMode;
            [[NSNotificationCenter defaultCenter] postNotificationName:ZYDeviceRDISReciveNoti object:data];

        }
    }
}
-(void)loadAxisConfigurationModel:(void (^)(BOOL, ZYParaCustomSettingModel *))handler{
    @weakify(self)
    [self loadAxisConfiguration:^(BOOL success) {
        @strongify(self)
        if (success) {
            ZYParaCustomSettingModel *setting = [[ZYParaCustomSettingModel alloc] init];
            for (ZYStabilizerAxis *axi in self.axisArray) {
                //NSLog(@"z后的方向 %ld",axi.idx);
                ZYStabilizerAxisConfig *config = axi.curConfig;
                switch (axi.idx) {
                    case 0:{
                        setting.followSpeedPitch    = @(config.maxFollowRate);
                        setting.controlSpeedPitch   = @(config.maxControlRate);
                        setting.smoothnessPitch     = @(config.smoothness);
                        setting.trimmingPitch       = @(config.maxSharpTurning);
                        setting.deadzonePitch       = @(config.deadArea);
                        setting.controlDirectPitch  = @(config.antiDiretion);
                        break;
                    }
                    case 1:{
                        setting.followSpeedRoll    = @(config.maxFollowRate);
                        setting.controlSpeedRoll   = @(config.maxControlRate);
                        setting.smoothnessRoll     = @(config.smoothness);
                        setting.trimmingRoll       = @(config.maxSharpTurning);
                        setting.deadzoneRoll       = @(config.deadArea);
                        setting.controlDirectRoll  = @(config.antiDiretion);
                        break;
                    }
                    case 2:{
                        setting.followSpeedYaw    = @(config.maxFollowRate);
                        setting.controlSpeedYaw   = @(config.maxControlRate);
                        setting.smoothnessYaw     = @(config.smoothness);
                        setting.deadzoneYaw       = @(config.deadArea);
                        setting.controlDirectYaw  = @(config.antiDiretion);
                        break;
                    }
                    default:
                        break;
                }
                
            }
            BLOCK_EXEC(handler,success,setting);

        }
        else{
            BLOCK_EXEC(handler,NO,nil);
        }
    }];
}

-(void)p_loadConfigWithCount:(int)count result:(BOOL)result FromStabilizer:(void (^)(BOOL success))handler{
    __block int nextCount = count - 1;
    __block int blockResult = result;

    @weakify(self)
    [Axis(nextCount) loadConfigFromStabilizer:^(BOOL success) {
        @strongify(self);
        blockResult &= success;
        if (nextCount == 0) {
            BLOCK_EXEC(handler, blockResult);
        }
        else{
            [self p_loadConfigWithCount:nextCount result:blockResult FromStabilizer:handler];
        }
    }];
}
-(void) loadAxisConfiguration:(void (^)(BOOL success))handler;
{
    [self p_loadConfigWithCount:MAX_AXIS_COUNT result:YES FromStabilizer:handler];
//    __block NSUInteger axisLoadedCount = 0;
//    __block BOOL result = YES;
//    void(^axisConfigCheck)(BOOL success) = ^(BOOL success) {
//        result &= success;
//        axisLoadedCount++;
//        if (axisLoadedCount == MAX_AXIS_COUNT) {
//            BLOCK_EXEC(handler, result);
//            //NSLog(@"轴配置读取%d %@", success, self.axisArray);
//        }
//    };
//
//    for (int i = 0; i < MAX_AXIS_COUNT; i++) {
//        [Axis(i) loadConfigFromStabilizer:axisConfigCheck];
//    }
    
}

-(void)p_saveAxisConfiguration:(NSArray<ZYStabilizerAxisConfig*>*) axisConfigs WithCount:(int)count result:(BOOL)result FromStabilizer:(void (^)(BOOL success))handler{
    __block int nextCount = count - 1;
    __block int blockResult = result;
    
     ZYStabilizerAxisConfig* config = [axisConfigs objectAtIndex:nextCount];
    @weakify(self)
    [Axis(nextCount) configurateStabilizer:config compeletion:^(BOOL success) {
        @strongify(self);
        blockResult &= success;
        if (nextCount == 0) {
            BLOCK_EXEC(handler, blockResult);
        }
        else{
            [self p_saveAxisConfiguration:axisConfigs WithCount:nextCount result:blockResult FromStabilizer:handler];
        }
    }];
}

-(void) saveAxisConfiguration:(NSArray<ZYStabilizerAxisConfig*>*) axisConfigs compeletionHandler:(void (^)(BOOL success))handler;
{
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractCodeRockerDirectionConfig_W param:@(0)];
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }

    if (request.trasmissionType == ZYTrasmissionTypeWIFI) {
        @weakify(self)
        [self p_saveAxisConfiguration:axisConfigs WithCount:MAX_AXIS_COUNT result:YES FromStabilizer:^(BOOL success) {
            @strongify(self)
            NSUInteger antiDirectionData = 0;
            
            BOOL antiDirectionException = NO;
            for (int i = 0; i < MAX_AXIS_COUNT; i++) {
                ZYStabilizerAxisConfig* config = [axisConfigs objectAtIndex:i];
                BOOL antiDirection = (config?:Axis(i).curConfig).antiDiretion;
                antiDirectionData |= antiDirection << i;
                if ([config.exceptKeys containsObject:@"antiDiretion"]) {
                    antiDirectionException = antiDirectionException||YES;
                }
            }
            
            if (antiDirectionException) {
                NSLog(@"方向控制不需要配置");
                BLOCK_EXEC(handler, success);
                return;
            }
            
            [self sendRequest:ZYBleInteractCodeRockerDirectionConfig_W data:@(antiDirectionData) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    BLOCK_EXEC(handler, (YES && success));
                } else {
                    BLOCK_EXEC(handler, NO);
                }
            }];
        }];
        return;
    }
    else{
            __block NSUInteger axisLoadedCount = 0;
            __block BOOL result = YES;
            void(^axisConfigCheck)(BOOL success) = ^(BOOL success) {
                result &= success;
                axisLoadedCount++;
                if (axisLoadedCount == MAX_AXIS_COUNT+1) {
                    //NSLog(@"轴配置保存%d %@", success, self.axisArray);
                    BLOCK_EXEC(handler, result);
                }
            };
        
            NSUInteger antiDirectionData = 0;
            BOOL antiDirectionException = NO;

            for (int i = 0; i < MAX_AXIS_COUNT; i++) {
                ZYStabilizerAxisConfig* config = [axisConfigs objectAtIndex:i];
                [Axis(i) configurateStabilizer:config compeletion:axisConfigCheck];
                BOOL antiDirection = (config?:Axis(i).curConfig).antiDiretion;
                antiDirectionData |= antiDirection << i;
                if ([config.exceptKeys containsObject:@"antiDiretion"]) {
                    antiDirectionException = antiDirectionException||YES;
                }
            }
            if (antiDirectionException) {
                NSLog(@"方向控制不需要配置");
                BLOCK_EXEC(axisConfigCheck, YES);
                return;
            }
        
            [self sendRequest:ZYBleInteractCodeRockerDirectionConfig_W data:@(antiDirectionData) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                if (state == ZYBleDeviceRequestStateResponse) {
                    BLOCK_EXEC(axisConfigCheck, YES);
                } else {
                    BLOCK_EXEC(axisConfigCheck, NO);
                }
            }];
    }
}

-(void)saveAxisCustomSetting:(ZYParaCustomSettingModel *)setting exceptKeys:(NSArray *)exceptKeys compeletionHandler:(void (^)(BOOL))handler{
        ZYStabilizerAxisConfig *pitchConfig = [[ZYStabilizerAxisConfig alloc] init];
        ZYStabilizerAxisConfig *rollConfig = [[ZYStabilizerAxisConfig alloc] init];
        ZYStabilizerAxisConfig *yawConfig = [[ZYStabilizerAxisConfig alloc] init];
        if (exceptKeys.count > 0) {
            pitchConfig.exceptKeys = [exceptKeys mutableCopy];
            rollConfig.exceptKeys = [exceptKeys mutableCopy];
            yawConfig.exceptKeys = [exceptKeys mutableCopy];
        }


        pitchConfig.maxFollowRate = setting.followSpeedPitch.floatValue;
        pitchConfig.maxControlRate = setting.controlSpeedPitch.floatValue;
        pitchConfig.smoothness = setting.smoothnessPitch.unsignedIntegerValue;
        pitchConfig.maxSharpTurning = setting.trimmingPitch.floatValue;
        pitchConfig.deadArea = setting.deadzonePitch.floatValue;
        pitchConfig.antiDiretion = setting.controlDirectPitch.boolValue;

        rollConfig.maxFollowRate = setting.followSpeedRoll.floatValue;
        rollConfig.maxControlRate = setting.controlSpeedRoll.floatValue;
        rollConfig.smoothness = setting.smoothnessRoll.unsignedIntegerValue;
        rollConfig.maxSharpTurning = setting.trimmingRoll.floatValue;
        rollConfig.deadArea = setting.deadzoneRoll.floatValue;
        rollConfig.antiDiretion = setting.controlDirectRoll.boolValue;

        yawConfig.maxFollowRate = setting.followSpeedYaw.floatValue;
        yawConfig.maxControlRate = setting.controlSpeedYaw.floatValue;
        yawConfig.smoothness = setting.smoothnessYaw.unsignedIntegerValue;
        yawConfig.maxSharpTurning = 0;
        yawConfig.deadArea = setting.deadzoneYaw.floatValue;
        yawConfig.antiDiretion = setting.controlDirectYaw.boolValue;


        NSArray<ZYStabilizerAxisConfig*>* configs = [NSArray arrayWithObjects:pitchConfig, rollConfig, yawConfig, nil];
    #pragma -mark 情景模式
        [self saveAxisConfiguration:configs compeletionHandler:handler];
}

-(void) saveAxisCustomSetting:(ZYParaCustomSettingModel*)setting compeletionHandler:(void (^)(BOOL success))handler
{
    [self saveAxisCustomSetting:setting exceptKeys:nil compeletionHandler:handler];
}

#pragma mark - 保存设置
-(void)saveSettingsWithHandler:(void(^)(BOOL success))handler{

    [self sendRequest:ZYBleInteractSave data:@(ZYBLE_SAVE_PARAM) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            BLOCK_EXEC(handler,YES);
        }else{
            //NSLog(@"saveSettingsWithHandler state:%ld ERROR %s",param,__func__);
            BLOCK_EXEC(handler,NO);
        }
        
    }];
}

/*
 ZYBleLocaltionSetPointPowered                          = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x30),   //位置定点使能 [0,1]-->[关闭,打开] ZYBleLocationSetPointPowered

 ZYBleLocaltionSetPointControlRegister           = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x31),   //位置定点使能控制寄存器[0,3]-->[清零，开始，保留，暂停] ZYBleLocationSetPointControlRegisterType

 ZYBleLocaltionSetPointStateRegister             = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x32),   //位置定点使能状态寄存器[15:4,3,2,1,0]->[保留,暂停,完成,开始,使能] ZYBleLocationSetPointStateRegisterType

 ZYBleRotateAnglePitchControl                    = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x33),   //俯仰角度制 [-9000, 9000] 对应[ -90°,90°]
 ZYBleRotateAngleRollControl                     = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x034),   //横滚角度控制 [-4500, 4500] 对应[ -45°,45°]
 ZYBleRotateAngleYawControl                      = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x035),   //航向角度控制 [-18000, 18000] 对应[ - 180°,180°]

 ZYBleSetPointMotionTimeHeight                  = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x036),   //位置定点移动时间（低16bit）[0,FFFF]

 ZYBleSetPointMotionTimeLoad                    = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x037),   //位置定点移动时间（高16bit）[0,FFFF]
 */

/*
 @strongify(self)
 [self openLocationSetPointEnable:^(BOOL success) {

 }];
 */


#pragma mark - Hardware Motion

-(void)byHardwareControlMovePitch:(float)pitch roll:(float)roll yaw:(float)yaw durartion:(NSTimeInterval)seconds completion:(void (^)(BOOL success))handler{
    _isCancel = NO;
    if ([self.movtionAxis count]) {
        [self closeLoop];
        @weakify(self);
        [self stopLocaltionSetPointControlHandler:^(BOOL success) {
            @strongify(self);
            [self.movtionAxis removeAllObjects];
            [self byHardwareControlMovePitch:pitch roll:roll yaw:yaw durartion:seconds completion:handler];
        }];
        return;
    }

#ifdef DEBUG
    
//    //NSLog(@"////////////////pitch = %f,roll = %f,yaw = %f durartion:%f///////////",pitch,roll,yaw,seconds);
#endif


    self.movtionAxis = [@[] mutableCopy];

    if (pitch != STABILIZER_AXIS_VALUE_NO_CHANGE) {
        ZYStabilizerHardwareMotion *mPitch = [ZYStabilizerHardwareMotion stabilizerHardwareMotionAxisWithControlCode:ZYBlePitchRotateAngleControl angleCode:ZYBleInteractCodePitchAngle_R angle:pitch];
        [self.movtionAxis addObject:mPitch];
    }

    if (roll != STABILIZER_AXIS_VALUE_NO_CHANGE) {
        ZYStabilizerHardwareMotion *mRoll = [ZYStabilizerHardwareMotion stabilizerHardwareMotionAxisWithControlCode:ZYBleRollRotateAngleControl angleCode:ZYBleInteractCodeRollAngle_R angle:roll];
        [self.movtionAxis addObject:mRoll];
    }

    if (yaw != STABILIZER_AXIS_VALUE_NO_CHANGE) {
        ZYStabilizerHardwareMotion *mYaw = [ZYStabilizerHardwareMotion stabilizerHardwareMotionAxisWithControlCode:ZYBleYawRotateAngleControl angleCode:ZYBleInteractCodeYawAngle_R angle:yaw];
        [self.movtionAxis addObject:mYaw];
    }
    //
    //    millisecond = 0;
    //        if (millisecond<1) {
    //            millisecond = 1;
    //        }


    if (_timeoutTimer) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:seconds + 20 target:self selector:@selector(timeoutTimerEvent) userInfo:nil repeats:NO];
    self.movtionDuration = seconds*1000;
    self.downTimerSeconds = seconds;
    self.harewareMotionStep = ZYHardwareMotionStep_SetWorkModel;
    BLOCK_EXEC(_compeletionHandler,NO);

    self.compeletionHandler = handler;
    [self progressHardwareMoveEvent];

}



-(void)timeoutTimerEvent{
    if (_compeletionHandler){
        [self cancelMove];

    }
    if (_timeoutTimer) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
}

-(void)progressHardwareMoveEvent{
    if (_isCancel) {
        BLOCK_EXEC(self.compeletionHandler,NO);
        self.compeletionHandler = nil;
        return;
    }
    @weakify(self)
    switch (_harewareMotionStep) {
        case ZYHardwareMotionStep_SetWorkModel:{
//            //NSLog(@"设置工作模式");

            [self enableMotionMode:ZYBleDeviceWorkModeLock compeletion:^(BOOL success, ZYBleDeviceWorkMode originalMode) {

                if (success) {
                    if (self.isNoControlLocaltionSetPointPowered) {
                        self.harewareMotionStep += 2;

                    }else{
                        self.harewareMotionStep ++;

                    }
                }
                [self progressHardwareMoveEvent];
            } ];
        }break;

            //        case ZYHardwareMotionStep_LocationSetPointClean:{
            //            [self cleanSetPointControlRegister:^(BOOL success) {
            //                @strongify(self)
            //                if (success) {
            //                    self.harewareMotionStep ++;
            //                }
            //                [self progressHardwareMoveEvent];
            //            }];
            //        }break;

        case ZYHardwareMotionStep_LocationSetOpenEanble:{
//            //NSLog(@"打开使能");

            [self openLocationSetPointEnable:^(BOOL success) {

                @strongify(self)
                if (success) {
                    self.harewareMotionStep ++ ;
                }
                [self progressHardwareMoveEvent];
            }];
        }break;

        case ZYHardwareMotionStep_SetMotionAxis :{
//            //NSLog(@"设置角度");

            [self sendDirections:self.movtionAxis completion:^(BOOL success) {
                @strongify(self)
                if (success) {
                    self.harewareMotionStep ++;
                }
                [self progressHardwareMoveEvent];
            }];
        }break;

        case  ZYHardwareMotionStep_SetDurationTime :{
//            //NSLog(@"设置持续时间");

            [self setDurationMilliSecond:self.movtionDuration completion:^(BOOL success) {
                @strongify(self);
                if (success) {
                    self.harewareMotionStep ++;
                }
                [self progressHardwareMoveEvent];
            }];
        }break;

        case ZYHardwareMotionStep_startLocaltionSetPointControl:{
//            //NSLog(@"开始位置定点使能控制寄存");

            [self startLocaltionSetPointControlHandler:^(BOOL success) {
                @strongify(self)
                if (success) {
                    self.harewareMotionStep ++;
                }
                [self progressHardwareMoveEvent];
            }];
        }break;

        case ZYHardwareMotionStep_MindLocationControlRegisterToCompleted:{
//            //NSLog(@"关注 位置定点使能控制寄存 状态");
            [self mindLocationSetPointControlRegisterToCompleted:^{
                @strongify(self)
                if (self.isNoControlLocaltionSetPointPowered) {
//                    //NSLog(@"~完成！");

                    void(^compeletionHandler)(BOOL success) = self.compeletionHandler;
                    self.compeletionHandler = nil;

                    BLOCK_EXEC(compeletionHandler,YES);

                    self.harewareMotionStep = ZYHardwareMotionStep_SetWorkModel;

                }else{
                    self.harewareMotionStep ++;
                    [self progressHardwareMoveEvent];

                }

            }];
        }break;

        case ZYHardwareMotionStep_CloseLocationSetEanble:{
//            //NSLog(@"关闭使能");

            [self closeLocationSetPointEnable:^(BOOL success) {
                @strongify(self)
//                //NSLog(@"完成！关闭使能:%d",success);
                void(^compeletionHandler)(BOOL success) = self.compeletionHandler;
                self.compeletionHandler = nil;

                BLOCK_EXEC(compeletionHandler,success);

                self.harewareMotionStep = ZYHardwareMotionStep_SetWorkModel;

            }];
        }
        default:
            break;
    }

}

-(void)sendDirections:(NSMutableArray<ZYStabilizerHardwareMotion*>*)motions completion:(void(^)(BOOL success))handler{
    ZYStabilizerHardwareMotion *motion = [motions firstObject];
    @weakify(self)
    [self moveWithMotion:motion completion:^(BOOL success) {
        if (success) {
            NSMutableArray *tempMarr= [motions mutableCopy];
            if (tempMarr.count > 0) {
                [tempMarr removeObjectAtIndex:0];
            }
            if ([tempMarr count]) {
                @strongify(self)
                [self sendDirections:tempMarr completion:handler];
            }else{
                BLOCK_EXEC(handler,YES);
            }
        }else{
//            //NSLog(@"sendDirections error");
            BLOCK_EXEC(handler,NO);
        }
    }];
}

-(void)setDurationMilliSecond:(NSInteger)milliSecond completion:(void(^)(BOOL success))handler{
    @weakify(self)
    [self setDurationLowBit:milliSecond compeletion:^(BOOL success) {

        @strongify(self)
        if (success) {
            [self setDurationHighBit:milliSecond compeletion:^(BOOL success) {

                BLOCK_EXEC(handler,success);
            }];
        }else{
            BLOCK_EXEC(handler,NO);
        }
    }];
}

-(void)openLocationSetPoint:(void(^)(BOOL success))handler{
//    if (!_isNoControlLocaltionSetPointPowered) {
//        return;
//    }
    [self beginAppControl];
    if (self.MotionControlType == ZYBLEMotionControlTypeSoftware) {
        BLOCK_EXEC(handler,YES);
            }
    else{
        [self openLocationSetPointEnable:handler];
    }

}

-(void)openLocationSetPointEnable:(void(^)(BOOL success))handler{

    [self sendRequest:ZYBleLocaltionSetPointPowered data:@(ZYBleLocationSetPointPoweredOn) completed:handler];

}

-(void)cleanSetPointControlRegister:(void(^)(BOOL success))handler{
    [self sendRequest:ZYBleLocaltionSetPointControlRegister data:@(ZYBleLocationSetPointControlRegisterTypeClean) completed:handler];

}

-(void)startLocaltionSetPointControlHandler:(void(^)(BOOL success))handler{
    [self sendRequest:ZYBleLocaltionSetPointControlRegister data:@(ZYBleLocationSetPointControlRegisterTypeStart) completed:handler];
}

-(void)stopLocaltionSetPointControlHandler:(void(^)(BOOL success))handler{
    [self sendRequest:ZYBleLocaltionSetPointControlRegister data:@(ZYBleLocationSetPointControlRegisterTypeStop) completed:handler];
}

-(void)moveWithMotion:(ZYStabilizerHardwareMotion*)motion completion:(void(^)(BOOL success))handler{
    [self sendRequest:motion.controlCode data:@(motion.angle) completed:handler];
}


-(void)movePitchAxisWithAngle:(short)angle compeletion:(void(^)(BOOL success))handler{
    [self sendRequest:ZYBlePitchRotateAngleControl data:@(angle) completed:handler];

}

-(void)moveRollAxisWithAngle:(short)angle compeletion:(void(^)(BOOL success))handler{
    [self sendRequest:ZYBleRollRotateAngleControl data:@(angle) completed:handler];

}

-(void)moveYawAxisWithAngle:(short)angle compeletion:(void(^)(BOOL success))handler{
    [self sendRequest:ZYBleYawRotateAngleControl data:@(angle) completed:handler];
}

-(void)setDurationHighBit:(NSInteger)milliSeconds compeletion:(void(^)(BOOL success))handler{
    //    unsigned short high = (milliSceonds & 0xffff0000) >> 16;
    [self sendRequest:ZYBleSetPointMotionTimeHighBit data:@(milliSeconds) completed:handler];

}

-(void)setDurationLowBit:(NSInteger)milliSeconds compeletion:(void(^)(BOOL success))handler{
    //    unsigned short low = milliSeonds & 0x0000ffff;
    [self sendRequest:ZYBleSetPointMotionTimeLowBit data:@(milliSeconds) completed:handler];
}

-(void)startLocationSetPointControlRegister:(void(^)(BOOL success))handler{
    [self sendRequest:ZYBleLocaltionSetPointStateRegister data:@(ZYBleLocationSetPointStateRegisterTypeStart) completed:handler];
}

-(void)mindLocationSetPointControlRegisterToCompleted:(void(^)(void))handler{
    if (self.isCancel) {
        return;
    }
    @weakify(self)
    [self sendTwoResultsRequest:ZYBleLocaltionSetPointStateRegister_R completed:^(BOOL success,NSUInteger param) {
        if (self.isCancel) {
            return;
        }
        //        //NSLog(@"mindLocationSetPointControlRegisterToCompleted:  success:%ld  param:%lu",(long)success,(unsigned long)param);
#define CheckBit(val, pos) ((val&(0x0001<<pos))==(0x0001<<pos))
       
        NSMutableString* stateString = [NSMutableString string];
        for (int i = 0; i < 7; i++) {
            if (CheckBit(param, i)) {
                if (i == 0) {
                    [stateString appendString:@"使能"];
                } else if (i == 1) {
                    [stateString appendString:@"开始"];
                } else if (i == 2) {
                    [stateString appendString:@"完成"];
                } else if (i == 3) {
                    [stateString appendString:@"暂停"];
                } else if (i == 4) {
                    [stateString appendString:@"俯仰"];
                } else if (i == 5) {
                    [stateString appendString:@"横滚"];
                } else if (i == 6) {
                    [stateString appendString:@"航向"];
                }
            }
        }
#ifdef DEBUG
        
//            //NSLog(@"定点状态 %lx %@", param, stateString);
#endif

        if (param == 4) {
            BLOCK_EXEC(handler);
            return ;
        }
        if ([self.sendDelegate respondsToSelector:@selector(modelStr)]) {
            NSString *str = [self.sendDelegate modelStr];
            
            if ([ZYBleDeviceDataModel likeSmoothXWithString:str]) {
                 if (CheckBit(param, 10) == 1) {
                   BLOCK_EXEC(handler);
                   return ;
                 }
            }
        }
//       if (CheckBit(param, 10) == 1) {
//                  BLOCK_EXEC(handler);
//                  return ;
//              }
        @strongify(self)

        float requeryTime ;
        if (self.downTimerSeconds>3599) {
            requeryTime = 600;
            self.downTimerSeconds -= requeryTime;

        }else if (self.downTimerSeconds>599){
            requeryTime = 60;
            self.downTimerSeconds -= requeryTime;

        }else if (self.downTimerSeconds >299){
            requeryTime = 30;
            self.downTimerSeconds -= requeryTime;

        }else if (self.downTimerSeconds >99){
            requeryTime = 10;
            self.downTimerSeconds -= requeryTime;

        }else if (self.downTimerSeconds >49){
            requeryTime = 5;
            self.downTimerSeconds -= requeryTime;

        }
        else if(self.downTimerSeconds >2){
            requeryTime = 1;
            
        }
        else if (self.downTimerSeconds < 0.2f){
            requeryTime = 0.1f;
            
        }
        

        self.delayedBlockHandle = perform_block_after_delay_seconds(requeryTime, ^{
            @strongify(self)

            [self mindLocationSetPointControlRegisterToCompleted:handler];

            self.delayedBlockHandle = nil;

        });

    }];
}

-(void)closeLocationSetPoint:(void(^)(BOOL success))handler{
//    if (!_isNoControlLocaltionSetPointPowered) {
//        return;
//    }
    [self endAppControl];
    if (self.MotionControlType == ZYBLEMotionControlTypeSoftware) {
        BLOCK_EXEC(handler,YES);
    }
    else{
        [self closeLocationSetPointEnable:handler];
    }
}

-(void)closeLocationSetPointEnable:(void(^)(BOOL success))handler{


    [self sendRequest:ZYBleLocaltionSetPointPowered data:@(ZYBleLocationSetPointPoweredOFF)  completed:handler];
}

-(void) sendRequest:(NSUInteger)code completed:(void(^)(BOOL success))handler
{

//    @weakify(self)
    [self sendRequest:code data:@(0)  completed:handler];
}

-(void) sendRequest:(NSUInteger)code data:(NSNumber*)data completed:(void(^)(BOOL success))handler
{
    @weakify(self)
    [self sendRequest:code data:data completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        if (self.MotionControlType == ZYBLEMotionControlTypeHareware) {
            BLOCK_EXEC(handler,(ZYBleDeviceRequestStateResponse == state))
        }
        else{
            self.delayedBlockHandle = perform_block_after_delay_seconds(kLoopTimeTnterval, ^{
                @strongify(self)
                
                //            //NSLog(@"sendRequest:%lu -- data:%@ state %ld",(unsigned long)code,data,(long)state);
                BLOCK_EXEC(handler,(ZYBleDeviceRequestStateResponse == state))
                
                self.delayedBlockHandle = nil;
                
            });
        }
        
    }];
}

-(void) sendTwoResultsRequest:(NSUInteger)code  completed:(void(^)(BOOL success,NSUInteger param))handler
{

    [self sendRequest:code  completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        BLOCK_EXEC(handler,(ZYBleDeviceRequestStateResponse == state),param)
    }];
}

-(void)closeLoop{
    if (nil != _delayedBlockHandle) {
        _delayedBlockHandle(YES);
    }
    _delayedBlockHandle = nil;
}

-(BOOL) canMoveAxisSmoothly:(float)fromPosition toPosition:(float)toPosition inTime:(float)totalTime
{
    float fDis = fabsf(toPosition-fromPosition);
    fDis = (fDis>180) ? (360-fDis) : fDis;
    return fDis / totalTime >= 0.01;
}

-(void) beginAppControl {
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(modelStr)]) {
        NSString *str = [self.sendDelegate modelStr];
        if (str != modelNumberSmooth4) {
            return;
        }
    }
    else{
        return;
    }
    
    [self sendRequest:ZYBleInteractAppControl data:@(1) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            //NSLog(@"app 开始控制");
        } else {
            //NSLog(@"app 开始控制失败");
        }
    }];
}

-(void) endAppControl
{
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(modelStr)]) {
        NSString *str = [self.sendDelegate modelStr];
        if (str != modelNumberSmooth4) {
            return;
        }
    }
    else{
        return;
    }
    
    [self sendRequest:ZYBleInteractAppControl data:@(0) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            //NSLog(@"app 结束控制");
        } else {
            //NSLog(@"app 结束控制失败");
        }
    }];
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
    [[ZYBleDeviceClient defaultClient] sendBLERequest:request completionHandler:handler];
}

-(void) sendMutableRequest:(ZYBleMutableRequest*)request completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler{
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    
    [[ZYBleDeviceClient defaultClient] sendMutableRequest:request completionHandler:handler];
}

-(void)dealloc{
#ifdef DEBUG
    
    //NSLog(@"%@",[self class]);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Device_BLEOffLine object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Device_State_Event_Notification_ResourceData object:nil];
}

/**
 跟踪指令发送
 
 @param pitch
 @param yaw
 @param handler 回掉
 */
- (void)tracckMove:(float)pitch yaw:(float)yaw compeletion:(nullable void (^)(BOOL success))handler{
    NSInteger innerPith = (int)pitch;
    NSInteger innerYaw = (int)yaw;
    if (innerPith < 0) {
        innerPith = 0;
    }
    else if (innerPith > 1000){
        innerPith = 1000;
    }
    
    if (innerYaw < 0) {
        innerYaw = 0;
    }
    else if (innerYaw > 1000){
        innerYaw = 1000;
    }
    
    ZYBleDeviceRequest* requestPitch = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractPitchTrackControl param:@(innerPith)];
    requestPitch.mask = ZYBleDeviceRequestMaskUpdate;
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:requestPitch];
    }
    
    ZYBleDeviceRequest* requestYaw = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:ZYBleInteractYawTrackControl param:@(innerYaw)];
    requestYaw.mask = ZYBleDeviceRequestMaskUpdate;
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:requestYaw];
    }
    
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    [client sendRequests:@[requestYaw,requestPitch] completionHandler:handler];
}

/**
 跟踪指令发送
 
 @param pitch
 @param yaw
 @param handler
 */
- (void)storyPositionMove:(float)pitch roll:(float)roll yaw:(float)yaw duration:(float)duration compeletion:(nullable void (^)(BOOL success))handler{
    ZYBlStoryCtrlPositionData *data = [[ZYBlStoryCtrlPositionData alloc] init];
 

    data.pitchDegree = pitch;
    data.rollDegree = roll;
    data.yawDegree = yaw;
    data.duration = duration * 100;
    [self configPrecision:data];
    
    [data createRawData];
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithZYControlData:data];
    request.needSendSoon = YES;
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    //      [self configRequest:request];
    @weakify(self);
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    [client sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        @strongify(self);
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlStoryCtrlPositionData *innaData = param;
            if ([innaData isKindOfClass:[ZYBlStoryCtrlPositionData class]]) {
                [self configPrecision:data];
            }
//            //NSLog(@"storyPosit pitchDegree = %f rollDegree =%f发送成功", innaData.pitchDegree,innaData.rollDegree);
            handler(YES);
        } else {
//            //NSLog(@"设备类型%@请求失败", param);
            handler(NO);
        }
    }];
}

-(void)configPrecision:(ZYBlStoryCtrlPositionData *)data{
    ZYProductSupportFunctionModel *model = nil;
   if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(delegatefunctionModel)]) {
       model = [self.sendDelegate delegatefunctionModel];
       if (model) {
           data.precisionPitch = 1.0 / model.precisionPitch ;
           data.precisionRoll = 1.0 / model.precisionRoll ;
           data.precisionYaw = 1.0 / model.precisionYaw;
       }
   }
}

/**
 跟踪指令发送
 
 @param pitch
 @param yaw
 @param handler
 */
- (void)storySpeedMove:(int)pitch roll:(int)roll yaw:(int)yaw duration:(float)duration compeletion:(nullable void (^)(BOOL success))handler{
    ZYBlStoryCtrlSpeedData *data = [[ZYBlStoryCtrlSpeedData alloc] init];
    data.pitchSpeed = pitch;
    data.rollSpeed = roll;
    data.yawSpeed = yaw;
    data.duration = duration * 100;
    [data createRawData];
    ZYBleMutableRequest* request = [[ZYBleMutableRequest alloc] initWithZYControlData:data];
    request.needSendSoon = YES;
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    //      [self configRequest:request];
    ZYBleDeviceClient *client = [ZYBleDeviceClient defaultClient];
    [client sendMutableRequest:request completionHandler:^(ZYBleDeviceRequestState state, id param) {
        if (state == ZYBleDeviceRequestStateResponse) {
            ZYBlStoryCtrlSpeedData *innaData = param;
//            //NSLog(@"storyPosit pitchSpeed = %f rollSpeed =%f发送成功", innaData.pitchSpeed,innaData.rollSpeed);
            handler(YES);
        } else {
//            //NSLog(@"设备类型%@请求失败", param);
            handler(NO);
        }
    }];
}
@end

