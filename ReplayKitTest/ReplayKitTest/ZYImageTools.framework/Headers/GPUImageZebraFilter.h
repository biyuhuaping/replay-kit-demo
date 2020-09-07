//
//  GPUImageLUTFilter.h
//  Pods
//
//  Created by Frost Zhang on 2017/7/10.
//
//

#import <Foundation/Foundation.h>
#import "GPUImageTwoInputFilter.h"

@interface GPUImageZebraFilter : GPUImageTwoInputFilter
{
    GLint thresholdsUniform;
    GLint quadDimensionUniform;
}

//adjust thresholds
@property(readwrite, nonatomic) CGFloat thresholds;
//zebra scale
@property(readwrite, nonatomic) CGPoint quadDimension;

@end
