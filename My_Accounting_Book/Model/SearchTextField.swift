//
//  SearchTextField.swift
//  SearchTextField
//
//  Created by Alejandro Pasccon on 4/20/16.
//  Copyright © 2016 Alejandro Pasccon. All rights reserved.
//

import UIKit
import Material

@objc(TextFieldPlaceholderAnimation)
public enum TextFieldPlaceholderAnimation: Int {
    case `default`
    case hidden
}

@objc(TextFieldDelegate)
public protocol SearchTextFieldDelegate: UITextFieldDelegate {
    /**
     A delegation method that is executed when the textField changed.
     - Parameter textField: A TextField.
     - Parameter didChange text: An optional String.
     */
    @objc
    optional func searchTextField(textField: UISearchTextField, didChange text: String?)
    
    /**
     A delegation method that is executed when the textField will clear.
     - Parameter textField: A TextField.
     - Parameter willClear text: An optional String.
     */
    @objc
    optional func searchTextField(textField: UISearchTextField, willClear text: String?)
    
    /**
     A delegation method that is executed when the textField is cleared.
     - Parameter textField: A TextField.
     - Parameter didClear text: An optional String.
     */
    @objc
    optional func searchTextField(textField: UISearchTextField, didClear text: String?)
}



open class UISearchTextField: UITextField {
    
    /// Default size when using AutoLayout.
    open override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: 32)
    }
    
    /// A Boolean that indicates if the placeholder label is animated.
    @IBInspectable
    open var isPlaceholderAnimated = true
    
    /// Set the placeholder animation value.
    open var placeholderAnimation = TextFieldPlaceholderAnimation.default {
    didSet {
    guard isEditing else {
    placeholderLabel.isHidden = !isEmpty && .hidden == placeholderAnimation
    return
    }
    
    placeholderLabel.isHidden = .hidden == placeholderAnimation
    }
    }
    
    /// A boolean indicating whether the text is empty.
    open var isEmpty: Bool {
    return 0 == text?.utf16.count
    }
    
    open override var text: String? {
    didSet {
    placeholderAnimation = { placeholderAnimation }()
    }
    }
    
    open override var leftView: UIView? {
    didSet {
    prepareLeftView()
    layoutSubviews()
    }
    }
    
    /// The leftView width value.
    open var leftViewWidth: CGFloat {
    guard nil != leftView else {
    return 0
    }
    
    return leftViewOffset + bounds.height
    }
    
    /// The leftView offset value.
    open var leftViewOffset: CGFloat = 16
    
    /// Placeholder normal text
    @IBInspectable
    open var leftViewNormalColor = Color.darkText.others {
    didSet {
    updateLeftViewColor()
    }
    }
    
    /// Placeholder active text
    @IBInspectable
    open var leftViewActiveColor = Color.blue.base {
    didSet {
    updateLeftViewColor()
    }
    }
    
    /// Divider normal height.
    @IBInspectable
    open var dividerNormalHeight: CGFloat = 1 {
    didSet {
    guard !isEditing else {
    return
    }
    
    dividerThickness = dividerNormalHeight
    }
    }
    
    
    /// Divider active height.
    @IBInspectable
    open var dividerActiveHeight: CGFloat = 2 {
    didSet {
    guard isEditing else {
    return
    }
    
    dividerThickness = dividerActiveHeight
    }
    }
    
    /// Divider normal color.
    @IBInspectable
    open var dividerNormalColor = Color.grey.lighten2 {
    didSet {
    guard !isEditing else {
    return
    }
    
    dividerColor = dividerNormalColor
    }
    }
    
    /// Divider active color.
    @IBInspectable
    open var dividerActiveColor = Color.blue.base {
    didSet {
    guard isEditing else {
    return
    }
    
    dividerColor = dividerActiveColor
    }
    }
    
    /// The placeholderLabel font value.
    @IBInspectable
    open override var font: UIFont? {
    didSet {
    placeholderLabel.font = font
    }
    }
    
    /// The placeholderLabel text value.
    @IBInspectable
    open override var placeholder: String? {
    get {
    return placeholderLabel.text
    }
    set(value) {
    if isEditing && isPlaceholderUppercasedWhenEditing {
    placeholderLabel.text = value?.uppercased()
    } else {
    placeholderLabel.text = value
    }
    layoutSubviews()
    }
    }
    
    open override var isSecureTextEntry: Bool {
    didSet {
    updateVisibilityIcon()
    fixCursorPosition()
    }
    }
    
    /// The placeholder UILabel.
    @IBInspectable
    open let placeholderLabel = UILabel()
    
    /// Placeholder normal text
    @IBInspectable
    open var placeholderNormalColor = Color.darkText.others {
    didSet {
    updatePlaceholderLabelColor()
    }
    }
    
    /// Placeholder active text
    @IBInspectable
    open var placeholderActiveColor = Color.blue.base {
    didSet {
    updatePlaceholderLabelColor()
    }
    }
    
    /// This property adds a padding to placeholder y position animation
    @IBInspectable
    open var placeholderVerticalOffset: CGFloat = 0
    
    /// This property adds a padding to placeholder y position animation
    @IBInspectable
    open var placeholderHorizontalOffset: CGFloat = 0
    
    /// The scale of the active placeholder in relation to the inactive
    @IBInspectable
    open var placeholderActiveScale: CGFloat = 0.75 {
    didSet {
    layoutPlaceholderLabel()
    }
    }
    
    /// The detailLabel UILabel that is displayed.
    @IBInspectable
    open let detailLabel = UILabel()
    
    /// The detailLabel text value.
    @IBInspectable
    open var detail: String? {
    get {
    return detailLabel.text
    }
    set(value) {
    detailLabel.text = value
    layoutSubviews()
    }
    }
    
    /// Detail text
    @IBInspectable
    open var detailColor = Color.darkText.others {
    didSet {
    updateDetailLabelColor()
    }
    }
    
    /// Vertical distance for the detailLabel from the divider.
    @IBInspectable
    open var detailVerticalOffset: CGFloat = 8 {
    didSet {
    layoutSubviews()
    }
    }
    
    /// Handles the textAlignment of the placeholderLabel.
    open override var textAlignment: NSTextAlignment {
    get {
    return super.textAlignment
    }
    set(value) {
    super.textAlignment = value
    placeholderLabel.textAlignment = value
    detailLabel.textAlignment = value
    }
    }
    
    /// A reference to the clearIconButton.
    open fileprivate(set) var clearIconButton: IconButton?
    
    /// Enables the clearIconButton.
    @IBInspectable
    open var isClearIconButtonEnabled: Bool {
    get {
    return nil != clearIconButton
    }
    set(value) {
    guard value else {
    clearIconButton?.removeTarget(self, action: #selector(handleClearIconButton), for: .touchUpInside)
    removeFromRightView(view: clearIconButton)
    clearIconButton = nil
    return
    }
    
    guard nil == clearIconButton else {
    return
    }
    
    clearIconButton = IconButton(image: Icon.cm.clear, tintColor: placeholderNormalColor)
    clearIconButton!.contentEdgeInsetsPreset = .none
    clearIconButton!.pulseAnimation = .none
    
    rightView?.grid.views.insert(clearIconButton!, at: 0)
    isClearIconButtonAutoHandled = { isClearIconButtonAutoHandled }()
    
    layoutSubviews()
    }
    }
    
    /// Enables the automatic handling of the clearIconButton.
    @IBInspectable
    open var isClearIconButtonAutoHandled = true {
    didSet {
    clearIconButton?.removeTarget(self, action: #selector(handleClearIconButton), for: .touchUpInside)
    
    guard isClearIconButtonAutoHandled else {
    return
    }
    
    clearIconButton?.addTarget(self, action: #selector(handleClearIconButton), for: .touchUpInside)
    }
    }
    
    /// A reference to the visibilityIconButton.
    open fileprivate(set) var visibilityIconButton: IconButton?
    
    /// Icon for visibilityIconButton when in the on state.
    open var visibilityIconOn = Icon.visibility {
    didSet {
    updateVisibilityIcon()
    }
    }
    
    /// Icon for visibilityIconButton when in the off state.
    open var visibilityIconOff = Icon.visibilityOff {
    didSet {
    updateVisibilityIcon()
    }
    }
    
    /// Enables the visibilityIconButton.
    @IBInspectable
    open var isVisibilityIconButtonEnabled: Bool {
    get {
    return nil != visibilityIconButton
    }
    set(value) {
    guard value else {
    visibilityIconButton?.removeTarget(self, action: #selector(handleVisibilityIconButton), for: .touchUpInside)
    removeFromRightView(view: visibilityIconButton)
    visibilityIconButton = nil
    return
    }
    
    guard nil == visibilityIconButton else {
    return
    }
    
    isSecureTextEntry = true
    visibilityIconButton = IconButton(image: nil, tintColor: placeholderNormalColor.withAlphaComponent(0.54))
    updateVisibilityIcon()
    visibilityIconButton!.contentEdgeInsetsPreset = .none
    visibilityIconButton!.pulseAnimation = .centerRadialBeyondBounds
    
    rightView?.grid.views.append(visibilityIconButton!)
    isVisibilityIconButtonAutoHandled = { isVisibilityIconButtonAutoHandled }()
    
    layoutSubviews()
    }
    }
    
    /// Enables the automatic handling of the visibilityIconButton.
    @IBInspectable
    open var isVisibilityIconButtonAutoHandled = true {
    didSet {
    visibilityIconButton?.removeTarget(self, action: #selector(handleVisibilityIconButton), for: .touchUpInside)
    guard isVisibilityIconButtonAutoHandled else {
    return
    }
    
    visibilityIconButton?.addTarget(self, action: #selector(handleVisibilityIconButton), for: .touchUpInside)
    }
    }
    
    @IBInspectable
    open var isPlaceholderUppercasedWhenEditing = false {
    didSet {
    updatePlaceholderTextToActiveState()
    }
    }
    
    /**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
    public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    prepare()
    }
    
    /**
     An initializer that initializes the object with a CGRect object.
     If AutoLayout is used, it is better to initilize the instance
     using the init() initializer.
     - Parameter frame: A CGRect instance.
     */
    public override init(frame: CGRect) {
    super.init(frame: frame)
    prepare()
    }
    
    open override func layoutSubviews() {
    super.layoutSubviews()
    //layoutShape()
    layoutPlaceholderLabel()
    layoutBottomLabel(label: detailLabel, verticalOffset: detailVerticalOffset)
    layoutDivider()
    layoutLeftView()
    layoutRightView()
    }
    
    open override func becomeFirstResponder() -> Bool {
    layoutSubviews()
    return super.becomeFirstResponder()
    }
    
    /// EdgeInsets for text.
    @objc
    open var textInset: CGFloat = 0
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
    var b = super.textRect(forBounds: bounds)
    b.origin.x += textInset
    b.size.width -= textInset
    return b
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return textRect(forBounds: bounds)
    }
    
    /**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepare method
     to initialize property values and other setup operations.
     The super.prepare method should always be called immediately
     when subclassing.
     */
    open func prepare() {
    clipsToBounds = false
    borderStyle = .none
    backgroundColor = nil
    contentScaleFactor = Screen.scale
    font = RobotoFont.regular(with: 16)
    textColor = Color.darkText.primary
    
    prepareDivider()
    preparePlaceholderLabel()
    prepareDetailLabel()
    prepareTargetHandlers()
    prepareTextAlignment()
    prepareRightView()
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////
    // Public interface
    
    /// Maximum number of results to be shown in the suggestions list
    open var maxNumberOfResults = 0
    
    /// Maximum height of the results list
    open var maxResultsListHeight = 0
    
    /// Indicate if this field has been interacted with yet
    open var interactedWith = false
    
    /// Indicate if keyboard is showing or not
    open var keyboardIsShowing = false
    
    /// How long to wait before deciding typing has stopped
    open var typingStoppedDelay = 0.8
    
    /// Set your custom visual theme, or just choose between pre-defined SearchTextFieldTheme.lightTheme() and SearchTextFieldTheme.darkTheme() themes
  
    open var theme = SearchTextFieldTheme.lightTheme() {
        didSet {
            tableView?.reloadData()
            
            if let placeholderColor = theme.placeholderColor {
                if let placeholderString = placeholder {
                    self.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
                }
                
                self.placeholder_Label?.textColor = placeholderColor
            }
            
            if let hightlightedFont = self.highlightAttributes[.font] as? UIFont {
                self.highlightAttributes[.font] = hightlightedFont.withSize(self.theme.font.pointSize)
            }
        }
    }
    
    /// Show the suggestions list without filter when the text field is focused
    open var startVisible = false
    
    /// Show the suggestions list without filter even if the text field is not focused
    open var startVisibleWithoutInteraction = false {
        didSet {
            if startVisibleWithoutInteraction {
                textFieldDidChange()
            }
        }
    }
    
    /// Set an array of SearchTextFieldItem's to be used for suggestions
    open func filterItems(_ items: [SearchTextFieldItem]) {
        filterDataSource = items
    }
    
    /// Set an array of strings to be used for suggestions
    open func filterStrings(_ strings: [String]) {
        var items = [SearchTextFieldItem]()
        
        for value in strings {
            items.append(SearchTextFieldItem(title: value))
        }
        
        filterItems(items)
    }
    
    /// Closure to handle when the user pick an item
    open var itemSelectionHandler: SearchTextFieldItemHandler?
    
    /// Closure to handle when the user stops typing
    open var userStoppedTypingHandler: (() -> Void)?
    
    /// Set your custom set of attributes in order to highlight the string found in each item
    open var highlightAttributes: [NSAttributedString.Key: AnyObject] = [.font: UIFont.boldSystemFont(ofSize: 10)]
    
    /// Start showing the default loading indicator, useful for searches that take some time.
    open func showLoadingIndicator() {
        self.rightViewMode = .always
        indicator.startAnimating()
    }
    
    /// Force the results list to adapt to RTL languages
    open var forceRightToLeft = false
    
    /// Hide the default loading indicator
    open func stopLoadingIndicator() {
        self.rightViewMode = .never
        indicator.stopAnimating()
    }
    
    /// When InlineMode is true, the suggestions appear in the same line than the entered string. It's useful for email domains suggestion for example.
    open var inlineMode: Bool = false {
        didSet {
            if inlineMode == true {
                autocorrectionType = .no
                spellCheckingType = .no
            }
        }
    }
    
    /// Only valid when InlineMode is true. The suggestions appear after typing the provided string (or even better a character like '@')
    open var startFilteringAfter: String?
    
    /// Min number of characters to start filtering
    open var minCharactersNumberToStartFiltering: Int = 0
    
    /// Force no filtering (display the entire filtered data source)
    open var forceNoFiltering: Bool = false
    
    /// If startFilteringAfter is set, and startSuggestingInmediately is true, the list of suggestions appear inmediately
    open var startSuggestingInmediately = false
    
    /// Allow to decide the comparision options
    open var comparisonOptions: NSString.CompareOptions = [.caseInsensitive]
    
    /// Set the results list's header
    open var resultsListHeader: UIView?
    
    // Move the table around to customize for your layout
    open var tableXOffset: CGFloat = 0.0
    open var tableYOffset: CGFloat = 0.0
    open var tableCornerRadius: CGFloat = 2.0
    open var tableBottomMargin: CGFloat = 10.0
    
    ////////////////////////////////////////////////////////////////////////
    // Private implementation
    
    fileprivate var tableView: UITableView?
    fileprivate var shadowView: UIView?
    fileprivate var direction: Direction = .down
    fileprivate var fontConversionRate: CGFloat = 0.7
    fileprivate var keyboardFrame: CGRect?
    fileprivate var timer: Timer? = nil
    fileprivate var placeholder_Label: UILabel?
    fileprivate static let cellIdentifier = "APSearchTextFieldCell"
    fileprivate let indicator = UIActivityIndicatorView(style: .gray)
    fileprivate var maxTableViewSize: CGFloat = 0
    
    fileprivate var filteredResults = [SearchTextFieldItem]()
    fileprivate var filterDataSource = [SearchTextFieldItem]() {
        didSet {
            filter(forceShowAll: forceNoFiltering)
            buildSearchTableView()
            
            if startVisibleWithoutInteraction {
                textFieldDidChange()
            }
        }
    }
    
    fileprivate var currentInlineItem = ""
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.addTarget(self, action: #selector(UISearchTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(UISearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(UISearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(UISearchTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UISearchTextField.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UISearchTextField.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UISearchTextField.keyboardDidChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
   /* override open func layoutSubviews() {
        super.layoutSubviews()
        
        if inlineMode {
            buildPlaceholderLabel()
        } else {
            buildSearchTableView()
        }
        
        // Create the loading indicator
        indicator.hidesWhenStopped = true
        self.rightView = indicator
    }*/
    
    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightFrame = super.rightViewRect(forBounds: bounds)
        rightFrame.origin.x -= 5
        return rightFrame
    }
    
    // Create the filter table and shadow view
    fileprivate func buildSearchTableView() {
        if let tableView = tableView, let shadowView = shadowView {
            tableView.layer.masksToBounds = true
            tableView.layer.borderWidth = theme.borderWidth > 0 ? theme.borderWidth : 0.5
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.tableHeaderView = resultsListHeader
            if forceRightToLeft {
                tableView.semanticContentAttribute = .forceRightToLeft
            }
            
            shadowView.backgroundColor = UIColor.lightText
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize.zero
            shadowView.layer.shadowOpacity = 1
            
            self.window?.addSubview(tableView)
        } else {
            tableView = UITableView(frame: CGRect.zero)
            shadowView = UIView(frame: CGRect.zero)
        }
        
        redrawSearchTableView()
    }
    
    fileprivate func buildPlaceholderLabel() {
        var newRect = self.placeholderRect(forBounds: self.bounds)
        var caretRect = self.caretRect(for: self.beginningOfDocument)
        let textRect = self.textRect(forBounds: self.bounds)
        
        if let range = textRange(from: beginningOfDocument, to: endOfDocument) {
            caretRect = self.firstRect(for: range)
        }
        
        newRect.origin.x = caretRect.origin.x + caretRect.size.width + textRect.origin.x
        newRect.size.width = newRect.size.width - newRect.origin.x
        
        if let placeholder_Label = placeholder_Label {
            placeholder_Label.font = self.font
            placeholder_Label.frame = newRect
        } else {
            placeholder_Label = UILabel(frame: newRect)
            placeholder_Label?.font = self.font
            placeholder_Label?.backgroundColor = UIColor.clear
            placeholder_Label?.lineBreakMode = .byClipping
            
            if let placeholderColor = self.attributedPlaceholder?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as? UIColor {
                placeholder_Label?.textColor = placeholderColor
            } else {
                placeholder_Label?.textColor = UIColor ( red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0 )
            }
            
            self.addSubview(placeholder_Label!)
        }
    }
    
    // Re-set frames and theme colors
    fileprivate func redrawSearchTableView() {
        if inlineMode {
            tableView?.isHidden = true
            return
        }
        
        if let tableView = tableView {
            guard let frame = self.superview?.convert(self.frame, to: nil) else { return }
            
            //TableViews use estimated cell heights to calculate content size until they
            //  are on-screen. We must set this to the theme cell height to avoid getting an
            //  incorrect contentSize when we have specified non-standard fonts and/or
            //  cellHeights in the theme. We do it here to ensure updates to these settings
            //  are recognized if changed after the tableView is created
            tableView.estimatedRowHeight = theme.cellHeight
            if self.direction == .down {
                
                var tableHeight: CGFloat = 0
                if keyboardIsShowing, let keyboardHeight = keyboardFrame?.size.height {
                    tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - frame.height - keyboardHeight))
                } else {
                    tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - frame.height))
                }
                
                if maxResultsListHeight > 0 {
                    tableHeight = min(tableHeight, CGFloat(maxResultsListHeight))
                }
                
                // Set a bottom margin of 10p
                if tableHeight < tableView.contentSize.height {
                    tableHeight -= tableBottomMargin
                }
                
                var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
                tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
                tableViewFrame.origin.x += 2 + tableXOffset
                tableViewFrame.origin.y += frame.size.height + 2 + tableYOffset
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.tableView?.frame = tableViewFrame
                })
                
                var shadowFrame = CGRect(x: 0, y: 0, width: frame.size.width - 6, height: 1)
                shadowFrame.origin = self.convert(shadowFrame.origin, to: nil)
                shadowFrame.origin.x += 3
                shadowFrame.origin.y = tableView.frame.origin.y
                shadowView!.frame = shadowFrame
            } else {
                let tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - theme.cellHeight))
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.tableView?.frame = CGRect(x: frame.origin.x + 2, y: (frame.origin.y - tableHeight), width: frame.size.width - 4, height: tableHeight)
                    self?.shadowView?.frame = CGRect(x: frame.origin.x + 3, y: (frame.origin.y + 3), width: frame.size.width - 6, height: 1)
                })
            }
            
            superview?.bringSubviewToFront(tableView)
            superview?.bringSubviewToFront(shadowView!)
            
            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }
            
            tableView.layer.borderColor = theme.borderColor.cgColor
            tableView.layer.cornerRadius = tableCornerRadius
            tableView.separatorColor = theme.separatorColor
            tableView.backgroundColor = theme.bgColor
            
            tableView.reloadData()
        }
    }
    
    // Handle keyboard events
    @objc open func keyboardWillShow(_ notification: Notification) {
        if !keyboardIsShowing && isEditing {
            keyboardIsShowing = true
            keyboardFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            interactedWith = true
            prepareDrawTableResult()
        }
    }
    
    @objc open func keyboardWillHide(_ notification: Notification) {
        if keyboardIsShowing {
            keyboardIsShowing = false
            direction = .down
            redrawSearchTableView()
        }
    }
    
    @objc open func keyboardDidChangeFrame(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.keyboardFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self?.prepareDrawTableResult()
        }
    }
    
    @objc open func typingDidStop() {
        self.userStoppedTypingHandler?()
    }
    
    // Handle text field changes
    @objc open func textFieldDidChange() {
        if !inlineMode && tableView == nil {
            buildSearchTableView()
        }
        
        interactedWith = true
        
        // Detect pauses while typing
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: typingStoppedDelay, target: self, selector: #selector(UISearchTextField.typingDidStop), userInfo: self, repeats: false)
        
        if text!.isEmpty {
            clearResults()
            tableView?.reloadData()
            if startVisible || startVisibleWithoutInteraction {
                filter(forceShowAll: true)
            }
            self.placeholder_Label?.text = ""
        } else {
            filter(forceShowAll: forceNoFiltering)
            prepareDrawTableResult()
        }
        
        buildPlaceholderLabel()
    }
    
    @objc open func textFieldDidBeginEditing() {
        if (startVisible || startVisibleWithoutInteraction) && text!.isEmpty {
            clearResults()
            filter(forceShowAll: true)
        }
        placeholder_Label?.attributedText = nil
    }
    
    @objc open func textFieldDidEndEditing() {
        clearResults()
        tableView?.reloadData()
        placeholder_Label?.attributedText = nil
    }
    
    @objc open func textFieldDidEndEditingOnExit() {
        if let firstElement = filteredResults.first {
            if let itemSelectionHandler = self.itemSelectionHandler {
                itemSelectionHandler(filteredResults, 0)
            }
            else {
                if inlineMode, let filterAfter = startFilteringAfter {
                    let stringElements = self.text?.components(separatedBy: filterAfter)
                    
                    self.text = stringElements!.first! + filterAfter + firstElement.title
                } else {
                    self.text = firstElement.title
                }
            }
        }
    }
    
    open func hideResultsList() {
        if let tableFrame:CGRect = tableView?.frame {
            let newFrame = CGRect(x: tableFrame.origin.x, y: tableFrame.origin.y, width: tableFrame.size.width, height: 0.0)
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = newFrame
            })
            
        }
    }
    
    fileprivate func filter(forceShowAll addAll: Bool) {
        clearResults()
        
        if text!.count < minCharactersNumberToStartFiltering {
            return
        }
        
        for i in 0 ..< filterDataSource.count {
            
            let item = filterDataSource[i]
            
            if !inlineMode {
                // Find text in title and subtitle
                let titleFilterRange = (item.title as NSString).range(of: text!, options: comparisonOptions)
                let subtitleFilterRange = item.subtitle != nil ? (item.subtitle! as NSString).range(of: text!, options: comparisonOptions) : NSMakeRange(NSNotFound, 0)
                
                if titleFilterRange.location != NSNotFound || subtitleFilterRange.location != NSNotFound || addAll {
                    item.attributedTitle = NSMutableAttributedString(string: item.title)
                    item.attributedSubtitle = NSMutableAttributedString(string: (item.subtitle != nil ? item.subtitle! : ""))
                    
                    item.attributedTitle!.setAttributes(highlightAttributes, range: titleFilterRange)
                    
                    if subtitleFilterRange.location != NSNotFound {
                        item.attributedSubtitle!.setAttributes(highlightAttributesForSubtitle(), range: subtitleFilterRange)
                    }
                    
                    filteredResults.append(item)
                }
            } else {
                var textToFilter = text!.lowercased()
                
                if inlineMode, let filterAfter = startFilteringAfter {
                    if let suffixToFilter = textToFilter.components(separatedBy: filterAfter).last, (suffixToFilter != "" || startSuggestingInmediately == true), textToFilter != suffixToFilter {
                        textToFilter = suffixToFilter
                    } else {
                        placeholder_Label?.text = ""
                        return
                    }
                }
                
                if item.title.lowercased().hasPrefix(textToFilter) {
                    let indexFrom = textToFilter.index(textToFilter.startIndex, offsetBy: textToFilter.count)
                    let itemSuffix = item.title[indexFrom...]
                    
                    item.attributedTitle = NSMutableAttributedString(string: String(itemSuffix))
                    filteredResults.append(item)
                }
            }
        }
        
        tableView?.reloadData()
        
        if inlineMode {
            handleInlineFiltering()
        }
    }
    
    // Clean filtered results
    fileprivate func clearResults() {
        filteredResults.removeAll()
        tableView?.removeFromSuperview()
    }
    
    // Look for Font attribute, and if it exists, adapt to the subtitle font size
    fileprivate func highlightAttributesForSubtitle() -> [NSAttributedString.Key: AnyObject] {
        var highlightAttributesForSubtitle = [NSAttributedString.Key: AnyObject]()
        
        for attr in highlightAttributes {
            if attr.0 == NSAttributedString.Key.font {
                let fontName = (attr.1 as! UIFont).fontName
                let pointSize = (attr.1 as! UIFont).pointSize * fontConversionRate
                highlightAttributesForSubtitle[attr.0] = UIFont(name: fontName, size: pointSize)
            } else {
                highlightAttributesForSubtitle[attr.0] = attr.1
            }
        }
        
        return highlightAttributesForSubtitle
    }
    
    // Handle inline behaviour
    func handleInlineFiltering() {
        if let text = self.text {
            if text == "" {
                self.placeholder_Label?.attributedText = nil
            } else {
                if let firstResult = filteredResults.first {
                    self.placeholder_Label?.attributedText = firstResult.attributedTitle
                } else {
                    self.placeholder_Label?.attributedText = nil
                }
            }
        }
    }
    
    // MARK: - Prepare for draw table result
    
    fileprivate func prepareDrawTableResult() {
        guard let frame = self.superview?.convert(self.frame, to: UIApplication.shared.keyWindow) else { return }
        if let keyboardFrame = keyboardFrame {
            var newFrame = frame
            newFrame.size.height += theme.cellHeight
            
            if keyboardFrame.intersects(newFrame) {
                direction = .up
            } else {
                direction = .down
            }
            
            redrawSearchTableView()
        } else {
            if self.center.y + theme.cellHeight > UIApplication.shared.keyWindow!.frame.size.height {
                direction = .up
            } else {
                direction = .down
            }
        }
    }
}//end of class


fileprivate extension UISearchTextField {
    /// Prepares the divider.
    func prepareDivider() {
        dividerColor = dividerNormalColor
    }
    
    /// Prepares the placeholderLabel.
    func preparePlaceholderLabel() {
        placeholderNormalColor = Color.darkText.others
        placeholderLabel.backgroundColor = .clear
        addSubview(placeholderLabel)
    }
    
    /// Prepares the detailLabel.
    func prepareDetailLabel() {
        detailLabel.font = RobotoFont.regular(with: 12)
        detailLabel.numberOfLines = 0
        detailColor = Color.darkText.others
        addSubview(detailLabel)
    }
    
    /// Prepares the leftView.
    func prepareLeftView() {
        leftView?.contentMode = .left
        leftViewMode = .always
        updateLeftViewColor()
    }
    
    /// Prepares the target handlers.
    func prepareTargetHandlers() {
        addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)
    }
    
    /// Prepares the textAlignment.
    func prepareTextAlignment() {
        textAlignment = .rightToLeft == Application.userInterfaceLayoutDirection ? .right : .left
    }
    
    /// Prepares the rightView.
    func prepareRightView() {
        rightView = UIView()
        rightView?.grid.columns = 2
        rightViewMode = .whileEditing
        clearButtonMode = .never
    }
}

fileprivate extension UISearchTextField {
    /// Updates the leftView tint color.
    func updateLeftViewColor() {
        leftView?.tintColor = isEditing ? leftViewActiveColor : leftViewNormalColor
    }
    
    /// Updates the placeholderLabel text color.
    func updatePlaceholderLabelColor() {
        tintColor = placeholderActiveColor
        placeholderLabel.textColor = isEditing ? placeholderActiveColor : placeholderNormalColor
    }
    
    /// Update the placeholder text to the active state.
    func updatePlaceholderTextToActiveState() {
        guard isPlaceholderUppercasedWhenEditing else {
            return
        }
        
        guard isEditing || !isEmpty else {
            return
        }
        
        placeholderLabel.text = placeholderLabel.text?.uppercased()
    }
    
    /// Update the placeholder text to the normal state.
    func updatePlaceholderTextToNormalState() {
        guard isPlaceholderUppercasedWhenEditing else {
            return
        }
        
        guard isEmpty else {
            return
        }
        
        placeholderLabel.text = placeholderLabel.text?.capitalized
    }
    
    /// Updates the detailLabel text color.
    func updateDetailLabelColor() {
        detailLabel.textColor = detailColor
    }
}

fileprivate extension UISearchTextField {
    /// Layout the placeholderLabel.
    func layoutPlaceholderLabel() {
        let w = leftViewWidth + textInset
        let h = 0 == bounds.height ? intrinsicContentSize.height : bounds.height
        
        placeholderLabel.transform = CGAffineTransform.identity
        
        guard isEditing || !isEmpty || !isPlaceholderAnimated else {
            placeholderLabel.frame = CGRect(x: w, y: 0, width: bounds.width - leftViewWidth - 2 * textInset, height: h)
            return
        }
        
        placeholderLabel.frame = CGRect(x: w, y: 0, width: bounds.width - leftViewWidth - 2 * textInset, height: h)
        placeholderLabel.transform = CGAffineTransform(scaleX: placeholderActiveScale, y: placeholderActiveScale)
        
        switch textAlignment {
        case .left, .natural:
            placeholderLabel.frame.origin.x = w + placeholderHorizontalOffset
        case .right:
            placeholderLabel.frame.origin.x = (bounds.width * (1.0 - placeholderActiveScale)) - textInset + placeholderHorizontalOffset
        default:break
        }
        
        placeholderLabel.frame.origin.y = -placeholderLabel.frame.height + placeholderVerticalOffset
    }
    
    /// Layout the leftView.
    func layoutLeftView() {
        guard let v = leftView else {
            return
        }
        
        let w = leftViewWidth
        v.frame = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        dividerContentEdgeInsets.left = w
    }
    /// Layout the rightView.
    func layoutRightView() {
        guard let rightView = rightView else {
            return
        }
        
        let w = CGFloat(rightView.grid.views.count) * bounds.height
        rightView.frame = CGRect(x: bounds.width - w, y: 0, width: w, height: bounds.height)
        rightView.grid.reload()
    }
}

internal extension UISearchTextField {
    /// Layout given label at the bottom with the vertical offset provided.
    func layoutBottomLabel(label: UILabel, verticalOffset: CGFloat) {
        let c = dividerContentEdgeInsets
        label.frame.origin.x = c.left
        label.frame.origin.y = bounds.height + verticalOffset
        label.frame.size.width = bounds.width - c.left - c.right
        label.frame.size.height = label.sizeThatFits(CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude)).height
    }
}

fileprivate extension UISearchTextField {
    /// Handles the text editing did begin state.
    @objc
    func handleEditingDidBegin() {
        leftViewEditingBeginAnimation()
        placeholderEditingDidBeginAnimation()
        dividerEditingDidBeginAnimation()
    }
    
    // Live updates the textField text.
    @objc
    func handleEditingChanged(textField: UISearchTextField) {
        (delegate as? SearchTextFieldDelegate)?.searchTextField?(textField: self, didChange: textField.text)
    }
    
    /// Handles the text editing did end state.
    @objc
    func handleEditingDidEnd() {
        leftViewEditingEndAnimation()
        placeholderEditingDidEndAnimation()
        dividerEditingDidEndAnimation()
    }
    
    /// Handles the clearIconButton TouchUpInside event.
    @objc
    func handleClearIconButton() {
        guard nil == delegate?.textFieldShouldClear || true == delegate?.textFieldShouldClear?(self) else {
            return
        }
        
        let t = text
        
        (delegate as? SearchTextFieldDelegate)?.searchTextField?(textField: self, willClear: t)
        
        text = nil
        
        (delegate as? SearchTextFieldDelegate)?.searchTextField?(textField: self, didClear: t)
    }
    
    /// Handles the visibilityIconButton TouchUpInside event.
    @objc
    func handleVisibilityIconButton() {
        UIView.transition(
            with: (visibilityIconButton?.imageView)!,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.isSecureTextEntry = !self.isSecureTextEntry
        })
    }
}

extension UISearchTextField {
    /// The animation for leftView when editing begins.
    fileprivate func leftViewEditingBeginAnimation() {
        updateLeftViewColor()
    }
    
    /// The animation for leftView when editing ends.
    fileprivate func leftViewEditingEndAnimation() {
        updateLeftViewColor()
    }
    
    /// The animation for the divider when editing begins.
    fileprivate func dividerEditingDidBeginAnimation() {
        dividerThickness = dividerActiveHeight
        dividerColor = dividerActiveColor
    }
    
    /// The animation for the divider when editing ends.
    fileprivate func dividerEditingDidEndAnimation() {
        dividerThickness = dividerNormalHeight
        dividerColor = dividerNormalColor
    }
    
    /// The animation for the placeholder when editing begins.
    fileprivate func placeholderEditingDidBeginAnimation() {
        guard .default == placeholderAnimation else {
            placeholderLabel.isHidden = true
            return
        }
        
        updatePlaceholderLabelColor()
        
        guard isPlaceholderAnimated else {
            updatePlaceholderTextToActiveState()
            return
        }
        
        guard isEmpty else {
            updatePlaceholderTextToActiveState()
            return
        }
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.placeholderLabel.transform = CGAffineTransform(scaleX: self.placeholderActiveScale, y: self.placeholderActiveScale)
            
            self.updatePlaceholderTextToActiveState()
            
            switch self.textAlignment {
            case .left, .natural:
                self.placeholderLabel.frame.origin.x = self.leftViewWidth + self.textInset + self.placeholderHorizontalOffset
            case .right:
                self.placeholderLabel.frame.origin.x = (self.bounds.width * (1.0 - self.placeholderActiveScale)) - self.textInset + self.placeholderHorizontalOffset
            default:break
            }
            
            self.placeholderLabel.frame.origin.y = -self.placeholderLabel.bounds.height + self.placeholderVerticalOffset
        })
    }
    
    /// The animation for the placeholder when editing ends.
    fileprivate func placeholderEditingDidEndAnimation() {
        guard .default == placeholderAnimation else {
            placeholderLabel.isHidden = !isEmpty
            return
        }
        
        updatePlaceholderLabelColor()
        updatePlaceholderTextToNormalState()
        
        guard isPlaceholderAnimated else {
            return
        }
        
        guard isEmpty else {
            return
        }
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.placeholderLabel.transform = CGAffineTransform.identity
            self.placeholderLabel.frame.origin.x = self.leftViewWidth + self.textInset
            self.placeholderLabel.frame.origin.y = 0
        })
    }
}

private extension UISearchTextField {
    /// Updates visibilityIconButton image based on isSecureTextEntry value.
    func updateVisibilityIcon() {
        visibilityIconButton?.image = isSecureTextEntry ? visibilityIconOff : visibilityIconOn
    }
    
    /// Remove view from rightView.
    func removeFromRightView(view: UIView?) {
        guard let v = view, let i = rightView?.grid.views.index(of: v) else {
            return
        }
        
        rightView?.grid.views.remove(at: i)
    }
    
    /**
     Reassign text to reset cursor position.
     Fixes issue-1119. Previously issue-1030, and issue-1023.
     */
    func fixCursorPosition() {
        let t = text
        text = nil
        text = t
    }
}








extension UISearchTextField: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = !interactedWith || (filteredResults.count == 0)
        shadowView?.isHidden = !interactedWith || (filteredResults.count == 0)
        
        if maxNumberOfResults > 0 {
            return min(filteredResults.count, maxNumberOfResults)
        } else {
            return filteredResults.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: UISearchTextField.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: UISearchTextField.cellIdentifier)
        }
        
        cell!.backgroundColor = UIColor.clear
        cell!.layoutMargins = UIEdgeInsets.zero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.textLabel?.font = theme.font
        cell!.detailTextLabel?.font = UIFont(name: theme.font.fontName, size: theme.font.pointSize * fontConversionRate)
        cell!.textLabel?.textColor = theme.fontColor
        cell!.detailTextLabel?.textColor = theme.subtitleFontColor
        
        cell!.textLabel?.text = filteredResults[(indexPath as NSIndexPath).row].title
        cell!.detailTextLabel?.text = filteredResults[(indexPath as NSIndexPath).row].subtitle
        cell!.textLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].attributedTitle
        cell!.detailTextLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].attributedSubtitle
        
        cell!.imageView?.image = filteredResults[(indexPath as NSIndexPath).row].image
        
        cell!.selectionStyle = .none
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return theme.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemSelectionHandler == nil {
            self.text = filteredResults[(indexPath as NSIndexPath).row].title
        } else {
            let index = indexPath.row
            itemSelectionHandler!(filteredResults, index)
        }
        
        clearResults()
    }
}

////////////////////////////////////////////////////////////////////////
// Search Text Field Theme

public struct SearchTextFieldTheme {
    public var cellHeight: CGFloat
    public var bgColor: UIColor
    public var borderColor: UIColor
    public var borderWidth : CGFloat = 0
    public var separatorColor: UIColor
    public var font: UIFont
    public var fontColor: UIColor
    public var subtitleFontColor: UIColor
    public var placeholderColor: UIColor?
    
    init(cellHeight: CGFloat, bgColor:UIColor, borderColor: UIColor, separatorColor: UIColor, font: UIFont, fontColor: UIColor, subtitleFontColor: UIColor? = nil) {
        self.cellHeight = cellHeight
        self.borderColor = borderColor
        self.separatorColor = separatorColor
        self.bgColor = bgColor
        self.font = font
        self.fontColor = fontColor
        self.subtitleFontColor = subtitleFontColor ?? fontColor
    }
    
    public static func lightTheme() -> SearchTextFieldTheme {
        return SearchTextFieldTheme(cellHeight: 30, bgColor: UIColor (red: 1, green: 1, blue: 1, alpha: 0.6), borderColor: UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), separatorColor: UIColor.clear, font: UIFont.systemFont(ofSize: 10), fontColor: UIColor.black)
    }
    
    public static func darkTheme() -> SearchTextFieldTheme {
        return SearchTextFieldTheme(cellHeight: 30, bgColor: UIColor (red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6), borderColor: UIColor (red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0), separatorColor: UIColor.clear, font: UIFont.systemFont(ofSize: 10), fontColor: UIColor.white)
    }
}

////////////////////////////////////////////////////////////////////////
// Filter Item

open class SearchTextFieldItem {
    // Private vars
    fileprivate var attributedTitle: NSMutableAttributedString?
    fileprivate var attributedSubtitle: NSMutableAttributedString?
    
    // Public interface
    public var title: String
    public var subtitle: String?
    public var image: UIImage?
    
    public init(title: String, subtitle: String?, image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    public init(title: String, subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public init(title: String) {
        self.title = title
    }
}

public typealias SearchTextFieldItemHandler = (_ filteredResults: [SearchTextFieldItem], _ index: Int) -> Void

////////////////////////////////////////////////////////////////////////
// Suggestions List Direction

enum Direction {
    case down
    case up
}
