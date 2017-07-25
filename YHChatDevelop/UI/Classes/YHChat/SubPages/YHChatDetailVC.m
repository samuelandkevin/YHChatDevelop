//
//  YHChatDetailVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatDetailVC.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "YHChatModel.h"
#import "YHUserInfo.h"
#import "HHUtils.h"
#import "YHChatHeader.h"
#import "TestData.h"
#import "YHAudioPlayer.h"
#import "YHAudioRecorder.h"
#import "YHUploadManager.h"
#import "YHChatManager.h"
#import "UIBarButtonItem+Extension.h"
#import "YHChatTextLayout.h"
#import "YHDocumentVC.h"
#import "YHNavigationController.h"
#import "YHWebViewController.h"
#import "YHShootVC.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
#import "YHActionSheet.h"
#import "YHChatDevelop-Swift.h"
#import "YHSqliteManager.h"
#import "CardDetailViewController.h"

@interface YHChatDetailVC ()<UITableViewDelegate,UITableViewDataSource,YHExpressionKeyboardDelegate,CellChatTextLeftDelegate,CellChatTextRightDelegate,CellChatVoiceLeftDelegate,CellChatVoiceRightDelegate,CellChatImageLeftDelegate,CellChatImageRightDelegate,CellChatBaseDelegate,
    CellChatFileLeftDelegate,CellChatFileRightDelegate,
    CellChatCheckinLeftDelegate,CellChatCheckinRightDelegate,
    YHPhotoPickerDelegate,YHChatTableViewDelegate>{
    int  _currentRequestPage;  //当前请求页面
    BOOL _noMoreDataInDB;      //数据库无更多数据
    YHChatModel *_lastDataInDB;//上一条在数据库的聊天记录
}
@property (nonatomic,assign)DBChatType dbChatType;
@property (nonatomic,copy)  NSString *sessionID;
@property (nonatomic,assign)BOOL isFirstEntered;

@end

@implementation YHChatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    //数据初始化
    _dbChatType = self.model.isGroupChat? DBChatType_Group:DBChatType_Private;
    _sessionID  = self.model.sessionUserId;
    _isFirstEntered = YES;
    
    //初始化UI
    [self initUI];
    
    //设置表情键盘
    [self setupExpKeyBoard];
    
    //设置消息
    [self setupMsg];
    
    //本地加载聊天记录
    WeakSelf
    [self loadChatLogFromCacheComplete:^(BOOL success, id obj) {
        [weakSelf.keyboard aboveViewScollToBottom:NO];
    }];
    
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

   
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithImgName:@"common_user" target:self selector:@selector(onRight:)];
    
    
    self.title = self.model.isGroupChat?[NSString stringWithFormat:@"%@(%lu)",self.model.sessionUserName,(unsigned long)self.model.sessionUserHead.count]: self.model.sessionUserName;
    
    self.view.backgroundColor = RGBCOLOR(239, 236, 236);
    
    //tableview
    self.tableView = [[YHChatTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(239, 236, 236);
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
   
    //注册Cell
    _chatHelper = [[YHChatHelper alloc ] init];
    [_chatHelper registerCellClassWithTableView:self.tableView];
    
}

#pragma mark - Public Method

//表情键盘
- (void)setupExpKeyBoard{
    YHExpressionKeyboard *keyboard = [[YHExpressionKeyboard alloc] initWithViewController:self aboveView:self.tableView];
    _keyboard = keyboard;
}

//设置信息
- (void)setupMsg{
    //设置WebScoket
    NSString *chatUserId = _model.sessionUserId;
    [[YHChatManager sharedInstance] connectToUserID:chatUserId isGroupChat:_model.isGroupChat];
    
    WeakSelf
    //接收新消息回调
    [[YHChatManager sharedInstance] receiveNewMsg:^(YHChatModel *model) {
        //更新UI
        model.layout = [model textLayout];
        [weakSelf.dataArray addObject:model];
        [weakSelf.tableView reloadData];
        [weakSelf.keyboard aboveViewScollToBottom];
        
        //写入数据库
        [[SqliteManager sharedInstance] updateOneChatLogWithType:weakSelf.dbChatType sessionID:weakSelf.sessionID aChatLog:model updateItems:nil complete:^(BOOL success, id obj) {
            if (success) {
                DDLog(@"新消息写入数据库成功,%@",obj);
            }else{
                DDLog(@"新消息写入数据库失败,%@",obj);
            }
        }];
    }];
    
}

//从缓存加载聊天记录
- (void)loadChatLogFromCacheComplete:(void(^)(BOOL success, id obj))complete{
    [self _loadFromDBWithLastChatLog:_lastDataInDB complete:^(BOOL success, id obj) {
        if (complete) {
            complete(success,obj);
        }
    }];
}


#pragma mark - Private Method
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
        [YHAlertView showWithTitle:@"发送时间超过2分钟的消息，不能被撤回。" message:nil cancelButtonTitle:nil otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            
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

#pragma mark - @protocol CellChatCheckinLeftDelegate
- (void)retweetImage:(UIImage *)image inLeftCheckinCell:(CellChatCheckinLeft *)leftCheckinCell{

}

#pragma mark - @protocol CellChatCheckinRightDelegate
- (void)retweetImage:(UIImage *)image inRightCheckinCell:(CellChatCheckinRight *)rightCheckinCell{

}

- (void)withDrawImage:(UIImage *)image inRightCheckinCell:(CellChatCheckinRight *)rightCheckinCell{

}


#pragma mark - @protocol CellChatTextLeftDelegate

- (void)tapLeftAvatar:(YHUserInfo *)userInfo{
    DDLog(@"点击左边头像");
    CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
    vc.model = _model;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)retweetMsg:(NSString *)msg inLeftCell:(CellChatTextLeft *)leftCell{
    DDLog(@"转发左边消息:%@",msg);
    DDLog(@"所在的行是:%ld",leftCell.indexPath.row);

}

- (void)onLinkInChatTextLeftCell:(CellChatTextLeft *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText] loadCache:NO];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol CellChatTextRightDelegate
- (void)tapRightAvatar:(YHUserInfo *)userInfo{
    DDLog(@"点击右边头像,%@",userInfo);
    CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
    vc.model = _model;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText] loadCache:NO];
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
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal] loadCache:NO];
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
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal] loadCache:NO];
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
            cell.baseDelegate = self;
            cell.indexPath    = indexPath;
            cell.showCheckBox = _showCheckBox;
            [cell setupModel:model];
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
                
            }else if(model.msgType == YHMessageType_Checkin){
            
                if (model.direction == 0) {
                    CellChatCheckinRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatCheckinRight class])];
                    cell.delegate     = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatCheckinLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatCheckinLeft class])];
                    cell.delegate     = self;
                    cell.baseDelegate = self;
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
                [YHAlertView showWithTitle:error.localizedDescription message:nil cancelButtonTitle:nil otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                    
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

#pragma mark - YHChatTableViewDelegate
- (void)loadMoreData{
    if (_noMoreDataInDB && !self.dataArray.count) {
        [self _requestChatLogsFromNetWithLastChatLogModel:_lastDataInDB];
    }else{
        [self _loadFromDBWithLastChatLog:_lastDataInDB complete:^(BOOL success, id obj) {
        }];
    }
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


//从数据库加载聊天记录 lastChatLog:上一条聊天记录
- (void)_loadFromDBWithLastChatLog:(YHChatModel *)lastChatLog complete:(NetManagerCallback)complete{
    

    if (_noMoreDataInDB) {
        [self.tableView setNoMoreData];
        return;
    }
 
    WeakSelf
    [[SqliteManager sharedInstance] queryChatLogTableWithType:_dbChatType sessionID:_sessionID lastChatLog:lastChatLog length:lengthForEveryRequest complete:^(BOOL success, id obj) {
        [weakSelf.tableView loadFinish];
        
        if (success) {
            NSArray *cacheList = obj;
            if (cacheList.count) {
                
                
                [weakSelf.dataArray insertObjects:cacheList atIndex:0];
                
                if (cacheList.count < lengthForEveryRequest) {
                    //数据库无更多数据
                    _noMoreDataInDB = YES;
                    [weakSelf.tableView setNoMoreData];
                }else{
                    //数据库还有更多
                    _noMoreDataInDB = NO;
                }
                
                //获取当前页
                _lastDataInDB        = cacheList.firstObject;
                _currentRequestPage  = _lastDataInDB.curReqPage;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];

                    if (complete) {
                        complete(YES,nil);
                    }
                });
                [weakSelf _requestUpdateChatLogsFromNetWithLastChatLogInDB:cacheList.lastObject];
            }else{
                _noMoreDataInDB = YES;
                [weakSelf _requestChatLogsFromNetWithLastChatLogModel:_lastDataInDB];
                if (complete) {
                    complete(NO,nil);
                }
            }
        }else{
            DDLog(@"%@",obj);
            if (complete) {
                complete(NO,nil);
            }
        }
        
    }];
    
}

//第一次进入此控制器,去请求最新的聊天记录,更新数据库
- (void)_requestUpdateChatLogsFromNetWithLastChatLogInDB:(YHChatModel *)lastChatLogInDB{
    if (!lastChatLogInDB || !_isFirstEntered) {
        return;
    }
    _isFirstEntered = NO;
    WeakSelf
    QChatType qcType = weakSelf.model.isGroupChat?QChatType_Group:QChatType_Private;
    [[NetManager sharedInstance] postFetchChatLogWithType:qcType sessionID:_sessionID fromOldChatLog:lastChatLogInDB toNewChatLog:nil complete:^(BOOL success, id obj) {
        if (success) {
            NSArray *retArr = obj;
            if (retArr.count){
                NSMutableArray *arrToDB = [NSMutableArray new];
                for (int i =0 ;i< retArr.count; i++ ){
                    int totalcount = (int)weakSelf.dataArray.count;
                    int curReqPage = (totalcount-1+i)/lengthForEveryRequest;
                    YHChatModel *model = retArr[i];
                    model.curReqPage   = curReqPage;
                    model.layout = [model textLayout];
                    [weakSelf.dataArray addObject:model];
                    [arrToDB addObject:model];
                }
                
                [weakSelf.tableView reloadData];
                [weakSelf.keyboard aboveViewScollToBottom:NO];
                
                //插入数据到数据库
                [weakSelf _updateChatLogsWithArr:arrToDB];
            }
            
        }else{
            DDLog(@"%@",obj);
        }
    }];

}


//从服务器加载聊天记录,lastChatLogModel:上一次加载的最后一条聊天记录
- (void)_requestChatLogsFromNetWithLastChatLogModel:(YHChatModel *)lastChatLogModel{
    
    QChatType qcType = self.model.isGroupChat?QChatType_Group:QChatType_Private;
    WeakSelf
    [[NetManager sharedInstance] postFetchChatLogWithType:qcType sessionID:self.model.sessionUserId timestamp:lastChatLogModel.createTime  complete:^(BOOL success, id obj) {
        [weakSelf.tableView loadFinish];
        if (success) {
            NSArray *retArr = obj;
            if (retArr.count){
                [weakSelf.dataArray removeAllObjects];
                for (int i =0 ;i< retArr.count; i++ ){
                    int curReqPage = i/lengthForEveryRequest;
                    YHChatModel *model = retArr[i];
                    model.curReqPage   = curReqPage;
                    model.layout = [model textLayout];
                    [weakSelf.dataArray addObject:model];
                }
                
                [weakSelf.tableView reloadData];
                [weakSelf.keyboard aboveViewScollToBottom:NO];
                [weakSelf _updateChatLogsWithArr:weakSelf.dataArray];
            }
            
        }else{
            postTips(obj, @"获取聊天记录失败");
        }
    }];
}

//更新聊天数据
- (void)_updateChatLogsWithArr:(NSArray<YHChatModel *> *)arr{
    if (!arr.count) {
        return;
    }
    DBChatType type = self.model.isGroupChat?DBChatType_Group:DBChatType_Private;
    [[SqliteManager sharedInstance] updateChatLogWithType:type sessionID:self.model.sessionUserId chatLogList:arr complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"%@",obj);
        }else{
            DDLog(@"%@",obj);
        }
    }];
}


#pragma mark - Action
- (void)onRight:(id)sender{
    if (_model.isGroupChat){
        YHGroupSetting *vc = [[YHGroupSetting alloc] init];
        vc.groupID = _model.sessionUserId;
        vc.model   = _model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserId:_model.sessionUserId];
        vc.model = _model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)dealloc{
    [[YHChatManager sharedInstance] close];
    DDLog(@"%s is dealloc",__func__);
}

- (void)viewWillAppear:(BOOL)animated{
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [super viewWillDisappear:animated];
    
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
