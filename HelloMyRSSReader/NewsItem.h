//
//  NewsItem.h
//  HelloMyRSSReader
//
//  Created by terrychiu on 2016/8/12.
//  Copyright © 2016年 terrychiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsItem : UIImageView

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *pubDate;
@property (nonatomic,strong)NSString *link;

@end
