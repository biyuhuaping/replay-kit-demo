//
//  ZYBLControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlCoder.h"
#import "ZYBlData.h"

@interface ZYBlControlCoder : ZYControlCoder

-(NSData*) encode:(ZYBlData*)data;
-(ZYBlData*) decode:(NSData*)data;
+(NSString*) descriptionForBlData:(ZYBlData*)data;

+(BOOL) canParse:(NSData*)data;
+(ZYBlData*) buildBlData:(void*) message;

@end
