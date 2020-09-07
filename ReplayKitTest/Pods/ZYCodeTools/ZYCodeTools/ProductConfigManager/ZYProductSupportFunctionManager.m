//
//  ZYProductSupportFunctionManager.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/8/30.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//


#import "ZYProductSupportFunctionManager.h"

@interface ZYProductSupportModel()

@property (nonatomic,strong, readwrite)   ZYProductSupportFunctionModel   * _Nullable functionModel;//支持功能的模型对象
@end


@implementation ZYProductSupportModel

@end

@interface ZYProductSupportFunctionManager()

/**
所有的产品内容
 */
@property (nonatomic,strong)           NSMutableDictionary       *productDiction;

@end

@implementation ZYProductSupportFunctionManager
static  ZYProductSupportFunctionManager  *shareSingleton = nil;
+( instancetype ) defaultManager{
     if (shareSingleton == nil) {
        shareSingleton = [[ZYProductSupportFunctionManager alloc] init];
    }
    return shareSingleton;
}
+(id) allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            shareSingleton = [super allocWithZone:zone];
            [shareSingleton loadList];
    });
    return shareSingleton;
    
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

-(void)loadList
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"list.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
    _productDiction = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dic in dataArray) {
        NSArray *array = [dic objectForKey:@"models"];
        NSString *str = [dic objectForKey:@"profile"];
        if ([[str lowercaseString] containsString:@".json"]) {
            for (NSString *strId in array) {
                if (strId.length > 0) {
                    ZYProductSupportModel *model = [[ZYProductSupportModel alloc] init];
                    model.productId = [strId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    model.jsonName = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    int number = (int)strtoul([strId UTF8String],0,16);  //16进制字符串转换成int
                    model.productIdNumber = number;
                    _productDiction[@(number)] = model;
                }
            }
        }
        else{
            NSLog(@"后缀不是json");
        }
    }
}

-(ZYProductSupportFunctionModel *)modelWithProductId:(NSUInteger)productIdNumber
{
    if (_productDiction) {
        ZYProductSupportModel *model =  _productDiction[@(productIdNumber)];
        if (model) {
            if (model.functionModel) {
                return model.functionModel;
            }
            else{
                if (model.jsonName.length > 0) {
                    NSString *path = [[NSBundle mainBundle] pathForResource:model.jsonName ofType:nil];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                        NSData *data = [NSData dataWithContentsOfFile:path];
                        NSError *error;
                        NSDictionary  *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                        if (!error && [dic isKindOfClass:[NSDictionary class]]) {
                            ZYProductSupportFunctionModel *functionModel = [ZYProductSupportFunctionModel functionModelWithDic:dic];
                            functionModel.productIdNumber = productIdNumber;
                            model.functionModel = functionModel;
                            return [functionModel copy];
                        }
                        else{
                            NSLog(@"%@",error);
                        }
                    }
                    
                    
                }
               
            }
        }
    }
    ZYProductSupportFunctionModel *modelReturn = [[ZYProductSupportFunctionModel alloc] init];
    modelReturn.productIdNumber = productIdNumber;
    return modelReturn;
}
@end
