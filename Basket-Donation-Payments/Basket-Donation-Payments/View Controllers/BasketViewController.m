//
//  BasketViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "BasketViewController.h"
#import "PaymentPriceViewController.h"
#import "NonprofitCollectionViewCell.h"
#import "NonprofitViewController.h"
#import "Nonprofit.h"
#import "User.h"
#import "Utils.h"

@interface BasketViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *basketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *nonprofitsCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *totalValueDonatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *basketDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFavesLabel;

@property (nonatomic, strong) Nonprofit *nonprofitToSend;
@end

@implementation BasketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.nonprofitsCollectionView.delegate = self;
    self.nonprofitsCollectionView.dataSource = self;

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favoriteUnfavoriteBasket)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];

    self.numberOfFavesLabel.text = [NSString stringWithFormat:@"%ld Favorites", (long)self.basket.favoriteCount];
    self.basketNameLabel.text = self.basket.name;
    User *createdBy = self.basket.createdByUser;
    if (createdBy == nil) {
        self.createdByLabel.text = @"Created by the Basket team";
    } else {
        self.createdByLabel.text = [NSString stringWithFormat:@"Created by %@ %@", createdBy.firstName, createdBy.lastName];
    }
    self.totalValueDonatedLabel.text = [NSString stringWithFormat: @"$%0.2f", self.basket.totalDonatedValue];
    self.basketDescriptionLabel.text = self.basket.basketDescription;
}
- (IBAction)donateButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"BasketPaymentSegue" sender:nil];
}

- (void)favoriteUnfavoriteBasket {
    NSMutableArray<Basket*> *favBaskets = [[User currentUser] favoriteBaskets];
    if ([favBaskets containsObject:self.basket]) {
        [favBaskets removeObject:self.basket];
        self.basket.favoriteCount -= 1;
    } else {
        [favBaskets addObject:self.basket];
        self.basket.favoriteCount += 1;
    }
    self.numberOfFavesLabel.text = [NSString stringWithFormat:@"%ld Favorites", (long)self.basket.favoriteCount];
    [self.basket saveInBackground];
    [[User currentUser] saveInBackground];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showNonprofitDetail"]) {
        NonprofitViewController *nonprofitVC = [segue destinationViewController];
        nonprofitVC.nonprofit = self.nonprofitToSend;
        self.nonprofitToSend = nil;
    } else if ([segue.identifier isEqualToString:@"BasketPaymentSegue"]) {
        PaymentPriceViewController *paymentVC = [segue destinationViewController];
        paymentVC.basket = self.basket;
    }

}

#pragma mark - Collection View
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    NonprofitCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NonprofitCell" forIndexPath:indexPath];
    Nonprofit *n = self.basket.nonprofits[indexPath.row];
    cell.nonprofitProfilePic.image = [Utils getImageFromPFFile:n.profilePicFile];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return self.basket.nonprofits.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.nonprofitToSend = self.basket.nonprofits[indexPath.item];
    [self performSegueWithIdentifier:@"showNonprofitDetail" sender:nil];
    
}

@end
