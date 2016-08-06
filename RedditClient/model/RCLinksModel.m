//
//  RCLinksModel.m
//  RedditClient
//
//  Created by Orest Savchak on 8/6/16.
//  Copyright © 2016 Orest Savchak. All rights reserved.
//

#import "RCLinksModel.h"
#import <RSInstance.h>
#import <RSSearchConfiguration.h>

@interface RCLinksModel ()

typedef void(^RCSearchCallback)(NSArray<RSLink *> *links);
typedef void(^RCFailureCallback)();

@property (strong, nonatomic) NSMutableArray<RSLink *> *links;
@property (strong, nonatomic) NSString *currentQuery;
@property (nonatomic) NSInteger bottomBatch;

@end

@implementation RCLinksModel

- (void)searchForQuery:(NSString *)query {
    self.currentQuery = query;
    self.bottomBatch = 0;
    
    [self searchItemsForBatch:0 withSuccessCallback:^(NSArray<RSLink *> *links) {
        self.links = [NSMutableArray arrayWithArray:links];
    } andFailureCallback:^{
        self.links = [@[] mutableCopy];
        [self.delegate linksModel:self didLinksUpdate:self.links onTop:YES];
    }];
}

- (void)updateTopItems {
    [self searchItemsForBatch:RSBatchNumberTopItems withSuccessCallback:^(NSArray<RSLink *> *links) {
        [self.links insertObjects:links atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, links.count)]];
    } andFailureCallback:nil];
}

- (void)updateBottomItems {
    [self searchItemsForBatch:self.bottomBatch + 1 withSuccessCallback:^(NSArray<RSLink *> *links) {
        self.bottomBatch++;
        [self.links addObjectsFromArray:links];
    } andFailureCallback:nil];
}

- (void)searchItemsForBatch:(NSInteger)batch
        withSuccessCallback:(RCSearchCallback)callback
         andFailureCallback:(RCFailureCallback)failure {
    RSSearchConfiguration *config = [RSSearchConfiguration configurationWithBlock:^(RSConfigurationBuilder *builder) {
        builder.query = self.currentQuery;
        builder.limit = 25;
        builder.batchNumber = batch;
    }];
    __weak RCLinksModel *weakSelf = self;
    [[RSInstance sharedInstance] searchForLinksWithConfiguration:config
                                                     andCallback:^(NSArray<RSLink *> *links, NSError *error) {
                                                         RCLinksModel *strongSelf = weakSelf;
                                                         if (![config.query isEqualToString:weakSelf.currentQuery] || !strongSelf) {
                                                             return;
                                                         }
                                                         if (error) {
                                                             [strongSelf.delegate linksModel:strongSelf didFailedToLoadWithError:error];
                                                             if (failure) {
                                                                 failure();
                                                             }
                                                             return;
                                                         }
                                                         callback(links);
                                                         [strongSelf.delegate linksModel:strongSelf didLinksUpdate:strongSelf.links onTop:batch <= 0];
                                                     }];
}

@end
