//
//  SearchViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "SearchViewController.h"
#import "Basket.h"
#import "Nonprofit.h"
#import "BasketTableViewCell.h"
#import "NonprofitListCell.h"
#import "Utils.h"
#import "BasketViewController.h"
#import "NonprofitViewController.h"

@interface SearchViewController () <UITableViewDataSource,  UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) NSArray<Basket*> *filteredBaskets;
@property (nonatomic, strong) NSArray<Nonprofit*> *filteredNonprofits;
@property (nonatomic, strong) NSArray<Basket*> *baskets;
@property (nonatomic, strong) NSArray<Nonprofit*> *nonprofits;
@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) Basket *basketToPass;
@property (nonatomic, strong) Nonprofit *nonprofitToPass;
@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.rowHeight = UITableViewAutomaticDimension;
    self.refreshIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
    [self getBasketsAndNonprofits];
    self.searchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)getBasketsAndNonprofits {
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        PFQuery *query = [PFQuery queryWithClassName:@"Basket"];
        [query includeKey:@"nonprofits"];
        [query includeKey:@"nonprofits.verificationFiles"];
        [query includeKey:@"createdByUser"];
        [query includeKey:@"allTransactions"];
        [query includeKey:@"featuredValueDict"];
        NSArray<Basket*> *bArray = [query findObjects];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (bArray) {
                self.baskets = bArray;
                self.filteredBaskets = bArray;
                [self.searchTableView reloadData];
            } else {
                self.baskets = [NSArray array];
                self.filteredBaskets = [NSArray array];
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error loading feed" andMessage:@"" okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }];
    [queue addOperationWithBlock:^{
        PFQuery *query = [ PFQuery queryWithClassName:@"Nonprofit"];
        NSArray<Nonprofit*> *nArray = [query findObjects];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.refreshIndicator stopAnimating];
            if (nArray) {
                self.nonprofits = nArray;
                self.filteredNonprofits = nArray;
                [self.searchTableView reloadData];
            } else {
                self.nonprofits = [NSArray array];
                self.filteredNonprofits = [NSArray array];
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error loading feed" andMessage:@"" okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }];
}

#pragma mark Table View

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BasketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasketTableViewCell"];

        Basket *basket = self.filteredBaskets[indexPath.row];
        cell.basketNameLabel.text = basket.name;
        cell.basketDescriptionLabel.text = basket.basketDescription;
        [Utils getNonprofitImagesFromBasket:basket onCell:cell];
        return cell;

    } else {
        NonprofitListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NonprofitTableViewCell"];
        Nonprofit *nonprofit = self.filteredNonprofits[indexPath.row];
        cell.nonprofitNameLabel.text = nonprofit.nonprofitName;
        cell.nonprofitDescriptionLabel.text = nonprofit.nonprofitDescription;
        cell.nonprofitProfileImageView.image = [Utils getImageFromPFFile:nonprofit.profilePicFile];
        return cell;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.filteredBaskets.count;
    } else {
        return self.filteredNonprofits.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.basketToPass = self.filteredBaskets[indexPath.row];
        [self performSegueWithIdentifier:@"showBasketDetail" sender:nil];

    } else {
        self.nonprofitToPass = self.filteredNonprofits[indexPath.row];
        [self performSegueWithIdentifier:@"showNonprofitDetail" sender:nil];
    }
}


# pragma mark Sections

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 2;
    return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Baskets";
    } else {
        return @"Nonprofits";
    }
}

#pragma mark Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchText = [searchText lowercaseString];
    if (searchText.length > 0) {
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSString* searching;
            if ([evaluatedObject isKindOfClass:[Basket class]]) {
                Basket *b = evaluatedObject;
                searching = [NSString stringWithFormat:@"%@ %@ %@", b.name, b.basketDescription, b.category];
            } else if ([evaluatedObject isKindOfClass:[Nonprofit class]]) {
                Nonprofit *n = evaluatedObject;
                searching = [NSString stringWithFormat:@"%@ %@ %@", n.nonprofitName, n.nonprofitDescription, n.category];
            }
            return [[searching lowercaseString] containsString:searchText];
        }];
        self.filteredBaskets = [self.baskets filteredArrayUsingPredicate:pred];
        self.filteredNonprofits = [self.nonprofits filteredArrayUsingPredicate:pred];
    } else {
        self.filteredNonprofits = self.nonprofits;
        self.filteredBaskets = self.baskets;
    }
    [self.searchTableView reloadData];
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationController.navigationBar.hidden = NO;
    if ([segue.identifier isEqualToString:@"showBasketDetail"]) {
        BasketViewController *basketVC = [segue destinationViewController];
        basketVC.basket = self.basketToPass;
        self.basketToPass = nil;
    } else if ([segue.identifier isEqualToString:@"showNonprofitDetail"]) {
        NonprofitViewController *nonprofitVC = [segue destinationViewController];
        nonprofitVC.nonprofit = self.nonprofitToPass;
        self.nonprofitToPass = nil;
    }
}



@end
