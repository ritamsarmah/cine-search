//
//  Actor.h
//  CineSearch
//
//  Created by Ritam Sarmah on 12/31/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Actor : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* role;
@property (nonatomic, copy) NSString* profileURL;

- (instancetype)initWithName:(NSString *)name role:(NSString *)role profileURL:(NSString *)profileURL;

@end
