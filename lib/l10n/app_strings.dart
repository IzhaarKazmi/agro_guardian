import 'package:flutter/widgets.dart';
import 'package:agro_guardian/services/weather_models.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  bool get isUrdu => locale.languageCode == 'ur';

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  String get appName => isUrdu ? 'ایگرو گارڈین' : 'Agro Guardian';
  String get splashTagline => isUrdu
      ? 'فصل کی بیماریوں کی اسمارٹ دیکھ بھال'
      : 'Smart crop disease care';
  String get pleaseLogin => isUrdu ? 'براہ کرم لاگ اِن کریں' : 'Please Login';
  String get pleaseSignup => isUrdu ? 'نیا اکاؤنٹ بنائیں' : 'Create Account';
  String get email => isUrdu ? 'ای میل' : 'Email';
  String get password => isUrdu ? 'پاس ورڈ' : 'Password';
  String get login => isUrdu ? 'لاگ اِن' : 'Login';
  String get signup => isUrdu ? 'سائن اپ' : 'Signup';
  String get logout => isUrdu ? 'لاگ آؤٹ' : 'Logout';
  String get history => isUrdu ? 'تاریخ' : 'History';
  String get historyTitle => isUrdu ? 'اسکین کی تاریخ' : 'Scan History';
  String get historyEmpty => isUrdu
      ? 'ابھی تک کوئی اسکین محفوظ نہیں۔'
      : 'No scans saved yet.';
  String get historyEmptyHint => isUrdu
      ? 'نتائج حاصل کرنے کے بعد یہاں تاریخ نظر آئے گی۔'
      : 'Run detection and your results will appear here.';
  String get historyClear => isUrdu ? 'سب صاف کریں' : 'Clear all';
  String get historyClearConfirmTitle =>
      isUrdu ? 'تاریخ صاف کریں؟' : 'Clear history?';
  String get historyClearConfirmBody => isUrdu
      ? 'تمام محفوظ اسکین حذف ہو جائیں گے۔'
      : 'All saved scans will be deleted from this device.';
  String get historyDelete => isUrdu ? 'حذف' : 'Delete';
  String get historySavedLocally => isUrdu
      ? 'اس ڈیوائس پر محفوظ'
      : 'Saved on this device';
  String get historyDetails => isUrdu ? 'تفصیل' : 'Details';
  String get clearImage => isUrdu ? 'تصویر ہٹائیں' : 'Clear Image';
  String get dontHaveAccount =>
      isUrdu ? 'اکاؤنٹ نہیں ہے؟' : "Don't have an account?";
  String get alreadyHaveAccount =>
      isUrdu ? 'پہلے سے اکاؤنٹ ہے؟' : 'Already have an account?';
  String get english => 'English';
  String get urdu => 'اردو';
  String get language => isUrdu ? 'زبان' : 'Language';
  String get selectImage => isUrdu ? 'تصویر منتخب کریں' : 'Select Image';
  String get openCamera => isUrdu ? 'کیمرہ کھولیں' : 'Open Camera';
  String get getResults => isUrdu ? 'نتائج حاصل کریں' : 'Get Results';
  String get getTreatment => isUrdu ? 'علاج دیکھیں' : 'Get Treatment';
  String get selectedCrop => isUrdu ? 'منتخب فصل' : 'Selected crop';
  String get chooseCrop => isUrdu ? 'فصل منتخب کریں' : 'Choose a crop';
  String get detectDisease =>
      isUrdu ? 'بیماری کی تشخیص' : 'Detect Disease';
  String get detectSubtitle => isUrdu
      ? 'پتوں کی تصویر اپلوڈ کریں اور بیماری معلوم کریں'
      : 'Upload a leaf image to identify crop disease';
  String get tipPickImage => isUrdu
      ? 'شروع کرنے کے لیے گیلری یا کیمرے سے پتے کی تصویر لیں۔'
      : 'Start by picking a leaf photo from gallery or camera.';
  String get tipSelectCrop => isUrdu
      ? 'تشخیص سے پہلے اوپر سے فصل منتخب کریں۔'
      : 'Select a crop above before running detection.';
  String get tipReady => isUrdu
      ? 'تیار ہیں — نتائج حاصل کریں دبائیں۔'
      : 'Ready — tap Get Results to analyze.';
  String get apple => isUrdu ? 'سیب' : 'Apple';
  String get grapes => isUrdu ? 'انگور' : 'Grapes';
  String get corn => isUrdu ? 'مکئی' : 'Corn';
  String get results => isUrdu ? 'نتائج' : 'Results';
  String get disease => isUrdu ? 'بیماری' : 'Disease';
  String get confidence => isUrdu ? 'اعتماد' : 'Confidence';
  String get treatmentInfo =>
      isUrdu ? 'علاج کی معلومات' : 'Treatment Information';
  String get ok => isUrdu ? 'ٹھیک ہے' : 'OK';
  String get noImageSelected =>
      isUrdu ? 'تصویر منتخب نہیں ہوئی' : 'No image selected';
  String get enterEmailPassword => isUrdu
      ? 'براہ کرم ای میل اور پاس ورڈ درج کریں۔'
      : 'Please enter your email and password.';
  String get loginFailed => isUrdu
      ? 'لاگ اِن ناکام۔ دوبارہ کوشش کریں۔'
      : 'Login failed. Please try again.';
  String get signupFailed => isUrdu
      ? 'سائن اپ ناکام۔ دوبارہ کوشش کریں۔'
      : 'Sign up failed. Please try again.';
  String get noAccountFound => isUrdu
      ? 'اس ای میل کا کوئی اکاؤنٹ نہیں ملا۔'
      : 'No account found for this email.';
  String get incorrectCredentials => isUrdu
      ? 'غلط ای میل یا پاس ورڈ۔'
      : 'Incorrect email or password.';
  String get invalidEmail => isUrdu
      ? 'درست ای میل ایڈریس درج کریں۔'
      : 'Please enter a valid email address.';
  String get accountDisabled => isUrdu
      ? 'یہ اکاؤنٹ غیر فعال کر دیا گیا ہے۔'
      : 'This account has been disabled.';
  String get emailInUse => isUrdu
      ? 'اس ای میل پر پہلے سے اکاؤنٹ موجود ہے۔'
      : 'An account already exists for this email.';
  String get weakPassword => isUrdu
      ? 'پاس ورڈ کم از کم ۶ حروف کا ہونا چاہیے۔'
      : 'Password must be at least 6 characters.';
  String get signupNotAllowed => isUrdu
      ? 'ای میل/پاس ورڈ سائن اپ فعال نہیں ہے۔'
      : 'Email/password sign-up is not enabled in Firebase.';
  String get forgotPassword => isUrdu
      ? 'پاس ورڈ بھول گئے؟'
      : 'Forgot password?';
  String get resetPassword => isUrdu
      ? 'پاس ورڈ ری سیٹ کریں'
      : 'Reset password';
  String get resetPasswordPrompt => isUrdu
      ? 'اپنا ای میل درج کریں۔ ہم آپ کو پاس ورڈ ری سیٹ لنک بھیجیں گے۔'
      : 'Enter your email and we will send you a password reset link.';
  String get passwordResetSent => isUrdu
      ? 'اگر یہ ای میل رجسٹرڈ ہے تو پاس ورڈ ری سیٹ لنک بھیج دیا گیا ہے۔'
      : 'If that email is registered, a password reset link has been sent.';
  String get passwordResetFailed => isUrdu
      ? 'پاس ورڈ ری سیٹ ای میل نہیں بھیجی جا سکی۔ دوبارہ کوشش کریں۔'
      : 'Could not send the password reset email. Please try again.';
  String get selectImageFirst => isUrdu
      ? 'پہلے تصویر منتخب کریں۔'
      : 'Select an image before running detection.';
  String get selectCropFirst => isUrdu
      ? 'پہلے فصل منتخب کریں۔'
      : 'Select a crop category first.';
  String get noPrediction => isUrdu
      ? 'اس تصویر کے لیے کوئی نتیجہ نہیں ملا۔'
      : 'No disease prediction was returned for this image.';
  String get detectionFailed => isUrdu
      ? 'تشخیص ناکام۔ ماڈل فائل چیک کر کے دوبارہ کوشش کریں۔'
      : 'Detection failed. Make sure the model file exists and try again.';
  String get modelLoadFailed => isUrdu
      ? 'ماڈل لوڈ نہیں ہو سکا۔'
      : 'Could not load the model.';
  String get gateRejectTitle =>
      isUrdu ? 'تصویر قبول نہیں' : 'Image not supported';
  String get gateRejectMessage => isUrdu
      ? 'یہ سیب، انگور، یا مکئی کا پتہ نہیں لگتا۔ فی الحال ہم صرف ان تین فصلوں کی حمایت کرتے ہیں۔'
      : "This doesn't look like an apple, grape, or corn leaf. "
          'For now we only support these three crops.';
  String get gateMismatchTitle =>
      isUrdu ? 'فصل مماثل نہیں' : 'Crop mismatch';
  String gateCropMismatch(String detectedCategory, String selectedCategory) {
    final detected = gateLeafPhrase(detectedCategory);
    final selected = cropDisplayName(selectedCategory);
    return isUrdu
        ? 'یہ $detected پتہ لگتا ہے، لیکن آپ نے $selected منتخب کیا ہے۔'
        : 'This looks like $detected leaf, but you selected $selected.';
  }

  String gateSwitchTo(String category) {
    final name = cropDisplayName(category);
    return isUrdu ? '$name پر سوئچ کریں' : 'Switch to $name';
  }

  String cropDisplayName(String category) {
    switch (category) {
      case 'Apple':
        return apple;
      case 'Grapes':
        return grapes;
      case 'Corn':
        return corn;
      default:
        return category;
    }
  }

  String gateLeafPhrase(String category) {
    if (isUrdu) {
      switch (category) {
        case 'Apple':
          return 'سیب کا';
        case 'Grapes':
          return 'انگور کا';
        case 'Corn':
          return 'مکئی کا';
        default:
          return category;
      }
    }
    switch (category) {
      case 'Apple':
        return 'an apple';
      case 'Grapes':
        return 'a grape';
      case 'Corn':
        return 'a corn';
      default:
        return 'a $category'.toLowerCase();
    }
  }
  String get noTreatment => isUrdu
      ? 'علاج کی معلومات دستیاب نہیں۔'
      : 'No treatment information available.';
  String get runDetectionFirst => isUrdu
      ? 'پہلے نتائج حاصل کریں، پھر علاج دیکھیں۔'
      : 'Run detection first to view treatment advice.';
  String get logoutConfirmTitle =>
      isUrdu ? 'لاگ آؤٹ؟' : 'Log out?';
  String get logoutConfirmBody => isUrdu
      ? 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟'
      : 'Are you sure you want to log out?';
  String get cancel => isUrdu ? 'منسوخ' : 'Cancel';
  String get weatherTitle =>
      isUrdu ? 'مقامی موسم اور بیماری کا خطرہ' : 'Local weather & disease risk';
  String get weatherRefresh => isUrdu ? 'تازہ کریں' : 'Refresh';
  String get weatherLoading =>
      isUrdu ? 'موسم حاصل ہو رہا ہے…' : 'Fetching local weather…';
  String get weatherLoadCta => isUrdu
      ? 'مقامی موسم کی بنیاد پر مشورہ دیکھیں'
      : 'Get disease tips from local weather';
  String get weatherTemp => isUrdu ? 'درجہ حرارت' : 'Temp';
  String get weatherHumidity => isUrdu ? 'نمی' : 'Humidity';
  String get weatherRain => isUrdu ? 'بارش' : 'Rain';
  String get weatherRisk => isUrdu ? 'خطرہ' : 'Risk';
  String get weatherRiskLow => isUrdu ? 'کم' : 'Low';
  String get weatherRiskModerate => isUrdu ? 'درمیانہ' : 'Moderate';
  String get weatherRiskHigh => isUrdu ? 'زیادہ' : 'High';
  String get weatherCommonDiseases =>
      isUrdu ? 'عام بیماریاں' : 'Common diseases now';
  String get weatherRecommendations =>
      isUrdu ? 'عام سفارشات' : 'General recommendations';
  String get weatherLocationDisabled => isUrdu
      ? 'لوکیشن سروس بند ہے۔ اسے آن کر کے دوبارہ کوشش کریں۔'
      : 'Location is turned off. Enable it and try again.';
  String get weatherLocationDenied => isUrdu
      ? 'لوکیشن کی اجازت درکار ہے۔ سیٹنگز میں اجازت دیں۔'
      : 'Location permission is needed. Allow it in Settings.';
  String get weatherFailed => isUrdu
      ? 'موسم حاصل نہیں ہو سکا۔ دوبارہ کوشش کریں۔'
      : 'Could not fetch weather. Please try again.';
  String get weatherUsingApproxLocation => isUrdu
      ? 'تقریبی مقام (IP) استعمال ہو رہا ہے'
      : 'Using approximate location';
  String get weatherPoweredBy =>
      isUrdu ? 'Open-Meteo (مفت)' : 'Powered by Open-Meteo (free)';

  String get healthyPlantAdvice => isUrdu
      ? 'اچھی خبر! پودا صحت مند لگ رہا ہے۔ باقاعدہ پانی، روشنی، اور صفائی جاری رکھیں، اور بیماری کی علامات پر نظر رکھیں۔'
      : 'Good news — the plant looks healthy. Keep up regular watering, light, and cleanliness, and watch for early disease signs.';

  WeatherDiseaseAdvice weatherAdviceFor(WeatherSnapshot weather) {
    final diseases = <String>[];
    final recommendations = <String>[];
    var risk = DiseaseRiskLevel.low;
    late String summary;

    if (weather.isWet && weather.isHumid) {
      risk = DiseaseRiskLevel.high;
      summary = isUrdu
          ? 'گیلی اور مرطوب فضا فنگس بیماریوں کے لیے بہت موزوں ہے۔'
          : 'Wet, humid conditions strongly favor fungal leaf diseases.';
      diseases.addAll([
        isUrdu ? 'سیب سکاب' : 'Apple scab',
        isUrdu ? 'انگور کالا سڑن / پتوں کے داغ' : 'Grape black rot / leaf spot',
        isUrdu
            ? 'مکئی کا گرے لیف سپاٹ اور شمالی جھلساؤ'
            : 'Corn gray leaf spot & northern leaf blight',
      ]);
      recommendations.addAll([
        isUrdu
            ? 'صبح سویرے پتے خشک رکھنے کی کوشش کریں؛ رات کو پانی کم دیں۔'
            : 'Keep foliage dry; water early so leaves dry during the day.',
        isUrdu
            ? 'متاثرہ پتے ہٹا کر صفائی برقرار رکھیں۔'
            : 'Remove infected leaves and improve field sanitation.',
        isUrdu
            ? 'بارش سے پہلے حفاظتی فنگس سائیڈ پر غور کریں۔'
            : 'Consider a protectant fungicide before more rain.',
      ]);
    } else if (weather.isHumid && weather.isMild) {
      risk = DiseaseRiskLevel.moderate;
      summary = isUrdu
          ? 'معتدل درجہ حرارت اور زیادہ نمی فنگس کے پھیلاؤ کو بڑھا سکتی ہے۔'
          : 'Mild temperatures with high humidity raise fungal spread risk.';
      diseases.addAll([
        isUrdu ? 'سیڈر ایپل رسٹ' : 'Cedar apple rust',
        isUrdu ? 'انگور بلیک میزلز' : 'Grape black measles',
        isUrdu ? 'مکئی کے پتوں کی بیماریاں' : 'Corn leaf blights',
      ]);
      recommendations.addAll([
        isUrdu
            ? 'فصلوں کے درمیان ہوا کی روانی بہتر بنائیں۔'
            : 'Improve airflow between plants and avoid dense canopy.',
        isUrdu
            ? 'روزانہ پتوں پر داغ یا زنگ نما علامات چیک کریں۔'
            : 'Scout daily for spots, rust, or blight symptoms.',
        isUrdu
            ? 'ضروری ہو تو جلد حفاظتی علاج شروع کریں۔'
            : 'Start preventative treatment early if symptoms appear.',
      ]);
    } else if (weather.isHot && weather.humidity < 50) {
      risk = DiseaseRiskLevel.low;
      summary = isUrdu
          ? 'گرم اور خشک موسم میں فنگس کا خطرہ کم ہے، مگر پودے پر دباؤ ہو سکتا ہے۔'
          : 'Hot and dry weather lowers fungal pressure but plants may stress.';
      diseases.addAll([
        isUrdu ? 'فنگس بیماریاں کم عام' : 'Fungal leaf diseases less common',
        isUrdu ? 'پانی کی کمی سے کمزوری' : 'Stress / wilting from heat',
      ]);
      recommendations.addAll([
        isUrdu
            ? 'صبح یا شام گہرا پانی دیں۔'
            : 'Water deeply in morning or evening.',
        isUrdu
            ? 'مٹی کی نمی برقرار رکھیں تاکہ پودا کمزور نہ ہو۔'
            : 'Maintain soil moisture so plants stay resilient.',
        isUrdu
            ? 'شدید گرمی میں اسپرے سے پرہیز کریں۔'
            : 'Avoid spraying during peak heat.',
      ]);
    } else if (weather.isCool && weather.isHumid) {
      risk = DiseaseRiskLevel.moderate;
      summary = isUrdu
          ? 'ٹھنڈی مرطوب ہوا خاص طور پر مکئی اور انگور کے پتوں کی بیماریوں میں مدد دیتی ہے۔'
          : 'Cool humid air favors leaf diseases, especially in corn and grapes.';
      diseases.addAll([
        isUrdu ? 'شمالی پتوں کا جھلساؤ' : 'Northern leaf blight',
        isUrdu ? 'گرے لیف سپاٹ' : 'Gray leaf spot',
        isUrdu ? 'انگور کے پتوں کے دھبے' : 'Grape leaf spots',
      ]);
      recommendations.addAll([
        isUrdu
            ? 'نچلے اور پرانے متاثرہ پتے ہٹائیں۔'
            : 'Remove lower and older infected leaves.',
        isUrdu
            ? 'فصل کی گردش اور مزاحم اقسام استعمال کریں۔'
            : 'Use crop rotation and resistant varieties when possible.',
        isUrdu
            ? 'شدید علامات پر فنگس سائیڈ کا جائزہ لیں۔'
            : 'Evaluate foliar fungicide if disease pressure rises.',
      ]);
    } else {
      risk = DiseaseRiskLevel.low;
      summary = isUrdu
          ? 'موجودہ موسم بیماری کے عام خطرے کو کم رکھتا ہے — معمول کی نگرانی جاری رکھیں۔'
          : 'Current weather keeps general disease pressure relatively low — keep routine scouting.';
      diseases.addAll([
        isUrdu ? 'معمولی فنگس دباؤ' : 'Typical low fungal pressure',
      ]);
      recommendations.addAll([
        isUrdu
            ? 'ہفتہ وار پتوں کا معائنہ کریں۔'
            : 'Inspect leaves weekly for early spots.',
        isUrdu
            ? 'اچھی نکاسی اور صفائی برقرار رکھیں۔'
            : 'Maintain drainage and field hygiene.',
        isUrdu
            ? 'بارش بڑھے تو دوبارہ موسم چیک کریں۔'
            : 'Re-check weather tips after heavy rain.',
      ]);
    }

    return WeatherDiseaseAdvice(
      riskLevel: risk,
      summary: summary,
      commonDiseases: diseases,
      recommendations: recommendations,
    );
  }

  String treatmentFor(String label) {
    final normalized = label.toLowerCase().trim();
    final looksHealthy = normalized.contains('healthy');

    if (looksHealthy) {
      return healthyPlantAdvice;
    }

    final bare = label.replaceFirst(RegExp(r'^\d+\s+'), '').trim();

    switch (bare) {
      case 'Apple Scab':
        return isUrdu
            ? 'مائیکلوبوٹینل (جیسے Spectracide Immunox) سیب کے سکاب کے خلاف مؤثر ہے۔ سبز سرے سے پھول جھڑنے تک اسپرے کر سکتے ہیں۔'
            : 'Myclobutanil (Spectracide Immunox Multipurpose Fungicide Spray Concentrate) is effective against apple scab. Apply from green tip until after petal fall.';
      case 'Cedar apple rust':
        return isUrdu
            ? 'مائیکلوبوٹینل والے فنگس سائیڈز زنگ روکنے میں بہترین ہیں۔ تانبا اور سلفر بھی استعمال ہو سکتے ہیں۔ کلیوں کے نکلتے ہی اسپرے شروع کریں تا آنکہ موسم گرم اور خشک ہو جائے۔'
            : 'Fungicides with Myclobutanil are most effective against rust. Copper and sulfur can also help. Spray from bud break until warm, dry weather.';
      case 'Corn Gray leaf spot disease':
        return isUrdu
            ? 'مزاحم مکئی ہائبرڈ، مناسب کاشت، اور فصل کی تبدیلی استعمال کریں۔ ضرورت پڑنے پر پتوں پر فنگس سائیڈ لگائیں۔'
            : 'Use resistant corn hybrids, appropriate tillage, and crop rotation. Foliar fungicides can help when economically justified.';
      case 'Corn Northern Leaf Blight':
        return isUrdu
            ? 'ابتدائی موسم میں پتوں پر فنگس سائیڈ لگانا شمالی پتوں کے جھلسنے اور متعلقہ بیماریوں کے خطرے کو کم کر سکتا ہے۔'
            : 'Early-season foliar fungicides can help manage northern corn leaf blight and related leaf diseases.';
      case 'Grape Black Measles':
        return isUrdu
            ? 'انگور کی بیماریوں کے لیے صفائی، مزاحم اقسام، اور فنگس سائیڈ اسپرے مل کر استعمال کریں۔'
            : 'Manage grape diseases with culture, sanitation, resistant varieties, and fungicide sprays together.';
      case 'Grape Black rot':
        return isUrdu
            ? 'مینکوزیب اور زائرم کالا سڑن کے خلاف بہت مؤثر ہیں۔ انھیں انفیکشن سے پہلے لگانا ضروری ہے کیونکہ یہ صرف حفاظتی ہیں۔'
            : 'Mancozeb and Ziram are highly effective against black rot. Apply before infection because they are protectants only.';
      case 'Grape Isariopsis Leaf Spot':
        return isUrdu
            ? 'انگور کی بیل پر سب سے عام فنگس سائیڈ بورڈو مرکب (تانبے والا) ہے۔'
            : 'The most widely used grapevine fungicide is Bordeaux mixture, a copper fungicide.';
      default:
        return noTreatment;
    }
  }
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ur';

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
