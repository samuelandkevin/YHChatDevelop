//
//  SearchFriView.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHSearchFriView.h"
#import "CellForMyFri.h"
#import "Masonry.h"

@interface YHSearchFriView()<UITableViewDelegate,UITableViewDataSource,CellForMyFriDelegate>

@end

@implementation YHSearchFriView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return  self;
}

- (void)setUp{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 60.0f;
    [tableView registerClass:[CellForMyFri class] forCellReuseIdentifier:NSStringFromClass([CellForMyFri class])];
    tableView.backgroundColor = kTbvBGColor;
    [self addSubview:tableView];
    _tableView = tableView;
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(weakSelf);
    }];
}

#pragma mark - Lazy Load
- (NSMutableArray<YHUserInfo *> *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CellForMyFri *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForMyFri class])];
    if (indexPath.row < self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
        cell.delegate = self;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

#pragma mark - CellForMyFriDelegate
- (void)didSelectOneFriend:(BOOL)didSel inCell:(CellForMyFri *)cell{
   
    if(didSel){
         cell.model.likeCount = 1;
    }else{
         cell.model.likeCount = 0;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelSearchFri:userArray:)]) {
        [_delegate didSelSearchFri:didSel userArray:@[cell.model]];
    }

}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging)]) {
        [_delegate scrollViewWillBeginDragging];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
