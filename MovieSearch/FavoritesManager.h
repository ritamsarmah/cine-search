//
//  FavoritesManager.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoritesManager : NSObject <NSCoding> {
    // Store id numbers of favorited movies
    NSMutableArray *favorites;
}

@property (nonatomic, retain) NSMutableArray *favorites;

+ (id) sharedManager;
- (void) addFavorite:(int)idNumber;
- (void) removeFavorite:(int)idNumber;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)saveState;

@end
