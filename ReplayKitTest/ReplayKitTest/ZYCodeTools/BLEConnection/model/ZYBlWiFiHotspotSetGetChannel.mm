//
//  ZYBlWiFiHotspotScan.m
//  ZYCamera
//
//  Created by zz on 2019/11/20.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotSetGetChannel.h"
#import "ZYBlData_internal.h"
#import "BlWiFiHotspotCHNMessage.h"

using namespace zy;
SAFE_CAST(BlWiFiHotspotCHNMessage);

@interface ZYBlWiFiHotspotSetGetChannel()
{
    BlWiFiHotspotCHNMessage *_message;
}

@end
@implementation ZYBlWiFiHotspotSetGetChannel
@synthesize message = _message;
- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.message = new BlWiFiHotspotCHNMessage();
    
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotCHNMessage);
    if (self.dataType == 0) {
        message->buildRequest(_opt, _channel_status, (char *)[_channel UTF8String]);
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
    CAST_MESSAGE(BlWiFiHotspotCHNMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotCHNMessage*)data;
}

- (uint8_t)opt
{
    CAST_MESSAGE(BlWiFiHotspotCHNMessage);
    return message->opt;
}

- (uint8_t)channel_status
{
    CAST_MESSAGE(BlWiFiHotspotCHNMessage);
    return message->status;
}

- (NSString *)channel
{
    CAST_MESSAGE(BlWiFiHotspotCHNMessage);
    return [NSString stringWithUTF8String:message->chn_info];
}
@end
