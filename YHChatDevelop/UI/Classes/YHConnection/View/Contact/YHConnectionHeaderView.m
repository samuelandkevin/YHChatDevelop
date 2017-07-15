//
//  YHConnectionHeaderView.m
//  PikeWay
//
//  Created by YHIOS002 on 16/10/31.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHConnectionHeaderView.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

@interface YHConnectionHeaderView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy) void (^block)(NSIndexPath *indexPath);
@end

@implementation YHConnectionHeaderView

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
    tableView.rowHeight  = 44.0f;
    [tableView registerClass:[CellForContact class] forCellReuseIdentifier:NSStringFromClass([CellForContact class])];
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
    
    WeakSelf
    CellForContact *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell startAnimation:^(BOOL finished) {
        if (weakSelf.block) {
            weakSelf.block(indexPath);
        }
    }];
    
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

   CellForContact *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForContact class])];
    if (indexPath.row < self.itemNameArray.count) {
        cell.labelTitle.text = self.itemNameArray[indexPath.row];
        
    }
    if (indexPath.row < self.iconNameArray.count){
        cell.imgvIcon.image = [UIImage imageNamed:self.iconNameArray[indexPath.row]];
    }
    if (indexPath.row < self.unReadMsgArray.count) {
        int unReadMsgCount = [self.unReadMsgArray[indexPath.row] intValue];
        [cell setBadgeWith:unReadMsgCount];

    }else{
        cell.labelCount.hidden = YES;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemNameArray.count;
}


#pragma mark - Public
- (void)didSelectRowHandler:(void(^)(NSIndexPath *indexPath))handler{
    _block = handler;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
