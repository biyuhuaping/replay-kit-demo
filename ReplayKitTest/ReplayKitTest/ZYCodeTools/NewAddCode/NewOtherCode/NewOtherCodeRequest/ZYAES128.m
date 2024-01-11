//
//  ZYAES128.m
//  ZYFilmic
//
//  Created by Liao GJ on 2020/3/15.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "ZYAES128.h"

#import <CommonCrypto/CommonCrypto.h>

#import <CommonCrypto/CommonDigest.h>
@implementation ZYAES128
//对NSData 进行加密

+(NSData *)encryptDataWithData:(NSData *)data Key:(NSString *)key

{
    
    char keyPtr[kCCKeySizeAES128 + 1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(key) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          
                                          kCCAlgorithmAES128,
                                          
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          
                                          keyPtr,
                                          
                                          kCCBlockSizeAES128,
                                          
                                          NULL,
                                          
                                          [data bytes],
                                          
                                          dataLength,
                                          
                                          buffer,
                                          
                                          bufferSize,
                                          
                                          &numBytesEncrypted);
    
    if(cryptStatus == kCCSuccess)
        
    {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        
    }
    
    free(buffer);
    
    return nil;
    
}

+(NSData *)decryptDataWithData:(NSData *)data andKey:(NSString *)key

{
    
    char keyPtr[kCCKeySizeAES128 + 1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [data bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    
    if(cryptStatus == kCCSuccess)
        
    {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    
    free(buffer);
    
    return nil;
    
}

+(NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key

{
    
    const char *cStr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cStr length:[string length]];
    
    //对数据进行加密
    
    NSData *result = [self encryptDataWithData:data Key:key];
    
    //转换为2进制字符串
    
    if(result && result.length > 0)
        
    {
        
        Byte *datas = (Byte *)[result bytes];
        
        NSMutableString *outPut = [NSMutableString stringWithCapacity:result.length];
        
        for(int i = 0 ; i < result.length ; i++)
            
        {
            [outPut appendFormat:@"%02x",datas[i]];
            
        }
        
        return outPut;
        
    }
    
    return nil;
    
}
+(NSString *)decryptStringWithString:(NSString *)string andKey:(NSString *)key

{

 NSMutableData *data = [NSMutableData dataWithCapacity:string.length/2.0];

 unsigned char whole_bytes;

 char byte_chars[3] = {'\0','\0','\0'};

 int i;

 for(i = 0 ; i < [string length]/2 ; i++)

 {

 byte_chars[0] = [string characterAtIndex:i * 2];

 byte_chars[1] = [string characterAtIndex:i * 2 + 1];

 whole_bytes = strtol(byte_chars, NULL, 16);

 [data appendBytes:&whole_bytes length:1];

 }

 NSData *result = [self decryptDataWithData:data andKey:key];

 if(result && result.length > 0)

 {

 return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];

 }

 return nil;

}


@end
