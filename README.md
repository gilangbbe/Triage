# Triage - Customer Care Management App

A powerful iOS application designed to supercharge micro-enterprise customer care processes by providing seamless customer data management and order parsing capabilities through a custom keyboard extension.

## Features

### 📱 Main App
- **Customer Order Management**: Create, read, update, and delete customer orders
- **MVVM Architecture**: Clean, maintainable code structure following best practices
- **Smart Data Parsing**: Automatically parse customer information from text messages
- **Analytics Dashboard**: Track order statistics and trends
- **Search & Filter**: Quickly find orders by customer name, email, or address
- **Status Management**: Track order progress (Pending, Processing, Completed, Cancelled)

### ⌨️ Keyboard Extension
- **Custom iOS Keyboard**: Parse customer data directly from messaging apps
- **WhatsApp Integration**: Copy customer orders from WhatsApp and parse instantly
- **Cross-App Compatibility**: Works with any messaging or text input app
- **Real-time Parsing**: Instant feedback on parsed customer data
- **Shared Data**: Seamlessly syncs with the main app using App Groups

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern for clean separation of concerns:

```
triage/
├── Models/
│   └── CustomerOrder.swift          # Data models and parsing logic
├── ViewModels/
│   ├── OrderListViewModel.swift     # Order list business logic
│   └── AddOrderViewModel.swift      # Add/edit order logic
├── Views/
│   ├── OrderListView.swift          # Main order list interface
│   ├── OrderDetailView.swift        # Order detail and editing
│   ├── AddOrderView.swift           # Add new order form
│   ├── AnalyticsView.swift          # Analytics dashboard
│   └── SettingsView.swift           # App settings and configuration
├── Managers/
│   └── DataManager.swift            # Data persistence and sharing
└── TriageKeyboard/
    └── KeyboardViewController.swift  # Keyboard extension logic
```

## Supported Message Formats

The parser is flexible and supports various formats:

```
name: John Doe
email: john@example.com
address: 123 Main Street, City, State
phone: +1234567890
order: 2x Coffee (Large), 1x Sandwich

# Also supports Indonesian/local variations:
nama: Jane Smith
alamat: Jl. Sudirman No. 45
hp: 081234567890
pesanan: 3x Nasi Goreng, 2x Es Teh
```

## Installation & Setup

### 1. Clone and Build
```bash
git clone [your-repo-url]
cd triage
open triage.xcodeproj
```

### 2. Add Keyboard Extension Target
1. In Xcode, select your project
2. Click the '+' button to add a new target
3. Choose iOS → Application Extension → Custom Keyboard Extension
4. Name it "TriageKeyboard"
5. Set bundle identifier: `com.yourcompany.triage.TriageKeyboard`

### 3. Configure App Groups
1. Select your main app target
2. Go to Signing & Capabilities
3. Add "App Groups" capability
4. Add group: `group.com.yourcompany.triage`
5. Repeat for the TriageKeyboard target

### 4. Replace Generated Files
- Copy `TriageKeyboard/KeyboardViewController.swift` to your keyboard target
- Replace the generated `Info.plist` with the provided one

### 5. Enable Keyboard on Device
1. Go to Settings → General → Keyboard → Keyboards
2. Tap "Add New Keyboard"
3. Select "Triage Parser"
4. Enable "Allow Full Access"

## Usage

### Using the Main App
1. **Add Orders**: Tap the '+' button to add new customer orders
2. **Parse from Text**: Use the "Parse from Text" feature to automatically extract customer data
3. **Manage Orders**: View, edit, and update order status
4. **Analytics**: Track your business performance with built-in analytics

### Using the Keyboard Extension
1. Open any messaging app (WhatsApp, Messages, etc.)
2. Switch to the "Triage Parser" keyboard
3. Paste or type customer order information
4. Tap "Parse & Save" to automatically extract and save customer data
5. The parsed order will appear in your main Triage app

## Data Persistence

- **Local Storage**: Uses UserDefaults for simple, efficient data storage
- **Shared Container**: App Groups enable data sharing between main app and keyboard extension
- **Automatic Sync**: Data syncs automatically between keyboard and main app
- **Export Capability**: Export all customer data as JSON

## Security & Privacy

- **Local Data**: All customer data stays on your device
- **No Cloud Sync**: Complete privacy - no data sent to external servers
- **Secure Sharing**: App Groups provide secure data sharing between app and extension

## Development

### Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

### Key Technologies
- SwiftUI for modern, declarative UI
- Combine for reactive programming
- App Groups for secure data sharing
- Custom Keyboard Extension for cross-app functionality

### Building from Source
1. Open `triage.xcodeproj` in Xcode
2. Select your development team
3. Update bundle identifiers if needed
4. Build and run both targets (main app and keyboard extension)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements

- [ ] iCloud sync for data backup
- [ ] Export to CSV/Excel formats
- [ ] Customer communication templates
- [ ] Order fulfillment tracking
- [ ] Multi-language support
- [ ] Dark mode optimization
- [ ] iPad optimization
- [ ] Integration with popular e-commerce platforms

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@yourcompany.com or create an issue in this repository.

---

Made with ❤️ for micro-enterprises worldwide
