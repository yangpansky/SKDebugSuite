//
//  SKDebugFPSMonitor.m
//  Test
//
//  Created by yangpan on 2022/1/5.
//

#import "SKDebugFPSMonitor.h"
#import "SKDebugToolLabel.h"
#import <UIKit/UIKit.h>

@interface SKDebugFPSMonitor()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval lastTimestamp;
@property (nonatomic, assign) NSInteger performTimes;
@end

@implementation SKDebugFPSMonitor
- (void)dealloc {
    [self stopMonitoring];
}

- (void)startMonitoring {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTicks:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkTicks:(CADisplayLink *)link {
    if (0 == _lastTimestamp) {
        _lastTimestamp = link.timestamp;
        !self.updateBlock?:self.updateBlock([self fpsAttributedString:-1]);
        return;
    }
    
    _performTimes ++;
    NSTimeInterval interval = link.timestamp - _lastTimestamp;
    if (interval < 1) {
        return;
    }
    _lastTimestamp = link.timestamp;
    float fps = _performTimes / interval;
    _performTimes = 0;
    !self.updateBlock?:self.updateBlock([self fpsAttributedString:fps]);
}

- (void)stopMonitoring {
    [_displayLink invalidate];
}

- (NSAttributedString * _Nonnull)fpsAttributedString:(float)fps {
    UIColor *color;
    NSMutableAttributedString *text;
    if (fps < 0) {
        color = [UIColor colorWithHue:0.27 * 0.8 saturation:1 brightness:0.9 alpha:1];
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"-- FPS"]];
    }else {
        CGFloat progress = fps / 60.0;
        color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
    }
    
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:[SKDebugToolLabel mainFont] range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:[SKDebugToolLabel additionFont] range:NSMakeRange(text.length - 4, 1)];
    return text;
}
@end
