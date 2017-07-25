//
//  YHRegisterChooseJobMainViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/9.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHRegisterChooseJobMainViewController.h"
#import "YHRegisterChooseJobFunctionViewController.h"
#import "YHRegisterCompleteInfoViewController.h"
#import "CellForRegister.h"
#import "CellForRegister2.h"
#import "YHChatDevelop-Swift.h"

@interface YHRegisterChooseJobMainViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) CellForRegister *cell;
@property (nonatomic,strong) CellForRegister2 *cell2;
@property (nonatomic,weak) IBOutlet UITableView *tableViewList;

@end

@implementation YHRegisterChooseJobMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (void)setupNavigationBar{
    self.title = @"注册";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
}

- (void)initUI{
  
    [self setupNavigationBar];
    
    //选择行业职能
    _cell   = [CellForRegister cell];
    _cell.textField.placeholder = @"选择行业职能";
    _cell.textField.enabled     = NO;
    _cell.textField.delegate    = self;
    _cell.imgvDownArrow.hidden  = NO;
    _cell.cstBotLineLeading.constant = -15;
    
    //下一步
    _cell2.btnNext.layer.cornerRadius  = 3;
    _cell2.btnNext.layer.masksToBounds = YES;
    
    //2.点击下一步
    __weak typeof(self) weakSelf = self;
    weakSelf.cell2.onNextBlock = ^{
        
        YHRegisterCompleteInfoViewController *vc = [[YHRegisterCompleteInfoViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
        
    };

}

#pragma mark - Lazy Load

- (CellForRegister2 *)cell2{
    if (!_cell2) {
        _cell2 = [CellForRegister2 cell];
    }
    return _cell2;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        YHRegisterChooseJobFunctionViewController *vc = [[YHRegisterChooseJobFunctionViewController alloc] initWithSureToPushNextController:YES];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 44.0f;
    }
    else{
        return 140.f;
    }
    
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        return _cell;
    }
    else{
        return self.cell2;
    
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
}

#pragma mark - Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
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
