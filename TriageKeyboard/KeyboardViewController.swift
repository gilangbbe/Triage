//
//  KeyboardViewController.swift
//  TriageKeyboard
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    private var parseButton: UIButton!
    private var pasteButton: UIButton!
    private var quickRepliesButton: UIButton!
    private var textView: UITextView!
    private var statusLabel: UILabel!
    private var nextKeyboardButton: UIButton!
    private var quickRepliesCollectionView: UICollectionView!
    private var quickRepliesContainer: UIView!
    
    private var quickReplies: [QuickReplyData] = []
    private var showingQuickReplies = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Set the keyboard height - increased to accommodate quick replies
        let heightConstraint = NSLayoutConstraint(
            item: view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0.0,
            constant: showingQuickReplies ? 320 : 220
        )
        heightConstraint.priority = UILayoutPriority(999)
        view.addConstraint(heightConstraint)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadQuickReplies()
        setupKeyboardUI()
    }
    
    private func setupKeyboardUI() {
        view.backgroundColor = UIColor.systemGray6
        
        // Create main container
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Triage Customer Parser"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Text view for input
        textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "Paste customer message here..."
        textView.textColor = UIColor.placeholderText
        textView.backgroundColor = UIColor.systemBackground
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textView)
        
        // Button stack
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStack)
        
        // Paste button
        pasteButton = UIButton(type: .system)
        pasteButton.setTitle("Paste", for: .normal)
        pasteButton.backgroundColor = UIColor.systemBlue
        pasteButton.setTitleColor(.white, for: .normal)
        pasteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        pasteButton.layer.cornerRadius = 8
        pasteButton.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(pasteButton)
        
        // Parse button
        parseButton = UIButton(type: .system)
        parseButton.setTitle("Parse & Save", for: .normal)
        parseButton.backgroundColor = UIColor.systemGreen
        parseButton.setTitleColor(.white, for: .normal)
        parseButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        parseButton.layer.cornerRadius = 8
        parseButton.addTarget(self, action: #selector(parseButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(parseButton)
        
        // Quick Replies button
        quickRepliesButton = UIButton(type: .system)
        quickRepliesButton.setTitle("Quick Replies", for: .normal)
        quickRepliesButton.backgroundColor = UIColor.systemPurple
        quickRepliesButton.setTitleColor(.white, for: .normal)
        quickRepliesButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        quickRepliesButton.layer.cornerRadius = 8
        quickRepliesButton.addTarget(self, action: #selector(toggleQuickReplies), for: .touchUpInside)
        buttonStack.addArrangedSubview(quickRepliesButton)
        
        // Next keyboard button
        nextKeyboardButton = UIButton(type: .system)
        nextKeyboardButton.setTitle("🌐", for: .normal)
        nextKeyboardButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(nextKeyboardButton)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = ""
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2
        statusLabel.textColor = UIColor.secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statusLabel)
        
        // Quick Replies Container
        quickRepliesContainer = UIView()
        quickRepliesContainer.backgroundColor = UIColor.systemBackground
        quickRepliesContainer.layer.cornerRadius = 8
        quickRepliesContainer.layer.borderColor = UIColor.systemGray4.cgColor
        quickRepliesContainer.layer.borderWidth = 1
        quickRepliesContainer.translatesAutoresizingMaskIntoConstraints = false
        quickRepliesContainer.isHidden = true
        containerView.addSubview(quickRepliesContainer)
        
        // Collection View for Quick Replies
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        quickRepliesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        quickRepliesCollectionView.backgroundColor = UIColor.clear
        quickRepliesCollectionView.delegate = self
        quickRepliesCollectionView.dataSource = self
        quickRepliesCollectionView.register(QuickReplyCell.self, forCellWithReuseIdentifier: "QuickReplyCell")
        quickRepliesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        quickRepliesContainer.addSubview(quickRepliesCollectionView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Text view
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            textView.heightAnchor.constraint(equalToConstant: 60),
            
            // Button stack
            buttonStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            buttonStack.heightAnchor.constraint(equalToConstant: 36),
            
            // Next keyboard button constraint
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 36),
            
            // Quick Replies Container
            quickRepliesContainer.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 12),
            quickRepliesContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            quickRepliesContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            quickRepliesContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Collection View
            quickRepliesCollectionView.topAnchor.constraint(equalTo: quickRepliesContainer.topAnchor),
            quickRepliesCollectionView.leadingAnchor.constraint(equalTo: quickRepliesContainer.leadingAnchor),
            quickRepliesCollectionView.trailingAnchor.constraint(equalTo: quickRepliesContainer.trailingAnchor),
            quickRepliesCollectionView.bottomAnchor.constraint(equalTo: quickRepliesContainer.bottomAnchor),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: quickRepliesContainer.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    @objc private func pasteButtonTapped() {
        if let clipboardText = UIPasteboard.general.string {
            textView.text = clipboardText
            textView.textColor = UIColor.label
            statusLabel.text = "Text pasted from clipboard"
            statusLabel.textColor = UIColor.systemBlue
        } else {
            statusLabel.text = "No text found in clipboard"
            statusLabel.textColor = UIColor.systemRed
        }
    }
    
        @objc private func parseButtonTapped() {
        guard let text = textView.text, !text.isEmpty else {
            statusLabel.text = "Error: No text to parse"
            statusLabel.textColor = UIColor.systemRed
            return
        }
        
        let parser = PatientDataParser()
        let parsedData = parser.parse(from: text)
        
        guard !parsedData.fullName.isEmpty else {
            statusLabel.text = "Error: Could not parse patient information"
            statusLabel.textColor = UIColor.systemRed
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
        statusLabel.text = "✓ Patient parsed and saved successfully"
        statusLabel.textColor = UIColor.systemGreen
        
        // Clear the text view
        clearTextView()
    }
    
    private func clearTextView() {
        textView.text = "Paste customer message here..."
        textView.textColor = UIColor.placeholderText
        statusLabel.text = ""
    }
    
    private func savePatientToSharedContainer(_ patient: PatientData) {
        guard let sharedDefaults = SharedConfiguration.sharedUserDefaults else {
            statusLabel.text = "Error: Could not access shared storage"
            statusLabel.textColor = UIColor.systemRed
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
    
    @objc private func toggleQuickReplies() {
        showingQuickReplies.toggle()
        quickRepliesContainer.isHidden = !showingQuickReplies
        
        // Update button appearance
        quickRepliesButton.backgroundColor = showingQuickReplies ? UIColor.systemOrange : UIColor.systemPurple
        quickRepliesButton.setTitle(showingQuickReplies ? "Hide Replies" : "Quick Replies", for: .normal)
        
        // Update keyboard height
        updateViewConstraints()
        
        // Reload collection view if showing
        if showingQuickReplies {
            loadQuickReplies()
            quickRepliesCollectionView.reloadData()
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
        
        // Hide quick replies after selection
        showingQuickReplies = false
        quickRepliesContainer.isHidden = true
        quickRepliesButton.backgroundColor = UIColor.systemPurple
        quickRepliesButton.setTitle("Quick Replies", for: .normal)
        updateViewConstraints()
        
        statusLabel.text = "Quick reply inserted: \(reply.title)"
        statusLabel.textColor = UIColor.systemBlue
        
        // Clear status after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.statusLabel.text = ""
        }
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension KeyboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        contentView.backgroundColor = UIColor.systemBlue
        contentView.layer.cornerRadius = 8
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            contentView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    func configure(with reply: QuickReplyData) {
        titleLabel.text = reply.title
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? UIColor.systemBlue.withAlphaComponent(0.7) : UIColor.systemBlue
        }
    }
}


// MARK: - UITextViewDelegate
extension KeyboardViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholderText {
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Paste customer message here..."
            textView.textColor = UIColor.placeholderText
        }
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
