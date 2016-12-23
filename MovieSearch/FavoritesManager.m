//
//  FavoritesManager.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "FavoritesManager.h"

@implementation FavoritesManager

@synthesize favorites;

+ (id)sharedManager {
    static FavoritesManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        self.favorites = [decoder decodeObjectForKey:@"favorites"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:favorites forKey:@"favorites"];
}

- (void)addFavorite:(int)idNumber {
    
}

- (void)removeFavorite:(int)idNumber {
    
}

- (void)saveState {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.favorites];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"favorites"];
}

@end
