/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/


import UIKit

class TabBarViewController: UITabBarController {
    
    /// Image view to temporarily cover feed and content so it doesn't appear to flash when showing login screen
    var backgroundImageView: UIImageView!
    
    // A view model that will keep state and do all the data handling for the TabBarViewController
    var viewModel : TabBarViewModel!
    
    
    /**
     Method called upon view did load. It creates an instance of the TabBarViewModel, sets the tabBar tint color, adds a background image view, and sets its delegate
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TabBarViewModel(passDataNotificationToTabBarVCCallback: handleDataNotification)
        
        self.tabBar.tintColor! = UIColor.whiteColor()
        
        self.addBackgroundImageView()
        
        self.delegate = self        
    }
    
    
    /**
     Method called upon view did appear. It tells the feed to start the loading animation and it trys to show login
     
     - parameter animated: Bool
     */
    override func viewDidAppear(animated: Bool) {
        
        self.viewModel.tellFeedToStartLoadingAnimation()

        self.checkServerConnection()
    }

    
    /**
     Method called as a callback from the OS when the app recieves a memory warning from the OS
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /**
     Method adds image view so no flickering occurs before showing login. Starts a simple loading animation that is dismissed when PULL from CloudantSyncClient completes
     */
    func addBackgroundImageView() {
        
        self.backgroundImageView = UIImageView(frame: self.view.frame)
        self.backgroundImageView.image = UIImage(named: "login_background")
        self.view.addSubview(self.backgroundImageView)
        
    }
    
    /**
     Method trys to show the login by asking the viewModel to try to show login
     */
    func tryToShowLogin() {
        viewModel.tryToShowLogin()
    }
    
    
    /**
     Method handles DataManagerNotifications passed to the view controller from its viewModel
     
     - parameter dataManagerNotification: DataManagerNotification
     */
    func handleDataNotification(dataManagerNotification : DataManagerNotification){
        
        switch dataManagerNotification {
        case .GotPastLoginCheck:
            hideBackgroundImage()
        case .PhotosUploadFailure:
            showUploadErrorAlert()
        case .UserNotAuthenticated:
            presentLoginVC()
        case .PhotosListFailure:
            showFeedErrorAlert()
        case .ServerConnectionFailure(let message):
            presentServerAlert(message)
        case .ServerConnectionChecked:
            tryToShowLogin()
            selectedIndex = 0 // switch to feed tab
        case .ServerConnectionSuccess:
            selectedIndex = 0 // switch to feed tab
        case .UserSignedOut:
            presentLoginVCAnimated()
           
        default: break
        }
        
    }
    
    
    /**
     Method hides the background image
     */
    func hideBackgroundImage() {
        
        //hide temp background image used to prevent flash animation
        self.backgroundImageView.hidden = true
        self.backgroundImageView.removeFromSuperview()
        
    }
    
    func checkServerConnection () {
        if let serverUrl = NSUserDefaults.standardUserDefaults().stringForKey(Utils.PREFERENCE_SERVER) {
            PhotosDataManager.SharedInstance.connect(serverUrl) { error in
                if let _ = error {
                    self.presentServerAlert("Bad server URL: " + serverUrl)
                }
                else {
                    DataManagerCalbackCoordinator.SharedInstance.sendNotification(.ServerConnectionChecked)
                }
            }
        }
        else {
            presentServerAlert("Server is not set")
        }
        
    }

    func presentServerAlert (message: String) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString(message, comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        hideBackgroundImage()
        selectedIndex = 3 // switch to settings tab
        
    }

    /**
     Method to show the error alert and asks user if they would like to retry getting feed data
     */
    func showFeedErrorAlert() {
        
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Oops! An error occurred downloading photos.", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Try Again", comment: ""), style: .Default, handler: { (action: UIAlertAction!) in
            self.viewModel.retryPullingFeedData() 
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    
    /**
     Method to show the error alert and asks user if they would like to retry pushing to object storage
     */
    func showUploadErrorAlert() {
        
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Oops! An error occurred uploading photo.", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Try Again", comment: ""), style: .Default, handler: { (action: UIAlertAction!) in
           CameraDataManager.SharedInstance.uploadPhotosIfThereAreAnyLeftInTheQueue()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action: UIAlertAction!) in
            
            CameraDataManager.SharedInstance.cancelUploadingPictureToObjectStorage()
            
        }))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    /**
     Method to show the login VC without animation
     */
    func presentLoginVC(){
        
        let loginVC = Utils.vcWithNameFromStoryboardWithName("loginVC", storyboardName: "Main") as! LoginViewController
        
        self.presentViewController(loginVC, animated: false, completion: { _ in
            
            self.hideBackgroundImage()
        })
   
    }
    
    
    /**
     Method to show the login VC with animation
     */
    func presentLoginVCAnimated(){
        
        let loginVC = Utils.vcWithNameFromStoryboardWithName("loginVC", storyboardName: "Main") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: { _ in
            self.hideBackgroundImage()
        })
        
    }


}


extension TabBarViewController: UITabBarControllerDelegate {
    
    /**
     Method is called right when the user selects a tab. It expects a return value that tells the TabBarViewController whether it should select that tab or not. In this case we check if the user has pressed the sign in later option in on the login VC. If the user has pressed the sign in later option, then we present the Login View Controller when the user presses the profile or camera tab. Else we show those tabs as normal.
     
     - parameter tabBarController: UITabBarController
     - parameter viewController:   UIViewController
     
     - returns: Bool
     */
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if let _ = viewController as? CameraViewController { //if camera tab is selected, show camera picker
            return checkIfUserPressedSignInLater(true)
        }
        else if let _ = viewController as? ProfileViewController {
            return checkIfUserPressedSignInLater(false)
        }
        else { //if feed selected, actually show it everytime
            return true
        }
    }
    
    
    /**
     Check if user has pressed sign in later button previously, and if he/she has, will show login if user taps camera or profile
     
     - parameter showCameraPicker: whether or not to show the camera picker (camera tab or profile tab tapped)
     
     - returns: Returns a boolean -- true if tab bar with show the selected tab, and false if it will not
     */
    func checkIfUserPressedSignInLater(showCameraPicker: Bool!) -> Bool! {
        if NSUserDefaults.standardUserDefaults().boolForKey("hasPressedLater") == true {
            presentLoginVCAnimated()
            return false
        }
        else { //only show camera picker if user has not pressed "sign in later"
            if (showCameraPicker == true) { //only show camera picker if tapped the camera tab
                CameraDataManager.SharedInstance.showImagePickerActionSheet(self)
                return false
            }
            else { //if tapping profile page and logged in, show that tab
                return true
            }
        }
    
    }
    
    
    
}

