//
//  AddBasketViewController.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddBasketViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *basketDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *basketNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *basketHeaderImageView;
@property (weak, nonatomic) IBOutlet UITextField *basketCategoryTextField;

@end

NS_ASSUME_NONNULL_END
