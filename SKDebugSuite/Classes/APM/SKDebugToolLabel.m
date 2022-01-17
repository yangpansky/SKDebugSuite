//
//  SKDebugToolLabel.m
//  Test
//
//  Created by yangpan on 2022/1/5.
//

#import "SKDebugToolLabel.h"

@implementation SKDebugToolLabel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.adjustsFontSizeToFitWidth = YES;
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    }
    return self;
}

+ (UIFont *)mainFont {
    return [UIFont fontWithName:@"Menlo" size:13];
}

+ (UIFont *)additionFont {
    return [UIFont fontWithName:@"Menlo" size:9];
}
@end
