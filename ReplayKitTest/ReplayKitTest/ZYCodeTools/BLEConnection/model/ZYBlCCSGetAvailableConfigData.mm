//
//  ZYBlCCSGetAvailableConfigData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlCCSGetAvailableConfigData.h"
#import "BlCCSGetAvailableConfigMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlCCSGetAvailableConfigMessage);

@implementation CCSConfigItem
-(NSString*) description
{
    return [NSString stringWithFormat:@"idx:%lu, value:%@", (unsigned long)_idx, _itemLists];
}
@end

@interface ZYBlCCSGetAvailableConfigData()
{
    BlCCSGetAvailableConfigMessage* _message;
}
@end

@implementation ZYBlCCSGetAvailableConfigData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlCCSGetAvailableConfigMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlCCSGetAvailableConfigMessage);
    if (self.dataType == 0) {
        message->buildRequest(_idx);
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
    CAST_MESSAGE(BlCCSGetAvailableConfigMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlCCSGetAvailableConfigMessage*)data;
}

@end
