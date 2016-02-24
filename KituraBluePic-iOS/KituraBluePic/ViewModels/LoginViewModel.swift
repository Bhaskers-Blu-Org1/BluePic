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
//
//
//import UIKit
//
//class LoginViewModel: NSObject {
//    
//    
//    //callback used to inform the LoginViewController whether facebook authentication was a success or not
//    var fbAuthCallback: ((Bool!)->())!
//    
//    
//    /**
//     Method to initialize view model with the appropriate callback
//     
//     - parameter fbAuthCallback: callback to be executed on completion of trying to authenticate with Facebook
//     
//     - returns: an instance of this view model
//     */
//    init(fbAuthCallback: ((Bool!)->())) {
//        super.init()
//        
//        self.fbAuthCallback = fbAuthCallback
//        
//    }
//    
//    
//    /**
//     Method to attempt authenticating with Facebook and call the callback if failure, otherwise will continue to object storage container creation
//     */
//    func authenticateWithFacebook() {
//        FacebookDataManager.SharedInstance.authenticateUser({(response: FacebookDataManager.NetworkRequest) in
//            if (response == FacebookDataManager.NetworkRequest.Success) {
//                print("successfully logged into facebook with keys:")
//                if let userID = FacebookDataManager.SharedInstance.fbUniqueUserID {
//                    if let userDisplayName = FacebookDataManager.SharedInstance.fbUserDisplayName {
//                        print("\(userID)")
//                        print("\(userDisplayName)")
//                        //save that user has not pressed login later
//                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "hasPressedLater")
//                        NSUserDefaults.standardUserDefaults().synchronize()
//                        
//                      
//                    }
//                }
//            }
//            else {
//                print("failure logging into facebook")
//                self.fbAuthCallback(false)
//
//            }
//        })
//    }
//    
//    
//    func dummyLogin() {
//    
//        
//    }
//    
//}