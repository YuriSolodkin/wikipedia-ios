import SwiftUI
import WMF

class UserInput: ObservableObject {
    @Published var text: String = ""
}

class VanishAccountCustomUIHostingController: UIHostingController<VanishAccountContentView> {
    
    enum LocalizedStrings {
        static let backConfirmationTitle = WMFLocalizedString("vanish-account-back-confirm-title", value: "Are you sure you want to discard this vanish request?", comment: "Title of confirmation alert on vanishing request screen, if user taps Back after filling out information.")
        static let backConfirmationDiscard = WMFLocalizedString("vanish-account-back-confirm-discard", value: "Discard Request", comment: "Text of confirmation alert discard option on vanishing request screen, if user taps Back after filling out information. This option backs out of the screen.")
        static let backConfirmationKeepEditing = WMFLocalizedString("vanish-account-back-confirm-keep-editing", value: "Keep Editing", comment: "Text of confirmation alert keep editing option on vanishing request screen, if user taps Back after filling out information. This option keeps them on the screen to continue editing.")
    }
    
    let userInput = UserInput()
    
    init(title: String, theme: Theme, username: String) {
        super.init(rootView: VanishAccountContentView(userInput: userInput, theme: theme, username: username))
        self.title = title
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // Custom back button, so we can present the action sheet
        let newBackButton = UIBarButtonItem(title: CommonStrings.accessibilityBackTitle, style: .plain, target: self, action: #selector(tappedBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func tappedBack() {
        if userInput.text.count > 0 {
            let alertController = UIAlertController(title: LocalizedStrings.backConfirmationTitle, message: nil, preferredStyle: .actionSheet)
            let discardAction = UIAlertAction(title: LocalizedStrings.backConfirmationDiscard, style: .destructive) { action in
                self.navigationController?.popViewController(animated: true)
            }
            let keepEditingAction = UIAlertAction(title: LocalizedStrings.backConfirmationKeepEditing, style: .cancel)
            
            alertController.addAction(discardAction)
            alertController.addAction(keepEditingAction)
            alertController.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
            
            present(alertController, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}