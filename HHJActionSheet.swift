//
//  HHJActionSheet.swift
//  Sugram
//
//  Created by bu88 on 2018/9/5.
//  Copyright © 2018年 gossip. All rights reserved.
//

/**
 仿微信自定义的UIActioSheet
 */

import UIKit

public class HHJActionSheet: UIView {

    // MARK: --------Public
    /// 初始一个仿微信的ActionSheet，页面中最终有且仅有一个ActionSheet，如果在创建了一个ActionSheet后再创建一个，则会放回前面创建那个
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - cancelTitle: 取消按钮的标题
    ///   - destructiveTitle: 破坏性按钮标题（红色字体）
    ///   - otherTitles: 普通选项按钮标题
    ///   - view: actionSheet放在哪个View上面，如果传nil，则放在keyWindow
    ///   - handle: 点击回调事件
    /// - Returns: 创建的ActionSheet实例
    @objc public class func showActionSheetWithTitle(_ title: String?, cancelTitle: String?, destructiveTitle: String?, otherTitles: [String]?, in view: UIView?, handle: @escaping (Int) -> Void) -> HHJActionSheet {
        //创建自身并设置样式
        if let actionSheet = self.staticActionSheet {
            return actionSheet
        }
        
        let actionSheet = HHJActionSheet(frame: UIScreen.main.bounds)
        actionSheet.didClickBlock = handle
        actionSheet.addGestureRecognizer(UITapGestureRecognizer(target: actionSheet, action: #selector(HHJActionSheet.hideWithAnimaiton)))
        actionSheet.backgroundColor = UIColor.clear
        if let superView = view {
            superView.addSubview(actionSheet)
        } else {
            if let window = UIApplication.shared.keyWindow {
                window.addSubview(actionSheet)
            }
        }
        let buryView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        actionSheet.titleView.addSubview(buryView)
        
        var subViewHeight:CGFloat = 0.0
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let kTitleLabelHorGap:CGFloat = 20
        //开始创建子控件
        if let titleString = title, !titleString.isEmpty {
            let titleLabel = UILabel(frame: CGRect(x: kTitleLabelHorGap, y: 0, width: screenWidth-kTitleLabelHorGap*2, height: 0))
            titleLabel.numberOfLines = 0
            titleLabel.textColor = UIColor.gray
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.textAlignment = .center
            titleLabel.text = titleString
            titleLabel.sizeToFit()
            
            let labelView = UIView(frame: CGRect(x: 0, y: subViewHeight, width: screenWidth, height: max(actionSheet.kTitleLabelMinHeight,titleLabel.bounds.size.height + 40)))
            labelView.backgroundColor = UIColor.white
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: titleLabel.bounds.size.width, height: labelView.bounds.size.height)
            
            actionSheet.titleView.addSubview(labelView)
            labelView.addSubview(titleLabel)
            addBottomLineIn(labelView)
            
            subViewHeight = labelView.frame.maxY
        }
        var destructiveButtonTag = 1
        if let otherButtonTitles = otherTitles, !otherButtonTitles.isEmpty {
            for (index, buttonTitle) in otherButtonTitles.enumerated() {
                let buttonView = actionSheet.buttonViewWithTitle(buttonTitle, buttonY: subViewHeight, titleColor: UIColor.black, tag: index+1)
                subViewHeight = buttonView.frame.maxY
                actionSheet.titleView.addSubview(buttonView)
                if index < otherButtonTitles.count-1 {
                    addBottomLineIn(buttonView)
                } else if let destructiveButtonTitle = destructiveTitle, !destructiveButtonTitle.isEmpty {
                    addBottomLineIn(buttonView)
                }
            }
            destructiveButtonTag = otherButtonTitles.count + 1
        }
        
        if let destructiveButtonTitle = destructiveTitle, !destructiveButtonTitle.isEmpty {
            let buttonView = actionSheet.buttonViewWithTitle(destructiveButtonTitle, buttonY: subViewHeight, titleColor: UIColor.red, tag: destructiveButtonTag)
            actionSheet.titleView.addSubview(buttonView)
            subViewHeight = buttonView.frame.maxY
        }
        
        if let cancelButtonTitle = cancelTitle, !cancelButtonTitle.isEmpty {
            let buttonView = actionSheet.buttonViewWithTitle(cancelButtonTitle, buttonY: subViewHeight+6, titleColor: UIColor.black, tag: 0)
            actionSheet.titleView.addSubview(buttonView)
            subViewHeight = buttonView.frame.maxY
        }
        
        actionSheet.titleView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: subViewHeight)
        actionSheet.addSubview(actionSheet.titleView)
        buryView.frame = actionSheet.titleView.bounds
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions(rawValue: 7), animations: {
            actionSheet.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            actionSheet.titleView.frame = CGRect(x: actionSheet.titleView.frame.origin.x, y: screenHeight-actionSheet.titleView.bounds.size.height, width: actionSheet.titleView.bounds.size.width, height: actionSheet.titleView.bounds.size.height)
        }) { (finish) in
            
        }
        self.staticActionSheet = actionSheet
        return actionSheet
    }
    
    /// 关掉actionSheet
    ///
    /// - Parameters:
    ///   - index: 关掉actionSheet响应按钮按钮的时间，效果同用户选择
    ///   - animated: 是否需要动画
    @objc public func dismissWithButtonIndex(_ index:Int, animated: Bool) {
        didClickBlock(index)
        if animated {
            hideWithAnimaiton()
        } else {
            hideWithoutAnimaiton()
        }
    }
    
    // MARK: --------Private
    static weak var staticActionSheet: HHJActionSheet? = nil
    let kTitleLabelMinHeight:CGFloat = 54
    let titleView = UIView()
    var didClickBlock: ((Int) -> Void)!
    
    // MARK: --------UIView
    class func addBottomLineIn(_ view: UIView) {
        let lineViewHeight = 1/UIScreen.main.scale
        let lineView = UIView(frame: CGRect(x: 0, y: view.frame.maxY-lineViewHeight, width: view.bounds.size.width, height: lineViewHeight))
        lineView.backgroundColor = UIColor(white: 217/255, alpha: 1)
        view.addSubview(lineView)
    }
    
    func buttonViewWithTitle(_ title: String, buttonY: CGFloat, titleColor: UIColor, tag:Int) -> UIView {
        let buttonView = UIView(frame: CGRect(x: 0, y: buttonY, width: UIScreen.main.bounds.width, height: kTitleLabelMinHeight))
        buttonView.backgroundColor = UIColor.white
        let button = UIButton(type: .custom)
        button.frame = buttonView.bounds
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        buttonView.addSubview(button)
        button.addTarget(self, action: #selector(HHJActionSheet.buttonClick(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(HHJActionSheet.buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(HHJActionSheet.buttonDragOut(_:)), for: .touchDragOutside)
        button.addTarget(self, action: #selector(HHJActionSheet.buttonTouchDown(_:)), for: .touchDragInside)
        return buttonView
    }

    // MARK: --------Action
    @objc func buttonClick(_ button: UIButton) {
        buttonDragOut(button)
        dismissWithButtonIndex(button.tag, animated: true)
    }
    
    @objc func buttonTouchDown(_ button: UIButton) {
        if let superView = button.superview {
            superView.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        }
    }
    
    @objc func buttonDragOut(_ button: UIButton) {
        if let superView = button.superview {
            superView.backgroundColor = UIColor.white
        }
    }
    
    // MARK: --------hide
    @objc func hideWithAnimaiton() {
        hideWith(duration: 0.25)
    }
    
    func hideWithoutAnimaiton() {
        hideWith(duration: 0)
    }
    
    func hideWith(duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: 7), animations: {
            self.backgroundColor = UIColor.clear
            self.titleView.frame = CGRect(x: self.titleView.frame.origin.x, y: UIScreen.main.bounds.size.height, width: self.titleView.frame.size.width, height: self.titleView.frame.size.height)
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
}
