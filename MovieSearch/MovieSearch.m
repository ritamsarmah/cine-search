//
//  MovieSearch.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MovieSearch.h"

@implementation MovieSearch

// Returns mutable array of movies
- (void)search:(NSString *)query completion:(void (^)(NSMutableArray*))completion{
    
    // Reformat search query for request
    NSString* newQuery = [query stringByReplacingOccurrencesOfString:@" "
                                                         withString:@"+"];
    NSLog(@"%@", newQuery);
    NSMutableArray *movies = [NSMutableArray array];
    NSString *url = [NSString stringWithFormat:@"https://api.themoviedb.org/3/search/movie?query=%@&api_key=%@", newQuery, key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        /* Prints movie data response to console
         NSString *movieData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
         NSLog(@"%@", movieData); */
         
        
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSError *error = nil;
            id results = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
            
            if (error) { NSLog(@"Error retrieving movie data"); }
            
            if ([results isKindOfClass:[NSDictionary class]]) {
                NSDictionary *movieResults = [results objectForKey:@"results"];
                for(id movie in movieResults) {
                    NSString *title = [movie objectForKey:@"title"];
                    NSLog(@"%@", title);
                    NSString *overview = [movie objectForKey:@"overview"];
                    NSString *releaseDate = [self formatDate:[movie objectForKey:@"release_date"]];
                    NSNumber *rating = [NSNumber numberWithDouble:[[movie objectForKey:@"vote_average"] doubleValue]];
                    NSString *poster = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"poster_path"]];
                    NSString *backdrop = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/w500/%@", [movie objectForKey:@"backdrop_path"]];
                    Movie *newMovie = [[Movie alloc] initWithTitle:title overview:overview releaseDate:releaseDate rating:rating posterURL:poster backdropURL:backdrop];
                    [movies addObject:newMovie];
                }
                completion(movies);
            }
            else {
                NSLog(@"Not valid dictionary");
            }
        }
    }] resume];
}

- (NSString *)formatDate:(NSString *)stringDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:stringDate];
    
    [dateFormat setDateFormat: @"MMMM d, YYYY"];
    stringDate = [dateFormat stringFromDate:date];
    return stringDate;
}

@end
