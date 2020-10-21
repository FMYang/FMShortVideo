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

#define kScreenW UIScreen.mainScreen.bounds.size.width
#define kScreenH UIScreen.mainScreen.bounds.size.height

static const int pageSize = 20;

@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray<VideoModel *> *dataSource;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) FMPlayerView *playerView;
@end

@implementation HomeVC

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAuthSuccess) name:@"networkAuthSuccess" object:nil];
    
    self.page = 1;
    
    [self setupUI];
    [self fetchData];
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
        NSLog(@"%@", result);
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL stopped = !scrollView.isDragging && !scrollView.isDecelerating && !scrollView.isTracking;
    if(stopped) {
        NSInteger row = ceil((scrollView.contentOffset.y / kScreenH));
        [self playVideo:row]; // 滑动停止播放当前视频
    }
}

- (void)playVideo:(NSInteger)row {
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
    VideoCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    self.playerView.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    [cell.contentView insertSubview:self.playerView atIndex:1];
    
    VideoModel *model = self.dataSource[row];
    NSString *videoPath = model.video;
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
