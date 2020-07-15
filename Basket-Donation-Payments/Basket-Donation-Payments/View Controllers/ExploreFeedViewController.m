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
    
    //FIXME: temporarily force-create baskets
    Basket *b1 = [Basket initPlaceholderTestBasketWithName:@"b1"];
    [b1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"hell ya");
            
          } else {
              NSLog(@"%@", error.localizedDescription);
        }
  }];
    PFQuery *query = [PFQuery queryWithClassName:@"Basket"];
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
    [basket.headerPicFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            cell.basketImageView.image = [UIImage imageNamed:@"PlaceholderHeaderPic"];
        } else {
            cell.basketImageView.image = [UIImage imageWithData:data];
        }
    }];
    return cell;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //TODO: for now, just query and list all baskets
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
        
    }
}


@end
