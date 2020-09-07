//
//  ZYBlData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"
#import "ZYBlData_internal.h"
#import "BlMessage.h"
using namespace zy;
SAFE_CAST(BlMessage);

@interface ZYBlData()
{
    BlMessage* _message;
}
@end

@implementation ZYBlData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlMessage();
        _free = YES;
    }
    return self;
}

-(void) dealloc
{
    BlMessage* message = castToBlMessage(self.message);
    if (message && self.free) {
        delete message;
        self.message = NULL;
    }
}

-(NSUInteger) headCode
{
    return castToBlMessage(self.message)->getHead().headCode;
}

-(void) setHeadCode:(NSUInteger) headCode
{
    castToBlMessage(self.message)->getHead().headCode = headCode;
}

-(NSUInteger) lenght
{
    return castToBlMessage(self.message)->getHead().lenght;
}

-(void) setLenght:(NSUInteger) lenght
{
    castToBlMessage(self.message)->getHead().lenght = lenght;
}

-(NSUInteger) address
{
    return castToBlMessage(self.message)->getHead().address;
}

-(void) setAddress:(NSUInteger) address
{
    castToBlMessage(self.message)->getHead().address = address;
}

-(NSUInteger) command
{
    return castToBlMessage(self.message)->getHead().command;
}

-(void) setCommand:(NSUInteger) command
{
    castToBlMessage(self.message)->getHead().command = command;
}

-(NSUInteger) status
{
    return castToBlMessage(self.message)->getHead().status;
}

-(void) setStatus:(NSUInteger) status
{
    castToBlMessage(self.message)->getHead().status = status;
}

-(NSData*) content
{
    BlMessage* message = castToBlMessage(self.message);
    return [NSData dataWithBytes:message->getBody() length:message->getBodySize()];
}

-(void) setContent:(NSData*) content
{
    BlMessage* message = castToBlMessage(self.message);
    message->setBody((BYTE*)content.bytes, content.length, true);
}

-(void*) createRawData
{
    BlMessage* message = castToBlMessage(self.message);
    if (self.dataType == 0) {
        //message->buildRequest();
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
    BlMessage* message = castToBlMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlMessage*)data;
}

-(NSDictionary*) toDictionary
{
    const NSUInteger MSG_CONTENT_START = 0;
    Byte* bytes = (Byte*)self.content.bytes;
    NSUInteger command = self.command;
    NSUInteger status = self.status;
    if (command == ZYBleInteractSync) {
        if(self.content.length < 16){
            return @{@"status":@(status),kDataParseSuccess:@(NO)};
        }
        //数据区第6字节开始
        NSUInteger idx = MSG_CONTENT_START + 4;
        NSUInteger size = 0;
        NSUInteger count = 0;
        NSUInteger archVersion = 0;
        NSUInteger hwVersion = 0;
        memcpy(&size, bytes+idx, 2);  //2+4~6
        idx += 2;
        memcpy(&count, bytes+idx, 2);  //2+6~8
        //跳过2字节数据
        idx += 4;
        memcpy(&archVersion, bytes+idx, 2); //2+10~12
        idx += 2;
        memcpy(&hwVersion, bytes+idx, 2); //2+12~14
        idx += 2;
        
        return @{@"status":@(status), @"size":@(size), @"count":@(count), @"archVersion":@(archVersion), @"hwVersion":@(hwVersion)};
    } else if (command == ZYBleInteractCheck) {
        if(self.content.length < 2){
            return @{@"status":@(status),kDataParseSuccess:@(NO)};
        }
        NSUInteger idx = MSG_CONTENT_START;
        int crc = 0;
        memcpy(&crc, bytes+idx, 2);
        idx += 2;
        return @{@"status":@(status), @"crc":@(crc)};
    } else if (command == ZYBleInteractUpdateWrite) {
        if(self.content.length < 2){
            return @{@"status":@(status),kDataParseSuccess:@(NO)};
        }
        NSUInteger idx = MSG_CONTENT_START;
        unsigned int nPage = 0;
        memcpy(&nPage, bytes+idx, 2);
        idx += 2;
        return @{@"status":@(status), @"page":@(nPage)};
    } else if (command == ZYBleInteractByPass) {
        NSUInteger idx = MSG_CONTENT_START;
//        unsigned int code = 0;
//        memcpy(&code, bytes+idx, 2);
//        idx += 2;
        return @{@"status":@(status)};
    } else {
        return @{@"status":@(status)};
    }
}

@end
