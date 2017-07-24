//
//  AFTableViewCell.h
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

@interface AFCollectionViewCell : UICollectionViewCell

@property (nonatomic) Movie *movie;

@end

@interface AFIndexedCollectionView : UICollectionView

@property (nonatomic) NSInteger section;

@end

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface AFTableViewCell : UITableViewCell

@property (nonatomic, strong) AFIndexedCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate section:(NSInteger)section;

@end
