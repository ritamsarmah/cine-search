//
//  Movie.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* overview;
@property (nonatomic, copy) NSString* releaseDate;
@property (nonatomic) NSNumber* rating;
@property (nonatomic, copy) NSString* posterURL;
@property (nonatomic, copy) NSString* backdropURL;

- (instancetype)initWithTitle:(NSString*)title
                     overview:(NSString*)overview
                  releaseDate:(NSString*)releaseDate
                       rating:(NSNumber*)rating
                    posterURL:(NSString*)posterURL
                  backdropURL:(NSString*)backdropURL;

@end
