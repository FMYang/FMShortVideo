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

#import "DouyinService.h"

#define kScreenW UIScreen.mainScreen.bounds.size.width
#define kScreenH UIScreen.mainScreen.bounds.size.height

static const int pageSize = 20;

@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray<VideoModel *> *dataSource;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) FMPlayerView *playerView;
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
    
    self.page = 1;
    
    [self setupUI];
//    [self fetchData];
    
    [DouyinService getDouyinRecommendList];
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
        NSLog(@"%@", error.error);
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
    return kScreenH;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginScrollIndex = self.currentIndex;
    
//    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
//    self.velocity = velocity.y;
//    NSLog(@"fm y轴平移的速度 = %@", NSStringFromCGPoint(velocity));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL stopped = !scrollView.isDragging && !scrollView.isDecelerating && !scrollView.isTracking;
    if(stopped) {
        self.currentIndex = ceil((scrollView.contentOffset.y / kScreenH));
        if(self.currentIndex != self.beginScrollIndex) {
        [self playVideo:self.currentIndex]; // 滑动停止播放当前视频
        }
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        // 平移的距离
//        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
////        CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
//        NSLog(@"fm y轴平移的距离 = %@", NSStringFromCGPoint(translatedPoint));
////        NSLog(@"fm y轴平移的速度 = %@", NSStringFromCGPoint(velocity));
//        if((translatedPoint.y < -kScreenH/2 || (self.velocity < 0 && self.velocity < -1200)) && self.currentIndex < (self.dataSource.count - 1)) {
//            NSLog(@"向下翻页");
//            self.currentIndex ++;   //向下滑动索引递增
//        }
//        if((translatedPoint.y > kScreenH/2 || (self.velocity > 0 && self.velocity > 800)) && self.currentIndex > 0) {
//            NSLog(@"向上翻页");
//            self.currentIndex --;   //向上滑动索引递减
//        }
//
//        scrollView.panGestureRecognizer.enabled = NO;
//        NSLog(@"fm beginScrollIndex = %d, currentIndex = %d", self.beginScrollIndex, self.currentIndex);
//
//        [UIView animateWithDuration:0.15
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseOut animations:^{
//            //UITableView滑动到指定cell
//            [self.listTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//            if(self.currentIndex != self.beginScrollIndex) {
//                [self playVideo:self.currentIndex]; // 滑动停止播放当前视频
//            }
//        } completion:^(BOOL finished) {
//            scrollView.panGestureRecognizer.enabled = YES;
//        }];
//    });
}

- (void)playVideo:(NSInteger)row {
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
    VideoCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    self.playerView.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    [cell.contentView insertSubview:self.playerView atIndex:1];
    
    VideoModel *model = self.dataSource[row];
    NSString *videoPath = @"http://v95-dy-a.ixigua.com/0c3ed64b9c02077a31c2ce3dd6456a1e/5f914862/video/tos/cn/tos-cn-ve-15/e5b19fd4459d461295d7e495d3614876/?a=1128&br=1968&bt=492&cr=3&cs=&cv=1&dr=0&ds=6&er=&l=20201022154846010202092157261310FA&lr=all&mime_type=video_mp4&qs=11&rc=M2wzbWV0NndkdTMzOmkzM0ApaDQzaDs2NTs1NzYzNTo8ZWdrMDQ0LjFxYV5fLS1iLS9zc2MyNWNeYy9gNDVeMjRjNS06Yw%3D%3D&vl=&vr=";//model.video;
    NSLog(@"%@", videoPath);
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
    self.playerView.asset = asset;
}

#pragma mark - UI
- (void)setupUI {
    [self.view addSubview:self.listTableView];
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
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

- (FMPlayerView *)playerView {
    if(!_playerView) {
        _playerView = [[FMPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _playerView.volume = 0.5;
    }
    return _playerView;
}

@end
