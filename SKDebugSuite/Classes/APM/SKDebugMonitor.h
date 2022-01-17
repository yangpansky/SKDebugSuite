//
//  SKDebugMonitor.h
//  SKDebugTool
//
//  Created by yangpan on 2022/1/5.
//

#import <UIKit/UIKit.h>

typedef void(^ValueUpdateBlock)(NSAttributedString * _Nonnull value);

@protocol SKDebugMonitorProtocol <NSObject>
- (NSAttributedString * _Nonnull)monitorValue;
@required
- (void)startMonitoring;
- (void)stopMonitoring;
@end

@interface SKDebugMonitor : NSObject <SKDebugMonitorProtocol>
@property (nonatomic, copy, nullable) ValueUpdateBlock updateBlock;
- (UIColor * _Nonnull)colorByPercent:(CGFloat)percent;
@end
