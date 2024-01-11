//
//  ZYBlData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbMediaData.h"
//#import "BlMessage.h"
#import "ZYUsbData_internal.h"
//using namespace zy;
//SAFE_CAST(BlMessage);

@interface ZYUsbMediaData()
{
    //BlMessage* _message;
}
@end

@implementation ZYUsbMediaData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        //self.message = new BlMessage();
    }
    return self;
}

//-(NSUInteger) headCode
//{
//    return castToBlMessage(self.message)->getHead().headCode;
//}
//
//-(void) setHeadCode:(NSUInteger) headCode
//{
//    castToBlMessage(self.message)->getHead().headCode = headCode;
//}
//
//-(NSUInteger) lenght
//{
//    return castToBlMessage(self.message)->getHead().lenght;
//}
//
//-(void) setLenght:(NSUInteger) lenght
//{
//    castToBlMessage(self.message)->getHead().lenght = lenght;
//}
//
//-(NSUInteger) address
//{
//    return castToBlMessage(self.message)->getHead().address;
//}
//
//-(void) setAddress:(NSUInteger) address
//{
//    castToBlMessage(self.message)->getHead().address = address;
//}
//
//-(NSUInteger) command
//{
//    return castToBlMessage(self.message)->getHead().command;
//}
//
//-(void) setCommand:(NSUInteger) command
//{
//    castToBlMessage(self.message)->getHead().command = command;
//}
//
//-(NSUInteger) status
//{
//    return castToBlMessage(self.message)->getHead().status;
//}
//
//-(void) setStatus:(NSUInteger) status
//{
//    castToBlMessage(self.message)->getHead().status = status;
//}
//
//-(NSData*) content
//{
//    BlMessage* message = castToBlMessage(self.message);
//    return [NSData dataWithBytes:message->getBody() length:message->getBodySize()];
//}
//
//-(void) setContent:(NSData*) content
//{
//    BlMessage* message = castToBlMessage(self.message);
//    message->setBody((BYTE*)content.bytes, content.length, true);
//}
//
//-(void*) createRawData
//{
//    return self.message;
//}
//
//-(void) setRawData:(void*)data
//{
//    BlMessage* message = castToBlMessage(self.message);
//    if (message) {
//        delete message;
//        self.message = NULL;
//    }
//    self.message = (zy::BlMessage*)data;
//}

@end
