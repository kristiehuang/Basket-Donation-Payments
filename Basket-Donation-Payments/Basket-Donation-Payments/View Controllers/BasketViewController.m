//
//  BasketViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "BasketViewController.h"
#import "NonprofitCollectionViewCell.h"
#import "NonprofitViewController.h"
#import "Nonprofit.h"
#import "User.h"
#import "BraintreePayPal.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"

@interface BasketViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *basketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *nonprofitsCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *totalValueDonatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *basketDescriptionLabel;

@property (nonatomic, strong) Nonprofit *nonprofitToSend;
@end

@implementation BasketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nonprofitsCollectionView.delegate = self;
    self.nonprofitsCollectionView.dataSource = self;
    self.basketNameLabel.text = self.basket.name;
    User *createdBy = self.basket.createdByUser;
    self.createdByLabel.text = [NSString stringWithFormat:@"Created by %@ %@", createdBy.firstName, createdBy.lastName];
    self.totalValueDonatedLabel.text = [NSString stringWithFormat: @"$%0.2f", self.basket.totalDonatedValue];
    self.basketDescriptionLabel.text = self.basket.basketDescription;
}
- (IBAction)donateButtonTapped:(id)sender {

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showNonprofitDetail"]) {
        NonprofitViewController *nonprofitVC = [segue destinationViewController];
        nonprofitVC.nonprofit = self.nonprofitToSend;
        self.nonprofitToSend = nil;
    }

}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    NonprofitCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NonprofitCell" forIndexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return 3;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.nonprofitToSend = self.basket.nonprofits[indexPath.item];
    [self performSegueWithIdentifier:@"showNonprofitDetail" sender:nil];
    
}

@end
