//
//  ViewController.m
//  RedditClient
//
//  Created by Orest Savchak on 8/5/16.
//  Copyright © 2016 Orest Savchak. All rights reserved.
//

#import "RCLinksListViewController.h"
#import "RCLinksTableViewCell.h"
#import "RCLinksModel.h"
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <SVPullToRefresh/UIScrollView+SVInfiniteScrolling.h>

@interface RCLinksListViewController ()<UITableViewDataSource, RCLinksModelDelegate>

@property (strong, nonatomic) RCLinksModel *model;

@property (strong, nonatomic) NSArray<RSLink *> *links;

@property (weak, nonatomic) IBOutlet UITableView *linksTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation RCLinksListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model.delegate = self;
    __weak RCLinksListViewController *weakSelf = self;
    [self.linksTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.linksTableView showsPullToRefresh];
        [weakSelf didPulledToRefresh];
    }];
    [self.linksTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.linksTableView showsInfiniteScrolling];
        [weakSelf didInfiniteScolled];
    }];
}

- (RCLinksModel *)model {
    if (!_model) {
        _model = [RCLinksModel new];
    }
    return _model;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didClickSearch:(UIButton *)sender {
    [self.model searchForQuery:self.searchTextField.text];
}

- (void)didPulledToRefresh {
    [self.model updateTopItems];
}

- (void)didInfiniteScolled {
    [self.model updateBottomItems];
}

#pragma mark RCLinksModelDelegate implementation

- (void)linksModel:(RCLinksModel *)model didLinksUpdate:(NSArray<RSLink *> *)links onTop:(BOOL)onTop {
    if (onTop) {
        [self.linksTableView.pullToRefreshView stopAnimating];
    } else {
        [self.linksTableView.infiniteScrollingView stopAnimating];
    }
    
    NSIndexPath *startAtPosition = onTop ? [NSIndexPath indexPathForRow:0 inSection:0] : [self.linksTableView.indexPathsForVisibleRows.lastObject copy];
    self.links = [links copy];
    [self.linksTableView reloadData];
    if (self.links.count) {
        [self.linksTableView scrollToRowAtIndexPath:startAtPosition
                                   atScrollPosition:UITableViewScrollPositionBottom
                                           animated:NO];
    }
}

- (void)linksModel:(RCLinksModel *)model didFailedToLoadWithError:(NSError *)error {
    [self.linksTableView.pullToRefreshView stopAnimating];
    [self.linksTableView.infiniteScrollingView stopAnimating];
}

#pragma mark UITableViewDataSource implementation

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCLinksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linksCell"];
    [cell updateWithDataObject:[self.links objectAtIndex:[indexPath row]]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.links.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
