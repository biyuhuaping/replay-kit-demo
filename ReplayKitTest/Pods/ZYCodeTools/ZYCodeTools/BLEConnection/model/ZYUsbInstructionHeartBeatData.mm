//
//  ZYUsbInstructionHeartBeatData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbInstructionHeartBeatData.h"
#import "UsbInstructionHeartBeatMessage.h"
#import "ZYUsbData_internal.h"

using namespace zy;
SAFE_CAST_USB(UsbInstructionHeartBeatMessage);

@interface ZYUsbInstructionHeartBeatData()
{
    UsbInstructionHeartBeatMessage* _message;
}

@property (nonatomic)         BOOL  useCustomMesage;
@property (nonatomic)         NSUInteger  customMesageId;


@end

@implementation ZYUsbInstructionHeartBeatData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new UsbInstructionHeartBeatMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE_USB(UsbInstructionHeartBeatMessage);
    if (self.dataType == 0) {
        if (self.useCustomMesage) {
            message->buildRequest(_flag, _sec, _usec,_customMesageId);
        }
        else{
            message->buildRequest(_flag, _sec, _usec);
        }
    }
    return self.message;
}

-(void *)createRawDataWithMsgId:(NSUInteger)msgId{
    CAST_MESSAGE_USB(UsbInstructionHeartBeatMessage);
    if (self.dataType == 0) {
        _customMesageId = msgId;
        _useCustomMesage = YES;
        message->buildRequest(_flag, _sec, _usec,_customMesageId);
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    CAST_MESSAGE_USB(UsbInstructionHeartBeatMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::UsbInstructionHeartBeatMessage*)data;
}

-(NSUInteger) uid
{
    CAST_MESSAGE_USB(UsbInstructionHeartBeatMessage);
    return message->getHead().content.cmdid;
}

-(NSUInteger) flag
{
    CAST_MESSAGE_USB(UsbInstructionHeartBeatMessage);
    return message->m_data.body.flag;
}

-(NSUInteger) sec
{
    CAST_MESSAGE_USB(UsbInstructionHeartBeatMessage);
    return message->m_data.body.sec;
}

-(NSUInteger) usec
{
    CAST_MESSAGE_USB(UsbInstructionHeartBeatMessage);
    return message->m_data.body.usec;
}

@end
