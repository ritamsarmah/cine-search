//
//  FavoritesViewController.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/21/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieSingleton.h"

@interface FavoritesViewController : UITableViewController

@property MovieSingleton *manager;
@property NSMutableDictionary *imageCache;

@end
