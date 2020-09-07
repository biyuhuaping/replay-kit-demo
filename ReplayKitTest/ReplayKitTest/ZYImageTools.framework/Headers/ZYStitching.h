//
//  ZYStitching.h
//  ZYImageTools
//
//  Created by Frost Zhang on 2017/2/18.
//  Copyright © 2017年 Frost Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYStitching : NSObject

@property (nonatomic, readwrite) BOOL clipBlack;
@property (nonatomic, readwrite) double outputQuality;

-(void) stitchingImages:(NSArray<UIImage*>*)images compeletion:(void(^)(UIImage* result))compeletionHandler;

@end
