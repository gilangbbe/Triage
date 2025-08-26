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
    private var textView: UITextView!
    private var statusLabel: UILabel!
    private var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Set the keyboard height
        let heightConstraint = NSLayoutConstraint(
            item: view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0.0,
            constant: 220
        )
        heightConstraint.priority = UILayoutPriority(999)
        view.addConstraint(heightConstraint)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStack)
        
        // Paste button
        pasteButton = UIButton(type: .system)
        pasteButton.setTitle("Paste", for: .normal)
        pasteButton.backgroundColor = UIColor.systemBlue
        pasteButton.setTitleColor(.white, for: .normal)
        pasteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        pasteButton.layer.cornerRadius = 8
        pasteButton.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(pasteButton)
        
        // Parse button
        parseButton = UIButton(type: .system)
        parseButton.setTitle("Parse & Save", for: .normal)
        parseButton.backgroundColor = UIColor.systemGreen
        parseButton.setTitleColor(.white, for: .normal)
        parseButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        parseButton.layer.cornerRadius = 8
        parseButton.addTarget(self, action: #selector(parseButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(parseButton)
        
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
            textView.heightAnchor.constraint(equalToConstant: 80),
            
            // Button stack
            buttonStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            
            // Next keyboard button constraint
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 44),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 8),
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
        let text = textView.text ?? ""
        
        if text.isEmpty || text == "Paste customer message here..." {
            statusLabel.text = "Please enter or paste customer message first"
            statusLabel.textColor = UIColor.systemRed
            return
        }
        
        // Parse the text using the same logic as the main app
        if let order = CustomerOrderParser.parseFromText(text) {
            // Save to shared container
            saveOrderToSharedContainer(order)
            
            statusLabel.text = "✓ Order parsed and saved for \(order.name)"
            statusLabel.textColor = UIColor.systemGreen
            
            // Clear the text view after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.clearTextView()
            }
        } else {
            statusLabel.text = "Could not parse order. Check format and try again."
            statusLabel.textColor = UIColor.systemRed
        }
    }
    
    private func clearTextView() {
        textView.text = "Paste customer message here..."
        textView.textColor = UIColor.placeholderText
        statusLabel.text = ""
    }
    
    private func saveOrderToSharedContainer(_ order: CustomerOrderData) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.triage") else {
            statusLabel.text = "Error: Could not access shared storage"
            statusLabel.textColor = UIColor.systemRed
            return
        }
        
        // Load existing orders
        var orders: [CustomerOrderData] = []
        if let data = sharedDefaults.data(forKey: "SavedOrders"),
           let decodedOrders = try? JSONDecoder().decode([CustomerOrderData].self, from: data) {
            orders = decodedOrders
        }
        
        // Add new order
        orders.append(order)
        
        // Save back to shared container
        if let encoded = try? JSONEncoder().encode(orders) {
            sharedDefaults.set(encoded, forKey: "SavedOrders")
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
struct CustomerOrderData: Codable {
    let id: String
    var name: String
    var email: String
    var address: String
    var phoneNumber: String?
    var orderDetails: String?
    var dateCreated: Date
    var status: String
    
    init(name: String, email: String, address: String, phoneNumber: String? = nil, orderDetails: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.address = address
        self.phoneNumber = phoneNumber
        self.orderDetails = orderDetails
        self.dateCreated = Date()
        self.status = "Pending"
    }
}

struct CustomerOrderParser {
    static func parseFromText(_ text: String) -> CustomerOrderData? {
        let lines = text.components(separatedBy: .newlines)
        var name = ""
        var email = ""
        var address = ""
        var phoneNumber: String?
        var orderDetails: String?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let components = trimmedLine.components(separatedBy: ":")
            
            if components.count >= 2 {
                let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let value = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
                
                switch key {
                case "name", "nama":
                    name = value
                case "email", "e-mail":
                    email = value
                case "address", "alamat", "addr":
                    address = value
                case "phone", "telephone", "telepon", "hp", "no hp":
                    phoneNumber = value
                case "order", "pesanan", "details":
                    orderDetails = value
                default:
                    // Ignore unrecognized keys
                    break
                }
            }
        }
        
        // Only create order if we have at least name and one contact method
        if !name.isEmpty && (!email.isEmpty || !address.isEmpty) {
            return CustomerOrderData(
                name: name,
                email: email,
                address: address,
                phoneNumber: phoneNumber,
                orderDetails: orderDetails
            )
        }
        
        return nil
    }
}
