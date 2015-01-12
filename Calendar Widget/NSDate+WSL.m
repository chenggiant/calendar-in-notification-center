//
//  NSDate+WSL.m
//  Calendar
//
//  Created by Stephen Darlington on 12/01/2015.
//  Copyright (c) 2015 Wandle Software Limited. All rights reserved.
//

#import "NSDate+WSL.h"

@implementation NSDate (WSL)

- (instancetype)wsl_beginningOfMonth {
    NSDateComponents* thisMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth
                                                                  fromDate:self];
    [thisMonth setDay:1];
    return [[NSCalendar currentCalendar] dateFromComponents:thisMonth];
}

@end
