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
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>

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


@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray<VideoModel *> *dataSource;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) ZYCameraPlayerView *playerView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger beginScrollIndex;
@property (nonatomic, assign) CGFloat velocity;
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
    
    dispatch_after(DISPATCH_TIME_NOW + 0.25, dispatch_get_main_queue(), ^{
        [self fetchData];
    });
}

- (void)networkDidChange {
    if(AFNetworkReachabilityManager.sharedManager.reachable) {
        self.playerView.videoUrl = self.playerView.videoUrl;
    }
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
    NSLog(@"fm fetchData %d", self.page);

    /**
     https://nine.ifeng.com/vappRecomlist?id=VIDEOSHORTPLAY&ch=vch_sv_edit&action=up&pullNum=10&pullTotal=7&ts=2022-03-11%2011%3A40%3A35&gv=7.27.1&adgv=7.27.5&av=0&proid=ifengvideo&os=ios_14.6&df=iPhone12%2C1&vt=5&screen=828x1792&publishid=4002&uid=12463ffc5c4044d48979ce25e953f82d&nw=wifi&st=16469700351542&sn=47109890e707a2642f3dc10475435e90
     */
    NSDictionary *params = @{@"id": @"VIDEOSHORTPLAY",
                             @"ch": @"vch_sv_edit",
                             @"action": @"up",
                             @"pullNum": @(self.page),
                             @"pullTotal": @(self.page),
                             @"ts": @"2022-03-11%2011%3A40%3A35",
                             @"gv": @"7.27.1",
                             @"adgv": @"7.27.1",
                             @"av": @"0",
                             @"proid": @"ifengvideo",
                             @"os": @"ios_14.6",
                             @"df": @"iPhone12%2C1",
                             @"vt": @"5",
                             @"screen": @"828x1792",
                             @"publishid": @"4002",
                             @"uid": @"12463ffc5c4044d48979ce25e953f82d",
                             @"nw": @"nv",
                             @"st": @"16469700351542",
                             @"sn": @"47109890e707a2642f3dc10475435e90"};
    
    [HomeNetwork fetchList:params success:^(NSArray<VideoModel *> *items) {
        [self.dataSource addObjectsFromArray:items];
        [self.listTableView reloadData];
        if(self.page == 1) {
            [self playVideo:0]; // 请求完成播放第0个视频
        }
    } fail:^{
        NSLog(@"error");
    }];
    
//    [HomeNetwork fetchList:params success:^(NSArray<VideoModel *> * _Nonnull result, FMResponse * _Nonnull response) {
//        [self.dataSource removeAllObjects];
//        [self.dataSource addObjectsFromArray:result];
//        [self.listTableView reloadData];
//        [self playVideo:0]; // 请求完成播放第0个视频
//    } fail:^(FMError * _Nonnull error) {
//        NSString *errmsg = @"";
//        switch (error.reason) {
//            case FMErrorReasonNetworkLost:
//                errmsg = @"没有网络";
//                break;
//
//            case FMErrorReasonDataIsNil:
//                errmsg = @"没有数据";
//                break;
//
//            case FMErrorReasonClientError:
//                errmsg = @"客户端错误";
//                break;
//
//            case FMErrorReasonServiceError:
//                errmsg = @"服务端错误";
//                break;
//
//            case FMErrorReasonTimeout:
//                errmsg = @"请求超时";
//                break;
//
//            default:
//                break;
//        }
//        NSLog(@"%@", errmsg);
//    }];
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
    NSLog(@"fm === %@", NSStringFromCGSize(scrollView.contentSize));
    BOOL stopped = !scrollView.isDragging && !scrollView.isDecelerating && !scrollView.isTracking;
    if(stopped) {
        self.currentIndex = ceil((scrollView.contentOffset.y / kContentHeight));
        if(self.currentIndex != self.beginScrollIndex) {
            if(self.currentIndex < self.dataSource.count) {
                [self playVideo:self.currentIndex]; // 滑动停止播放当前视频
            }
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
    NSString *videoPath = model.videoPlayUrl;

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
        
        __weak typeof(self) weakSelf = self;
        MJRefreshAutoFooter *footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            weakSelf.page += 1;
            [weakSelf fetchData];
            [weakSelf.listTableView.mj_footer endRefreshing];
        }];
        footer.triggerAutomaticallyRefreshPercent = -0.5;
        footer.autoTriggerTimes = -1;
        self.listTableView.mj_footer = footer;
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
