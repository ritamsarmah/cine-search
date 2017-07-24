//
//  MovieSearch.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

@interface MovieSearch : NSObject

@property NSDictionary *genres;

- (void)search:(NSString*)query completion:(void (^)(NSMutableArray*))completion;
- (NSString *)formatDate:(NSString*)stringDate;
- (void)getMovieForID:(NSInteger)idNumber completion:(void (^)(Movie *))completion;
- (void)getTrailerForID:(NSNumber *)idNumber completion:(void (^)(NSString *))completion;
- (void)getNowPlaying:(void (^)(NSMutableArray *))completion;
- (void)getPopular:(void (^)(NSMutableArray *))completion;
- (void)getRecommendedForID:(NSInteger)idNumber completion:(void (^)(NSMutableArray *))completion;

@end
