//
//  ZYStarControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlCoder.h"

#import "common_def.h"
#import "ZYStarData.h"

@interface ZYStarControlCoder : ZYControlCoder

@property (nonatomic, readwrite) SCCContentType contentType;

-(NSData*) encode:(ZYStarData*)data;
-(ZYStarData*) decode:(NSData*)data;

-(void) enableBigEndian:(bool)big_endian;

@end
