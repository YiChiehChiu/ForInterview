//
//  MasterViewController.m
//  HelloMyRSSReader
//
//  Created by terrychiu on 2016/8/12.
//  Copyright © 2016年 terrychiu. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Reachability.h"//記得要加進來，Reachability是主動偵測網路狀態
#import "RSSParserDelegate.h"//記得要加進來
@interface MasterViewController ()
{
    Reachability *serverReach;//宣告偵測網路狀態變數
}
@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //apple原本的code，是提供給我們編輯跟新增的，目前用不著
    /*self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;*/
    
    //splitViewController運作時所需的
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    

    //Prepare serverReach
    //NSNotificationCenter是通知中心，是分派訊息的架構，是監聽網路要回報狀態，會觸發networkStatusChanged就可以知道網路狀態改變，name:kReachabilityChangedNotification是監聽的名字，觸發會啟動@selector(networkStatusChanged)。object:nil是指監聽特定物件
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged) name:kReachabilityChangedNotification object:nil];
    
//reachabilityWithHostName是連到特定主機，不能加http://
  serverReach = [Reachability reachabilityWithHostName:@"tw.news.yahoo.com"];
    //startNotifier是會偵測網路狀態
  [serverReach startNotifier];
    
//serverReach = [Reachability reachabilityForInternetConnection];
//    若沒有要特定主機只需確認連網就用這個方法
    
    
    //add a refresh button增加重新整理的按鈕，UIBarButtonSystemItemRefresh是內建的圖示按鈕，還有其他可以選。rightBarButtonItem是將button放在右邊，還有其他可以選，如果要有很多button的話可以這樣做，self.navigationItem.rightBarButtonItems = @[refreshBtn,refreshBtn];
    
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(downloadNewsList)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    
}

-(void)networkStatusChanged{
    //兩個方法都行[serverReach currentReachabilityStatus];
    NetworkStatus status = serverReach.currentReachabilityStatus;
    
    if (status == NotReachable) {
        NSLog(@"Network Not reachable");
    }else{
        NSLog(@"Reachable with %ld",status);
        [self downloadNewsList];
    }
}

-(void)downloadNewsList{
    //要顯示的網頁要用RSS的網址
    NSString *urlString = @"https://udn.com/rssfeed/news/2/6638?ch=news";
    //http的get，是用來串接別人的網站
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //確認是否完整的xml
        if (error) {
            NSLog(@"Download RSS Content Fail: %@",error);
            return ;
        }
        //debug用的未必一定要
        NSString *rssContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"RSS Content: %@",rssContent);
        
        //Parse XML基本型
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
        RSSParserDelegate *parserDelegate = [RSSParserDelegate new];
        parser.delegate = parserDelegate;
        
        BOOL success = [parser parse];
        
        if (success) {
            NSLog(@"Parse OK.");
            
            self.objects = [parserDelegate getNewsItems];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }else{
            NSLog(@"Parse Fail.");

        }
        
    }];
    [task resume];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //原本內建是NSDate
        NewsItem *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //這邊也有修改
    NewsItem *object = self.objects[indexPath.row];
    cell.textLabel.text = object.title;
    cell.detailTextLabel.text = object.pubDate;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
