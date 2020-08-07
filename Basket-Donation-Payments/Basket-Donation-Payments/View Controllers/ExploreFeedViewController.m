//
//  ExploreFeedViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "ExploreFeedViewController.h"
#import "BasketTableViewCell.h"
#import "BasketViewController.h"
#import "Nonprofit.h"
#import "Basket.h"
#import "Utils.h"
#import <Parse/Parse.h>

@interface ExploreFeedViewController ()  <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *exploreBasketsTableView;
@property (nonatomic, strong) NSArray<Basket*> *baskets;
@property (nonatomic, strong) NSArray<Basket*> *featuredBaskets;
@property (nonatomic, strong) Basket *basketToPass;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ExploreFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.exploreBasketsTableView.delegate = self;
    self.exploreBasketsTableView.dataSource = self;
    self.exploreBasketsTableView.rowHeight = UITableViewAutomaticDimension;
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(getBaskets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    [self.exploreBasketsTableView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Utils getBasketsWithCompletion:^(NSArray<Basket*> * _Nullable objects, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error loading feed" andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                self.baskets = objects;
                NSArray<Basket*> *sortedFeatured = [objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"totalFeaturedValue" ascending:NO]]];
                self.featuredBaskets = [sortedFeatured subarrayWithRange:NSMakeRange(0, MIN(3, sortedFeatured.count))];
                [self.exploreBasketsTableView reloadData];
            }
            [self.refreshControl endRefreshing];
        });
    }];
    self.navigationController.navigationBar.hidden = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasketTableViewCell"];

    Basket *basket;
    if (indexPath.section == 0) {
        basket = self.featuredBaskets[indexPath.row];
    } else {
        basket = self.baskets[indexPath.row];
    }
    cell.basketNameLabel.text = basket.name;
    cell.basketDescriptionLabel.text = basket.basketDescription;
    [Utils getNonprofitImagesFromBasket:basket onCell:cell];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.basketToPass = self.featuredBaskets[indexPath.row];
    } else {
        self.basketToPass = self.baskets[indexPath.row];
    }
    [self performSegueWithIdentifier:@"showBasketDetail" sender:nil];
}

# pragma mark Sections

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 2;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.featuredBaskets.count;
    } else {
        return self.baskets.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Recommended Baskets";
    } else {
        return @"All Baskets";
    }
}

# pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showBasketDetail"]) {
        BasketViewController *basketVC = [segue destinationViewController];
        basketVC.basket = self.basketToPass;
        self.basketToPass = nil;
    }
}




@end
