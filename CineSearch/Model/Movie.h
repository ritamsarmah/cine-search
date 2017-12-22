//
//  Movie.h
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* overview;
@property (nonatomic, copy) NSString* releaseDate;
@property (nonatomic, copy) NSString* runtime;
@property (nonatomic) NSNumber* rating;
@property (nonatomic, copy) NSString* posterURL;
@property (nonatomic, copy) NSString* backdropURL;
@property (nonatomic) NSArray* genres;
@property (nonatomic) NSNumber* idNumber;

- (instancetype)initWithTitle:(NSString*)title
                     overview:(NSString*)overview
                  releaseDate:(NSString*)releaseDate
                      runtime:(NSString*)runtime
                       rating:(NSNumber*)rating
                       genres:(NSArray*)genres
                    posterURL:(NSString*)posterURL
                  backdropURL:(NSString*)backdropURL
                     idNumber:(NSNumber*)idNumber;

@end
