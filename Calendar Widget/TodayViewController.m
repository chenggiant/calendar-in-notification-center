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
@property (strong) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;

@property (nonatomic, strong) IBOutlet NSTextField* dateLabel;

@property (nonatomic, strong) NSDate* displayDate;

@property (strong) IBOutlet NSPanGestureRecognizer *swipeGestureRecognizer;

@end

@implementation TodayViewController

@synthesize days = _days;

-(void)awakeFromNib {
    // Setup view
    self.collectionView.backgroundColors = @[ [NSColor clearColor] ];

    // Calculate the first of the month
    NSDate* now = [NSDate date];
    NSDateComponents* thisMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth
                                                                  fromDate:now];
    [thisMonth setDay:1];
    now = [[NSCalendar currentCalendar] dateFromComponents:thisMonth];
    
    // Initialise date
    self.displayDate = now;
    [self updateCalendar:self.displayDate];
    [self updateDateLabel:self.displayDate];
}

- (void)updateDateLabel:(NSDate*) date {
    NSString* dateFormatString = [NSDateFormatter dateFormatFromTemplate:@"MMMMyyyy" options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.dateFormat = dateFormatString;
    [self.dateLabel setStringValue:[df stringFromDate:date]];
}

- (void)updateCalendar:(NSDate*)date {
    // Work out calendar
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [cal components:NSCalendarUnitMonth | NSCalendarUnitYear
                                              fromDate:date];
    NSDateComponents* nowComponents = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                             fromDate:[NSDate date]];
    NSUInteger today;
    if (nowComponents.month == dateComponents.month && nowComponents.year == dateComponents.year) {
        today = nowComponents.day;
    }
    else {
        // this will never be matched
        today = 0;
    }
    
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
    
    [dateComponents setDay:1];
    NSDate* beginningOfMonth = [cal dateFromComponents:dateComponents];
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
    NSInteger totalCount = 7 - [monthArray count] % 7;
    if (totalCount == 7) {
        totalCount = 0;
    }
    for (NSInteger i = 0; i < totalCount; i++) {
        WSLDay* day = [[WSLDay alloc] init];
        day.date = [NSString stringWithFormat:@"%lu", (unsigned long)i + 1];
        day.textColor = [NSColor lightGrayColor];
        [monthArray addObject:day];
        current = [cal dateByAddingComponents:addDay toDate:current options:0];
    }

    // Make sure the collection view (and widget) is big enough to display all the cells
    CGSize cellSize = self.collectionView.itemPrototype.view.frame.size;
    self.collectionViewHeightConstraint.constant = [monthArray count] / 7 * cellSize.height;
    
    self.days = monthArray;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    completionHandler(NCUpdateResultNoData);
}

- (IBAction)swipeGesture:(NSPanGestureRecognizer*)sender {
    if (sender.state == NSGestureRecognizerStateRecognized) {
        NSPoint v = [sender velocityInView:self.collectionView];
        if (v.y > 20.0) {
            NSDateComponents* nextMonth = [[NSDateComponents alloc] init];
            [nextMonth setMonth:-1]; // -1 month
            self.displayDate = [[NSCalendar currentCalendar] dateByAddingComponents:nextMonth toDate:self.displayDate options:0];
            [self updateCalendar:self.displayDate];
            [self updateDateLabel:self.displayDate];
        }
        else if (v.y < -20.0) {
            NSDateComponents* previousMonth = [[NSDateComponents alloc] init];
            [previousMonth setMonth:1]; // +1 month
            self.displayDate = [[NSCalendar currentCalendar] dateByAddingComponents:previousMonth toDate:self.displayDate options:0];
            [self updateCalendar:self.displayDate];
            [self updateDateLabel:self.displayDate];
        }
    }
}

@end

