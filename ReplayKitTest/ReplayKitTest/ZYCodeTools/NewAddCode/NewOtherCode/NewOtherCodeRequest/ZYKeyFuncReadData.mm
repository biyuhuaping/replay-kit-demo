//
//  ZYKeyFuncReadData.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYKeyFuncReadData.h"

#import "BlOtherCMD_KEYFUNC_DEFINE_READMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCMD_KEYFUNC_DEFINE_READMessage);

@interface ZYKeyFuncReadData()
{
    BlOtherCMD_KEYFUNC_DEFINE_READMessage* _message;
}
@end

@implementation ZYKeyFuncReadData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMD_KEYFUNC_DEFINE_READMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_READMessage);
    if (self.dataType == 0) {
        message->buildRequest(_keyInfo);
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
    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_READMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherCMD_KEYFUNC_DEFINE_READMessage*)data;
}


-(uint16)keyInfo{
    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_READMessage);
    return message->m_data.body.keyInfo;
}

-(NSArray *)keyFun{
    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_READMessage);
   NSMutableArray* configs = [NSMutableArray array];
   for (int i = 0; i < message->keyFunlist.size(); i++) {
       uint8 value = message->keyFunlist[i];
       [configs addObject:@(value)];
   }
   return configs;
}
@end
