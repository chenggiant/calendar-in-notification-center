//
//  NSArray+Functional.h
//  Yummy
//
//  Created by Stephen Darlington on 12/12/2014.
//  Copyright (c) 2014 Wandle Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (NSArray*)wsl_map:(id(^)(id))mapfn;

@end
