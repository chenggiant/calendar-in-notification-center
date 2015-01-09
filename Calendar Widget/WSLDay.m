//
//  WSLDay.m
//  Calendar
//
//  Created by Stephen Darlington on 09/01/2015.
//  Copyright (c) 2015 Wandle Software Limited. All rights reserved.
//

#import "WSLDay.h"

@implementation WSLDay

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.date, self.textColor];
}

@end
