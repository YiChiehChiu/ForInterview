//
//  RSSParserDelegate.m
//  HelloMyRSSReader
//
//  Created by terrychiu on 2016/8/12.
//  Copyright © 2016年 terrychiu. All rights reserved.
//

#import "RSSParserDelegate.h"

@implementation RSSParserDelegate//RSS是資訊發佈的標準，大部分在新聞網站或是部落格
{   //標籤標頭
    NewsItem *currentNewsItem;
    //標籤內容
    NSMutableString *currentElementValue;
    NSMutableArray *results;
}
//element表示在rss的開始標籤跟結束標籤還有內容是一組的element，掃到開始標籤會跑來這
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    
    if ([elementName isEqualToString:@"item"]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            currentNewsItem = [NewsItem new];
        });
    }else if([elementName isEqualToString:@"title"]){
        //標籤與標籤之間有空白行，要先清空，讓foundCharacters可以得到正確值
        currentElementValue= nil;
    }else if ([elementName isEqualToString:@"link"]){
        currentElementValue= nil;
    }else if ([elementName isEqualToString:@"pubDate"]){
        currentElementValue= nil;
    }
    
    
}
//非標籤以外的東西會跑來這
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //標籤外的內文是string，currentElementValue為空值時，會建立物件並放到string，否則currentElementValue會加到string裡。意思是因為NSXMLParser運作機制讓網頁讀取可能會分段，讀到一半的currentElementValue可以直接加到string裡
    if (currentElementValue == nil) {
        currentElementValue = [[NSMutableString alloc]initWithString:string];
    }else{
        [currentElementValue appendString:string];
    }
}

//掃到結束標籤會跑來這
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"item"]) {
        //result給予初始化，是要result為nil的時候才會初始化
        if (results == nil) {
            results = [NSMutableArray new];
        }
        //遇到結束標籤時，開始標籤會加在result這裡，result是成品
        [results addObject:currentNewsItem];
        //標籤的值再轉成nil
        currentNewsItem =nil;
        
    }else if([elementName isEqualToString:@"title"]){
        //currentElementValue的內容塞到currentNewsItem
        currentNewsItem.title = currentElementValue;
    }else if ([elementName isEqualToString:@"link"]){
        currentNewsItem.link = currentElementValue;
    }else if ([elementName isEqualToString:@"pubDate"]){
        currentNewsItem.pubDate = currentElementValue;
    }
    //只取title link pubDate，標籤後面不要的東西就要清空
    currentElementValue = nil;
}

-(NSMutableArray*) getNewsItems{
    return results;
}

@end
