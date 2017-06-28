//
//  YHChatDetailVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatDetailVC.h"
#import "YHRefreshTableView.h"
#import "YHChatHeader.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "YHChatModel.h"
#import "YHExpressionKeyboard.h"
#import "YHUserInfo.h"
#import "HHUtils.h"
#import "YHChatHeader.h"
#import "TestData.h"
#import "YHAudioPlayer.h"
#import "YHAudioRecorder.h"
#import "YHVoiceHUD.h"
#import "YHUploadManager.h"
#import "YHChatManager.h"
#import "UIBarButtonItem+Extension.h"
#import "YHChatTextLayout.h"
#import "YHDocumentVC.h"
#import "YHNavigationController.h"
#import "YHWebViewController.h"
#import "YHShootVC.h"
#import "YHUserInfoManager.h"
#import "NetManager+Chat.h"
#import "YHAlertView.h"
#import "YHActionSheet.h"
#import "YHChatDevelop-Swift.h"
#import "NetManager+Profile.h"
#import "SqliteManager.h"

@interface YHChatDetailVC ()<UITableViewDelegate,UITableViewDataSource,YHExpressionKeyboardDelegate,CellChatTextLeftDelegate,CellChatTextRightDelegate,CellChatVoiceLeftDelegate,CellChatVoiceRightDelegate,CellChatImageLeftDelegate,CellChatImageRightDelegate,CellChatBaseDelegate,
CellChatFileLeftDelegate,CellChatFileRightDelegate,YHPhotoPickerDelegate>

//控件
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) YHExpressionKeyboard *keyboard;
@property (nonatomic,strong) YHVoiceHUD *imgvVoiceTips;

//数据
@property (nonatomic,strong) YHChatHelper *chatHelper;
@property (nonatomic,assign) BOOL showCheckBox;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation YHChatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [self initUI];
   
    //设置WebScoket
    NSString *chatUserId = _model.sessionUserId;
    [[YHChatManager sharedInstance] connectToUserID:chatUserId isGroupChat:_model.isGroupChat];
    
    
    WeakSelf
    //接收新消息回调
    [[YHChatManager sharedInstance] receiveNewMsg:^(YHChatModel *model) {
        
        [weakSelf.dataArray addObject:[weakSelf _textLayoutWithChatModel:model]];
        [weakSelf.tableView reloadData];
        [weakSelf.keyboard aboveViewScollToBottom];
    }];
    
    //请求聊天记录
    [self _requestChatLog];
    
}

#pragma mark - Getter
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (YHVoiceHUD *)imgvVoiceTips{
    if (!_imgvVoiceTips) {
        _imgvVoiceTips = [[YHVoiceHUD alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _imgvVoiceTips.center = CGPointMake(self.view.center.x, self.view.center.y-64);
        [self.view addSubview:_imgvVoiceTips];
    }
    return _imgvVoiceTips;
}

#pragma mark - init
- (void)initUI{
    
    self.navigationController.navigationBar.translucent = NO;
    
    //设置导航栏
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];

    //    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"更多" target:self selector:@selector(onMore:) block:^(UIButton *btn) {
    //        btn.titleLabel.font = [UIFont systemFontOfSize:14];
    //        [btn setTitle:@"取消" forState:UIControlStateSelected];
    //        [btn setTitle:@"更多" forState:UIControlStateNormal];
    //    }];
    //
//        self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithImgName:@"common_leftArrow" target:self selector:@selector(onRight:)];
    
    
    self.title = self.model.isGroupChat?[NSString stringWithFormat:@"%@(%lu)",self.model.sessionUserName,(unsigned long)self.model.sessionUserHead.count]: self.model.sessionUserName;
    
    self.view.backgroundColor = RGBCOLOR(239, 236, 236);
    
    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(239, 236, 236);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    //注册Cell
    _chatHelper = [[YHChatHelper alloc ] init];
    [_chatHelper registerCellClassWithTableView:self.tableView];
    
    //表情键盘
    YHExpressionKeyboard *keyboard = [[YHExpressionKeyboard alloc] initWithViewController:self aboveView:self.tableView];
    _keyboard = keyboard;

}

#pragma mark - Private
//YHChatModel布局
- (YHChatModel *)_textLayoutWithChatModel:(YHChatModel *)model{
    CGFloat addFontSize     = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    UIColor *textColor      = [UIColor blackColor];
    UIColor *matchTextColor = UIColorHex(527ead);
    UIColor *matchTextHighlightBGColor = UIColorHex(bfdffe);
    if (model.direction == 0) {
        textColor                 = [UIColor whiteColor];
        matchTextColor            = [UIColor greenColor];
        matchTextHighlightBGColor = [UIColor grayColor];
    }
    if (model.msgType == YHMessageType_Text) {
        YHChatTextLayout *layout = [[YHChatTextLayout alloc] init];
        [layout layoutWithText:model.msgContent fontSize:(14+addFontSize) textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
        model.layout = layout;
    }
    return model;
}

//当前录音文件名字
- (NSString *)_currentRecordFileName
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)timeInterval];
    return fileName;
}

//显示录音时间太短Tips
- (void)_showShortRecordTips{
    WeakSelf
    self.imgvVoiceTips.hidden = NO;
    self.imgvVoiceTips.image  =  [UIImage imageNamed:@"voiceShort"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.imgvVoiceTips.hidden = YES;
    });
}

//消息撤回
- (BOOL)_withdrawMsgWithModel:(YHChatModel *)model{
    if (![_chatHelper msgCanWithdraw:model]){
        [YHAlertView showWithTitle:@"发送时间超过2分钟的消息，不能被撤回。" message:nil cancelButtonTitle:nil otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSUInteger buttonIndex) {
            
        }];
        return NO;
    }
    [[NetManager sharedInstance] putWithDrawMsgWithMsgID:model.chatId complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"消息撤回成功");
        }else{
            DDLog(@"消息撤回失败");
        }
    }];
    return YES;
}


#pragma mark - @protocol CellChatTextLeftDelegate

- (void)tapLeftAvatar:(YHUserInfo *)userInfo{
    DDLog(@"点击左边头像");
}

- (void)retweetMsg:(NSString *)msg inLeftCell:(CellChatTextLeft *)leftCell{
    DDLog(@"转发左边消息:%@",msg);
    DDLog(@"所在的行是:%ld",leftCell.indexPath.row);

}

- (void)onLinkInChatTextLeftCell:(CellChatTextLeft *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol CellChatTextRightDelegate
- (void)tapRightAvatar:(YHUserInfo *)userInfo{
    DDLog(@"点击右边头像,%@",userInfo);
}

- (void)retweetMsg:(NSString *)msg inRightCell:(CellChatTextRight *)rightCell{
    DDLog(@"转发右边消息:%@",msg);
    DDLog(@"所在的行是:%ld",(long)rightCell.indexPath.row);
}

- (void)tapSendMsgFailImg{
    DDLog(@"重发该消息?");
//    [HHUtils showAlertWithTitle:@"重发该消息?" message:nil okTitle:@"重发" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes) {
//        if (resultYes) {
//            DDLog(@"点击重发");
//        }
//    }];
}

- (void)withDrawMsg:(YHChatModel *)msg inRightCell:(CellChatTextRight *)rightCell{
    DDLog(@"撤回消息:\n%@",msg);
    
    if (rightCell.indexPath.row < self.dataArray.count) {
        
        if ([self _withdrawMsgWithModel:msg]) {
            [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
            [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
        }
       
    }
    
}

- (void)onLinkInChatTextRightCell:(CellChatTextRight *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol CellChatImageLeftDelegate

- (void)retweetImage:(UIImage *)image inLeftCell:(CellChatImageLeft *)leftCell{
    DDLog(@"转发图片：%@",image);
}

#pragma mark - @protocol CellChatImageRightDelegate

- (void)retweetImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell{
    DDLog(@"转发图片：%@",image);
}

- (void)withDrawImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell{
    DDLog(@"撤回图片：%@",image);
    
    if (rightCell.indexPath.row < self.dataArray.count) {
        
        YHChatModel *model = self.dataArray[rightCell.indexPath.row];
        
        if ([self _withdrawMsgWithModel:model]){
            [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
            [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    
}


#pragma mark - @protocol CellChatVoiceLeftDelegate
- (void)playInLeftCellWithVoicePath:(NSString *)voicePath{
    DDLog(@"播放:%@",voicePath);

}

- (void)retweetVoice:(NSString *)voicePath inLeftCell:(CellChatVoiceLeft *)leftCell{
    DDLog(@"转发语音:%@",voicePath);
}

#pragma mark - @protocol CellChatVoiceRightDelegate
- (void)playInRightCellWithVoicePath:(NSString *)voicePath{
    DDLog(@"播放:%@",voicePath);

}

//转发语音
- (void)retweetVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell{
    DDLog(@"转发语音:%@",voicePath);
}

//撤回语音
- (void)withDrawVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell{
    DDLog(@"撤回语音:%@",voicePath);
    if (rightCell.indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[rightCell.indexPath.row];
        if ([self _withdrawMsgWithModel:model]) {
            [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
            [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - @protocol CellChatFileLeftDelegate
//点击文件
- (void)onChatFile:(YHFileModel *)chatFile inLeftCell:(CellChatFileLeft *)leftCell{
    if (chatFile.filePathInLocal) {
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal]];
        vc.title = chatFile.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

//转发文件
- (void)retweetFile:(YHFileModel *)chatFile inLeftCell:(CellChatFileLeft *)leftCell{

}

#pragma mark - @protocol CellChatFileRightDelegate
//点击文件
- (void)onChatFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell{
    if (chatFile.filePathInLocal) {
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal]];
        vc.title = chatFile.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

//转发文件
- (void)retweetFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell{

}

//撤回文件
- (void)withDrawFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell{
    if (rightCell.indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[rightCell.indexPath.row];
        if ([self _withdrawMsgWithModel:model]) {
            [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
            [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
        }
    }

}

#pragma mark - @protocol CellChatBaseDelegate
- (void)onCheckBoxAtIndexPath:(NSIndexPath *)indexPath model:(YHChatModel *)model{
    DDLog(@"选择第%ld行的聊天记录",(long)indexPath.row);
}


#pragma mark - @protocol UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_keyboard endEditing];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}


#pragma mark - @protocol UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
        if(model.status == 1){
            //消息撤回
            CellChatTips *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTips class])];
            cell.model = model;
            return cell;
        }else{
            if (model.msgType == YHMessageType_Image){
                if (model.direction == 0) {
                    
                    CellChatImageRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                    
                }else{
                    
                    CellChatImageLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    
                    return cell;
                }
                
            }else if (model.msgType == YHMessageType_Voice){
                
                if (model.direction == 0) {
                    CellChatVoiceRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatVoiceLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
                
            }else if(model.msgType == YHMessageType_Doc){
                if (model.direction == 0) {
                    CellChatFileRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatFileRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatFileLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatFileLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
                
            }else if (model.msgType == YHMessageType_GIF){
                
                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatGIFLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFLeft class])];
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
                
            }else{
                if (model.direction == 0) {
                    CellChatTextRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatTextLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            }

        }
        
        
        
    }
    return [[UITableViewCell alloc] init];
}

#pragma mark - @protocol UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
        return [_chatHelper heightWithModel:model tableView:tableView];
    }
    return 44.0f;
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

}


// 松手时已经静止,只会调用scrollViewDidEndDragging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) { // scrollView已经完全静止
        [self _handleAnimatedImageView];
    }
}

// 松手时还在运动, 先调用scrollViewDidEndDragging,在调用scrollViewDidEndDecelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // scrollView已经完全静止
    [self _handleAnimatedImageView];
}

- (void)_handleAnimatedImageView{
    for (UITableViewCell *visiableCell in self.tableView.visibleCells) {
        if ([visiableCell isKindOfClass:[CellChatGIFLeft class]]) {
             [(CellChatGIFLeft *)visiableCell startAnimating];
        }else if ([visiableCell isKindOfClass:[CellChatGIFRight class]]){
             [(CellChatGIFRight *)visiableCell startAnimating];
        }
    }
}

#pragma mark - @protocol YHExpressionKeyboardDelegate
//发送
- (void)didTapSendBtn:(NSString *)text{
    
    if (text.length) {
        [self _requestSendText:text];
    }
    
}

- (void)didStartRecordingVoice{
    WeakSelf
    self.imgvVoiceTips.hidden = NO;
    [[YHAudioRecorder shareInstanced] startRecordingWithFileName:[self _currentRecordFileName] completion:^(NSError *error) {
        if (error) {
            if (error.code != 122) {
                [YHAlertView showWithTitle:error.localizedDescription message:nil cancelButtonTitle:nil otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSUInteger buttonIndex) {
                    
                }];

            }
        }
    }power:^(float progress) {
        weakSelf.imgvVoiceTips.progress = progress;
    }];
}

- (void)didStopRecordingVoice{
    self.imgvVoiceTips.hidden = YES;
    [self _requestSendVoice];
}

- (void)didDragInside:(BOOL)inside{
    if (inside) {

        [[YHAudioRecorder shareInstanced] resumeUpdateMeters];
        self.imgvVoiceTips.image = [UIImage imageNamed:@"voice_1"];
        self.imgvVoiceTips.hidden = NO;
    }else{

        [[YHAudioRecorder shareInstanced] pauseUpdateMeters];
        self.imgvVoiceTips.image = [UIImage imageNamed:@"cancelVoice"];
        self.imgvVoiceTips.hidden = NO;
    }
}

- (void)didCancelRecordingVoice{
    self.imgvVoiceTips.hidden = YES;
    [[YHAudioRecorder shareInstanced] removeCurrentRecordFile];
}

- (void)didSelectExtraItem:(NSString *)itemName{
    if([itemName isEqualToString:@"照片"]){
        NSArray *arr = @[@"拍照", @"从手机相册选取"];
        YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:arr];
        
        [sheet show];
        [sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
            if (isCancel == NO){

                UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                if (isCancel == false){
                    if (clickedIndex ==  0){
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                    }else{
                        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    }
              
                    [[YHPhotoPicker shareInstance] choosePhotoWithSourceType:sourceType inViewController:self];

                    
                }
            }
           
        }];
        
        
    }else if ([itemName isEqualToString:@"文件"]) {
        WeakSelf
        YHDocumentVC *vc = [[YHDocumentVC alloc] init];
        YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
        [vc didSelectFilesComplete:^(NSArray<YHFileModel *> *files) {
            DDLog(@"准备发送文件。");
            [weakSelf _requestSendOfficeFiles:files];
        }];
        [self.navigationController presentViewController:nav animated:YES completion:NULL];
    }else if([itemName isEqualToString:@"拍摄"]){
         DDLog(@"拍摄");
        YHShootVC *vc = [[YHShootVC alloc] init];
        [self.navigationController presentViewController:vc animated:YES completion:NULL];
    }
}

#pragma mark - YHPhotoPickerDelegate
//选择照片完毕
- (void)didFinishPickingPhotosWithPhotos:(NSArray<UIImage *> *)photos{
    UIImage *compressImage = photos[0];
    [self _requestSendImage:compressImage];
}

#pragma mark - 网络请求

//请求发送文本信息
- (void)_requestSendText:(NSString *)text{
    
    //创建本地文本信息
    YHChatModel *model = [YHChatHelper creatMessage:text msgType:YHMessageType_Text toID:_model.sessionUserId];
    [self.dataArray addObject:model];
    [self.tableView reloadData];
    
    //发送消息
    int chatType = _model.isGroupChat?QChatType_Group:QChatType_Private;
    [[NetManager sharedInstance] postSendChatMsgToReceiverID:_model.sessionUserId msgType:YHMessageType_Text msg:text chatType:chatType complete:^(BOOL success, id obj) {
        if (success) {
            YHChatModel *retObj = obj;
            model.chatId = retObj.chatId;
            DDLog(@"消息发送成功:%@",obj);
        }else{
            DDLog(@"消息发送失败:%@",obj);
        }
    }];

}

//请求发图片消息
- (void)_requestSendImage:(UIImage *)compressImage{
    
    //创建本地图片消息
    YHChatModel *model = [YHChatHelper creatMessage:nil msgType:YHMessageType_Image toID:_model.sessionUserId];
    model.imageMsg = compressImage;
    [self.dataArray addObject:model];
    [self.tableView reloadData];
    [self.keyboard aboveViewScollToBottom];
    
    
    WeakSelf
    [[NetManager sharedInstance] postUploadImage:compressImage complete:^(BOOL success, id obj) {
        
        if (success){
            DDLog(@"上传图片文件成功");
            NSURL *oriUrl = obj;
            NSString *oriUrlStr = oriUrl.absoluteString;
            
            //发送图片消息
            int chatType = weakSelf.model.isGroupChat?QChatType_Group:QChatType_Private;
            [[NetManager sharedInstance] postSendChatMsgToReceiverID:weakSelf.model.sessionUserId msgType:YHMessageType_Image msg:oriUrlStr chatType:chatType complete:^(BOOL success, id obj) {
                if (success) {
                    YHChatModel *retObj = obj;
                    model.chatId = retObj.chatId;
                    DDLog(@"图片消息发送成功:%@",obj);
                }else{
                    DDLog(@"图片消息发送失败:%@",obj);
                }
            }];
            
        }else{
            
        }
        
    } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        
    }];
}

//请求发送语音消息
- (void)_requestSendVoice{
    
    //停止录音
    WeakSelf
    [[YHAudioRecorder shareInstanced] stopRecordingWithCompletion:^(NSString *recordPath) {
        if ([recordPath isEqualToString:shortRecord]) {
            [weakSelf _showShortRecordTips];
        }else{
            DDLog(@"record finish , file path is :\n%@",recordPath);
            
            //创建本地语音消息
            NSString *voiceMsg = [NSString stringWithFormat:@"voice[local://%@]",recordPath];
            YHChatModel *model = [YHChatHelper creatMessage:voiceMsg msgType:YHMessageType_Voice toID:weakSelf.model.sessionUserId];
            [weakSelf.dataArray addObject:model];
            [weakSelf.tableView reloadData];
            [weakSelf.keyboard aboveViewScollToBottom];
            
            //上传语音文件
            [[YHUploadManager sharedInstance] uploadChatRecordWithPath:recordPath complete:^(BOOL success, id obj) {
                if (success) {
                    DDLog(@"上传语音文件成功,%@",obj);
                    
                    //语音文件的url
                    YHAudioModel *retObj = obj;
                    NSString *voiceUrlStr = retObj.url.absoluteString;
                    NSString *voiceMsg = [NSString stringWithFormat:@"voice[%@]",voiceUrlStr];
                    
                    //发送语音消息
                    int chatType = weakSelf.model.isGroupChat?QChatType_Group:QChatType_Private;
                    [[NetManager sharedInstance] postSendChatMsgToReceiverID:weakSelf.model.sessionUserId msgType:YHMessageType_Voice msg:voiceMsg chatType:chatType complete:^(BOOL success, id obj) {
                        if (success) {
                            YHChatModel *retObj = obj;
                            model.chatId = retObj.chatId;
                            DDLog(@"语音消息发送成功:%@",obj);
                        }else{
                            DDLog(@"语音消息发送失败:%@",obj);
                        }
                    }];
                    
                }else{
                    DDLog(@"上传语音文件失败,%@",obj);
                }
            } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
                DDLog(@"bytesWritten:%lld -- totalBytesWritten:%lld",bytesWritten,totalBytesWritten);
            }];
        }
    }];
    
   
}

//请求发送办公文件消息
- (void)_requestSendOfficeFiles:(NSArray <YHFileModel *>*)files{
    WeakSelf
    
    for (YHFileModel *fileModel in files) {
        //创建本地办公文件消息
        NSString *fileName = fileModel.fileName;
        if ([fileName containsString:[NSString stringWithFormat:@".%@",fileModel.ext]]) {
            fileName = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",fileModel.ext] withString:@""];
        }
        NSString *fileMsg = [NSString stringWithFormat:@"file(local://%@)[%@.%@]",fileModel.filePathInLocal,fileName,fileModel.ext];
        YHChatModel *model = [YHChatHelper creatMessage:fileMsg msgType:YHMessageType_Doc toID:weakSelf.model.sessionUserId];
        model.msgContent = fileMsg;
        model.fileModel  = fileModel;
        [weakSelf.dataArray addObject:model];
        
        [[YHUploadManager sharedInstance] uploadOfficeFileWithFileModel:fileModel complete:^(BOOL success, id obj) {
            if (success) {
                YHFileModel  *retModel = obj;
                model.fileModel = retModel;
                
                //发送办公文件信息
                NSString *fileMsg = [NSString stringWithFormat:@"file(%@)[%@.%@]",retModel.filePathInServer,retModel.fileName,retModel.ext];

                int chatType = weakSelf.model.isGroupChat?QChatType_Group:QChatType_Private;
                [[NetManager sharedInstance] postSendChatMsgToReceiverID:weakSelf.model.sessionUserId msgType:YHMessageType_Doc msg:fileMsg chatType:chatType complete:^(BOOL success, id obj) {
                    if (success) {
                        YHChatModel *retObj = obj;
                        model.chatId = retObj.chatId;
                        DDLog(@"办公文件消息发送成功:%@",obj);
                    }else{
                        DDLog(@"办公文件消息发送失败:%@",obj);
                    }
                }];
            }else{
            
            }
        } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
            
        }];
    }
    [weakSelf.tableView reloadData];
    [weakSelf.keyboard aboveViewScollToBottom];
    
   
    
    
}

//获取聊天记录
- (void)_requestChatLog{
    WeakSelf
    QChatType qcType = self.model.isGroupChat?QChatType_Group:QChatType_Private;
    [[NetManager sharedInstance] postFetchChatLogWithType:qcType sessionID:self.model.sessionUserId timestamp:nil  complete:^(BOOL success, id obj) {
        if (success) {
            [weakSelf.dataArray removeAllObjects];
            for (YHChatModel *model in obj) {
                [weakSelf.dataArray addObject:[self _textLayoutWithChatModel:model]];
            }
            //kun调试
            if (weakSelf.dataArray.count > 25) {
                weakSelf.dataArray =  [weakSelf.dataArray subarrayWithRange:NSMakeRange(weakSelf.dataArray.count-25, 25)].mutableCopy;
            }
            [weakSelf.tableView reloadData];
            [weakSelf.keyboard aboveViewScollToBottom:NO];
        }else{
            
        }
    }];
}


#pragma mark - Action
- (void)onMore:(UIButton *)sender{
    sender.selected = !sender.selected;
    _showCheckBox = sender.selected? YES:NO;
    [self.tableView reloadData];
}

- (void)onRight:(id)sender{

}

- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)dealloc{
    [[YHChatManager sharedInstance] close];
    DDLog(@"%s is dealloc",__func__);
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
