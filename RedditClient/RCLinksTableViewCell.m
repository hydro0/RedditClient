//
//  RCLinksTableViewCell.m
//  RedditClient
//
//  Created by Orest Savchak on 8/5/16.
//  Copyright © 2016 Orest Savchak. All rights reserved.
//

#import "RCLinksTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface RCLinksTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *creationDate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnailWidth;

@end

@implementation RCLinksTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateWithDataObject:(RSLink *)link {
    [self setThumbnailURL:link.thumbnailURL];
    [self setTitleText:link.title];
    [self setCreationDateText:link.createdAt];
}

- (void)setThumbnailURL:(NSString *)thumbnailURL {
    __weak RCLinksTableViewCell *weakSelf = self;
    [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnailURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        weakSelf.thumbnailWidth.constant = error ? 0 : 95;
        [weakSelf.thumbnail updateConstraints];
    }];
}

- (void)setTitleText:(NSString *)title {
    self.title.text = title;
}

- (void)setCreationDateText:(NSDate *)date {
    if (!date) {
        self.creationDate.text = @"";
    }
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.creationDate.text = [dateFormatter stringFromDate:date];
}


@end
