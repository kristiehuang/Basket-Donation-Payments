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
    //FIXME: temporarily force-create baskets
//    Basket *b1 = [Basket initPlaceholderTestBasketWithName:@"b1"];
//    [b1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
//            NSLog(@"hell ya");
//
//          } else {
//              NSLog(@"%@", error.localizedDescription);
//        }
//  }];
    PFQuery *query = [PFQuery queryWithClassName:@"Basket"];
    [query includeKey:@"nonprofits"];
    [query includeKey:@"createdByUser"];
    //FIXME: manually uploaded headerPicFiles on the dashboard are linked via http, which fails to query bc Apple wants https
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error");
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showBasketDetail"]) {
        BasketViewController *basketVC = [segue destinationViewController];
        basketVC.basket = self.basketToPass;
        self.basketToPass = nil;
    }
}


//Broken
- (void)getNonprofitImagesFromBasket:(Basket*)basket onCell:(BasketTableViewCell *)cell {
    int nonprofitsCount = (int) basket.nonprofits.count;
    for (int i = 0; i < 3; i++) {
        if (i >= nonprofitsCount) {
            //FIXME: placeholder pic is my pic for now hahah
            UIImage *im = [UIImage imageNamed:@"PlaceholderPic"];
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
                im = [UIImage imageNamed:@"PlaceholderPic"];
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
