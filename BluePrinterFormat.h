//
//  BluePrinterFormat.h
//  BluePrinter
//
//  Created by feng on 15/12/15.
//  Copyright © 2015年 feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BluePrinterFormat : NSObject

@property (nonatomic, strong, readonly) NSMutableString* contentString;


/**
 *  排版标题
 *
 *  @param title 标题文字
 *
 *  @return 返回排版后的标题
 */
- (NSString *)printTitle:(NSString*)title;

/**
 *  打印菜单
 *
 *  @param menuMsgDic Key为水果名字，value为一个字典，其key为数量，value为价格
 *
 *  @return 返回排版后的文字
 */
- (NSString *)printMenuMsg:(NSDictionary<NSString*,NSDictionary*> *)menuMsgDic isHead:(BOOL)isHead;

/**
 *  打印order信息
 *
 *  @param msgDic
 *
 *  @return 
 */
- (NSString *)printOrderMsg:(NSDictionary<NSString*,NSString*>*)msgDic;

/**
 *  打印价格信息
 *
 *  @param msgDic
 *
 *  @return 
 */
- (NSString *)printPriceMsg:(NSDictionary<NSString*,NSString*>*)msgDic isHead:(BOOL)isHead;

/**
 *  打印地址信息
 *
 *  @param msgDic
 *
 *  @return
 */
- (NSString *)printAddressMsg:(NSDictionary<NSString*,NSString*>*)msgDic isHead:(BOOL)isHead;

/**
 *  打印二维码
 *
 *  @param barString 二维码
 *
 *  @return 
 */
- (NSString *)printBarCode:(NSString *)barString;

- (NSString *)printLinePace;

@end
