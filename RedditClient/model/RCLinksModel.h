//
//  RCLinksModel.h
//  RedditClient
//
//  Created by Orest Savchak on 8/6/16.
//  Copyright © 2016 Orest Savchak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <RSLink.h>
@protocol RCLinksModelDelegate;

@interface RCLinksModel : NSObject

@property (weak, nonatomic) UIViewController<RCLinksModelDelegate> *delegate;

- (void)searchForQuery:(NSString *)query;
- (void)updateTopItems;
- (void)updateBottomItems;

@end

@protocol RCLinksModelDelegate <NSObject>

- (void)linksModel:(RCLinksModel *)model didLinksUpdate:(NSArray<RSLink *> *)links onTop:(BOOL)onTop;
- (void)linksModel:(RCLinksModel *)model didFailedToLoadWithError:(NSError *)error;

@end