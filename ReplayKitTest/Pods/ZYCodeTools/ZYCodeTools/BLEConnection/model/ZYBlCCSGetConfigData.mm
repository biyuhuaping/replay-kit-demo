//
//  ZYBlCCSGetConfigData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlCCSGetConfigData.h"
#import "BlCCSGetConfigMessage.h"
#import "ZYBlData_internal.h"
#import "ZYBlCCSGetAvailableConfigData.h"
using namespace zy;
SAFE_CAST(BlCCSGetConfigMessage);

@interface ZYBlCCSGetConfigData()
{
    BlCCSGetConfigMessage* _message;
}
@end

@implementation ZYBlCCSGetConfigData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlCCSGetConfigMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlCCSGetConfigMessage);
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
    CAST_MESSAGE(BlCCSGetConfigMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlCCSGetConfigMessage*)data;
}

-(NSUInteger) idx
{
    CAST_MESSAGE(BlCCSGetConfigMessage);
    if (message->m_itemlist.size() > 0) {
        return message->m_itemlist[0].configIdx;
    }
    return 0;
}

-(NSString*) value
{
    CAST_MESSAGE(BlCCSGetConfigMessage);
    if (message->m_itemlist.size() > 0) {
        return [NSString stringWithUTF8String:message->m_itemlist[0].value.c_str()];
    }
    return @"";
}

-(NSUInteger) cmdStatus
{
    CAST_MESSAGE(BlCCSGetConfigMessage);
    return message->m_data.body.status;
}

-(NSArray<CCSConfigItem*>*) configs
{
    CAST_MESSAGE(BlCCSGetConfigMessage);
    NSMutableArray* configs = [NSMutableArray array];
    for (int i = 0; i < message->m_itemlist.size(); i++) {
        ccs_item_value value = message->m_itemlist[i];
        CCSConfigItem* item = [[CCSConfigItem alloc] init];
        item.idx = value.configIdx;
        item.itemLists = [NSArray arrayWithObject:[NSString stringWithUTF8String:value.value.c_str()]];
        [configs addObject:item];
    }
    return configs;
}

@end
