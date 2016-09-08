//
//  CJHUDView.m
//  111
//
//  Created by 蔡晶 on 16/8/25.
//  Copyright © 2016年 蔡晶. All rights reserved.
//

#import "CJHUDView.h"

#define KEY_WINDOW [UIApplication sharedApplication].keyWindow
#define COLOR_HEX(hexValue,Alpha) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:Alpha]
#define kAnimationDuration 0.3
#define kShowDuration 1.7
// 友好的支持iOS7 所以改这里的值 同时也要改xib的约束
#define kTotalVerticalMargin 68
#define kTotalHorizonMargin 40

@interface CJHUDView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;


@end

@implementation CJHUDView

+ (instancetype)loadNibFromBundle{
    
    CJHUDView *hudView = [[[NSBundle mainBundle] loadNibNamed:@"CJHUDView" owner:self options:nil] lastObject];
    hudView.backgroundColor = COLOR_HEX(0x000000, 0.7);
    hudView.layer.masksToBounds = YES;
    hudView.layer.cornerRadius = 4;
    return hudView;
    
}

@end

@interface CJSimpleHUD ()

@property (nonatomic, strong) CJHUDView *hudView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat timerCount;
// initial frame
@property (nonatomic, assign) CGSize hudViewSize;
// defaultImage frame
@property (nonatomic, assign) CGSize defaultHudViewSize;

@end

@implementation CJSimpleHUD

+ (instancetype)sharedCJHud{
    static CJSimpleHUD *hud;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[CJSimpleHUD alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, SCREENSIZE.height)];
        CJHUDView *hudView = [CJHUDView loadNibFromBundle];
        hud->_hudView = hudView;
        hud->_timerCount = 0;
        hud->_successImageName = @"loginup_icon_success";
        hud->_failedImageName = @"loginup_icon_fail";
        hud->_processingImageName = @"yuan";
        hud->_hudViewSize = hudView.imageView.frame.size;
        hud.backgroundColor = COLOR_HEX(0x000000, 0.0);
        hudView.center = hud.center;
        [hud addSubview:hudView];
    });
    return hud;
}
+ (void)showFailedMessage:(NSString *)message delegate:(id<CJSimpleHUDDelegate>)delegate{
    CJSimpleHUD *hud =[CJSimpleHUD sharedCJHud];
    hud.delegate = delegate;
    [hud p_updateHUDFrameWithImageSize:hud->_hudViewSize];
    [self showCusTomMessage:message imageName:hud.failedImageName];
}

+ (void)showSuccessMessage:(NSString *)message delegate:(id<CJSimpleHUDDelegate>)delegate{
    CJSimpleHUD *hud =[CJSimpleHUD sharedCJHud];
    hud.delegate = delegate;
    [hud p_updateHUDFrameWithImageSize:hud->_hudViewSize];
    [self showCusTomMessage:message imageName:hud.successImageName];
}

+ (void)showSuccessMessage:(NSString *)message{
    CJSimpleHUD *hud =[CJSimpleHUD sharedCJHud];
    [hud p_updateHUDFrameWithImageSize:hud->_hudViewSize];
    [self showCusTomMessage:message imageName:hud.successImageName];
}

+ (void)showFailedMessage:(NSString *)message{
    CJSimpleHUD *hud =[CJSimpleHUD sharedCJHud];
    [hud p_updateHUDFrameWithImageSize:hud->_hudViewSize];
    [self showCusTomMessage:message imageName:hud.failedImageName];
}

+ (void)showProcessingMessage:(NSString *)message{
    CJSimpleHUD *hud =[CJSimpleHUD sharedCJHud];
    [hud p_updateHUDFrameWithImageSize:hud->_hudViewSize];
    [self showCusTomMessage:message imageName:hud.processingImageName];
}

+ (void)showCusTomMessage:(NSString *)message imageName:(NSString *)imageName{
    NSAssert([NSThread isMainThread], @"please use it in main thread");
    CJSimpleHUD *hud =[CJSimpleHUD sharedCJHud];
    hud->_hudView.detailLabel.text = message;
    hud->_hudView.imageView.image = [UIImage imageNamed:imageName];
    if (![imageName isEqualToString:hud.defaultImageName] && ![imageName isEqualToString:hud.successImageName] && ![imageName isEqualToString:hud.failedImageName]) [hud p_getHUDSizeByImageName:imageName];
    [hud startTimer];
    if (!hud.superview) [KEY_WINDOW addSubview:hud];;
    [hud startSpringAniamtion];
}

+ (void)showDefaultMessage:(NSString *)message{
    CJSimpleHUD *hud =[CJSimpleHUD sharedCJHud];
    [hud p_updateHUDFrameWithImageSize:hud->_defaultHudViewSize];
    [self showCusTomMessage:message imageName:hud.defaultImageName];
}
#pragma mark - private

- (void)p_updateHUDFrameWithImageSize:(CGSize)iamgeSize{
    CGFloat width = iamgeSize.width + kTotalHorizonMargin;
    CGFloat height = iamgeSize.height + kTotalVerticalMargin;
    if (width > SCREENSIZE.width) width = SCREENSIZE.width;
    if (height > SCREENSIZE.height) height = SCREENSIZE.height;
    _hudView.frame = CGRectMake(0, 0, width, height);
    _hudView.center = self.center;
    NSLog(@"frame:%@",NSStringFromCGRect(_hudView.frame));
}
- (CGSize)p_getHUDSizeByImageName:(NSString *)iamgeName{
    UIImage *image = [UIImage imageNamed:iamgeName];
    if (image.size.width <= _hudViewSize.width && image.size.height <= _hudViewSize.height) {
        _defaultHudViewSize = _hudViewSize;
        return _hudViewSize;
    }
    CGFloat width = 0;
    CGFloat height = 0;
    if (image.size.width > _hudViewSize.width) width = image.size.width;
    if (image.size.height > _hudViewSize.height) height = image.size.height;
    CGSize size = CGSizeMake(width, height);
    [self p_updateHUDFrameWithImageSize:size];
    return size;
}

#pragma mark - setter

- (void)setSuccessImageName:(NSString *)successImageName{
    _successImageName = successImageName;
    _hudViewSize = [self p_getHUDSizeByImageName:successImageName];
}
- (void)setFailedImageName:(NSString *)failedImageName{
    _failedImageName = failedImageName;
    _hudViewSize = [self p_getHUDSizeByImageName:failedImageName];
}
- (void)setProcessingImageName:(NSString *)processingImageName{
    _processingImageName = processingImageName;
    _hudViewSize = [self p_getHUDSizeByImageName:processingImageName];
}

- (void)setDefaultImageName:(NSString *)defaultImageName{
    _defaultImageName = defaultImageName;
    _defaultHudViewSize = [self p_getHUDSizeByImageName:defaultImageName];
}

#pragma mark - animations
- (void)startSpringAniamtion{
    if (self.isUserInteractionEnabled) {
        self.userInteractionEnabled = NO;
        self.hudView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.hudView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }
}

- (void)endSpringAniamtion{
    if (self.isUserInteractionEnabled) {
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.hudView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
            [self removeFromSuperview];
            [self endTimer];
            if ([self.delegate respondsToSelector:@selector(CJHUDdissmiss)]) {
                [self.delegate CJHUDdissmiss];
            }
            bool isOk = CGAffineTransformIsIdentity(self.hudView.transform);
            if (!isOk) {
                self.hudView.transform = CGAffineTransformIdentity;
            }
            self.delegate = nil;
        }];
    }
}
#pragma mark - timer
- (void)startTimer{
    if (self.timer) {
        [self endTimer];
    }
    self.timerCount = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(A_timer) userInfo:nil repeats:YES];
    
}
- (void)endTimer{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)A_timer{
    self.timerCount += 0.1;
    if (self.timerCount >= (kShowDuration-0.5)) {
        [self endTimer];
        [self endSpringAniamtion];
    }
}
#pragma mark - touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endTimer];
    self.userInteractionEnabled = YES;
    if ([self.delegate respondsToSelector:@selector(CJHUDdissmiss)]) {
        [self.delegate CJHUDdissmiss];
    }
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
    self.delegate = nil;
}

- (void)dealloc{
    [self endTimer];
}

@end