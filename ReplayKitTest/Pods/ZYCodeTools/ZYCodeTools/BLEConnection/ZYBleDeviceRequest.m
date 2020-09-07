//
//  ZYBleDeviceRequest.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/10.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleDeviceRequest.h"
#import "ZYCrcCheck.h"
#import "ZYBleProtocol.h"
#import "ZYStarData.h"
#import "ZYBlData.h"
#import "ZYStarControlCoder.h"
#import "ZYBlControlCoder.h"
#import "ZYBleMutableRequest.h"
#import "ZYAllControlData.h"

const NSUInteger MSG_BODY_LEN = 7;
const NSUInteger MSG_DATA_LEN = 5;

typedef void (^countdownBlock)(void);

@interface ZYBleDeviceRequest ()

@property (nonatomic, readwrite, strong) NSTimer* countdownTimer;
@property (nonatomic, readwrite, copy) countdownBlock countdownBlock;
@property (nonatomic, readwrite, copy) NSDate* sendTimeStamp;
@property (nonatomic, readwrite, copy) ZYControlData* controlData;

@end

@implementation ZYBleDeviceRequest

-(instancetype) initWithCodeAndParam:(NSUInteger)code param:(NSNumber*)param
{
    if ([self init]) {
        _code = code;
        _realCode = _code;
        _param = [self translateToUINT16:param];
        _packedWithNext = NO;
        _controlData = [[ZYStarData alloc] initWithCodeAndParam:code param:_param];
        _blocked = YES;
        _noNeedToUpdateDataCache = NO;
        if ([self isSameWithCode:ZYBleInteractPitchControl]
            || [self isSameWithCode:ZYBleInteractRollControl]
            || [self isSameWithCode:ZYBleInteractYawControl]) {
            _mask = ZYBleDeviceRequestMaskUpdate;
        } else {
            _mask = ZYBleDeviceRequestMaskUnique;
        }
        _needSendSoon = NO;
    }
    return self;
}

-(BOOL) isWaiting
{
    return _countdownBlock != nil;
}

-(BOOL) needResponse
{
    return !((ZYBLEMakeInteractCodeToCmd(self.code) == ZYBLE_CMD_CONTR) || [self isKeyEvent]);
}

+(BOOL) parseDataToCodeAndParam:(NSData*)data code:(NSUInteger*)aCode param:(NSUInteger*)aParam
{
    if (data.length == 4) {
        Byte* bytes = (Byte*)data.bytes;
        unsigned short codeH = bytes[0];
        unsigned short paramH = bytes[2];
        *aCode = (codeH << 8) | bytes[1];
        *aParam = (paramH << 8) | bytes[3];
        return YES;
    } else if (data.length == 7) {
        Byte* bytes = (Byte*)data.bytes;
        unsigned short codeH = bytes[1];
        unsigned short paramH = bytes[3];
        *aCode = (codeH << 8) | bytes[2];
        *aParam = (paramH << 8) | bytes[4];
        return YES;
    }
    return NO;
}

-(instancetype) initWithBytes:(NSData*)data
{
    if ([self init]) {
        [ZYBleDeviceRequest parseDataToCodeAndParam:data code:&_code param:&_param];
        _realCode = _code;
    }
    return self;
}

+(BOOL) isValidData:(NSData*)data
{
    if (data.length == 7) {
        Byte* bytes = (Byte*)data.bytes;
        NSUInteger crc = [ZYCrcCheck calculate:[NSData dataWithBytes:data.bytes length:MSG_DATA_LEN]];
        
        if (((crc >> 8) & 0xFF) == bytes[5]
            && (crc & 0xFF) == bytes[6]) {
            return YES;
        }
    }
    return NO;
}

-(NSData*) translateToBinaryWithCoder:(ZYControlCoder*)coder;
{
    return [coder encode:_controlData];
}

-(void) startCountdown:(NSUInteger)millisecond block:(void (^)(void))block
{
    if (self.delayMillisecond > 0) {
        millisecond = self.delayMillisecond;
    }
    if (self.code == ZYBleInteractSysReset) {
        millisecond = 1000;
    } 
    
    if (![self needResponse]) {
        return;
    }
    
    NSRunLoop* runLoop = [NSRunLoop mainRunLoop];
    if (_countdownTimer == nil) {
        _countdownTimer = [NSTimer timerWithTimeInterval:millisecond/1000. target:self selector:@selector(countdownReached:) userInfo:nil repeats:NO];
    }
    _countdownBlock = block;
    [runLoop addTimer:_countdownTimer forMode:NSRunLoopCommonModes];
    
    _sendTimeStamp = [NSDate date];
}

-(void) finishCountdown
{
    [_countdownTimer invalidate];
    _countdownBlock = nil;
    //NSLog(@"request respond in %.3f seconds", [[NSDate date] timeIntervalSinceDate:_sendTimeStamp]);
//    NSLog(@"request respond in %.3f seconds", [[NSDate date] timeIntervalSinceDate:_sendTimeStamp]);
}

#pragma 辅助函数
-(NSUInteger) translateToUINT16:(NSNumber*)value
{
    NSUInteger ret = value.unsignedIntegerValue;
    switch (self.code) {
        case ZYBleInteractCodePitchFollowMaxRate_W:
        case ZYBleInteractCodeRollFollowMaxRate_W:
        case ZYBleInteractCodeYawFollowMaxRate_W:
        case ZYBleInteractCodePitchControlMaxRate_W:
        case ZYBleInteractCodeRollControlMaxRate_W:
        case ZYBleInteractCodeYawControlMaxRate_W:
        case ZYBleInteractCodePitchSharpTurning_W:
        case ZYBleInteractCodeRollSharpTurning_W:
        case ZYBleInteractCodePitchDeadArea_W:
        case ZYBleInteractCodeRollDeadArea_W:
        case ZYBleInteractCodeYawDeadArea_W:
            ret = (int)(value.floatValue*100);
            break;
            
        case ZYBleInteractCodePitchSmoothness_W:
        case ZYBleInteractCodeRollSmoothness_W:
        case ZYBleInteractCodeYawSmoothness_W:
            ret = value.unsignedIntegerValue;
            break;
            
        case ZYBleSetPointMotionTimeHighBit:
            ret = ([value unsignedIntValue] & 0xffff0000) >> 16;
            break;
        case ZYBleSetPointMotionTimeLowBit:
            ret = ([value unsignedIntValue]  & 0x0000ffff) ;
            break;
            
        case ZYBleInteractPitchControl:
        case ZYBleInteractRollControl:
        case ZYBleInteractYawControl:
            ret = value.integerValue+2048;
            break;
            
        case ZYBlePitchRotateAngleControl:
        case ZYBleRollRotateAngleControl:
        case ZYBleYawRotateAngleControl:
            ret = (int)(value.floatValue*100);
            break;
        case ZYBleInteractPitchMotionControl:   //体感俯仰参数 [ -9000, 9000]
        case ZYBleInteractRollMotionControl:   //体感俯仰参数 [ 4500, 4500]
        case ZYBleInteractYawMotionControl:   //体感俯仰参数 [ -18000, 18000]
        {
            ret = (int)(value.floatValue*100);
        }
            break;
        default:
            break;
    }
    return ret;
}

-(void) countdownReached:(NSTimer*)timer
{
    [timer invalidate];
    if (_countdownBlock) {
//        NSLog(@"超时间到%@",self);
        _countdownBlock();
        _countdownBlock = nil;
    }
//    NSLog(@"request %@ timeout in %.3f seconds", self, [[NSDate date] timeIntervalSinceDate:_sendTimeStamp]);
}

#pragma 判断元素相等
- (BOOL)isEqualToRequest:(ZYBleDeviceRequest *)request
{
    if (!request) {
        return NO;
    }
    
    if (self.mask == ZYBleDeviceRequestMaskMulty) {
        return NO;
    }
    if ([request isKindOfClass:[ZYBleMutableRequest class]]) {
        ZYBleMutableRequest* mutableRequest = (ZYBleMutableRequest*)request;
        if (self.mask == ZYBleDeviceRequestMaskUpdate) {
            return (self.realCode == mutableRequest.realCode);
        } else {
            return (self.realCode == mutableRequest.realCode) && (self.param == mutableRequest.param);
            //&& (self.handler == mutableRequest.handler);
        }
    } else {
        if (self.mask == ZYBleDeviceRequestMaskUpdate) {
            return (self.code == request.code) && (self.handler == request.handler);
        } else {
            return (self.code == request.code) && (self.param == request.param) && (self.handler == request.handler);
        }
    }

}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[ZYBleDeviceRequest class]]) {
        return NO;
    }
    
    return [self isEqualToRequest:(ZYBleDeviceRequest *)object];
}

-(NSString*) description
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";   // 设置时间格式
    NSString *str = [formatter stringFromDate:_sendTimeStamp];
    
    return [NSString stringWithFormat:@"<0x%x %@ cmd:0x%02lx addr:0x%02lx index:0x%02lx Param %ld timeStamp %@ %@>", self, [self translateToBinaryWithCoder:[[ZYStarControlCoder alloc] init]], ((_code >> 8) & 0xF0), ((_code >> 8)& 0x0F), (_code & 0xFF), _param, str, starCodeToNSString(_code)];
}

-(BOOL) isKeyEvent
{
    return [self isSameWithCode:ZYBleInteractButtonEvent];
}

-(BOOL) isSameWithCode:(NSUInteger)code
{
    return ZYBLEMakeInteractCodeWithoutAdrCmp(self.code, code);
}

-(BOOL) isSameCodeWithRequest:(ZYBleDeviceRequest*)request
{
    return [self isSameWithCode:request.code];
}

-(void) notifyResultWithRequest:(ZYBleDeviceRequest*)request state:(ZYBleDeviceRequestState)state coder:(ZYControlCoder *)coder;
{
    BLOCK_EXEC_ON_MAINQUEUE(request.handler, state, self.param);
}

-(BOOL) postNotificationIfNeed:(ZYControlCoder*)coder
{
    return NO;
}

@end

ZYBleDeviceRequest* buildRequestWithControlData(ZYControlData* data)
{
    if ([data isKindOfClass:[ZYStarData class]]) {
        ZYStarData* starData = (ZYStarData*)data;
        return [[ZYBleDeviceRequest alloc] initWithCodeAndParam:starData.code param:@(starData.param)];
    }
    else if ([data isKindOfClass:[ZYBlData class]]
             || [data isKindOfClass:[ZYUsbData class]]) {
        ZYBleMutableRequest* result = [[ZYBleMutableRequest alloc] initWithZYControlData:data];
        return result;
    }
    return nil;
}


