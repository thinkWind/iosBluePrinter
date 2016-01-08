//
//  BluePrinterFormat.m
//  BluePrinter
//
//  Created by feng on 15/12/15.
//  Copyright © 2015年 feng. All rights reserved.
//

#import "BluePrinterFormat.h"

//一行最大数量
static const NSInteger LineByteSize = 32;

//分隔符
static NSString* const Spearator = @"$";

@interface BluePrinterFormat ()

@property (nonatomic, strong, readwrite) NSMutableString* contentString;

@end

@implementation BluePrinterFormat
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)printTitle:(NSString *)title
{
    self.contentString = [NSMutableString new];
    [self.contentString appendString:@"\n\n"]; //抬头留白
    [self.contentString appendString:title];
    [self.contentString appendFormat:@"\n"];
    return [self.contentString copy];
}

- (NSString *)printOrderMsg:(NSDictionary<NSString *,NSString *> *)msgDic
{
    self.contentString = [NSMutableString new];
    [self.contentString appendString:@"\n"];
    for (NSInteger idx = 0; idx < 32; ++idx) {
        [self.contentString appendString:@"="];
    }
    [self.contentString appendString:@"\n"];
    
    return [self printMiddleMsg:msgDic];
}

- (NSString *)printMenuMsg:(NSDictionary<NSString *,NSDictionary *> *)menuMsgDic isHead:(BOOL)isHead
{
    self.contentString = [NSMutableString new];
    if (isHead) {
        [self.contentString appendString:@"\n"];
        for (NSInteger idx = 0; idx < 32; ++idx) {
            [self.contentString appendString:@"-"];
        }
        [self.contentString appendString:@"\n"];
    }
   
    [menuMsgDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.contentString appendString:key];
        [self.contentString appendString:@"\n"];
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.contentString appendString:key];
            for (NSInteger idx = key.length; idx < LineByteSize - key.length - obj.length; ++idx) {
                [self.contentString appendString:@" "];
            }
            [self.contentString appendString:obj];
        }];
        [self.contentString appendString:@"\n"];
    }];
    return [self.contentString copy];
}

- (NSString *)printPriceMsg:(NSDictionary<NSString *,NSString *> *)msgDic isHead:(BOOL)isHead
{
    self.contentString = [NSMutableString new];
    if (isHead) {
        for (NSInteger idx = 0; idx < 32; ++idx) {
            [self.contentString appendString:@"-"];
        }
        [self.contentString appendString:@"\n"];
    }
    
    [msgDic enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.contentString appendString:key];
        for (NSInteger idx = key.length; idx < LineByteSize - key.length - obj.length-1; ++idx) {
            [self.contentString appendString:@" "];
        }
        [self.contentString appendString:obj];
        [self.contentString appendString:@"\n"];
    }];
    
    return [self.contentString copy];
}

- (NSString *)printAddressMsg:(NSDictionary<NSString *,NSString *> *)msgDic isHead:(BOOL)isHead
{
    self.contentString = [NSMutableString new];
    if (isHead) {
        for (NSInteger idx = 0; idx < 32; ++idx) {
            [self.contentString appendString:@"-"];
        }
    }
    
    [msgDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString* keyValue = [key stringByAppendingString:@": "];
        [self.contentString appendString:keyValue];
        //如果文字加起来大于最大字符，则要求obj换行
        
        if (keyValue.length + obj.length > LineByteSize) {
            while (keyValue.length + obj.length > LineByteSize) {
                NSInteger length = LineByteSize - obj.length; //可显示的字符
                NSString* newValue = [obj substringToIndex:length];
                [self.contentString appendString:newValue];
                [self.contentString appendString:@"\n"];
                for (NSInteger idx = 0; idx < keyValue.length; ++idx) {
                    [self.contentString appendString:@" "];
                }
                obj = [obj substringFromIndex:length];
            }
        }else
        {
            [self.contentString appendString:obj];
        }
        [self.contentString appendString:@"\n"];
    }];
    
    return [self.contentString copy];
}

- (NSString *)printLinePace
{
    self.contentString = [NSMutableString new];
    [self.contentString appendFormat:@"\n"];
    for (NSInteger idx = 0; idx < 32; ++idx) {
        [self.contentString appendString:@"-"];
    }
    return [self.contentString copy];
}

#pragma mark - 私有方法
/**
 *  排版内容
 *
 *  @param middleMsgDic 内容字典
 *  如:姓名：某某某
 *     苹果：5斤
 *
 *  @return 返回排版后的文字
 */
- (NSString *)printMiddleMsg:(NSDictionary<NSString *,NSString *> *)middleMsgDic
{
    [middleMsgDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.contentString appendString:key];
        [self.contentString appendString:@": "];
        [self.contentString appendString:obj];
        [self.contentString appendString:@"\n\n"];
    }];
    
    
    return [self.contentString substringToIndex:self.contentString.length - 2];
}




@end
