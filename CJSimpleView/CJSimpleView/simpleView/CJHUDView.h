//
//  CJHUDView.h
//  111
//
//  Created by 蔡晶 on 16/8/25.
//  Copyright © 2016年 蔡晶. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJHUDView : UIView


@end

@protocol CJSimpleHUDDelegate <NSObject>

- (void)CJHUDdissmiss;

@end

/**
 *  依赖keyWindow的HUD，使用时确保keyWindow加载完了
 */
@interface CJSimpleHUD : UIView
// 图片名均会保存
@property (nonatomic, strong) NSString *defaultImageName;
// 以下三项如果不需要进行修改,可以直接在.m单例方法中写好
@property (nonatomic, strong) NSString *successImageName;
@property (nonatomic, strong) NSString *failedImageName;
@property (nonatomic, strong) NSString *processingImageName;
@property (nonatomic, weak) id<CJSimpleHUDDelegate> delegate;

// singlton
+ (instancetype)sharedCJHud;
// 显示成功alert
+ (void)showFailedMessage:(NSString *)message delegate:(id<CJSimpleHUDDelegate>)delegate tag:(NSUInteger)tag;
// 显示失败alert
+ (void)showSuccessMessage:(NSString *)message delegate:(id<CJSimpleHUDDelegate>)delegate tag:(NSUInteger)tag;
// 显示成功alert
+ (void)showFailedMessage:(NSString *)message;
// 显示失败alert
+ (void)showSuccessMessage:(NSString *)message;
// 显示处理中alert
+ (void)showProcessingMessage:(NSString *)message;
// 自定义图片 以及描述
+ (void)showCusTomMessage:(NSString *)message imageName:(NSString *)imageName;
// 自己设定一个默认的描述 需要提前设置好defaultImage
+ (void)showDefaultMessage:(NSString *)message;

@end