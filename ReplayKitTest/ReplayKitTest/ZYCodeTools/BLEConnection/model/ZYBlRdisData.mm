//
//  ZYBlRdisData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlRdisData.h"
#import "BlRdisMessage.h"
#import "RdisMessage.h"
#import "ZYBlData_internal.h"
#import "ZYRdisData.h"
#import "ZYRdisControlCoder.h"
using namespace zy;
SAFE_CAST(BlRdisMessage);

@interface ZYBlRdisData()
{
    BlRdisMessage* _message;
}

@end

@implementation ZYBlRdisData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlRdisMessage();
    }
    return self;
}

-(void*) createRawData
{
    zy::BlRdisMessage* message = castToBlRdisMessage(self.message);
    if (self.dataType == 0) {
        const RdisMessage* rdisMessage = (const RdisMessage*)[_rdisData createRawData];
        message->buildRequest(rdisMessage);
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
    zy::BlRdisMessage* message = castToBlRdisMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlRdisMessage*)data;
}

-(ZYRdisData*) rdisData
{
//    BlRdisMessage* message = castToBlRdisMessage(self.message);
//    const RdisMessage* rdisMessage = message->getRdisMessage();
//    ZYRdisData* rdisData = [ZYRdisControlCoder buildRdisData:(void*)rdisMessage];
//    [rdisData setRawData:message];
//    rdisData.dataType = 1;
//    return rdisData;
    
    if (_rdisData) {
        return _rdisData;
    } else {
        BlRdisMessage* message = castToBlRdisMessage(self.message);
        const RdisMessage* rdisMessage = message->getRdisMessage();
        ZYRdisData* rdisData = [ZYRdisControlCoder buildRdisData:(void*)rdisMessage];
        [rdisData setRawData:const_cast<RdisMessage*>(rdisMessage) freeWhenDone:NO];
        rdisData.dataType = 1;
        return rdisData;
    }
}

@end
