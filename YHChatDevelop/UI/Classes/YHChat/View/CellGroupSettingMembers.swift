//
//  CellGroupSettingMembers.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/6/15.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation
import Kingfisher

/*Note: collectionView高度计算方式
 一些参数：
 kMagin = 10
 item宽度：let itemWidth  = (ScreenWidth - 5 * kMagin)/4
 item高度：let itemHeight = itemWidth + 30
 item行距：kMagin
 item间距：kMagin
 members: 人数 （如果是群主，添加“-”,"+"这两个按钮，非群主就添加“+”按钮）
 btnCount(按钮数量): members+2 或者 members+1
 准备计算：
 现在一行显示4个btn
 行数：rowCount = btnCount/4+floor(btnCount%4/4)
 collectionViewHeight = kMagin + (rowCount-1)*kMagin + rowCount*itemHeight + kMagin
 */

class CellGroupMem:UICollectionViewCell{
    private var imgvGroupowner:UIImageView!
    private var imgvAvatar:UIImageView!
    private var lbName:UILabel!
    fileprivate let kMagin:CGFloat = 10
    var model:CellGroupSettingMembersModel? {
        willSet(newValue){
            if newValue?.isBtnAdd == false ,newValue?.isBtnRemove == false{
                let groupM = newValue?.model
                imgvAvatar.kf.setImage(with:URL(string:(groupM?.avtarUrl)!) , placeholder: UIImage(named: "common_avatar_80px"), options: nil, progressBlock: nil, completionHandler: nil)
                lbName.text = groupM?.userName
                if groupM?.isGroupOwner == true{
                    imgvGroupowner.isHidden = false
                    imgvGroupowner.image = UIImage(named:"chat_groupOwner")
                }else{
                    imgvGroupowner.isHidden = true
                }
            }else if newValue?.isBtnAdd == true{
                imgvAvatar.image = UIImage(named:"chat_group_add")
                lbName.text = nil
                imgvGroupowner.isHidden = true
            }else if newValue?.isBtnRemove == true{
                imgvAvatar.image = UIImage(named:"chat_group_delete")
                lbName.text = nil
                imgvGroupowner.isHidden = true
            }else{
                imgvAvatar.image = UIImage(named: "common_avatar_80px")
                lbName.text = nil
                imgvGroupowner.isHidden = true
            }
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
 
    
    private func _setupUI(){
        imgvAvatar = UIImageView()
        contentView.addSubview(imgvAvatar)
        
        imgvGroupowner = UIImageView()
        contentView.addSubview(imgvGroupowner)
        
        lbName = UILabel()
        lbName.textAlignment = .center
        lbName.textColor = UIColor(red: 179/255.0, green: 179/255.0, blue: 179/255.0, alpha: 1.0)
        lbName.font = UIFont.systemFont(ofSize: 15.0)
        contentView.addSubview(lbName)
        

        
        contentView.backgroundColor = .white
        _layoutUI()
    }
    
    private func _layoutUI(){
        let itemWidth = (ScreenWidth - 5 * kMagin)/4
        imgvGroupowner.snp.makeConstraints { [unowned self](make) in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.left.top.equalTo(self.contentView)
        }
        
        imgvAvatar.snp.makeConstraints { [unowned self](make) in
            make.size.equalTo(CGSize(width: itemWidth, height: itemWidth))
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
        }
        
        lbName.snp.makeConstraints { [unowned self](make) in
            make.top.equalTo(self.imgvAvatar.snp.bottom)
            make.left.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol CellGroupSettingMembersDelegate:class {
    func onMemberAvatar(model:YHGroupMember) //点击头像
    func onInviteMember() //邀请好友到群聊
    func onDeleteMember() //删除群成员
}

class CellGroupSettingMembers : UITableViewCell {
    
    fileprivate var _collectionView:UICollectionView!
    fileprivate let kMagin:CGFloat = 10
    var _isGroupOwer = false
    var dataArray:[CellGroupSettingMembersModel]? {
        willSet(newValue){
            _collectionView.reloadData()
        }
    }
    
    weak var delegate:CellGroupSettingMembersDelegate?
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setupUI(){
        
        let flowLayout = UICollectionViewFlowLayout()
    
        //自动网格布局
        let itemWidth  = (ScreenWidth - 5 * kMagin)/4
        let itemHeight = itemWidth + 30
        //设置单元格大小
        flowLayout.itemSize =  CGSize(width: itemWidth, height: itemHeight)
        //最小行间距(默认为10)
        flowLayout.minimumLineSpacing = kMagin
        //最小item间距（默认为10）
        flowLayout.minimumInteritemSpacing = kMagin
        //设置senction的内边距
        flowLayout.sectionInset = UIEdgeInsetsMake(kMagin, kMagin, kMagin, kMagin)
        //设置UICollectionView的滑动方向
        flowLayout.scrollDirection = .vertical;

        //网格布局
        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        _collectionView.backgroundColor = .white
        _collectionView.showsVerticalScrollIndicator = false
    
        //注册cell
        _collectionView.register(CellGroupMem.classForCoder(), forCellWithReuseIdentifier: CellGroupMem.className())
       
        //设置数据源代理
        _collectionView.dataSource = self
        _collectionView.delegate   = self
        contentView.addSubview(_collectionView)
        
        _layoutUI()
        
    }
    
    private func _layoutUI(){
        _collectionView.snp.makeConstraints { [unowned self](make) in
            make.edges.equalTo(self.contentView)
        }
    }
}

extension CellGroupSettingMembers:UICollectionViewDelegate,UICollectionViewDataSource{
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = dataArray?.count,count > 0{
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellGroupMem.className(), for: indexPath) as! CellGroupMem
       
        if let count = dataArray?.count,count > indexPath.item{
            let model = dataArray?[indexPath.item]
            cell.model = model
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let count = dataArray?.count,count > indexPath.item,let model = dataArray?[indexPath.item]{
            if let groupMember = model.model, model.isBtnRemove == false ,model.isBtnAdd == false{
                delegate?.onMemberAvatar(model: groupMember)
            }else if model.isBtnAdd == true{
                delegate?.onInviteMember()
            }else if model.isBtnRemove == true{
                delegate?.onDeleteMember()
            }
        }
        
    }
}
