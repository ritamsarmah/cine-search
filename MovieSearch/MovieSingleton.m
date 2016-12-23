//
//  MovieSingleton.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MovieSingleton.h"

@implementation MovieSingleton

@synthesize database;

+ (id)sharedManager {
    static MovieSingleton *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        database = [[MovieSearch alloc] init];
    }
    return self;
}

@end
