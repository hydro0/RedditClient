//
//  RCLinksTableViewCell.h
//  RedditClient
//
//  Created by Orest Savchak on 8/5/16.
//  Copyright © 2016 Orest Savchak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSLink.h>

@interface RCLinksTableViewCell : UITableViewCell

- (void)updateWithDataObject:(RSLink *)link;

@end
