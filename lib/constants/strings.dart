class Strings {
  Strings._();

  //General
  static const appName = "Fight Blight BMore";
  static const introTitle = 'A blighted Baltimore is a bleeding Baltimore.';
  static const introDescription =
      'Join the fight against Bmore blight by documenting abandoned buildings, unsafe demolition zones, and other signs of neglect. Simply take a photo or video and upload it to the app and help create the bigger picture of blight in Bmore. It is a critical step toward safer, greener, and more economically vibrant communities.';
  static const email = "Email";
  static const emailHint = "Email address";
  static const emailRegisterHint =
      "Enter an email address to set up an account";
  static const password = "Password";
  static const passwordHint = "Enter a password";
  static const create = "Create";
  static const createAccount = "Create Account";
  static const login = "Login";
  static const firstName = "First Name";
  static const lastName = "Last Name";
  static const userName = "Username";
  static const verifyPassword = "Verify Password";
  static const verifyPasswordHint = "Re-enter Password";
  static const accountType = "Account Type";
  static const blightReporter = "Blight Reporter";
  static const developer = "Developer";
  static const select = "Select";
  static const get_started = "Get Started";
  static const reset = "Reset";
  static const resetPassword = "Reset Password";
  static const property_name = "Enter Property Name";
  static const post_description = "Write a caption or description.";
  static const address = "Address";
  static const enter_address = "Enter Address";
  static const pinpoint_location = "Pinpoint location or\nenter address below.";
  static const neighborhood = "Neighborhood (optional)";
  static const exNeighborhood = "";
  static const post_tags = "Tags";
  static const next = "Next";
  static const add = "Add";
  static const ok = "Ok";
  static const no = "No";
  static const yes = "Yes";
  static const flag = "Flag";
  static const cancel = "Cancel";
  static const saveTags = "Save Tags";
  static const post = "Post";
  static const search = "Search";
  static const update = "Update";
  static const save = "Save";
  static const remove = "Remove";
  static const show = "Show";
  static const hide = "Hide";
  static const photo = 'Photo';
  static const video = 'Video';
  static const resendVerificationLink = "Resend verification link";
  static const titleTags =
      'Select the tag(s) that best describe the condition of the current property.';
  static const accountCreated =
      'Your account has been created.\nA verification email has been sent to:';
  static const warnSaveTags =
      'Once these new tags are saved\nthey cannot be removed.\nDo you want to proceed?';
  static const dontShowMessage = 'Do not show this message again.';
  static const resetYourPassword = 'Reset your password.';
  static const newPassword = 'New Password';
  static const reEnterNewPassword = 'Re-Enter New Password';
  static const resetPasswordOr = 'Reset your password or';
  static const changePasswordEmail =
      'Enter your email address to\nreceive a link to reset your password.';
  static const logIn = 'Login';
  static const forgotPassword = 'Forgot Password?';
  static const createAnAccount = 'create an account.';
  static const loginOr = 'Log in or';
  static const requestTreePlantation =
      'Check to request a tree\nplanting or replacement';
  static const checkEviction = 'Check to report an eviction at \nthis property.';
  static const reportAs = 'Report as:';
  static const reportingEviction = 'Reporting Eviction';
  static const reportEviction = 'Report Eviction';
  static const clickForEviction =
      'Click here to report an eviction at this property.';
  static const evictionReported =
      'An eviction has been reported at this property.';
  static const evictionReported2 = 'An eviction has been reported.';
  static const thanksFbb = 'Thank you for fighting Bmore Blight.';
  static const infoEviction =
      'This action will report an eviction at:\nDoor Window Broken.';
  static const doorWindowBroken = 'Door Window Broken';
  static const photoLibrary = 'Photo Library';
  static const takeVideo = 'Take a Video';
  static const takePhoto = 'Take a Photo';
  static const titleActionSheet =
      'Take a photo or video or select one from your library.';
  static const titleProfileActionSheet = 'Change Profile Photo';
  static const areYouSure = 'This action cannot be undone.';
  static const wantRemovePhoto = 'Do you want to remove this photo?';
  static const wantRemoveVideo = 'Do you want to remove this video?';
  static const add_comment = "Add your comment";

  //screen title
  static const add_media = 'Add Media';
  static const add_property = 'Add Property';
  static const account_settings = 'Account Settings';

  //settings
  static const profile = 'Profile';
  static const change_password = 'Change Password';
  static const bookmarks = 'Bookmarks';
  static const notifications = 'Notifications';
  static const subscriptions = 'Subscriptions';
  static const help = 'Help';
  static const privacy_terms = 'Privacy and Terms of Use';
  static const contact_admin = 'Contact Admin';
  static const aboutFightBlight = 'About Fight Blight Bmore';
  static const logOut = 'Log Out';
  static const logout = 'Logout';
  static const editProfile = 'Edit Profile';

  static const privacyPolicyHeading = 'Privacy and Terms of Use';
  static const aboutUsHeading = 'About Us';
  static const helpHeading = 'Help Us';

  //permission messages
  static const checkInternetConnection = "Please check your connection.";
  static const locationPermissionHeading = "Access to location denied.";
  static const locationPermissionMessage =
      "Allow access to the location services.";
  static const locationFailureError = "Cannot get current location.";
  static const locationFailureMessage = "Please enable your GPS and try again.";
  static const confirmLogout = "Do you really want to logout?";

  //success message
  static const successPost = 'Thank you for reporting Bmore blight.';
  static const passwordChanged =
      'Your password has successfully \n been changed! Please login \n using your new password.';
  static const resetPasswordLinkSent =
      'An email to reset your \n password has been sent.';
  static const uploadSuccessful = 'Your photo or video posted successfully.';

  //error text
  static const emptyPassword = "A password is required.";
  static const noMedia =
      'A maximum of 4 photos and 1 video can be uploaded with your post.';
  static const minMedia = 'Please provide at least one photo or video.';
  static const emptyPropertyDetails =
      'Please provide the required property details.';
  static const maxLengthPassword =
      "Password must be at least 8 characters long.";
  static const validatePassword =
      "Password must contain at least 1 capital letter and 1 number";
  static const emptyEmail = "An email address is required.";
  static const validateEmail = 'Please enter a valid email address.';
  static const invalidCode = 'The verification link is invalid or expired.';
  static const emptyConfirmPassword = "Please confirm your password.";
  static const somethingWentWrong =
      'Something went wrong. Please try again later or contact the Admin.';
  static const networkError = 'Please check your network connection.';
  static const emailVerifyError =
      'We are unable to verify this email. Please try again.';
  static const weakPassword =
      'A stronger password is required. Please try again.';
  static const existingAccount =
      'An account with this email address already exists.';
  static const noUserFound =
      'An account with this email address does not exist.';
  static const wrongPassword = 'The password provided is incorrect.';
  static const maxLengthConfirmPassword =
      "Password must be at least 8 characters long.";
  static const passwordNotMatched =
      "These passwords do not match. Please re-enter your password.";
  static const validateConfirmPassword =
      "Password must contain at least 1 capital letter and 1 number";
  static const emptyAddress = "An address is required.";
  static const emptyDescription = "A description of the property is required.";
  static const emptyName = "A property name is required.";
  static const validateName =
      "The property name can be a maximum of 50 characters.";
  static const validateDescription =
      "The property description can be a maximum of 250 characters.";
  static const maxVideoUploads =
      "This property has reached the maximum limit for video uploads.";
  static const maxPhotoUploads =
      "This property has reached the maximum limit for uploading photos.";

  static const emptyFirstName = "The first name is required.";
  static const emptyLastName = "The last name is required.";
  static const emptyUserName = "A username is required.";
  static const emptyAccountType = "Please select the account type.";
  static const existingUsername =
      'An account with this username already exists.';
  static const emptyComment = "The comment is required.";
  static const emptyFlagReason = "The reason to flag the property is required.";
  static const warnAddComment =
      "Once this comment is saved\nit cannot be removed\nDo you want to proceed?";

  static const faqs = "Frequently Asked Questions";

  static const warnRequestTree =
      "Would you like to request a tree be\nplanted or replaced at this property?\nThis action cannot be undone.";
  static const warnFlagPost =
      "Explain the reason you are\nflagging the current property.";
  static const removeBookmark = "Do you really want to remove this bookmark?";
  static const successFlaggedProperty =
      "This property has been added to your bookmark list and flagged for an Admin to review. No further actions can be taken on this property until the post has been reviewed and the flag removed. An Admin may e-mail you for further information.";
  static const warnFlaggedProperty =
      "This property’s activity is being reviewed by the FBB Admin. The property post will be unavailable while it is being reviewed. You will receive a notification when the property review has been completed. Thank you for fighting Bmore Blight.";

  //placeholder text
  static const placeholderName = "Bmore Blight";
  static const placeholderDescription =
      "There is blight at this location that needs to be addressed for the improvement of our neighborhoods.";
}
