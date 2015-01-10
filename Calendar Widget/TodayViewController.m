//
//  TodayViewController.m
//  Calendar Widget
//
//  Created by Stephen Darlington on 09/01/2015.
//  Copyright (c) 2015 Wandle Software Limited. All rights reserved.
//

#import "TodayViewController.h"
#import "WSLDay.h"
#import "NSArray+Functional.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) NSMutableArray* days;
@property (nonatomic, strong) IBOutlet NSCollectionView* collectionView;

@property (nonatomic, strong) IBOutlet NSTextField* dateLabel;

@end

@implementation TodayViewController

@synthesize days = _days;

-(void)awakeFromNib {
    // Setup view
    self.collectionView.backgroundColors = @[ [NSColor clearColor] ];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterLongStyle;
    [self.dateLabel setStringValue:[df stringFromDate:[NSDate date]]];
    
    NSDate* d = [NSDate date];
    [self updateCalendar:d];
}

- (void)updateCalendar:(NSDate*)date {
    // Work out calendar
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* now = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                   fromDate:date];
    NSUInteger today = now.day;
    
    NSMutableArray* monthArray = [[NSMutableArray alloc] initWithCapacity:31];
    
    NSArray* weekday = [[cal weekdaySymbols] wsl_map:^(NSString* d) {
        return [d substringToIndex:2];
    }];
    for (NSInteger idx = 0; idx < 7 ; idx++) {
        WSLDay* day = [[WSLDay alloc] init];
        day.date = weekday[(idx + [cal firstWeekday] - 1) % 7];
        day.textColor = [NSColor darkGrayColor];
        [monthArray addObject:day];
    }
    
    // add some blanks at the beginning
    WSLDay* day = [[WSLDay alloc] init];
    day.date = @"";
    day.textColor = [NSColor whiteColor];
    
    [now setDay:1];
    NSDate* beginningOfMonth = [cal dateFromComponents:now];
    NSDateComponents* start = [cal components:NSCalendarUnitWeekday fromDate:beginningOfMonth];

    NSInteger dayOfWeek = start.weekday - cal.firstWeekday + 1;
    if (dayOfWeek < 1) {
        dayOfWeek = 7 + dayOfWeek;
    }
    for (NSInteger i = 1; i < dayOfWeek ; i++) {
        [monthArray addObject:day];
    }
    
    NSInteger firstIndex = [monthArray count];
    
    // how many days this month?
    NSDateComponents* endMonthComponents = [[NSDateComponents alloc] init];
    [endMonthComponents setMonth:1];
    [endMonthComponents setDay:-1];
    NSDate* endMonth = [cal dateByAddingComponents:endMonthComponents toDate:beginningOfMonth options:0];
    NSDateComponents* lastDay = [cal components:NSCalendarUnitDay fromDate:endMonth];
    NSUInteger daysThisMonth = lastDay.day;
    
    // add the days
    for (NSUInteger i = 1; i <= daysThisMonth; i++) {
        WSLDay* day = [[WSLDay alloc] init];
        day.date = [NSString stringWithFormat:@"%lu", (unsigned long)i];
        day.textColor = (i == today) ? [NSColor greenColor] : [NSColor whiteColor];
        [monthArray addObject:day];
    }
    
    // Add days of the previous month
    NSDateComponents* subtractDay = [[NSDateComponents alloc] init];
    [subtractDay setDay:-1];
    NSDate* current = [cal dateByAddingComponents:subtractDay toDate:beginningOfMonth options:0];
    for (--firstIndex; firstIndex >= 7; --firstIndex) {
        NSDateComponents* date = [cal components:NSCalendarUnitDay fromDate:current];
        WSLDay* day = [[WSLDay alloc] init];
        day.date = [NSString stringWithFormat:@"%lu", (unsigned long)date.day];
        day.textColor = [NSColor lightGrayColor];
        monthArray[firstIndex] = day;
        current = [cal dateByAddingComponents:subtractDay toDate:current options:0];
    }
    
    // Add days of the next month
    NSDateComponents* addDay = [[NSDateComponents alloc] init];
    [addDay setDay:1];
    current = [cal dateByAddingComponents:addDay toDate:endMonth options:0];
    NSInteger totalCount = 42 - [monthArray count];
    for (NSInteger i = 0; i < totalCount; i++) {
        WSLDay* day = [[WSLDay alloc] init];
        day.date = [NSString stringWithFormat:@"%lu", (unsigned long)i + 1];
        day.textColor = [NSColor lightGrayColor];
        [monthArray addObject:day];
        current = [cal dateByAddingComponents:addDay toDate:current options:0];
    }
    
    self.days = monthArray;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    completionHandler(NCUpdateResultNoData);
}

@end

