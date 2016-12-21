//
//  MovieSearch.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"
#import "Constants.h"

@interface MovieSearch : NSObject

@property NSDictionary *genres;

- (void)search:(NSString*)query completion:(void (^)(NSMutableArray*))completion;
- (NSString *)formatDate:(NSString*)stringDate;
- (void)getTrailerForID:(NSNumber *)idNumber completion:(void (^)(NSURL*))completion;

@end
