//
//  YHConnectionSearchView.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/31.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHConnectionSearchView.h"
#import "CellForMyFans.h"
#import "Masonry.h"

@interface YHConnectionSearchView ()
<UITableViewDelegate,UITableViewDataSource>

@end

@implementation YHConnectionSearchView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setup];
    }
    return self;
}

- (void)setup{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate   = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight  = 60.0f;
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CellForMyFans class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CellForMyFans class])];
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


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectRowAtIndexPath:userInfo:)] && (indexPath.row <self.dataArray.count)) {
        [_delegate didSelectRowAtIndexPath:indexPath userInfo:self.dataArray[indexPath.row]];
    }
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CellForMyFans *cell = [CellForMyFans cellWithTableView:tableView];
    [cell resetCell];
    if (indexPath.row < self.dataArray.count) {
        cell.userInfo = [self.dataArray objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
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
