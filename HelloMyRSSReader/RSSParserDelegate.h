//
//  RSSParserDelegate.h
//  HelloMyRSSReader
//
//  Created by terrychiu on 2016/8/12.
//  Copyright © 2016年 terrychiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsItem.h"
@interface RSSParserDelegate : NSObject <NSXMLParserDelegate>

-(NSMutableArray*) getNewsItems;

@end
