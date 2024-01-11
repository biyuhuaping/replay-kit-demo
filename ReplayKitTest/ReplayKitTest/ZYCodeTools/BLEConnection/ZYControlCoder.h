//
//  ZYControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZYControlData;

@interface ZYControlCoder : NSObject

-(NSData*) encode:(ZYControlData*)data;
-(ZYControlData*) decode:(NSData*)data;

-(BOOL) isValid:(NSData*)data;
-(NSUInteger) dataUsedLen;

-(void) enableBigEndian:(BOOL)big_endian;

@end
