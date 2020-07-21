//
//  AddBasket-AddNonprofitsViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/21/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "AddBasket-AddNonprofitsViewController.h"
#import "Nonprofit.h"
#import <Parse/Parse.h>
#import "Utils.h"
#import "NonprofitListCell.h"

@interface AddBasket_AddNonprofitsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *selectNonprofitsTableView;
@property (nonatomic, strong) NSArray<Nonprofit*> *allNonprofits;
@end

@implementation AddBasket_AddNonprofitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectNonprofitsTableView.delegate = self;
    self.selectNonprofitsTableView.dataSource = self;
    [self getAllNonprofitsFromParse];
}

- (void)getAllNonprofitsFromParse {
    PFQuery *nonprofitQuery = [PFQuery queryWithClassName:@"Nonprofit"];
    [nonprofitQuery includeKey:@"profilePicFile"];
    
    [nonprofitQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Cannot get nonprofits. Try again?" andMessage:error.localizedDescription okCompletion:^(UIAlertAction * _Nonnull action) {
                [self getAllNonprofitsFromParse];
            } cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];

        } else {
            self.allNonprofits = objects;
            [self.selectNonprofitsTableView reloadData];
        }
    }];
}

- (IBAction)createButtonTapped:(id)sender {
    NSLog(@"%@", self.basket.nonprofits);
    [self.basket saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
       //save basket to parse
        //clear all data, have navigation controller reset to Create Basket
        //switch tab controller to index 0
    }];

}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NonprofitListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NonprofitListCell"];
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];

    //set up cell UI with nonprofit info
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allNonprofits.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];
    //TURN COLOR CHANGE OR SELECTION UI
    [self.basket.nonprofits addObject:nonprofit];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
