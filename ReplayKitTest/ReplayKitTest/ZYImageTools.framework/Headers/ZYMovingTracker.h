//
//  ZYMovingTracker.h
//  ZYImageTools
//
//  Created by Frost Zhang on 2017/2/19.
//  Copyright © 2017年 Frost Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

/// 流状态
typedef NS_ENUM (NSUInteger, ZYMovingTrackerType) {
    /// 最高30fps
    ZYMovingTrackerType_CMT = 0,
    /// 最高10fps
    ZYMovingTrackerType_KCF = 1,
    /// 最高10fps
    ZYMovingTrackerType_DSST = 2,
};

@protocol ZYMovingTrackerDelegate <NSObject>

@required
-(UIImage*)requestNextFrame;

@optional
-(void)notifyTrackingResult;
@end

@interface ZYTrackerTargetInfo : NSObject
@property(nonatomic, readwrite, copy) NSString* name;
@property(nonatomic, readwrite) float confidence;
@property(nonatomic, readwrite) CGRect boundingBox;
@end

@interface ZYMovingTracker : NSObject

@property(nonatomic, readwrite) NSUInteger fps;
@property(nonatomic, readwrite) CGRect trackingRange;
@property(nonatomic, readonly) CGRect boundingBox;
@property(nonatomic, readonly) CGRect motionVec;
@property(nonatomic, readonly) CGPoint motionCompensation;
@property(nonatomic, readwrite) BOOL asyn;
@property(nonatomic, readonly) BOOL isRuning;
@property(nonatomic, readwrite) NSInteger type;

@property(nonatomic, readwrite, weak) id<ZYMovingTrackerDelegate> delegate;

-(UIImage*)processTrackingImage:(UIImage*)image;
-(UIImage*)processTrackingBuffer:(CMSampleBufferRef)buffer;
-(void)getTargetListWithUIImage:(UIImage*)image list:(NSMutableArray<ZYTrackerTargetInfo*>*)list;
-(void)getTargetListWithSampleBuffer:(CMSampleBufferRef)sampleBuffer list:(NSMutableArray<ZYTrackerTargetInfo*>*)list;

-(void) start;
-(void) stop;

@end
