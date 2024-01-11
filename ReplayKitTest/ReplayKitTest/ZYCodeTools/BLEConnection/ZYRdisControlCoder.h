//
//  ZYRdisControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlCoder.h"
#import "ZYRdisData.h"

@interface ZYRdisControlCoder : ZYControlCoder

-(NSData*) encode:(ZYRdisData*)data;
-(ZYRdisData*) decode:(NSData*)data;
-(NSString*) descriptionForRdisData:(ZYRdisData*)data;

+(BOOL) canParse:(NSData*)data;
+(ZYRdisData*) buildRdisData:(void*) message;

@end
