//
//  TodayViewController.m
//  Calendar Widget
//
//  Created by Stephen Darlington on 09/01/2015.
//  Copyright (c) 2015 Wandle Software Limited. All rights reserved.
//

#import "TodayViewController.h"
#import "WSLDay.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) NSMutableArray* days;
@property (nonatomic, strong) IBOutlet NSCollectionView* collectionView;

@property (nonatomic, strong) IBOutlet NSTextField* dateLabel;

@property (nonatomic, assign) BOOL weekStartsOnMonday;

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
    
    // add some blanks at the beginning
    WSLDay* day = [[WSLDay alloc] init];
    day.date = @"";
    day.textColor = [NSColor whiteColor];
    
    [now setDay:1];
    NSDate* beginningOfMonth = [cal dateFromComponents:now];
    NSDateComponents* start = [cal components:NSCalendarUnitWeekday fromDate:beginningOfMonth];

    self.weekStartsOnMonday = YES;
    NSInteger dayOfWeek = start.weekday - (self.weekStartsOnMonday ? 1 : 0);
    if (dayOfWeek < 1) {
        dayOfWeek = 7 + dayOfWeek;
    }
    for (NSInteger i = 1; i < dayOfWeek ; i++) {
        [monthArray addObject:day];
    }
    
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
    
    self.days = monthArray;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    completionHandler(NCUpdateResultNoData);
}

@end

