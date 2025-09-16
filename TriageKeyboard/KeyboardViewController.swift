//
//  KeyboardViewController.swift
//  TriageKeyboard
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import UIKit
import ObjectiveC

class KeyboardViewController: UIInputViewController {
    
    private var parseButton: UIButton!
    private var pasteButton: UIButton!
    private var textView: UITextView!
    private var statusLabel: UILabel!
    private var nextKeyboardButton: UIButton!
    private var quickRepliesCollectionView: UICollectionView!
    private var quickRepliesContainer: UIView!
    
    private var quickReplies: [QuickReplyData] = []
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Set the keyboard height - fixed height for always visible quick replies
        let heightConstraint = NSLayoutConstraint(
            item: view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0.0,
            constant: 380
        )
        heightConstraint.priority = UILayoutPriority(999)
        view.addConstraint(heightConstraint)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadQuickReplies()
        setupKeyboardUI()
        updateAppearanceForCurrentMode()
        
        // Load quick replies into collection view after UI is set up
        DispatchQueue.main.async {
            self.quickRepliesCollectionView.reloadData()
            // Force layout update for proper 2x2 grid
            self.quickRepliesCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update collection view layout when bounds change
        quickRepliesCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearanceForCurrentMode()
        }
    }
    
    private func updateAppearanceForCurrentMode() {
        // Update container background
        if let containerView = view.subviews.first {
            containerView.backgroundColor = UIColor.systemBackground
        }
        
        // Update button colors
        pasteButton?.backgroundColor = UIColor.customButtonColor
        pasteButton?.setTitleColor(UIColor.customTextColor, for: .normal)
        
        parseButton?.backgroundColor = UIColor.customButtonColor
        parseButton?.setTitleColor(UIColor.customTextColor, for: .normal)
        
        nextKeyboardButton?.backgroundColor = UIColor.lightGray
        nextKeyboardButton?.setTitleColor(UIColor.customTextColor, for: .normal)
        
        // Update status label colors
        statusLabel?.textColor = UIColor.customTextColor
        statusLabel?.backgroundColor = UIColor.customButtonColor.withAlphaComponent(0.1)
        
        // Update Quick Reply cells
        quickRepliesCollectionView?.reloadData()
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func setupKeyboardUI() {
        view.backgroundColor = UIColor.systemGray6
        
        // Create main container with improved styling
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: -3)
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Text view with improved styling and placeholder
        textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1.5
        textView.layer.cornerRadius = 12
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Add placeholder label
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Paste patient information..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 15)
        placeholderLabel.textColor = UIColor.placeholderText
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)
        textView.placeholderLabel = placeholderLabel
        
        containerView.addSubview(textView)
        
        // Button stack with improved styling
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fill
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStack)
        
        // Paste button with icon
        pasteButton = createStyledButton(
            title: "Paste",
            backgroundColor: UIColor.customButtonColor,
            action: #selector(pasteButtonTapped)
        )
        buttonStack.addArrangedSubview(pasteButton)
        
        // Parse button with icon
        parseButton = createStyledButton(
            title: "Save",
            backgroundColor: UIColor.customButtonColor,
            action: #selector(parseButtonTapped)
        )
        buttonStack.addArrangedSubview(parseButton)
        
        // Next keyboard button with improved styling
        nextKeyboardButton = UIButton(type: .system)
        nextKeyboardButton.setTitle("Back", for: .normal)
        nextKeyboardButton.setTitleColor(UIColor.customTextColor, for: .normal)
        nextKeyboardButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        nextKeyboardButton.backgroundColor = UIColor.customButtonColor.withAlphaComponent(0.1)
        nextKeyboardButton.layer.cornerRadius = 8
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(nextKeyboardButton)
        
        // Status label with improved styling and app icon
        statusLabel = UILabel()
        statusLabel.text = "Ready"
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 3
        statusLabel.textColor = UIColor.customTextColor
        statusLabel.backgroundColor = UIColor.customButtonColor.withAlphaComponent(0.1)
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statusLabel)
        
        // App icon in the status area
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "AppIcon")
        iconImageView.tintColor = UIColor.customTextColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.addSubview(iconImageView)
        
        // Quick Replies Container with improved styling
        quickRepliesContainer = UIView()
        quickRepliesContainer.backgroundColor = UIColor.secondarySystemBackground
        quickRepliesContainer.layer.cornerRadius = 12
        quickRepliesContainer.layer.borderColor = UIColor.systemGray4.cgColor
        quickRepliesContainer.layer.borderWidth = 1
        quickRepliesContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(quickRepliesContainer)
        
        // Quick replies header
        let quickRepliesHeader = UILabel()
        quickRepliesHeader.text = "Quick Replies"
        quickRepliesHeader.font = UIFont.boldSystemFont(ofSize: 14)
        quickRepliesHeader.textColor = UIColor.label
        quickRepliesHeader.translatesAutoresizingMaskIntoConstraints = false
        quickRepliesContainer.addSubview(quickRepliesHeader)
        
        // Collection View for Quick Replies with 2x2 grid layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        layout.itemSize = CGSize(width: 140, height: 50) // Default size, will be overridden by delegate
        
        quickRepliesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        quickRepliesCollectionView.backgroundColor = UIColor.clear
        quickRepliesCollectionView.delegate = self
        quickRepliesCollectionView.dataSource = self
        quickRepliesCollectionView.register(QuickReplyCell.self, forCellWithReuseIdentifier: "QuickReplyCell")
        quickRepliesCollectionView.showsVerticalScrollIndicator = true
        quickRepliesCollectionView.showsHorizontalScrollIndicator = false
        quickRepliesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        quickRepliesContainer.addSubview(quickRepliesCollectionView)
        
        // Setup constraints with improved spacing
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            
            // Text view
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 80),
            
            // Placeholder label
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -16),
            
            // Button stack
            buttonStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            
            // Button width constraints - make Paste and Save equal width, Back button shorter
            pasteButton.widthAnchor.constraint(equalTo: parseButton.widthAnchor),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 60),
            
            // Quick Replies Container
            quickRepliesContainer.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 12),
            quickRepliesContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            quickRepliesContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            quickRepliesContainer.heightAnchor.constraint(equalToConstant: 110),
            
            // Quick replies header
            quickRepliesHeader.topAnchor.constraint(equalTo: quickRepliesContainer.topAnchor, constant: 8),
            quickRepliesHeader.leadingAnchor.constraint(equalTo: quickRepliesContainer.leadingAnchor, constant: 12),
            quickRepliesHeader.trailingAnchor.constraint(equalTo: quickRepliesContainer.trailingAnchor, constant: -12),
            
            // Collection View
            quickRepliesCollectionView.topAnchor.constraint(equalTo: quickRepliesHeader.bottomAnchor, constant: 4),
            quickRepliesCollectionView.leadingAnchor.constraint(equalTo: quickRepliesContainer.leadingAnchor),
            quickRepliesCollectionView.trailingAnchor.constraint(equalTo: quickRepliesContainer.trailingAnchor),
            quickRepliesCollectionView.bottomAnchor.constraint(equalTo: quickRepliesContainer.bottomAnchor, constant: -4),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: quickRepliesContainer.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            // App icon in status area
            iconImageView.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: -12),
            iconImageView.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // Helper method to create styled buttons
    private func createStyledButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(UIColor.customTextColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = backgroundColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Add press animation
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    @objc private func buttonPressed(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonReleased(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform.identity
        }
    }
    
    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    @objc private func pasteButtonTapped() {
        if let clipboardText = UIPasteboard.general.string {
            textView.text = clipboardText
            textView.textColor = UIColor.label
            textView.placeholderLabel?.isHidden = !clipboardText.isEmpty
            showStatus("Text pasted from clipboard", color: UIColor.customButtonColor)
        } else {
            showStatus("No text found in clipboard", color: UIColor.customButtonColor)
        }
    }
    
        @objc private func parseButtonTapped() {
        guard let text = textView.text, !text.isEmpty else {
            showStatus("Error: No text to parse", color: UIColor.customButtonColor)
            return
        }
        
        let parser = PatientDataParser()
        let parsedData = parser.parse(from: text)
        
        guard !parsedData.fullName.isEmpty else {
            showStatus("Error: Could not parse patient information", color: UIColor.customButtonColor)
            return
        }
        
        let patient = PatientData(
            fullName: parsedData.fullName,
            nationalID: parsedData.nationalId,
            dateOfBirth: parsedData.dateOfBirth,
            gender: parsedData.gender?.rawValue,
            placeOfBirth: nil,
            phoneNumber: parsedData.phoneNumber.isEmpty ? nil : parsedData.phoneNumber,
            address: parsedData.address.isEmpty ? nil : parsedData.address
        )
        
        // Save to shared container for main app to process
        savePatientToSharedContainer(patient)
        
        // Show success message
        showStatus("Patient '\(parsedData.fullName)' parsed and saved successfully!", color: UIColor.customButtonColor)
        
        // Clear the text view
        clearTextView()
    }
    
    private func clearTextView() {
        textView.text = ""
        textView.placeholderLabel?.isHidden = false
        statusLabel.text = "Ready"
        statusLabel.textColor = UIColor.customTextColor
        statusLabel.backgroundColor = UIColor.customButtonColor.withAlphaComponent(0.1)
    }
    
    private func savePatientToSharedContainer(_ patient: PatientData) {
        guard let sharedDefaults = SharedConfiguration.sharedUserDefaults else {
            showStatus("Error: Could not access shared storage", color: UIColor.customButtonColor)
            return
        }
        
        // Load existing new patients waiting to be processed
        var newPatients: [PatientData] = []
        if let data = sharedDefaults.data(forKey: SharedConfiguration.SharedDataKeys.newPatients),
           let decodedPatients = try? JSONDecoder().decode([PatientData].self, from: data) {
            newPatients = decodedPatients
        }
        
        // Add the new patient to the queue
        newPatients.append(patient)
        
        // Save back to shared container
        if let encoded = try? JSONEncoder().encode(newPatients) {
            sharedDefaults.set(encoded, forKey: SharedConfiguration.SharedDataKeys.newPatients)
        }
    }
    
    private func showStatus(_ message: String, color: UIColor) {
        statusLabel.text = message
        statusLabel.textColor = UIColor.customTextColor
        statusLabel.backgroundColor = UIColor.customButtonColor
        
        // Auto-clear after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            UIView.animate(withDuration: 0.3) {
                self.statusLabel.alpha = 0
            } completion: { _ in
                self.statusLabel.text = "Ready"
                self.statusLabel.backgroundColor = UIColor.customButtonColor.withAlphaComponent(0.1)
                self.statusLabel.textColor = UIColor.customTextColor
                self.statusLabel.alpha = 1
            }
        }
    }
    
    private func loadQuickReplies() {
        guard let sharedDefaults = SharedConfiguration.sharedUserDefaults else {
            return
        }
        
        if let data = sharedDefaults.data(forKey: SharedConfiguration.SharedDataKeys.quickReplies),
           let replies = try? JSONDecoder().decode([QuickReplyData].self, from: data) {
            quickReplies = replies.filter { $0.isActive }
        }
    }
    
    private func insertQuickReply(_ reply: QuickReplyData) {
        textDocumentProxy.insertText(reply.message)
        showStatus("Quick reply inserted: \(reply.title)", color: UIColor.customButtonColor)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        
        // Update UI colors based on appearance
        if let titleLabel = view.subviews.first?.subviews.first as? UILabel {
            titleLabel.textColor = textColor
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension KeyboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quickReplies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuickReplyCell", for: indexPath) as! QuickReplyCell
        cell.configure(with: quickReplies[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reply = quickReplies[indexPath.item]
        insertQuickReply(reply)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Get the actual collection view width
        let collectionViewWidth = collectionView.bounds.width
        
        // If collection view width is still 0, use container width as fallback
        let containerWidth = collectionViewWidth > 0 ? collectionViewWidth : quickRepliesContainer.bounds.width
        
        // Calculate item width for 2 columns
        let sectionInsets: CGFloat = 24 // 12 + 12 for left/right margins
        let interItemSpacing: CGFloat = 8
        let availableWidth = containerWidth - sectionInsets - interItemSpacing
        let itemWidth = availableWidth / 2
        
        // Ensure minimum width in case calculations result in very small numbers
        let finalWidth = max(itemWidth, 120) // Minimum width of 120
        return CGSize(width: finalWidth, height: 50)
    }
}

// MARK: - QuickReplyCell
class QuickReplyCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.backgroundColor = UIColor.customButtonColor
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.customButtonColor.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 4
        
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = UIColor.customTextColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            contentView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(with reply: QuickReplyData) {
        titleLabel.text = reply.title
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? UIColor.customButtonColor.withAlphaComponent(0.7) : UIColor.customButtonColor
        }
    }
}


// MARK: - UITextViewDelegate
extension KeyboardViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.placeholderLabel?.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.placeholderLabel?.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UITextView Extension for Placeholder
extension UITextView {
    private struct AssociatedKeys {
        static var placeholderLabel = "placeholderLabel"
    }
    
    var placeholderLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.placeholderLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Custom Colors
extension UIColor {
    static let customTextColor = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(hex: "0F0E46") // Dark mode text
        default:
            return UIColor(hex: "EFEEFF") // Light mode text
        }
    }
    
    static let customButtonColor = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(hex: "EFEEFF") // Dark mode button
        default:
            return UIColor(hex: "0F0E46") // Light mode button
        }
    }
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}

// MARK: - Data Models for Keyboard Extension
struct QuickReplyData: Codable {
    let id: String
    var title: String
    var message: String
    var isActive: Bool
    var dateCreated: Date
    
    init(title: String, message: String, isActive: Bool = true) {
        self.id = UUID().uuidString
        self.title = title
        self.message = message
        self.isActive = isActive
        self.dateCreated = Date()
    }
}

struct PatientData: Codable {
    let id: String
    var fullName: String
    var nationalID: String?
    var dateOfBirth: Date?
    var gender: String?
    var placeOfBirth: String?
    var registeredAt: Date?
    var phoneNumber: String?
    var address: String?
    
    init(fullName: String, nationalID: String? = nil, dateOfBirth: Date? = nil, gender: String? = nil, placeOfBirth: String? = nil, phoneNumber: String? = nil, address: String? = nil) {
        self.id = UUID().uuidString
        self.fullName = fullName
        self.nationalID = nationalID
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.placeOfBirth = placeOfBirth
        self.phoneNumber = phoneNumber
        self.address = address
        self.registeredAt = Date()
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
}

// MARK: - Data Models
struct ParsedPatientData {
    let nationalId: String?
    let fullName: String
    let dateOfBirth: Date?
    let phoneNumber: String
    let address: String
    let gender: Gender?
}

class PatientDataParser {
    func parse(from text: String) -> ParsedPatientData {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else {
            return ParsedPatientData(
                nationalId: nil,
                fullName: "",
                dateOfBirth: nil,
                phoneNumber: "",
                address: "",
                gender: nil
            )
        }

        let nationalId = extractValue(for: ["NIK"], from: cleanText)
        let fullName   = extractValue(for: ["Nama lengkap", "Nama"], from: cleanText)
        var dobString  = extractValue(for: ["Tgl lahir", "Tempat/Tgl Lahir"], from: cleanText)
        let phone      = extractValue(for: ["No telp"], from: cleanText)
        var address    = extractValue(for: ["Alamat lengkap", "Alamat"], from: cleanText)
        let genderStr  = extractValue(for: ["Jenis kelamin", "Jenis kelamin (L/P)", "Jenis Kelamin"], from: cleanText)

        // Handle DOB with comma case
        if !dobString.isEmpty, let commaIdx = dobString.firstIndex(of: ",") {
            dobString = String(dobString[dobString.index(after: commaIdx)...]).trimmingCharacters(in: .whitespaces)
        }

        // Fallback: build full address if only partial pieces are available
        if address.isEmpty {
            let rtRw = extractValue(for: ["RT/RW"], from: cleanText)
            let kel  = extractValue(for: ["Kel/Desa"], from: cleanText)
            let kec  = extractValue(for: ["Kecamatan"], from: cleanText)
            address = [address, rtRw, kel, kec].filter { !$0.isEmpty }.joined(separator: ", ")
        }

        return ParsedPatientData(
            nationalId: nationalId.isEmpty ? nil : nationalId,
            fullName: fullName,
            dateOfBirth: DateParser.parse(from: dobString),
            phoneNumber: phone,
            address: address,
            gender: GenderParser.parse(from: genderStr)
        )
    }
    
    private func extractValue(for keys: [String], from text: String) -> String {
        for key in keys {
            let escapedKey = NSRegularExpression.escapedPattern(for: key)
            let pattern =
                "(?i)" + escapedKey + "\\s*[:：]\\s*([^\\n]*)" +                // normal paste
                "|(?i)" + escapedKey + "\\s*\\n\\s*[:：]\\s*([^\\n]*)"          // OCR with newline

            if let regex = try? NSRegularExpression(pattern: pattern) {
                let nsText = text as NSString
                if let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)) {
                    var val: String? = nil
                    if match.numberOfRanges > 1, match.range(at: 1).location != NSNotFound {
                        val = nsText.substring(with: match.range(at: 1))
                    } else if match.numberOfRanges > 2, match.range(at: 2).location != NSNotFound {
                        val = nsText.substring(with: match.range(at: 2))
                    }
                    if let val = val {
                        let trimmed = val.trimmingCharacters(in: .whitespacesAndNewlines)
                        let lower = trimmed.lowercased()
                        // Prevent capturing next key as value
                        if trimmed.isEmpty
                            || lower.contains("nama") || lower.contains("nik")
                            || lower.contains("tgl") || lower.contains("alamat")
                            || lower.contains("jenis kelamin") {
                            continue
                        }
                        return trimmed
                    }
                }
            }
        }
        return ""
    }
}

class DateParser {
    static func parse(from string: String) -> Date? {
        var cleanString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanString.isEmpty else { return nil }
        
        // If contains a comma, assume it's "City, dd-MM-yyyy"
        if let commaIdx = cleanString.firstIndex(of: ",") {
            cleanString = String(cleanString[cleanString.index(after: commaIdx)...]).trimmingCharacters(in: .whitespaces)
        }
        
        // Normalize multiple spaces
        cleanString = cleanString.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        let formats = [
            "d MMMM yyyy",   // 1 Januari 2000
            "dd MMMM yyyy",  // 01 Januari 2000
            "d-M-yyyy",      // 1-1-2000
            "dd-MM-yyyy",    // 01-01-2000
            "d/M/yyyy",      // 1/1/2000
            "dd/MM/yyyy",    // 01/01/2000
            "dd.MM.yyyy"     // 01.01.2000
        ]
        
        // Try Indonesian first
        for format in formats {
            let formatter = createFormatter(format: format, locale: "id_ID")
            if let date = formatter.date(from: cleanString) {
                return date
            }
        }
        
        // Fallback: English months
        for format in formats {
            let formatter = createFormatter(format: format, locale: "en_US_POSIX")
            if let date = formatter.date(from: cleanString) {
                return date
            }
        }
        
        return nil
    }
    
    private static func createFormatter(format: String, locale: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: locale)
        return formatter
    }
}

class GenderParser {
    static func parse(from string: String) -> Gender? {
        let cleanString = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanString.isEmpty else { return nil }
        
        if cleanString.hasPrefix("l") || cleanString.contains("laki") || cleanString.contains("pria") || cleanString.contains("male") {
            return .male
        } else if cleanString.hasPrefix("p") || cleanString.contains("perempuan") || cleanString.contains("wanita") || cleanString.contains("female") {
            return .female
        }
        
        return nil
    }
}
