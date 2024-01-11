//
//  ZYBlWiFiHotspotScan.m
//  ZYCamera
//
//  Created by zz on 2019/11/20.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotScan.h"
#import "ZYBlData_internal.h"
#import "BlWiFiHotspotCHN_SCANMessage.h"

using namespace zy;
SAFE_CAST(BlWiFiHotspotCHN_SCANMessage);

@interface ZYBlWiFiHotspotScan()
{
    BlWiFiHotspotCHN_SCANMessage *_message;
}

@end
@implementation ZYBlWiFiHotspotScan
@synthesize message = _message;
- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.message = new BlWiFiHotspotCHN_SCANMessage();
    
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotCHN_SCANMessage);
    if (self.dataType == 0) {
        char *tmp = (char *)"";
        message->buildRequest(_opt, tmp);
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
    CAST_MESSAGE(BlWiFiHotspotCHN_SCANMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotCHN_SCANMessage*)data;
}

- (uint8_t)opt
{
    CAST_MESSAGE(BlWiFiHotspotCHN_SCANMessage);
    return message->opt;
}

- (NSArray<NSString *> *)array
{
    CAST_MESSAGE(BlWiFiHotspotCHN_SCANMessage);
    
    NSMutableArray *tmp = [@[] mutableCopy];
    for (int i = 0; i < 128; ++i)
    {
        if (strlen(message->infos[i].scan_info) == 0)
            break;
        
        [tmp addObject:[NSString stringWithUTF8String:message->infos[i].scan_info]];
    }
    
    return tmp;
}
@end
