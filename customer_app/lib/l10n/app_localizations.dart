import 'package:flutter/material.dart';

/// App Localizations - Base class for multi-language support
/// Supports: English (en), Spanish (es), Hindi (hi), Nepali (ne)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish
    Locale('hi', ''), // Hindi
    Locale('ne', ''), // Nepali
  ];

  // Get translations based on current locale
  Map<String, String> get _localizedValues {
    switch (locale.languageCode) {
      case 'es':
        return _spanishTranslations;
      case 'hi':
        return _hindiTranslations;
      case 'ne':
        return _nepaliTranslations;
      case 'en':
      default:
        return _englishTranslations;
    }
  }

  String translate(String key) {
    return _localizedValues[key] ?? key;
  }

  // Getters for commonly used strings
  String get appName => translate('app_name');
  String get home => translate('home');
  String get dashboard => translate('dashboard');
  String get categories => translate('categories');
  String get cart => translate('cart');
  String get profile => translate('profile');
  String get orders => translate('orders');
  String get products => translate('products');
  String get search => translate('search');
  String get notifications => translate('notifications');
  String get messages => translate('messages');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get firstName => translate('first_name');
  String get lastName => translate('last_name');
  String get phone => translate('phone');
  String get address => translate('address');
  String get city => translate('city');
  String get state => translate('state');
  String get zipCode => translate('zip_code');
  String get country => translate('country');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get remove => translate('remove');
  String get update => translate('update');
  String get submit => translate('submit');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get retry => translate('retry');
  String get noData => translate('no_data');
  String get noResults => translate('no_results');
  
  // Shopping
  String get addToCart => translate('add_to_cart');
  String get buyNow => translate('buy_now');
  String get checkout => translate('checkout');
  String get total => translate('total');
  String get subtotal => translate('subtotal');
  String get shipping => translate('shipping');
  String get tax => translate('tax');
  String get discount => translate('discount');
  String get price => translate('price');
  String get quantity => translate('quantity');
  String get inStock => translate('in_stock');
  String get outOfStock => translate('out_of_stock');
  String get productDetails => translate('product_details');
  String get reviews => translate('reviews');
  String get rating => translate('rating');
  
  // Orders
  String get myOrders => translate('my_orders');
  String get orderDetails => translate('order_details');
  String get orderNumber => translate('order_number');
  String get orderDate => translate('order_date');
  String get orderStatus => translate('order_status');
  String get trackOrder => translate('track_order');
  String get cancelOrder => translate('cancel_order');
  
  // Status
  String get pending => translate('pending');
  String get processing => translate('processing');
  String get shipped => translate('shipped');
  String get delivered => translate('delivered');
  String get cancelled => translate('cancelled');
  
  // Analytics
  String get analytics => translate('analytics');
  String get revenue => translate('revenue');
  String get salesTrends => translate('sales_trends');
  String get topProducts => translate('top_products');
  String get customerBehavior => translate('customer_behavior');
  String get exportData => translate('export_data');
  
  // Language
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get english => translate('english');
  String get spanish => translate('spanish');
  String get hindi => translate('hindi');
  String get nepali => translate('nepali');

  // Profile
  String get editProfile => translate('edit_profile');
  String get fullName => translate('full_name');
  String get profileUpdated => translate('profile_updated');

  // Dashboard
  String get hello => translate('hello');
  String get welcomeBack => translate('welcome_back');
  String get customer => translate('customer');
  String get totalOrders => translate('total_orders');
  String get totalSpent => translate('total_spent');
  String get activeOrders => translate('active_orders');
  String get recentOrders => translate('recent_orders');
  String get seeAll => translate('see_all');
  String get viewAll => translate('view_all');
  String get browseProducts => translate('browse_products');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'hi', 'ne'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// English Translations
const Map<String, String> _englishTranslations = {
  'app_name': 'INDULINK',
  'home': 'Home',
  'dashboard': 'Dashboard',
  'categories': 'Categories',
  'cart': 'Cart',
  'profile': 'Profile',
  'orders': 'Orders',
  'products': 'Products',
  'search': 'Search',
  'notifications': 'Notifications',
  'messages': 'Messages',
  'settings': 'Settings',
  'logout': 'Logout',
  'login': 'Login',
  'register': 'Register',
  'email': 'Email',
  'password': 'Password',
  'confirm_password': 'Confirm Password',
  'first_name': 'First Name',
  'last_name': 'Last Name',
  'phone': 'Phone',
  'address': 'Address',
  'city': 'City',
  'state': 'State',
  'zip_code': 'Zip Code',
  'country': 'Country',
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'add': 'Add',
  'remove': 'Remove',
  'update': 'Update',
  'submit': 'Submit',
  'confirm': 'Confirm',
  'yes': 'Yes',
  'no': 'No',
  'ok': 'OK',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'retry': 'Retry',
  'no_data': 'No data available',
  'no_results': 'No results found',
  'add_to_cart': 'Add to Cart',
  'buy_now': 'Buy Now',
  'checkout': 'Checkout',
  'total': 'Total',
  'subtotal': 'Subtotal',
  'shipping': 'Shipping',
  'tax': 'Tax',
  'discount': 'Discount',
  'price': 'Price',
  'quantity': 'Quantity',
  'in_stock': 'In Stock',
  'out_of_stock': 'Out of Stock',
  'product_details': 'Product Details',
  'reviews': 'Reviews',
  'rating': 'Rating',
  'my_orders': 'My Orders',
  'order_details': 'Order Details',
  'order_number': 'Order Number',
  'order_date': 'Order Date',
  'order_status': 'Order Status',
  'track_order': 'Track Order',
  'cancel_order': 'Cancel Order',
  'pending': 'Pending',
  'processing': 'Processing',
  'shipped': 'Shipped',
  'delivered': 'Delivered',
  'cancelled': 'Cancelled',
  'analytics': 'Analytics',
  'revenue': 'Revenue',
  'sales_trends': 'Sales Trends',
  'top_products': 'Top Products',
  'customer_behavior': 'Customer Behavior',
  'export_data': 'Export Data',
  'language': 'Language',
  'select_language': 'Select Language',
  'english': 'English',
  'spanish': 'Spanish',
  'hindi': 'Hindi',
  'nepali': 'Nepali',
  'edit_profile': 'Edit Profile',
  'full_name': 'Full Name',
  'profile_updated': 'Profile Updated',
  'hello': 'Hello',
  'welcome_back': 'Welcome back',
  'customer': 'Customer',
  'total_orders': 'Total Orders',
  'total_spent': 'Total Spent',
  'active_orders': 'Active Orders',
  'recent_orders': 'Recent Orders',
  'see_all': 'See All',
  'view_all': 'View All',
  'browse_products': 'Browse Products',
};

// Spanish Translations
const Map<String, String> _spanishTranslations = {
  'app_name': 'INDULINK',
  'home': 'Inicio',
  'dashboard': 'Panel',
  'categories': 'Categorías',
  'cart': 'Carrito',
  'profile': 'Perfil',
  'orders': 'Pedidos',
  'products': 'Productos',
  'search': 'Buscar',
  'notifications': 'Notificaciones',
  'messages': 'Mensajes',
  'settings': 'Configuración',
  'logout': 'Cerrar sesión',
  'login': 'Iniciar sesión',
  'register': 'Registrarse',
  'email': 'Correo electrónico',
  'password': 'Contraseña',
  'confirm_password': 'Confirmar contraseña',
  'first_name': 'Nombre',
  'last_name': 'Apellido',
  'phone': 'Teléfono',
  'address': 'Dirección',
  'city': 'Ciudad',
  'state': 'Estado',
  'zip_code': 'Código postal',
  'country': 'País',
  'save': 'Guardar',
  'cancel': 'Cancelar',
  'delete': 'Eliminar',
  'edit': 'Editar',
  'add': 'Agregar',
  'remove': 'Quitar',
  'update': 'Actualizar',
  'submit': 'Enviar',
  'confirm': 'Confirmar',
  'yes': 'Sí',
  'no': 'No',
  'ok': 'OK',
  'loading': 'Cargando...',
  'error': 'Error',
  'success': 'Éxito',
  'retry': 'Reintentar',
  'no_data': 'No hay datos disponibles',
  'no_results': 'No se encontraron resultados',
  'add_to_cart': 'Agregar al carrito',
  'buy_now': 'Comprar ahora',
  'checkout': 'Pagar',
  'total': 'Total',
  'subtotal': 'Subtotal',
  'shipping': 'Envío',
  'tax': 'Impuesto',
  'discount': 'Descuento',
  'price': 'Precio',
  'quantity': 'Cantidad',
  'in_stock': 'En stock',
  'out_of_stock': 'Agotado',
  'product_details': 'Detalles del producto',
  'reviews': 'Reseñas',
  'rating': 'Calificación',
  'my_orders': 'Mis pedidos',
  'order_details': 'Detalles del pedido',
  'order_number': 'Número de pedido',
  'order_date': 'Fecha del pedido',
  'order_status': 'Estado del pedido',
  'track_order': 'Rastrear pedido',
  'cancel_order': 'Cancelar pedido',
  'pending': 'Pendiente',
  'processing': 'Procesando',
  'shipped': 'Enviado',
  'delivered': 'Entregado',
  'cancelled': 'Cancelado',
  'analytics': 'Analítica',
  'revenue': 'Ingresos',
  'sales_trends': 'Tendencias de ventas',
  'top_products': 'Productos principales',
  'customer_behavior': 'Comportamiento del cliente',
  'export_data': 'Exportar datos',
  'language': 'Idioma',
  'select_language': 'Seleccionar idioma',
  'english': 'Inglés',
  'spanish': 'Español',
  'hindi': 'Hindi',
  'nepali': 'Nepalí',
  'edit_profile': 'Editar Perfil',
  'full_name': 'Nombre Completo',
  'profile_updated': 'Perfil Actualizado',
};

// Hindi Translations
const Map<String, String> _hindiTranslations = {
  'app_name': 'INDULINK',
  'home': 'होम',
  'dashboard': 'डैशबोर्ड',
  'categories': 'श्रेणियाँ',
  'cart': 'कार्ट',
  'profile': 'प्रोफाइल',
  'orders': 'ऑर्डर',
  'products': 'उत्पाद',
  'search': 'खोजें',
  'notifications': 'सूचनाएं',
  'messages': 'संदेश',
  'settings': 'सेटिंग्स',
  'logout': 'लॉग आउट',
  'login': 'लॉग इन',
  'register': 'रजिस्टर',
  'email': 'ईमेल',
  'password': 'पासवर्ड',
  'confirm_password': 'पासवर्ड की पुष्टि करें',
  'first_name': 'पहला नाम',
  'last_name': 'अंतिम नाम',
  'phone': 'फोन',
  'address': 'पता',
  'city': 'शहर',
  'state': 'राज्य',
  'zip_code': 'पिन कोड',
  'country': 'देश',
  'save': 'सहेजें',
  'cancel': 'रद्द करें',
  'delete': 'हटाएं',
  'edit': 'संपादित करें',
  'add': 'जोड़ें',
  'remove': 'हटाएं',
  'update': 'अपडेट करें',
  'submit': 'जमा करें',
  'confirm': 'पुष्टि करें',
  'yes': 'हाँ',
  'no': 'नहीं',
  'ok': 'ठीक है',
  'loading': 'लोड हो रहा है...',
  'error': 'त्रुटि',
  'success': 'सफलता',
  'retry': 'पुनः प्रयास करें',
  'no_data': 'कोई डेटा उपलब्ध नहीं',
  'no_results': 'कोई परिणाम नहीं मिला',
  'add_to_cart': 'कार्ट में जोड़ें',
  'buy_now': 'अभी खरीदें',
  'checkout': 'चेकआउट',
  'total': 'कुल',
  'subtotal': 'उपयोग',
  'shipping': 'शिपिंग',
  'tax': 'टैक्स',
  'discount': 'छूट',
  'price': 'कीमत',
  'quantity': 'मात्रा',
  'in_stock': 'स्टॉक में',
  'out_of_stock': 'स्टॉक खत्म',
  'product_details': 'उत्पाद विवरण',
  'reviews': 'समीक्षाएं',
  'rating': 'रेटिंग',
  'my_orders': 'मेरे ऑर्डर',
  'order_details': 'ऑर्डर विवरण',
  'order_number': 'ऑर्डर नंबर',
  'order_date': 'ऑर्डर तारीख',
  'order_status': 'ऑर्डर स्थिति',
  'track_order': 'ऑर्डर ट्रैक करें',
  'cancel_order': 'ऑर्डर रद्द करें',
  'pending': 'लंबित',
  'processing': 'प्रोसेसिंग',
  'shipped': 'भेज दिया',
  'delivered': 'डिलीवर किया गया',
  'cancelled': 'रद्द',
  'analytics': 'विश्लेषण',
  'revenue': 'राजस्व',
  'sales_trends': 'बिक्री के रुझान',
  'top_products': 'शीर्ष उत्पाद',
  'customer_behavior': 'ग्राहक व्यवहार',
  'export_data': 'डेटा निर्यात करें',
  'language': 'भाषा',
  'select_language': 'भाषा चुनें',
  'english': 'अंग्रेज़ी',
  'spanish': 'स्पेनिश',
  'hindi': 'हिन्दी',
  'nepali': 'नेपाली',
  'edit_profile': 'प्रोफ़ाइल संपादित करें',
  'full_name': 'पूरा नाम',
  'profile_updated': 'प्रोफ़ाइल अपडेट हुई',
  'hello': 'नमस्ते',
  'welcome_back': 'वापसी पर स्वागत है',
  'customer': 'ग्राहक',
  'total_orders': 'कुल ऑर्डर',
  'total_spent': 'कुल खर्च',
  'active_orders': 'सक्रिय ऑर्डर',
  'recent_orders': 'हाल के ऑर्डर',
  'see_all': 'सभी देखें',
  'view_all': 'सभी देखें',
  'browse_products': 'उत्पाद ब्राउज़ करें',
};

// Nepali Translations
const Map<String, String> _nepaliTranslations = {
  'app_name': 'INDULINK',
  'home': 'गृह',
  'dashboard': 'ड्यासबोर्ड',
  'categories': 'वर्गहरू',
  'cart': 'कार्ट',
  'profile': 'प्रोफाइल',
  'orders': 'अर्डरहरू',
  'products': 'उत्पादनहरू',
  'search': 'खोज्नुहोस्',
  'notifications': 'सूचनाहरू',
  'messages': 'सन्देशहरू',
  'settings': 'सेटिङहरू',
  'logout': 'लग आउट',
  'login': 'लग इन',
  'register': 'दर्ता गर्नुहोस्',
  'email': 'इमेल',
  'password': 'पासवर्ड',
  'confirm_password': 'पासवर्ड पुष्टि गर्नुहोस्',
  'first_name': 'पहिलो नाम',
  'last_name': 'अन्तिम नाम',
  'phone': 'फोन',
  'address': 'ठेगाना',
  'city': 'शहर',
  'state': 'राज्य',
  'zip_code': 'पिन कोड',
  'country': 'देश',
  'save': 'बचत गर्नुहोस्',
  'cancel': 'रद्द गर्नुहोस्',
  'delete': 'मेटाउनुहोस्',
  'edit': 'सम्पादन गर्नुहोस्',
  'add': 'थप्नुहोस्',
  'remove': 'हटाउनुहोस्',
  'update': 'अद्यावधिक गर्नुहोस्',
  'submit': 'पेश गर्नुहोस्',
  'confirm': 'पुष्टि गर्नुहोस्',
  'yes': 'हो',
  'no': 'होइन',
  'ok': 'ठीक छ',
  'loading': 'लोड हुँदैछ...',
  'error': 'त्रुटि',
  'success': 'सफलता',
  'retry': 'पुन: प्रयास गर्नुहोस्',
  'no_data': 'कुनै डाटा उपलब्ध छैन',
  'no_results': 'कुनै नतिजा फेला परेन',
  'add_to_cart': 'कार्टमा थप्नुहोस्',
  'buy_now': 'अहिले किन्नुहोस्',
  'checkout': 'चेकआउट',
  'total': 'जम्मा',
  'subtotal': 'उप-जम्मा',
  'shipping': 'ढुवानी',
  'tax': 'कर',
  'discount': 'छुट',
  'price': 'मूल्य',
  'quantity': 'परिमाण',
  'in_stock': 'स्टकमा छ',
  'out_of_stock': 'स्टक सकियो',
  'product_details': 'उत्पादन विवरण',
  'reviews': 'समीक्षाहरू',
  'rating': 'मूल्याङ्कन',
  'my_orders': 'मेरो अर्डरहरू',
  'order_details': 'अर्डर विवरण',
  'order_number': 'अर्डर नम्बर',
  'order_date': 'अर्डर मिति',
  'order_status': 'अर्डर स्थिति',
  'track_order': 'अर्डर ट्रयाक गर्नुहोस्',
  'cancel_order': 'अर्डर रद्द गर्नुहोस्',
  'pending': 'विचाराधीन',
  'processing': 'प्रशोधन',
  'shipped': 'पठाइयो',
  'delivered': 'डेलिभर गरिएको',
  'cancelled': 'रद्द गरियो',
  'analytics': 'विश्लेषण',
  'revenue': 'राजस्व',
  'sales_trends': 'बिक्री प्रवृत्ति',
  'top_products': 'शीर्ष उत्पादनहरू',
  'customer_behavior': 'ग्राहक व्यवहार',
  'export_data': 'डाटा निर्यात गर्नुहोस्',
  'language': 'भाषा',
  'select_language': 'भाषा चयन गर्नुहोस्',
  'english': 'अंग्रेजी',
  'spanish': 'स्पेनिस',
  'hindi': 'हिन्दी',
  'nepali': 'नेपाली',
  'edit_profile': 'प्रोफाइल सम्पादन गर्नुहोस्',
  'full_name': 'पूरा नाम',
  'profile_updated': 'प्रोफाइल अपडेट गरियो',
  'hello': 'नमस्ते',
  'welcome_back': 'फर्कनु भएकोमा स्वागत छ',
  'customer': 'ग्राहक',
  'total_orders': 'कुल अर्डरहरू',
  'total_spent': 'कुल खर्च',
  'active_orders': 'सक्रिय अर्डरहरू',
  'recent_orders': 'हालका अर्डरहरू',
  'see_all': 'सबै हेर्नुहोस्',
  'view_all': 'सबै हेर्नुहोस्',
  'browse_products': 'उत्पादनहरू ब्राउज गर्नुहोस्',
};
