//
//  GPUImageColorCubeFilter.h
//  Pods
//
//  Created by Frost Zhang on 2017/7/11.
//
//

#import <Foundation/Foundation.h>
#import "GPUImageFilterGroup.h"

@interface GPUImageColorCubeFilter : GPUImageFilterGroup

-(instancetype) initWithLookupTexture:(UIImage*)image quad:(CGPoint)dimension;

@end
