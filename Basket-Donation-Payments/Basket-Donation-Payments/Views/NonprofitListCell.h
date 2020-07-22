//
//  NonprofitListCell.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/21/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NonprofitListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nonprofitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitProfileImageView;

@end

NS_ASSUME_NONNULL_END
