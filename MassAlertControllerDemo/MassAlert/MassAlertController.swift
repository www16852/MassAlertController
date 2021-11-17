//
//  MassAlertController.swift
//  MassAlertControllerDemo
//
//  Created by cm0673 on 2021/11/17.
//

import UIKit

/// 物件鎖
fileprivate struct ArcLock {
    var object: AnyObject
}

/// 大眾客製化AlertController
@available(iOS 11.0, *)
public class MassAlertController {
    
    public static var defaultParentVC: () -> (UIViewController?) = {nil}
    public static var defaultStyle: MassAlertStyle?
    
    private var contentView: UIView?
    private var alertView: MassAlertView?
    
    private var arcLock: ArcLock?
    private var style: MassAlertStyle
    private var context: Context
    public var actions: [MassAlertAction] = []
    
    public init(title: String?, message: String?, image: UIImage?, order: [ContentOrder]? = nil) {
        style = MassAlertController.defaultStyle ?? MassAlertStyle()
        context = .init(title: title, message: message, image: image)
        if let order = order {
            context.order = order
        }
    }
    
    deinit {print("[Deinit] MassAlertController")}
    
    public func addAction(_ action: MassAlertAction) {
        actions.append(action)
    }
    
    public func show() {
        arcLock = .init(object: self)
        let vc = MassAlertController.defaultParentVC() ?? UIViewController()
        let bounds = vc.view.bounds
        let contentView = UIView(frame: bounds)
        self.contentView = contentView
        vc.view.addSubview(contentView)
        
        setupBgView()
        setupMassAlertView()

    }
    
    private func setupBgView() {
        guard let contentView = self.contentView else {
            return
        }
        let bgView = UIView(frame: contentView.bounds)
        contentView.addSubview(bgView)
        bgView.backgroundColor = .init(white: 0, alpha: 0.6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(bgViewTap))
        bgView.addGestureRecognizer(tap)
        bgView.alpha = 0
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            bgView.alpha = 1
        }, completion: nil)
    }
    
    private func setupMassAlertView() {
        guard let contentView = self.contentView else {
            return
        }
        
        let alert = MassAlertView(target: self, style: style, context: context, actions: actions)
        self.alertView = alert
        alert.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(alert)
        alert.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        alert.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        alert.widthAnchor.constraint(equalToConstant: 292).isActive = true
        
        let constraint = alert.heightAnchor.constraint(equalToConstant: 183)
        constraint.priority = .init(rawValue: 200)
        constraint.isActive = true
        alert.heightAnchor.constraint(greaterThanOrEqualToConstant: 183).isActive = true
        alert.heightAnchor.constraint(lessThanOrEqualToConstant: 561).isActive = true

        alert.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            alert.transform = .identity
        }, completion: nil)
    }
    
    @objc
    private func bgViewTap() {
        removeViewAndPointRecycle()
    }
    
    @objc
    func btnAction(_ btn: UIButton) {
        if actions.indices.contains(btn.tag) {
            actions[btn.tag].action()
        }
        removeViewAndPointRecycle()
    }
    
    private func removeViewAndPointRecycle() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            self.contentView?.alpha = 0
        }, completion: {_ in
            self.contentView?.removeFromSuperview()
        })
        
        arcLock = nil
        actions = []
    }
    
    struct Context {
        var title: String?
        var message: String?
        var image: UIImage?
        var order: [ContentOrder] = [.title, .message, .image]
    }
    
    public enum ContentOrder {
        case title
        case message
        case image
    }
    
}

/// 大眾客製化AlertView
@available(iOS 11.0, *)
class MassAlertView: UIView {
    
    private lazy var contentView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.distribution = .fill
        return v
    }()
    
    private(set) var buttonView: MassAlertButtonView?
    
    private var style: MassAlertStyle
    
    init(target: Any?, style: MassAlertStyle, context: MassAlertController.Context, actions: [MassAlertAction]) {
        self.style = style
        super.init(frame: .zero)
        backgroundColor = style.alertBgColor
        layer.cornerRadius = 8
        setupSubView(target: target, context: context, actions: actions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubView(target: Any?, context: MassAlertController.Context, actions: [MassAlertAction]) {
        setupStack()
        addGap(20)
        addContentView(context: context)
        addBuffer(32)
        addAlertButton(target: target, actions: actions)
        addGap(12)
    }
    
    private func setupStack() {
        addSubview(contentView)
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func addContentView(context: MassAlertController.Context) {
        let alertContent = MassAlertContentView(context: context)
        contentView.addArrangedSubview(alertContent)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    private func addAlertButton(target: Any?, actions: [MassAlertAction]) {
        let view = MassAlertButtonView(target: target, style: style, actions: actions)
        self.buttonView = view
        contentView.addArrangedSubview(view)
    }
    
    private func addBuffer(_ h: CGFloat) {
        let view = UIView(frame: .init(x: 0, y: 0, width: 5, height: h))
        contentView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        let c = view.heightAnchor.constraint(equalToConstant: 32)
        c.priority = .init(rawValue: 900)
        c.isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: h).isActive = true
    }
    
    private func addGap(_ h: CGFloat) {
        let view = UIView(frame: .init(x: 0, y: 0, width: 5, height: h))
        contentView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: h).isActive = true
    }
    
}

/// 大眾客製化AlertContentView
@available(iOS 11.0, *)
class MassAlertContentView: UIView {
    
    private lazy var scollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.showsHorizontalScrollIndicator = false
        v.bounces = false
        return v
    }()
    
    private lazy var contentView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.distribution = .fill
        return v
    }()
    
    init(context: MassAlertController.Context) {
        super.init(frame: .zero)
        setupSubView(context: context)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubView(context: MassAlertController.Context) {
        addScrollView()
        var firstCell = true
        for order in context.order {
            switch order {
            case .title:
                guard let title = context.title else {continue}
                if firstCell == false {addGap(16)}
                addTitleLabel(title: title)
            case .message:
                guard let msg = context.message else {continue}
                if firstCell == false {addGap(16)}
                addMsgTextView(message: msg)
            case .image:
                guard let image = context.image else {continue}
                if firstCell == false {addGap(16)}
                addImageView(image: image)
            }
            firstCell = false
        }
    }

    private func addScrollView() {
        addSubview(scollView)
        scollView.addSubview(contentView)
        
        var constraint: NSLayoutConstraint
        scollView.frameLayoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scollView.frameLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scollView.frameLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        constraint = scollView.frameLayoutGuide.heightAnchor.constraint(equalTo: scollView.contentLayoutGuide.heightAnchor)
        constraint.priority = .init(rawValue: 900)
        constraint.isActive = true
        scollView.frameLayoutGuide.heightAnchor.constraint(lessThanOrEqualTo: scollView.contentLayoutGuide.heightAnchor).isActive = true
        scollView.frameLayoutGuide.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        scollView.contentLayoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scollView.contentLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scollView.contentLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scollView.contentLayoutGuide.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scollView.contentLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func addBuffer(_ h: CGFloat) {
        let view = UIView(frame: .init(x: 0, y: 0, width: 5, height: h))
        contentView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        let c = view.heightAnchor.constraint(equalToConstant: 32)
        c.priority = .init(rawValue: 900)
        c.isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: h).isActive = true
    }
    
    private func addGap(_ h: CGFloat) {
        let view = UIView(frame: .init(x: 0, y: 0, width: 5, height: h))
        contentView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: h).isActive = true
    }
    
    private func addImageView(image: UIImage) {
        let imageView = UIImageView()
        contentView.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor).isActive = true
        let ratio = image.size.width / image.size.height
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: ratio).isActive = true
        imageView.setContentHuggingPriority(.init(1000), for: .vertical)
        imageView.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
    }
    
    private func addTitleLabel(title: String) {
        let view = UIView()
        contentView.addArrangedSubview(view)
        let label = UILabel()
        view.addSubview(label)

        view.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.init(rawValue: 1000), for: .vertical)
        label.setContentCompressionResistancePriority(.init(rawValue: 1000), for: .vertical)
        label.text = title
    }
    
    private func addMsgTextView(message: String) {
        let view = UIView()
        contentView.addArrangedSubview(view)
        let textView = UITextView()
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        textView.textContainerInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        textView.textColor = .init(white: 217/255, alpha: 1)
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.setContentHuggingPriority(.init(rawValue: 1000), for: .vertical)
        textView.setContentCompressionResistancePriority(.init(rawValue: 1000), for: .vertical)
        textView.text = message
    }
    
}

@available(iOS 11.0, *)
class MassAlertButtonView: UIView {
    
    private var style: MassAlertStyle
    
    init(target: Any?, style: MassAlertStyle, actions: [MassAlertAction]) {
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 38).isActive = true
        setupSubview(target: target, actions: actions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview(target: Any?, actions: [MassAlertAction]) {
    // TODO: MassAlert 先採用有1-2顆按鈕的 之後的有需求再實作
        let factory = MassBtnFactory(style: style)
        if 1...2 ~= actions.count {
            let stack = UIStackView()
            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
            stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 12
            
            for (i, action) in actions.enumerated() {
                let btn: UIButton
                switch action.actionType {
                case .normal:
                    btn = factory.getNormalAction()
                case .main:
                    btn = factory.getMainAction()
                }
                btn.translatesAutoresizingMaskIntoConstraints = false

                btn.tag = i
                btn.setTitle(action.title, for: .init())
                btn.addTarget(target, action: #selector(MassAlertController.btnAction(_: )), for: .touchUpInside)
                stack.addArrangedSubview(btn)
            }
        }
    }
    
}

public struct MassAlertAction {
    var title: String
    var actionType: ActionType
    var action: () -> ()
    
    ///
    /// - Parameters:
    ///   - action: 內部處理沒處理好會強鎖住此Action 記得加上[weak self]
    public init(title: String, actionType: ActionType, action: @escaping () -> ()) {
        self.title = title
        self.actionType = actionType
        self.action = action
    }
    
    public enum ActionType {
        case main
        case normal
    }
}

public struct MassAlertStyle {
    /// alert背景顏色
    public var alertBgColor: UIColor = .init(white: 37/255, alpha: 1)
    public var confirmColor: UIColor = .init(red: 1, green: 120/255, blue: 0, alpha: 1)
    public var confirmPressColor: UIColor = .init(red: 204/255, green: 97/255, blue: 2/255, alpha: 1)
}

#if DEBUG

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(red: CGFloat(arc4random()) / CGFloat(UInt32.max),
                       green: CGFloat(arc4random()) / CGFloat(UInt32.max),
                       blue: CGFloat(arc4random()) / CGFloat(UInt32.max),
                       alpha: 1.0)
    }
    
}

#endif

class MassBtnFactory {
    
    private var style: MassAlertStyle
    
    init(style: MassAlertStyle) {
        self.style = style
    }
    
    func getMainAction() -> UIButton {
        let btn = HapticButton()
        btn.pressColor = style.confirmPressColor
        btn.originColor = style.confirmColor
        btn.backgroundColor = style.confirmColor
        btn.textColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.layer.cornerRadius = 4
        return btn
    }
    
    func getNormalAction() -> UIButton {
        let btn = HapticButton()
        btn.layer.borderColor = UIColor.init(white: 101/255, alpha: 1).cgColor
        btn.layer.borderWidth = 1
        btn.textColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.layer.cornerRadius = 4
        return btn
    }
    
}

/// 觸覺設計的button
class HapticButton: UIButton {
    
    var pressColor: UIColor?
    var originColor: UIColor?
    var textPressAlpha: CGFloat = 0.4
    var textColor: UIColor = .white

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBtn()
    }
    
    func setupBtn() {
        backgroundColor = originColor
        tintColor = textColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = pressColor
        titleLabel?.alpha = textPressAlpha
        imageView?.alpha = textPressAlpha
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if isTouchInside == true {
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = self.pressColor
                self.titleLabel?.alpha = self.textPressAlpha
                self.imageView?.alpha = self.textPressAlpha
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = self.originColor
                self.titleLabel?.alpha = 1
                self.imageView?.alpha = 1
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouchInside == true {
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } completion: { (_) in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: []) {
                    self.transform = .identity
                }
            }
        }
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = self.originColor
            self.titleLabel?.alpha = 1
            self.imageView?.alpha = 1
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.backgroundColor = self.originColor
        self.titleLabel?.alpha = 1
        self.imageView?.alpha = 1
        self.transform = .identity
    }
    
}
