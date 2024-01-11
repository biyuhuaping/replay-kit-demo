//
//  ZYStarData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStarData.h"
#import "StarMessage.h"


@interface ZYStarData()
{
    zy::StarMessage* _message;
}

@end

@implementation ZYStarData

-(instancetype) init
{
    if ([super init]) {
        _message = new zy::StarMessage(0, 0);
    }
    return self;
}

-(instancetype) initWithCodeAndParam:(NSUInteger)code param:(NSUInteger)param
{
    if ([self init]) {
        self.code = code;
        self.param = param;
    }
    return self;
}

-(void) dealloc
{
    if (_message) {
        delete _message;
        _message = NULL;
    }
}

-(NSUInteger) code
{
    return _message->getCode();
}

-(void) setCode:(NSUInteger) code
{
    _message->setCode((unsigned int)code);
}

-(NSUInteger) param
{
    return _message->getParam();
}

-(void) setParam:(NSUInteger) param
{
    return _message->setParam((unsigned int)param);
}

-(void*) createRawData
{
    return _message;
}

-(void) setRawData:(void*)data
{
    if (_message) {
        delete _message;
        _message = NULL;
    }
    _message = (zy::StarMessage*)data;
}

@end
