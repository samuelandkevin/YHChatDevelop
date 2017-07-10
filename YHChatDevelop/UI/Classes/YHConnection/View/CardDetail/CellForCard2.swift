//
//  CellForCard2.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/5/24.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation

class CellForCard2:UITableViewCell {

    var labelCompany:UILabel!//公司
    var labelJob:UILabel!//职业
    var labelBeginTime:UILabel!//开始时间
    var labelDotLine:UILabel!//“--”虚线
    var labelEndTime:UILabel!//结束时间
    var imgvTimeLineTop:UIImageView!//时间线的顶部
    
    var viewTopLine:UIView!
    var imgvCirle:UIImageView!
    var viewBotLine:UIView!
    
    private let _circleRadius = CGFloat(5)//圆圈半径
    
    var workExpModel:YHWorkExperienceModel?{
        willSet(newValue){
            labelCompany.text   = newValue?.company
            labelJob.text       = newValue?.position
            labelBeginTime.text = newValue?.beginTime
            labelEndTime.text   = newValue?.endTime
        }
    }
    var eduExpModel:YHEducationExperienceModel?{
        willSet(newValue){
            labelCompany.text   = newValue?.school
            labelJob.text       = newValue?.major
            labelBeginTime.text = newValue?.beginTime
            labelEndTime.text   = newValue?.endTime
        }
    }
    
    // MARK: - init 
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    private func _setupUI(){
    
        //圆圈上方竖线
        viewTopLine = UIView()
        viewTopLine.backgroundColor = kBlueColor_Swift
        contentView.addSubview(viewTopLine)
        
        //圆圈
        imgvCirle = UIImageView()
        let beizerPath = UIBezierPath()
        beizerPath.lineWidth = 1
        beizerPath.addArc(withCenter: CGPoint(x:_circleRadius,y:_circleRadius), radius: _circleRadius, startAngle: 0, endAngle: CGFloat((Double.pi)*2), clockwise: true)
        beizerPath.stroke()
        
        let shapLayer  = CAShapeLayer()
        shapLayer.path = beizerPath.cgPath
        shapLayer.fillColor   = UIColor.clear.cgColor
        shapLayer.strokeColor = kBlueColor_Swift.cgColor
        
        imgvCirle.layer.addSublayer(shapLayer)
        contentView.addSubview(imgvCirle)
        
        //圆圈下方竖线
        viewBotLine = UIView()
        viewBotLine.backgroundColor = kBlueColor_Swift
        contentView.addSubview(viewBotLine)
        

        //公司
        labelCompany = UILabel()
        labelCompany.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        labelCompany.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(labelCompany)
        
        //职业
        labelJob = UILabel()
        labelJob.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        labelJob.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(labelJob)
        
        //开始时间
        labelBeginTime = UILabel()
        labelBeginTime.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        labelBeginTime.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(labelBeginTime)
        
        //--
        labelDotLine = UILabel()
        labelDotLine.text = "--"
        labelDotLine.textAlignment = .center
        labelDotLine.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        labelDotLine.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(labelDotLine)
        
        //结束时间
        labelEndTime = UILabel()
        labelEndTime.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        labelEndTime.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(labelEndTime)
        
        
        _layoutUI()
    }
    
    private func _layoutUI(){
    
        viewTopLine.snp.makeConstraints { [unowned self](make) in
            make.top.equalTo(self.contentView)
            make.centerX.equalTo(self.viewBotLine.snp.centerX)
            make.width.equalTo(1)
            make.height.equalTo(14)
            
        }
        
        imgvCirle.snp.makeConstraints { [unowned self](make) in
            make.top.equalTo(self.viewTopLine.snp.bottom)
            make.centerX.equalTo(self.viewBotLine.snp.centerX)
            make.bottom.equalTo(self.viewBotLine.snp.top)
            make.size.equalTo(CGSize(width: 2*self._circleRadius, height: 2*self._circleRadius))
        }
        
        viewBotLine.snp.makeConstraints { [unowned self](make) in
            make.width.equalTo(1)
            make.bottom.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(22)
            
        }
        
        labelCompany.setContentHuggingPriority(249, for: .horizontal)
        labelCompany.setContentCompressionResistancePriority(749, for: .horizontal)

        labelCompany.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.viewBotLine.snp.right).offset(15)
            make.centerY.equalTo(self.imgvCirle.snp.centerY)
        }
        
        labelJob.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.labelCompany.snp.right).offset(30)
            make.right.lessThanOrEqualTo(self.contentView).offset(-10)
            make.centerY.equalTo(self.labelCompany.snp.centerY)
        }
        
        _ = labelBeginTime.contentHuggingPriority(for: .horizontal).advanced(by: 249)
        _ = labelBeginTime.contentCompressionResistancePriority(for: .horizontal).advanced(by: 749)
        
        labelBeginTime.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.labelCompany.snp.left)
            make.top.equalTo(self.labelCompany.snp.bottom).offset(15)
        }
        
    
        labelDotLine.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.labelBeginTime.snp.right)
            make.centerY.equalTo(self.labelBeginTime.snp.centerY)
            make.width.equalTo(23)
        }
        
        labelEndTime.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.labelDotLine.snp.right)
            make.centerY.equalTo(self.labelDotLine.snp.centerY)
            make.right.lessThanOrEqualTo(self.contentView)
        }
        
    
        
        
    }
    
    
}
