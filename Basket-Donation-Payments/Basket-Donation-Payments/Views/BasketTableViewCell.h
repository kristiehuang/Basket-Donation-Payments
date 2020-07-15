//
//  BasketTableViewCell.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/15/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasketTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *basketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *basketDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *basketImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *basketImageView0;
@property (weak, nonatomic) IBOutlet UIImageView *basketImageView2;

@end

NS_ASSUME_NONNULL_END
