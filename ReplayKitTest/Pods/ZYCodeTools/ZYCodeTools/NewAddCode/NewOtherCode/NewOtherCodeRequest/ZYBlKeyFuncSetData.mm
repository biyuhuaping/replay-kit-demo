//
//  ZYBlKeyFuncSetData.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlKeyFuncSetData.h"

#import "BlOtherCMD_KEYFUNC_DEFINE_SETMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCMD_KEYFUNC_DEFINE_SETMessage);

@interface ZYBlKeyFuncSetData()
{
    BlOtherCMD_KEYFUNC_DEFINE_SETMessage* _message;
}
@end

@implementation ZYBlKeyFuncSetData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMD_KEYFUNC_DEFINE_SETMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_SETMessage);
    if (self.dataType == 0) {
        message->buildRequest(_keyInfo,_keyFunc);
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
    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_SETMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherCMD_KEYFUNC_DEFINE_SETMessage*)data;
}

-(uint8)keyFunc{
    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_SETMessage);
    return message->m_data.body.keyFun;
}

-(uint16)keyInfo{

    CAST_MESSAGE(BlOtherCMD_KEYFUNC_DEFINE_SETMessage);
    return message->m_data.body.keyInfo;

}

@end
