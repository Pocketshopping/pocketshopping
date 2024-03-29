//^:loading indicator
//MIT:message indicator
//OOI: open order indicator-InHouse
//OHI: open order indicator-HomeDelivery
//PIT: product indicator
//SIT: Staff indicator
//PHI: Pocket unit history indicator
//PUI: Pocket unit usage indicator
//SEI: Settings indicator
//BIT: Branch indicator
//AIT: Account Indicator
//SET: Search Empty Indicator
//SPI: other source product indicator
const String LoadingIndicatorTitle = '^';
const String MessageIndicatorTitle = 'MIT';
const String OpenOrderIndicatorTitle = 'OOI';
const String OpenOrderHomeDeliveryIndicatorTitle = 'OHI';
const String ProductIndicatorTitle = 'PIT';
const String StaffIndicatorTitle = 'SIT';
const String PocketUnitHistoryIndicatorTitle = 'PHI';
const String PocketUnitUsageIndicatorTitle = 'PUI';
const String SettingsIndicatorTitle = 'SEI';
const String BranchIndicatorTitle = 'BIT';
const String AccountIndicatorTitle = 'AIT';
const String SearchEmptyIndicatorTitle = 'SET';
const String SearchEmptyOrderIndicatorTitle = 'EET';
const String SourceProductIndicatorTitle = 'SPI';
const String CompletedOrderIndicatorTitle = 'COI';
const String CancelledOrderIndicatorTitle = 'CAI';
const String ReviewsIndicatorTitle = 'RIT';
const String NewCustomerIndicatorTitle = 'NIT';
const String OldCustomerIndicatorTitle = 'OIT';
const String MerchantUIIndicatorTitle = 'MUT';
const String MyOpenOrderIndicatorTitle = 'MYO';
const MyClosedOrderIndicatorTitle = 'MYC';
const String PocketShoppingDefaultCover =
    'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2FpsCover.png?alt=media&token=690ccf94-1c3a-4263-9e88-f898116d4aa2';
const String PocketShoppingDefaultAvatar =
    'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Favatar.png?alt=media&token=7ef0593e-2289-4d25-ad27-34dc08d85040';
const String serverToken =
    'AAAAqX0WEGw:APA91bGWMn9QDp_xiH3fgsy8-4V348-0ltS2Pfjybk_lSafjSS8etIAry6jBzsc2n9eHj0SDr2TzYwVVBVmz2uhjftxPrhGLfWj9PgFRqAzOtck1_JjOsjMXyMYtGiqFoauMt5Z-LNLl';
const String WALLETAPI =
    'http://test.homlyng.com/api/'; // 'http://middleware.pocketshopping.com.ng/api/';
const String PAYSTACK =
    "Bearer sk_live_e1ee5fd989c97597e2f0431f09f8ccbacecbe215"; //sk_test_57f29ce25b5d4e53d0dc626a49caa98e7d6d1ebc";//sk_test_8c0cf47e2e690e41c984c7caca0966e763121968";
const String PRODUCTDEFAULT =
    "https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2FproductDefault.png?alt=media&token=658e76d8-f42e-4d16-b26e-d7166fcab7c8";
const String CURRENCY = "\u20A6";
const String PocketDefaultWallet = "304151834914";
const int TIMEOUT = 25;
const int CACHE_TIME_OUT = 5;
const String PaystackAPI = 'https://api.paystack.co/';
const String googleAPIKey = 'AIzaSyDWhKPubZYbSnuCUcOHyYptuQsXQYRDdSc';
const int requestWorkerID = 369;
const int merchantWorkerID = 963;
const String ABOUTUS = """ 
Pocketshopping is a platform that powers SME’s using special business analysis algorithm, flexible and fast delivery, tracking of logistics to ensure proper delivery of products and services Pocketshopping has identified the growing need of people seeking to shop and to get their goods delivered to them with ease and in shorter time intervals than the current systems, the platform is built to help customers to purchase goods and services anytime, anywhere. Utilizing a location-based algorithm it filters the closest business around the customer and help them to purchase at the comfort of their home and get their order delivered to them with the help of our delivery agents in no time.
""";
const PocketShoppingLogo =
    "https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Fblogo.png?alt=media&token=364c5f3a-1d1e-43f0-af69-88ba8eb3f344";
