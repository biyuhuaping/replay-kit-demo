//
//  GPUImageColorCubeFilter.h
//  Pods
//
//  Created by Frost Zhang on 2017/7/11.
//
//

#import <Foundation/Foundation.h>
#import "GPUImageFilterGroup.h"

@interface GPUImageZebraStripesFilter : GPUImageFilterGroup

//zebra scale
@property(readwrite, nonatomic) CGPoint quadDimension;
@property(readwrite, nonatomic) float level;

-(instancetype) initWithZebraTexture:(UIImage*)image;

@end
