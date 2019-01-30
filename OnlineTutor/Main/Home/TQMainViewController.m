//
//  TQMainViewController.m
//  OnlineTutor
//
//  Created by JiMo on 2018/7/30.
//  Copyright © 2018年 TQ. All rights reserved.
//

#import "TQMainViewController.h"
#import "VideoChatViewController.h"
#import "Masonry.h"
#import "NGMVideoController.h"
#import "NGMNewListCollectionViewCell.h"

//网络代理
#import "HYConversationManager.h"
#import "HYServerManager.h"
#import "TQConectServerView.h"

@interface TQMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,HYServerDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong)NSMutableArray *dataArray;

@property(nonatomic,strong)TQConectServerView *connectView;


@end

@implementation TQMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self setNavBarTitle:@"辅导1V1课堂"];
    self.dataArray  = [NSMutableArray array];
    
    [self addData];
    
    NSLog(@"==== %f==%f",kSCREEN_WIDTH,kAUTOSCALE_WIDTH(100));
    
    NSLog(@"kSCREEN_HEIGHT==== %f==%f",kSCREEN_HEIGHT,kAUTOSCALE_WIDTH(100));

    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo(60);
        make.bottom.mas_equalTo(-[self getTabBarHeight]);
    }];
    
    [self.view addSubview:self.connectView];
}

- (void)addData
{
    NSArray *array = [NSArray arrayWithObjects:@"1f374317852071e19c786f6e60793dae.jpg",@"1ab48f67177d2e4e8410672b531325c3.jpg",@"a1b24c853f5c9ddde39ae74818ddb3d7.jpg",@"39970ed41cf939e3f26fcb0580222f4c.jpg",@"29d3760d7621fc90fbfd3bedb5998595.jpg",@"8407bc4d9fe6c3595cdd4180ea8d9aff.jpg", nil];
    
    NSArray *nameArray = [NSArray arrayWithObjects:@"赵老师",@"钱老师",@"孙老师",@"李老师",@"周老师",@"吴老师",@"郑老师",@"王老师",@"冯老师",@"陈老师",@"葛老师", nil];

    
    NSArray *tipArray = [NSArray arrayWithObjects:@"赵老师带你学语文",@"钱老师带你学英语",@"孙老师带你学数学",@"李老师带你学化学",@"周老师带你学生物",@"吴老师带你学物理",@"郑老师带你学英语带你学语文",@"王老师带你学数学",@"冯老师带你学物理",@"陈老师带你学物理",@"葛老师带你学数学", nil];


    for (int i = 0; i < array.count; i++) {
        NGMHotListModel *model = [[NGMHotListModel alloc]init];
        model.cover = array[i];
        model.username = nameArray[i];
        model.tip = tipArray[i];
        [self.dataArray addObject:model];
    }
    
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((kSCREEN_WIDTH-8)/4.0, (kSCREEN_WIDTH-8)/4.0);
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        layout.sectionInset = UIEdgeInsetsMake(1, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.headerReferenceSize=CGSizeMake(kSCREEN_WIDTH,0); //设置collectionView头视图的大小
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"f1f1f1"];
        [_collectionView registerClass:[NGMNewListCollectionViewCell class] forCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName(NGMNewListCollectionViewCell.class)]];
        
    
    }
    return _collectionView;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NGMNewListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName(NGMNewListCollectionViewCell.class)] forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    self.connectView.hidden = NO;

    /*
     NGMVideoController *vc = [[NGMVideoController alloc]init];
     vc.isUnConnected = YES;
     [self.navigationController pushViewController:vc animated:YES];

     */
   
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}



#pragma mark - ==========HYServerDelegate===============

// 有客户端连接
- (void)onServerAcceptNewClient {
    // 跳转白板页面
    [self.view  hideToastActivity];
    NGMVideoController *vc = [[NGMVideoController alloc]init];
    vc.isServer = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (TQConectServerView *)connectView
{
    if (!_connectView) {
        _connectView = [[TQConectServerView alloc]initWithFrame:self.view.bounds];
        __weak typeof(self) weakSelf = self;
        _connectView.hidden = YES;
        _connectView.dismiss = ^{
            weakSelf.connectView.hidden = YES;
        };
        
        _connectView.refreshPort = ^{
            // 刷新端口号
            [[HYServerManager shared] stopListeningPort];
            // 开启会话服务器监听
            [[HYServerManager shared] startServerForListeningUpload:NO successed:^(NSString *ip, int port) {
                weakSelf.connectView.serverLb.text = [NSString stringWithFormat:@"服务器ip: %@ 端口号: %d", ip, port];
            } failed:^(NSError *error) {
                NSLog(@"****HY Error:监听会话端口失败");
                weakSelf.connectView.serverLb.text = error.domain;
            }];
            
            // 开启上传服务器监听
            [[HYServerManager shared] startServerForListeningUpload:YES successed:^(NSString *ip, int port) {
                NSLog(@"HY 上传地址：%@", [NSString stringWithFormat:@"服务器ip: %@ 端口号: %d", ip, port]);
            } failed:^(NSError *error) {
                NSLog(@"****HY Error:监听上传端口失败");
            }];
            
        };
        _connectView.startSettingServer = ^{
           
            [HYServerManager shared].serverDelegate = weakSelf;

            // 开启上传服务器监听
            [[HYServerManager shared] startServerForListeningUpload:YES successed:^(NSString *ip, int port) {
                NSLog(@"HY 上传地址：%@", [NSString stringWithFormat:@"服务器ip: %@ 端口号: %d", ip, port]);
            } failed:^(NSError *error) {
                NSLog(@"****HY Error:监听上传端口失败");
            }];
            
            // 开启服务器监听
            [[HYServerManager shared] startServerForListeningUpload:NO successed:^(NSString *ip, int port) {
                [weakSelf.view showToastWithMessage:@"等待对方进入"];
                weakSelf.connectView.serverLb.text = [NSString stringWithFormat:@"服务器ip: %@ 端口号: %d", ip, port];
            } failed:^(NSError *error) {
                weakSelf.connectView.serverLb.text = error.domain;
            }];
            
           
            
            
        };
        
        
        
        _connectView.startConect = ^(NSArray *strArr){
            [weakSelf.view showToastActivity];
            weakSelf.connectView.loadingLb.text = @"连接中...";

            [[HYConversationManager shared] connectWhiteboardServer:strArr[0] port:[strArr[1] intValue] successed:^(HYSocketService *service) {
                
                [weakSelf.view hideToastActivity];
                // 跳转白板页面
                NGMVideoController *vc = [[NGMVideoController alloc]init];
                vc.isServer = NO;
                [weakSelf.navigationController pushViewController:vc animated:YES];
                weakSelf.connectView.loadingLb.text = @"连接成功";
            } failed:^(NSError *error) {
                [weakSelf.view hideToastActivity];
                weakSelf.connectView.loadingLb.text = error.domain;
            }];
        };
    }
    return _connectView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
