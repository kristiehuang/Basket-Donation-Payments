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
    [self.exploreBasketsTableView insertSubview:self.refreshControl atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getBaskets];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)getBaskets {
    PFQuery *query = [PFQuery queryWithClassName:@"Basket"];
    [query includeKey:@"nonprofits"];
    [query includeKey:@"nonprofits.verificationFiles"];
    [query includeKey:@"createdByUser"];
    [query includeKey:@"allTransactions"];
    [query includeKey:@"featuredValueDict"];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Basket*> * _Nullable objects, NSError * _Nullable error) {
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
    }];
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
    
    //TODO: show profile pics of nonprofits
    //FIXME: SHOW BASKET HEADER VIEW, NOT NONPROFITS
    [self getNonprofitImagesFromBasket:basket onCell:cell];

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


//Broken
- (void)getNonprofitImagesFromBasket:(Basket*)basket onCell:(BasketTableViewCell *)cell {
    cell.basketImageView0.layer.cornerRadius = 25;
    cell.basketImageView1.layer.cornerRadius = 25;
    cell.basketImageView2.layer.cornerRadius = 25;
    int nonprofitsCount = (int) basket.nonprofits.count;
    for (int i = 0; i < 3; i++) {
        if (i >= nonprofitsCount) {
            UIImage *im = [UIImage imageNamed:@"PlaceholderProfilePic"];
            switch (i) {
                case 0:
                    cell.basketImageView0.image = im;
                    cell.basketImageView1.image = im;
                    cell.basketImageView2.image = im;
                    break;
                case 1:
                    cell.basketImageView1.image = im;
                    cell.basketImageView2.image = im;
                    break;
                case 2:
                    cell.basketImageView2.image = im;
                    break;
            }
            break;
        }
        Nonprofit *n = basket.nonprofits[i];
        PFFileObject *profFile = n.profilePicFile;
        [profFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            UIImage *im;
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
                im = [UIImage imageNamed:@"PlaceholderProfilePic"];
            } else {
                im = [UIImage imageWithData:data];
            }
            switch (i) {
                case 0: cell.basketImageView0.image = im; break;
                case 1: cell.basketImageView1.image = im; break;
                case 2: cell.basketImageView2.image = im; break;
            }
            [cell reloadInputViews];
        }];
    }
}


@end
