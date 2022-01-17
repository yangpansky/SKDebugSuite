//
//  SKDebugMonitor.m
//  SKDebugTool
//
//  Created by yangpan on 2022/1/5.
//

#import "SKDebugMonitor.h"

@interface SKDebugMonitor ()
{
    NSTimer *_timer;
}
@end

@implementation SKDebugMonitor
- (void)startMonitoring {
    [self stopMonitoring];
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateValue) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)updateValue {
    !self.updateBlock?:self.updateBlock([self monitorValue]);
}

- (NSMutableString *)monitorValue {
    // base implementation
    return [NSMutableString stringWithString:@"--"];
}

- (void)stopMonitoring {
    [_timer invalidate];
    _timer = nil;
}

- (UIColor *)colorByPercent:(CGFloat)percent {
    NSInteger r = 0, g = 0, one = 255 + 255;
    if (percent <= 0.5) {
        r = one * percent;
        g = 255;
    }
    if (percent > 0.5) {
        g = 255 - ((percent - 0.5 ) * one) ;
        r = 255;
    }
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:0 alpha:1];
}
@end
