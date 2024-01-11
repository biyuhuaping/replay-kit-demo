//
//  ZYRdisData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYRdisData.h"
#import "RdisMessage.h"
#import "ZYRdisControlCoder.h"

using namespace zy;

@interface ZYRdisData()
@property (nonatomic, readwrite, assign) RdisMessage* message;
@property (nonatomic, readwrite) BOOL free;
@end

@implementation ZYRdisData


-(instancetype) init
{
    if ([super init]) {
        self.message = new RdisMessage();
    }
    return self;
}

-(void) dealloc
{
    if (self.message && self.free) {
        delete self.message;
        self.message = NULL;
    }
}

-(void*) createRawData
{
    if (self.dataType == 0) {
        //self.message->buildRequest();
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    [self setRawData:data freeWhenDone:YES];
}

-(void) setRawData:(void*)data freeWhenDone:(BOOL)free
{
    self.free = free;
    if (self.message) {
        delete self.message;
        self.message = NULL;
    }
    self.message = (zy::RdisMessage*)data;
}

-(BOOL)imageBoxConnecting{
    return (ZYBleDeviceWorkMode)self.message->getRdisInfo().SYS_STATUS.re == 1;
}

-(ZYBleDeviceWorkMode) workMode
{
    return (ZYBleDeviceWorkMode)self.message->getRdisInfo().SYS_MODE.mode;
}

-(BOOL) followFocus
{
    return self.message->getRdisInfo().SYS_STATUS.followFocus == 1;
}

-(BOOL) zoom
{
    return self.message->getRdisInfo().SYS_STATUS.zoomer == 1;
}

-(BOOL) workStatus
{
    return self.message->getRdisInfo().SYS_STATUS.workStatus == 1;
}

-(BOOL) isRecording
{
    return self.message->getRdisInfo().PTP_DATA.recroding == 1;
}

-(BOOL) isLiving
{
    return self.message->getRdisInfo().PTP_DATA.living == 1;
}

-(BOOL) isConnectiong
{
    return self.message->getRdisInfo().PTP_DATA.conneting == 1;
}

@end
