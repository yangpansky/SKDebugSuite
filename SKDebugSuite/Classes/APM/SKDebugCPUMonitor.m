//
//  SKDebugCPUMonitor.m
//  Test
//
//  Created by yangpan on 2022/1/5.
//

#import "SKDebugCPUMonitor.h"
#import "SKDebugToolLabel.h"
#import <mach/mach.h>

@implementation SKDebugCPUMonitor
- (NSAttributedString *)monitorValue {
    float value = [self cpuValue];
    return [self cpuAttributedString:value];
}

- (float)cpuValue {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

- (NSAttributedString *)cpuAttributedString:(float)cpu {
    UIColor *color;
    NSMutableAttributedString *text;
    if (cpu < 0) {
        color = [UIColor colorWithHue:0.27 * 0.8 saturation:1 brightness:0.9 alpha:1];
        text = [[NSMutableAttributedString alloc] initWithString:@"-- CPU"];
    }else{
        CGFloat progress = cpu / 100;
        color = [self colorByPercent:progress];
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%% CPU",(int)round(cpu)]];
    }
    
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:[SKDebugToolLabel mainFont] range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:[SKDebugToolLabel additionFont] range:NSMakeRange(text.length - 4, 1)];
    return text;
}

@end
