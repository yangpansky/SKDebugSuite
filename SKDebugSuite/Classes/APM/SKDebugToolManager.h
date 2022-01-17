//
//  SKDebugToolManager.h
//  Test
//
//  Created by yangpan on 2022/1/5.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, SKDebugToolOptions) {
    SKDebugToolOptionsFPS    = 1 << 0,
    SKDebugToolOptionsCPU    = 1 << 1,
    SKDebugToolOptionsMemory = 1 << 2,
    SKDebugToolOptionsAll    = (SKDebugToolOptionsFPS | SKDebugToolOptionsCPU | SKDebugToolOptionsMemory)
};

@interface SKDebugToolManager : NSObject

+ (void)toggleWith:(SKDebugToolOptions)options;
+ (void)showWith:(SKDebugToolOptions)options;
+ (void)hide;
@end
