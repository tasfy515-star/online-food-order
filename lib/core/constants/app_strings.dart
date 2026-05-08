class AppStrings {
  // App
  static const String appName = 'YumFood';
  static const String tagline = 'Delicious food at your doorstep';

  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String phone = 'Phone Number';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String signInWithGoogle = 'Continue with Google';
  static const String orContinueWith = 'Or continue with';

  // Roles
  static const String customer = 'Customer';
  static const String restaurantOwner = 'Restaurant Owner';
  static const String admin = 'Admin';
  static const String selectRole = 'I am a...';

  // Home
  static const String searchHint = 'Search food or restaurants...';
  static const String popularRestaurants = 'Popular Restaurants';
  static const String topBrands = 'Top Brands';
  static const String categories = 'Categories';
  static const String specialOffers = 'Special Offers';

  // Categories
  static const List<String> foodCategories = [
    'Biriyani', 'Burger', 'Pizza', 'Meatbox',
    'Doifuska', 'Bangladeshi', 'Cakes',
    'Dessert', 'Rice', 'Pasta',
  ];

  // Top Brands
  static const List<String> TopBrands = [
    'Kacchi Vai', "Sultan's Dine", 'KFC', "Domino's Pizza",
    'PizzaBurg', 'Chillox', 'Burger King',
  ];

  // Cart
  static const String cart = 'Cart';
  static const String addToCart = 'Add to Cart';
  static const String checkout = 'Checkout';
  static const String totalAmount = 'Total Amount';
  static const String deliveryFee = 'Delivery Fee';
  static const String grandTotal = 'Grand Total';

  // Payment
  static const String paymentMethod = 'Payment Method';
  static const String cashOnDelivery = 'Cash on Delivery';
  static const String bkash = 'bKash';
  static const String cardPayment = 'Card Payment';
  static const String placeOrder = 'Place Order';

  // Order
  static const String orderConfirmed = 'Order Confirmed!';
  static const String thankYou = 'Thank You!';
  static const String estimatedDelivery = 'Estimated Delivery';
  static const String preparing = 'Preparing';
  static const String readyForPickup = 'Ready for Pickup';
  static const String delivered = 'Delivered';

  // Navigation
  static const String home = 'Home';
  static const String search = 'Search';
  static const String orders = 'Orders';
  static const String account = 'Account';

  // Errors
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternetConnection = 'No internet connection';
  static const String sessionExpired = 'Session expired, please login again';
}
