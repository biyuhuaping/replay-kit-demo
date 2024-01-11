//
//  ZYBlOtherSyncData.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherSyncData.h"

#import "BlOtherCMDSyncDataMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCMDSyncDataMessage);

@implementation CCSConfigSynItem
-(NSString*) description
{
    return [NSString stringWithFormat:@"idx:%lu, value:%@", (unsigned long)_idx, _itemLists];
}
@end

@interface ZYBlOtherSyncData()
{
    BlOtherCMDSyncDataMessage* _message;
}
@end

@implementation ZYBlOtherSyncData
@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMDSyncDataMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMDSyncDataMessage);
    if (self.dataType == 0) {
        message->buildRequest(_idx,_messageId);
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
    CAST_MESSAGE(BlOtherCMDSyncDataMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlOtherCMDSyncDataMessage*)data;
}

-(NSUInteger)idx
{
    CAST_MESSAGE(BlOtherCMDSyncDataMessage);
    if (message->m_itemlist.size() > 0) {
        return message->m_itemlist[0].configIdx;
    }
    return 0;
}

-(NSUInteger)messageId{

    CAST_MESSAGE(BlOtherCMDSyncDataMessage);
    return message->m_data.body.msgId;

   
}

-(NSArray<CCSConfigSynItem*>*) configs
{
    CAST_MESSAGE(BlOtherCMDSyncDataMessage);
    NSMutableArray* configs = [NSMutableArray array];
    for (int i = 0; i < message->m_itemlist.size(); i++) {
        ccs_sync_value value = message->m_itemlist[i];
        CCSConfigSynItem* item = [[CCSConfigSynItem alloc] init];
        item.idx = value.configIdx;
        item.itemLists = [NSArray arrayWithObject:[NSString stringWithUTF8String:value.value.c_str()]];
        [configs addObject:item];
    }
    return configs;
}

@end
