//
//  ZYConectModel.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/4/14.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MJExtension.h>

@interface ZYConectModel : NSObject

@property(nonatomic, copy)NSString *orignalName;

@property(nonatomic, copy)NSString *displayName;

@property(nonatomic, copy)NSString *isNeedAutoConnect ;

+(instancetype)connectModelWithOrignalName:(NSString*)oringnalName;
+(instancetype)connectModelWithDictionory:(NSDictionary*)dic;

-(NSMutableDictionary *)toDictionary;

//+(BOOL) 

@end
