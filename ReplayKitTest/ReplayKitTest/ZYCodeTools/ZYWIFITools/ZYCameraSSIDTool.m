//
//  ZYCameraSSIDTool.m
//  ZYCamera
//
//  Created by ZY27 on 2019/7/11.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYCameraSSIDTool.h"

@implementation ZYCameraSSIDTool

+(NSDictionary *)getSSIDAndPasswordWithStr:(NSString *)str{
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    /*
        sony
        W01:S:GUE1;P:eLNtxFkh;C:ILCE-6500;M:46916023B58F;
        SSID = DIRECT-<S>:<C>
        */
    
    if([str hasPrefix:@"W01"]){
     
        NSArray *array = [str componentsSeparatedByString:@";"];
        
        NSString *ssidStr;
        NSString *pw;
        
        NSString *sonySSid;
        NSString *sonyModel;
        
        for(NSString *subStr in array){
            
            
            if([subStr hasPrefix:@"W01:S:"]){

                NSArray *subArr = [subStr componentsSeparatedByString:@":"];
                if(subArr.count){
                
                    sonySSid = [subArr lastObject];
                }
            }
            
            if([subStr hasPrefix:@"C:"]){
                
                NSArray *subArr = [subStr componentsSeparatedByString:@":"];
                if(subArr.count){
                    
                    sonyModel = [subArr lastObject];
                }
                
            }
            
            if([subStr hasPrefix:@"P:"]){
                
                NSArray *subArr = [subStr componentsSeparatedByString:@":"];
                if(subArr.count){
                    
                    pw = [subArr lastObject];
                    if(pw.length){
                        [dic setObject:pw forKey:@"PW"];
                    }
                }
            }
        }
        
        if(sonySSid && sonyModel){
            
            ssidStr  = [NSString stringWithFormat:@"DIRECT-%@:%@",sonySSid,sonyModel];
            [dic setObject:ssidStr forKey:@"SSID"];
            
        }
        
    }
    
    /*
        Panasonic
        MDL: DSC-1 SSID: ZS110-49535A PW: a8c450049535a
        */
    if([str hasPrefix:@"MDL"]){
        
        str =  [str stringByReplacingOccurrencesOfString:@": " withString:@":"];
        
        NSArray *array = [str componentsSeparatedByString:@" "];
        NSString *ssidStr = @"";
        NSString *pw = @"";
        
        
        for(NSString *subStr in array){
            
            if([subStr hasPrefix:@"SSID:"]){
                
                NSArray *subArr = [subStr componentsSeparatedByString:@":"];
                if(subArr.count){
                    
                    ssidStr = [subArr lastObject];
                    if(ssidStr.length){
                        
                        [dic setObject:ssidStr forKey:@"SSID"];
                    }
                }
                
            }
        
            if([subStr hasPrefix:@"PW:"]){
                
                NSArray *subArr = [subStr componentsSeparatedByString:@":"];
                if(subArr.count){
                    
                    pw = [subArr lastObject];
                    if(pw.length){
                        
                        [dic setObject:pw forKey:@"PW"];
                    }
                }
                
                
            }
        }
    }
    
    return dic;
}

@end
