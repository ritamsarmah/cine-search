//
//  MovieSingleton.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieSearch.h"

@interface MovieSingleton : NSObject {
    MovieSearch *database;
}

@property (nonatomic, retain) MovieSearch *database;

+ (instancetype) sharedManager;

@end
