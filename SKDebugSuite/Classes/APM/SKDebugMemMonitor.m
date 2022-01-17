//
//  SKDebugMemMonitor.m
//  Test
//
//  Created by yangpan on 2022/1/5.
//

#import "SKDebugMemMonitor.h"
#import "SKDebugToolLabel.h"
#import <mach/mach.h>

@implementation SKDebugMemMonitor
- (NSAttributedString *)monitorValue {
    unsigned long long usage = [self usageMemory];
    return [self memoryAttributedString:usage];
}

- (unsigned long long)usageMemory {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (kernReturn != KERN_SUCCESS) { return NSNotFound; }
    return (int64_t) vmInfo.phys_footprint;
}

- (unsigned long long)totalMemory {
    return [[NSProcessInfo processInfo] physicalMemory];
}

- (NSAttributedString *)memoryAttributedString:(unsigned long long)memory {
    UIColor *color;
    NSMutableAttributedString *text;
    NSString *sep = @" / ";
    if (memory < 0) {
        color = [UIColor colorWithHue:0.27 * 0.8 saturation:1 brightness:0.9 alpha:1];
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"--M%@--", sep]];
    }else {
        CGFloat progress = memory / 350;
        color = [self colorByPercent:progress];
        unsigned long long total = [self totalMemory];
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1fM%@%@%%", memory/1024.0/1024.0, sep, [NSString stringWithFormat:@"%.2f", memory * 100.0 / total]]];
    }
    
    NSRange range = [text.mutableString rangeOfString:sep];

    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, range.location)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(range.location + range.length, text.length - range.location - range.length)];
    [text addAttribute:NSFontAttributeName value:[SKDebugToolLabel mainFont] range:NSMakeRange(0, range.location)];
    [text addAttribute:NSFontAttributeName value:[SKDebugToolLabel additionFont] range:NSMakeRange(range.location + range.length, text.length - range.location - range.length)];
    return text;
}
@end
