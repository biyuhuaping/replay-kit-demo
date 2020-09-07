//
//  ZYImageCurve.h
//  ZYImageTools
//
//  Created by Frost Zhang on 2017/7/7.
//  Copyright © 2017年 Frost Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ZYImageCurveChannelType) {
    ZYImageCurveChannelTypeR = 0,
    ZYImageCurveChannelTypeG = 1,
    ZYImageCurveChannelTypeB = 2,
    ZYImageCurveChannelTypeRGB = 3,
};

@interface ZYImageCurve : NSObject

@property (nonatomic, readonly, strong) NSArray<NSValue*>* pnts;

-(void) setChannel:(ZYImageCurveChannelType) type;
-(void) setControlPnts:(NSArray<NSValue*>*) pnts;
-(void) calculate:(float)precision;
-(float) getValue:(float)x;

//-(NSData*) getCurveData;
-(UIImage*) createDataImage;
-(UIImage*) adjust:(UIImage*)image;
+(UIImage*) createHistogram:(UIImage*)image;
@end
