//
//  MovieSearch.h
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieID.h"
#import "Movie.h"
#import "Actor.h"

@interface MovieSearch : NSObject

@property NSDictionary *genres;

- (void)getMoviesForQuery:(NSString*)query completion:(void (^)(NSMutableArray*))completion;
- (void)getNowPlaying:(void (^)(NSMutableArray *))completion;
- (void)getPopular:(void (^)(NSMutableArray *))completion;

- (void)getMovieForID:(MovieID *)movieID completion:(void (^)(Movie *))completion;
- (void)getTrailerForID:(MovieID *)movieID completion:(void (^)(NSString *))completion;
- (void)getCastForID:(MovieID *)movieID completion:(void (^)(NSArray *))completion;
- (void)getRecommendedForID:(MovieID *)movieID completion:(void (^)(NSMutableArray *))completion;

@end
