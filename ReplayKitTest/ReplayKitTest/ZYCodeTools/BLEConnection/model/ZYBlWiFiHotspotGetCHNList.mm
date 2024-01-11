//
//  ZYBlWiFiHotspotGetCHNList.m
//  ZYCamera
//
//  Created by zz on 2019/11/19.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotGetCHNList.h"
#import "ZYBlData_internal.h"
#import "BlWiFiHotspotGET_CHNLISTMessage.h"

using namespace zy;
SAFE_CAST(BlWiFiHotspotGET_CHNLISTMessage);

@interface ZYBlWiFiHotspotGetCHNList()
{
    BlWiFiHotspotGET_CHNLISTMessage* _message;
}
@end
@implementation ZYBlWiFiHotspotGetCHNList
@synthesize message = _message;

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.message = new BlWiFiHotspotGET_CHNLISTMessage();
    
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotGET_CHNLISTMessage);
    if (self.dataType == 0) {
        message->buildRequest();
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
    CAST_MESSAGE(BlWiFiHotspotGET_CHNLISTMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotGET_CHNLISTMessage*)data;
}

- (NSArray<NSString *> *)array {
    CAST_MESSAGE(BlWiFiHotspotGET_CHNLISTMessage);
    return [[NSString stringWithUTF8String:message->chn_list] componentsSeparatedByString:@","];
}
@end
