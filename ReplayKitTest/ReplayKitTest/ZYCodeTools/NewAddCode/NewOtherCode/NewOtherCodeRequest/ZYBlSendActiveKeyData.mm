//
//  ZYBlSendActiveKeyData.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlSendActiveKeyData.h"
#import "BlOtherCMD_SEND_ACTIVEKEYMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCMD_SEND_ACTIVEKEYMessage);

@interface ZYBlSendActiveKeyData()
{
    BlOtherCMD_SEND_ACTIVEKEYMessage* _message;
}
@end

@implementation ZYBlSendActiveKeyData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMD_SEND_ACTIVEKEYMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMD_SEND_ACTIVEKEYMessage);
    if (self.dataType == 0) {
        
        message->buildRequest((Byte *)[_keyData bytes],(int)_keyData.length);
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
    CAST_MESSAGE(BlOtherCMD_SEND_ACTIVEKEYMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherCMD_SEND_ACTIVEKEYMessage*)data;
}

-(NSUInteger) activeStatue
{
    CAST_MESSAGE(BlOtherCMD_SEND_ACTIVEKEYMessage);
    return message->active_status;
}

@end
