import UIKit

class LoginViewController: UIViewController {
  
  private let loginButton: KOLoginButton = {
    let button = KOLoginButton()
    button.addTarget(self, action: #selector(touchUpLoginButton(_:)), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    layout()
  }
  
  @objc private func touchUpLoginButton(_ sender: UIButton) {
    guard let session = KOSession.shared() else {
      return
    }
    
    if session.isOpen() {
      session.close()
    }
    
    session.open { (error) in
      if error != nil || !session.isOpen() { return }
      KOSessionTask.userMeTask(completion: { (error, user) in
        guard let user = user,
              let email = user.account?.email,
              let nickname = user.nickname else { return }
        
        let mainVC = TestViewController()
        mainVC.emailLabel.text = email
        mainVC.nicnameLabel.text = nickname
        
        self.present(mainVC, animated: false, completion: nil)
      })
    }
  }

  private func layout() {
    let guide = view.safeAreaLayoutGuide
    view.addSubview(loginButton)
    
    loginButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
    loginButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
    loginButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -30).isActive = true
    loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }
}
