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

@property (strong, nonatomic) NSString *currentQuery;
@property (nonatomic) NSInteger bottomBatch;

@end

@implementation RCLinksModel

- (void)searchForQuery:(NSString *)query {
    self.currentQuery = query;
    self.bottomBatch = 0;
    
    __weak RCLinksModel *weakSelf = self;
    [self searchItemsForBatch:0 withSuccessCallback:^(NSArray<RSLink *> *links) {
        [weakSelf.delegate linksModel:weakSelf didLinksUpdate:links];
    } andFailureCallback:^{
        [weakSelf.delegate linksModel:weakSelf didLinksUpdate:@[]];
    }];
}

- (void)updateTopItems {
    __weak RCLinksModel *weakSelf = self;
    [self searchItemsForBatch:RSBatchNumberTopItems withSuccessCallback:^(NSArray<RSLink *> *links) {
        [weakSelf.delegate linksModel:weakSelf didLinksPrepended:links];
    } andFailureCallback:nil];
}

- (void)updateBottomItems {
    __weak RCLinksModel *weakSelf = self;
    [self searchItemsForBatch:self.bottomBatch + 1 withSuccessCallback:^(NSArray<RSLink *> *links) {
        weakSelf.bottomBatch++;
        [weakSelf.delegate linksModel:weakSelf didLinksAppended:links];
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
                                                         if (![config.query isEqualToString:weakSelf.currentQuery] || !weakSelf) {
                                                             return;
                                                         }
                                                         if (!error) {
                                                             callback(links);
                                                             return;
                                                         }
                                                         if (failure) {
                                                             failure();
                                                         }
                                                         [weakSelf.delegate linksModel:weakSelf didFailedToLoadWithError:error];
                                                     }];
}

@end
