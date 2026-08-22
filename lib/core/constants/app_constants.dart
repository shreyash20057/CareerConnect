class AppConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String jobsCollection = 'jobs';
  static const String companiesCollection = 'companies';
  static const String applicationsCollection = 'applications';
  static const String savedCollection = 'saved';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profilePhotosPath = 'profile_photos';
  static const String resumesPath = 'resumes';
  static const String companyLogosPath = 'company_logos';

  // Pagination
  static const int pageSize = 20;

  // Matching Weights
  static const double skillWeight = 0.50;
  static const double educationWeight = 0.25;
  static const double experienceWeight = 0.15;
  static const double locationWeight = 0.10;

  // App Info
  static const String appName = 'CareerConnect';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@careerconnect.app';
}

class AppStrings {
  // Auth
  static const String welcomeBack = 'Welcome back';
  static const String createAccount = 'Create account';
  static const String signIn = 'Sign in';
  static const String signUp = 'Sign up';
  static const String continueWithGoogle = 'Continue with Google';
  static const String forgotPassword = 'Forgot password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your network.';
  static const String authError = 'Authentication failed. Please try again.';

  // Success
  static const String profileUpdated = 'Profile updated successfully';
  static const String applicationSubmitted = 'Application submitted!';
  static const String savedOpportunity = 'Saved to your list';
  static const String removedOpportunity = 'Removed from saved';
}