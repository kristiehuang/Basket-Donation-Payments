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
@property (nonatomic, strong) Basket *basketToPass;

@end

@implementation ExploreFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.exploreBasketsTableView.delegate = self;
    self.exploreBasketsTableView.dataSource = self;
    self.exploreBasketsTableView.rowHeight = UITableViewAutomaticDimension;

    PFQuery *query = [PFQuery queryWithClassName:@"Basket"];
    [query includeKey:@"nonprofits"];
    [query includeKey:@"nonprofits.verificationFiles"];
    [query includeKey:@"createdByUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error loading feed" andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            self.baskets = objects;
            [self.exploreBasketsTableView reloadData];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasketTableViewCell"];
    Basket *basket = self.baskets[indexPath.row];
    cell.basketNameLabel.text = basket.name;
    cell.basketDescriptionLabel.text = basket.basketDescription;
    
    //TODO: show profile pics of nonprofits
    [self getNonprofitImagesFromBasket:basket onCell:cell];

    return cell;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //TODO: add sections later, for isFeatured/recents/etc
    return self.baskets.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.basketToPass = self.baskets[indexPath.row];
    [self performSegueWithIdentifier:@"showBasketDetail" sender:nil];
}

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
