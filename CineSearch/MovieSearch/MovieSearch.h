//
//  MovieSearch.h
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"
#import "Actor.h"

@interface MovieSearch : NSObject

@property NSDictionary *genres;

- (void)getMoviesForQuery:(NSString*)query completion:(void (^)(NSMutableArray*))completion;

- (void)getNowPlaying:(void (^)(NSMutableArray *))completion;
- (void)getPopular:(void (^)(NSMutableArray *))completion;

// TODO: Refactor to receive MovieID
- (void)getMovieForID:(NSInteger)idNumber completion:(void (^)(Movie *))completion;
- (void)getTrailerForID:(NSNumber *)idNumber completion:(void (^)(NSString *))completion;
- (void)getCastForID:(NSInteger)idNumber completion:(void (^)(NSArray *))completion;
- (void)getRecommendedForID:(NSInteger)idNumber completion:(void (^)(NSMutableArray *))completion;

@end
