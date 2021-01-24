//
//  HomeVC.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import "HomeVC.h"
#import "HomeNetwork.h"
#import "VideoCell.h"
#import "FMPlayerView.h"
#import "ZYCameraPlayerView.h"

#import "DouyinService.h"

#import "DouyinFeedMin.pbobjc.h"
#import "Person.pbobjc.h"

#import "FollowFeed.h"
#import <MJExtension/MJExtension.h>

#define kScreenW UIScreen.mainScreen.bounds.size.width
#define kScreenH UIScreen.mainScreen.bounds.size.height

#define kIsIPhoneXSerial \
({BOOL isPhoneX = NO;\
    if (@available(iOS 11.0, *)) {\
        isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
    }\
(isPhoneX);})

/// 状态栏高度（默认值）
#define kStatusBarHeight            (kIsIPhoneXSerial ? 44 : 20)
/// tabbar高度
#define kTabBarHeight         (kIsIPhoneXSerial ? 83 : 49)
/// 导航栏高度
#define kNaviHeight            (kIsIPhoneXSerial ? 88 : 64)
/// 底部安全区高度
#define kBottomSafeHeight      (kIsIPhoneXSerial ? 34 : 0)
/// 顶部安全区高度
#define kTopSafeHeight      (kIsIPhoneXSerial ? 44 : 0)

#define kContentHeight (kScreenH - kTabBarHeight)

static const int pageSize = 20;

@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray<VideoModel *> *dataSource;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) ZYCameraPlayerView *playerView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger beginScrollIndex;
@property (nonatomic, assign) CGFloat velocity;

@property (nonatomic, strong) FollowFeed *followFeed;
@end

@implementation HomeVC

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAuthSuccess) name:@"networkAuthSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChange) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    self.page = 1;
    
    [self setupUI];
    
//    [self readLocalData];
    
    dispatch_after(DISPATCH_TIME_NOW + 0.25, dispatch_get_main_queue(), ^{
        [self fetchData];
    });
    
//    [DouyinService getDouyinRecommendList];
    
//    [self paraseDouyinData];
}

- (void)networkDidChange {
    if(AFNetworkReachabilityManager.sharedManager.reachable) {
        self.playerView.videoUrl = self.playerView.videoUrl;
    }
}

- (void)paraseDouyinData {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    NSString *path = [documentPath stringByAppendingPathComponent:@"douyin.protobuf"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    NSLog(@"%ld", data.length);

    NSError *err;
    Feed *feed = [Feed parseFromData:data error:&err];
    if(err) {
        NSLog(@"解析失败");
    } else {
        NSLog(@"解析成功");
    }
}

- (FollowFeed *)readLocalData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"douyin_userVideo" ofType:nil];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    FollowFeed *feed = [FollowFeed mj_objectWithKeyValues:data];
    
    for(FeedList *item in feed.data) {
        NSLog(@"%@", item.aweme.video.play_addr.url_list[0]);
    }
    
    self.followFeed = feed;
    return feed;
}

- (void)networkAuthSuccess {
    // 获取网络访问权限后，刷新下数据，防止第一次失败的情况
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - private method
- (void)fetchData {
    NSDictionary *params = @{@"page": @(self.page),
                             @"count": @(pageSize),
                             @"type": @"video"};
    
    [HomeNetwork fetchList:params success:^(NSArray<VideoModel *> * _Nonnull result, FMResponse * _Nonnull response) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:result];
        [self.listTableView reloadData];
        [self playVideo:0]; // 请求完成播放第0个视频
    } fail:^(FMError * _Nonnull error) {
        NSString *errmsg = @"";
        switch (error.reason) {
            case FMErrorReasonNetworkLost:
                errmsg = @"没有网络";
                break;
                
            case FMErrorReasonDataIsNil:
                errmsg = @"没有数据";
                break;
                
            case FMErrorReasonClientError:
                errmsg = @"客户端错误";
                break;
                
            case FMErrorReasonServiceError:
                errmsg = @"服务端错误";
                break;
                
            case FMErrorReasonTimeout:
                errmsg = @"请求超时";
                break;
                
            default:
                break;
        }
        NSLog(@"%@", errmsg);
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(VideoCell.class) forIndexPath:indexPath];
    [cell configCell:self.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kContentHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginScrollIndex = self.currentIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL stopped = !scrollView.isDragging && !scrollView.isDecelerating && !scrollView.isTracking;
    if(stopped) {
        self.currentIndex = ceil((scrollView.contentOffset.y / kContentHeight));
        if(self.currentIndex != self.beginScrollIndex) {
        [self playVideo:self.currentIndex]; // 滑动停止播放当前视频
        }
    }
}

- (void)playVideo:(NSInteger)row {
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
    VideoCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    self.playerView.frame = CGRectMake(0, 0, kScreenW, kContentHeight);
    [cell.contentView insertSubview:self.playerView atIndex:1];
    
    VideoModel *model = self.dataSource[row];
    NSString *videoPath = model.video;
    
    if(row < self.followFeed.data.count) {
        NSLog(@"xxxxxx");
        videoPath = self.followFeed.data[row].aweme.video.play_addr.url_list[1];
    }
    
    NSLog(@"%@", videoPath);

    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
    self.playerView.asset = asset;
}

#pragma mark - UI
- (void)setupUI {
    [self.view addSubview:self.listTableView];
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kContentHeight);
    }];
}

#pragma mark - getter
- (NSMutableArray<VideoModel *> *)dataSource {
    if(!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (UITableView *)listTableView {
    if(!_listTableView) {
        _listTableView = [[UITableView alloc] init];
        if (@available(iOS 11.0, *)) {
            _listTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _listTableView.scrollsToTop = NO;
        _listTableView.backgroundColor = UIColor.clearColor;
        _listTableView.pagingEnabled = YES;
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.showsVerticalScrollIndicator = NO;
        _listTableView.showsHorizontalScrollIndicator = NO;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listTableView registerClass:VideoCell.class forCellReuseIdentifier:NSStringFromClass(VideoCell.class)];
    }
    return _listTableView;
}

- (ZYCameraPlayerView *)playerView {
    if(!_playerView) {
        _playerView = [[ZYCameraPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kContentHeight)];
        _playerView.volume = 0.5;
    }
    return _playerView;
}

@end
