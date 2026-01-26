//
//  CollectionViewDemoViewController.m
//  UIexam
//
//  Created by zjs on 2026/1/26.
//

#import "CollectionViewDemoViewController.h"
#import "CustomCollectionViewCell.h"

@interface CollectionViewDemoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSString *> *dataArray;

@end

@implementation CollectionViewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UICollectionView示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupCollectionView];
    [self loadData];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 130);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"CustomCell"];
    
    [self.view addSubview:self.collectionView];
}

- (void)loadData {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 50; i++) {
        [array addObject:[NSString stringWithFormat:@"Item %ld", (long)i]];
    }
    self.dataArray = array;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomCell" forIndexPath:indexPath];
    NSString *title = self.dataArray[indexPath.item];
    [cell configureWithTitle:title];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了Item: %ld", (long)indexPath.item);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 可以根据不同Item返回不同大小
    return CGSizeMake(100, 130);
}

@end
