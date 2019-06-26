//
//  DetailViewController.h
//  HelloMyRSSReader
//
//  Created by terrychiu on 2016/8/12.
//  Copyright © 2016年 terrychiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

