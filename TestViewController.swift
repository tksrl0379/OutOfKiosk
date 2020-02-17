import UIKit

class TestViewController: UIViewController {
  
  let emailLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let nicnameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let logoutButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("로그아웃", for: .normal)
    button.addTarget(self, action: #selector(touchUpLogoutButton(_:)), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    layout()
  }
  
  @objc private func touchUpLogoutButton(_ sender: UIButton) {
    guard let session = KOSession.shared() else { return }
    session.logoutAndClose { (success, error) in
      if success {
        print("logout success.")
        self.dismiss(animated: true, completion: nil)
      } else {
        print(error?.localizedDescription)
      }
    }
  }
  
  private func layout() {
    let guide = view.safeAreaLayoutGuide
    view.addSubview(emailLabel)
    emailLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 30).isActive = true
    emailLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    
    view.addSubview(nicnameLabel)
    nicnameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30).isActive = true
    nicnameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    
    view.addSubview(logoutButton)
    logoutButton.topAnchor.constraint(equalTo: nicnameLabel.bottomAnchor, constant: 30).isActive = true
    logoutButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
  }
}
