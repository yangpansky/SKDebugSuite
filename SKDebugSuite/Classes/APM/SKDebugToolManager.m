//
//  SKDebugToolManager.m
//  Test
//
//  Created by yangpan on 2022/1/5.
//
#import <UIKit/UIKit.h>
#import "SKDebugToolManager.h"
#import "SKDebugToolLabel.h"
#import "SKDebugMemMonitor.h"
#import "SKDebugTempController.h"
#import "SKDebugFPSMonitor.h"
#import "SKDebugCPUMonitor.h"

#define kSKDebugAPMScreenWidth      [UIScreen mainScreen].bounds.size.width
#define kSKDebugAPMCurrentWindow    (debugAPMCurrentWindow())

static NSInteger const kSKDebugAPMLabelWidth = 82;
static NSInteger const kSKDebugAPMLabelHeight = 20;
static NSInteger const kSKDebugAPMMargin = 20;


static inline UIWindow *debugAPMCurrentWindow() {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
    }
    return window;
}

static inline BOOL debugAPMMatchSafeAreaIPhone() {
    BOOL result = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return result;
    }
    if (@available(iOS 11.0, *)) {
        if (kSKDebugAPMCurrentWindow.safeAreaInsets.bottom > 0.0) {
            result = YES;
        }
    }
    return result;
}

@interface SKDebugToolManager ()
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, strong) UIWindow *debugWindow;
@property (nonatomic, assign) SKDebugToolOptions current;
@property (nonatomic, strong) SKDebugToolLabel *memLabel;
@property (nonatomic, strong) SKDebugToolLabel *fpsLabel;
@property (nonatomic, strong) SKDebugToolLabel *cpuLabel;
@property (nonatomic, strong) SKDebugMonitor *memMonitor;
@property (nonatomic, strong) SKDebugMonitor *fpsMonitor;
@property (nonatomic, strong) SKDebugMonitor *cpuMonitor;
@end


@implementation SKDebugToolManager
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id __singletion;
    dispatch_once(&onceToken, ^{
        __singletion = [[self alloc] init];
    });
    return __singletion;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        _memMonitor = [SKDebugMemMonitor new];
        _fpsMonitor = [SKDebugFPSMonitor new];
        _cpuMonitor = [SKDebugCPUMonitor new];
    }
    return self;
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationUnknown ) {
        return;
    }
    CGFloat debugWindowY = debugAPMMatchSafeAreaIPhone() ? 30 : 0;
    self.debugWindow.frame = CGRectMake(0, debugWindowY, UIScreen.mainScreen.bounds.size.width, kSKDebugAPMLabelHeight);
    [self showWith:self.current];
}

- (void)addDebugWindow {
    CGFloat debugWindowY = debugAPMMatchSafeAreaIPhone() ? 30 : 0;
    CGFloat paddingY = debugAPMMatchSafeAreaIPhone() ? 10 : 20;
    self.debugWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, debugWindowY, kSKDebugAPMScreenWidth, kSKDebugAPMLabelHeight + paddingY)];
    self.debugWindow.backgroundColor = [UIColor clearColor];
    self.debugWindow.windowLevel = UIWindowLevelAlert;
    self.debugWindow.rootViewController = [SKDebugTempController new];
    self.debugWindow.hidden = NO;
    [kSKDebugAPMCurrentWindow addSubview:self.debugWindow];
}

- (void)clean {
    [self.memMonitor stopMonitoring];
    [self.debugWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.debugWindow removeFromSuperview];
    self.debugWindow = nil;
    self.isShowing = NO;
}

- (void)addLabel:(UILabel *)label {
    [self.debugWindow addSubview:label];
    CGRect labelFrame = CGRectZero;
    CGFloat y = debugAPMMatchSafeAreaIPhone() ? 10 : 20;
    if (label == self.cpuLabel) {
        labelFrame = CGRectMake((kSKDebugAPMScreenWidth - kSKDebugAPMLabelWidth) / 2, y, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
    } else if (label == self.fpsLabel) {
        labelFrame = CGRectMake(kSKDebugAPMScreenWidth - kSKDebugAPMLabelWidth - kSKDebugAPMMargin, y, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
    } else {// memory
        labelFrame = CGRectMake(kSKDebugAPMMargin, y, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
    }
    [UIView animateWithDuration:0.3 animations:^{
        label.frame = labelFrame;
    }completion:^(BOOL finished) {
        self.isShowing = YES;
    }];
}

#pragma mark - Show
- (void)showMemory {
    [self.memMonitor startMonitoring];
    __weak typeof(self) weakSelf = self;
    self.memMonitor.updateBlock = ^(NSAttributedString *value) {
        weakSelf.memLabel.attributedText = value;
    };
    [self addLabel:self.memLabel];
}

- (void)showFps {
    [self.fpsMonitor startMonitoring];
    __weak typeof(self) weakSelf = self;
    self.fpsMonitor.updateBlock = ^(NSAttributedString * value) {
        weakSelf.fpsLabel.attributedText = value;
    };
    [self addLabel:self.fpsLabel];
}

- (void)showCpu {
    [self.cpuMonitor startMonitoring];
    __weak typeof(self) weakSelf = self;
    self.cpuMonitor.updateBlock = ^(NSAttributedString * value) {
        weakSelf.cpuLabel.attributedText = value;
    };
    [self addLabel:self.cpuLabel];
}

- (void)toggleWith:(SKDebugToolOptions)options {
    self.current = options;
    if (self.isShowing) {
        [self hide];
    }else{
        [self showWith:options];
    }
}

- (void)showWith:(SKDebugToolOptions)options {
    self.current = options;
    [self clean];
    [self addDebugWindow];
    
    if (options & SKDebugToolOptionsMemory) {
        [self showMemory];
    }
    
    if (options & SKDebugToolOptionsFPS) {
        [self showFps];
    }
    
    if (options & SKDebugToolOptionsCPU) {
        [self showCpu];
    }
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.cpuLabel.frame = CGRectMake((kSKDebugAPMScreenWidth - kSKDebugAPMLabelWidth) / 2, -kSKDebugAPMLabelHeight, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
        self.memLabel.frame = CGRectMake(-kSKDebugAPMLabelWidth, 0, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
        self.fpsLabel.frame = CGRectMake(kSKDebugAPMScreenWidth + kSKDebugAPMLabelWidth, 0, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
    }completion:^(BOOL finished) {
        [self clean];
    }];
}

#pragma mark - Label
- (SKDebugToolLabel *)memLabel {
    if (!_memLabel) {
        _memLabel = [[SKDebugToolLabel alloc] init];
        _memLabel.frame = CGRectMake(-kSKDebugAPMLabelWidth, 0, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
    }
    return _memLabel;
}

- (SKDebugToolLabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[SKDebugToolLabel alloc] init];
        _fpsLabel.frame = CGRectMake(kSKDebugAPMScreenWidth + kSKDebugAPMLabelWidth, 0, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
    }
    return _fpsLabel;
}

-(SKDebugToolLabel *)cpuLabel {
    if (!_cpuLabel) {
        _cpuLabel = [[SKDebugToolLabel alloc] init];
        _cpuLabel.frame = CGRectMake((kSKDebugAPMScreenWidth - kSKDebugAPMLabelWidth) / 2, -kSKDebugAPMLabelHeight, kSKDebugAPMLabelWidth, kSKDebugAPMLabelHeight);
    }
    return _cpuLabel;
}

#pragma mark - Public Methods
+ (void)toggleWith:(SKDebugToolOptions)options {
    [[SKDebugToolManager sharedInstance] toggleWith:options];
}

+ (void)showWith:(SKDebugToolOptions)options {
    [[SKDebugToolManager sharedInstance] showWith:options];
}

+ (void)hide {
    [[SKDebugToolManager sharedInstance] hide];
}
@end
