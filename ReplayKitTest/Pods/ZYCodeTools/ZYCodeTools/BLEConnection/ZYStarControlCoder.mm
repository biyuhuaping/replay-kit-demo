//
//  ZYStarControlCoder.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStarControlCoder.h"
#import "StarControlCoder.h"

@interface ZYStarControlCoder()
{
    zy::StarControlCoder* _coder;
}
@end

@implementation ZYStarControlCoder

-(instancetype) init
{
    if ([super init]) {
        _coder = new zy::StarControlCoder();
        self.contentType = SCCContentTypeFull;
    }
    return self;
}

-(void) dealloc
{
    if (_coder) {
        delete _coder;
        _coder = NULL;
    }
}

-(SCCContentType) contentType
{
    return _coder->getContentType();
}

-(void) setContentType:(SCCContentType) contentType
{
    _coder->setContentType(contentType);
}

-(NSData*) encode:(ZYStarData*)starData
{
    _coder->clear();
    zy::StarMessage* rawData = (zy::StarMessage*)[starData createRawData];
    BYTE* data = NULL;
    int len = 0;
    _coder->encode(rawData, &data, &len);
    NSData* retData = [NSData dataWithBytes:data length:len];
    free(data);
    data = NULL;
    return retData;
}

-(ZYStarData*) decode:(NSData*)data
{
    zy::StarMessage* message = _coder->decode((BYTE*)data.bytes, (int)data.length);
    if (message) {
        ZYStarData* starData = [[ZYStarData alloc] init];
        [starData setRawData:message];
        return starData;
    }
    return nil;
}

-(BOOL) isValid:(NSData*)data
{
    return _coder->isValid((BYTE*)data.bytes, (int)data.length)?YES:NO;
}

-(NSUInteger) dataUsedLen
{
    return _coder->getCurrentSize();
}

-(void) enableBigEndian:(BOOL)big_endian
{
    _coder->enableBigEndian(big_endian?true:false);
}

@end
