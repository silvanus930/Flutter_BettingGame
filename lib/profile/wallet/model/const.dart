import '../../../config/defaultConfig.dart' as config;

final paymentMethods = {
  'OrangeMoney': "OrangeMoney",
  'OrangeMoney2' : "OrangeMoney2",
  'mPesa': "mPesa",
  'MTNMOMO': "MTNMOMO",
  'mPesaBP': "mPesaBP",
  'HelloCash': "HelloCash",
  'TeleBirr': "TeleBirr",
  'CashInternal': "CashInternal",
  'properties': {
    "OrangeMoney": {
      'codeOnBackend': "Orange.Cameroon",
    },
    "OrangeMoney2": {
      'codeOnBackend': "OrangeMoney.Cameroon",
    },
    "mPesa": {
      'codeOnBackend': "mPesa.DASSO.CDR",
    },
    "MTNMOMO": {
      'codeOnBackend': "MTN.MOMO",
    },
    "mPesaBP": {
      'codeOnBackend': "mPesa.BP.Kenya",
    },
    "HelloCash": {
      'codeOnBackend': "HelloCash.et",
    },
    "TeleBirr": {'codeOnBackend': "TeleBirr.et"},
    "CashInternal": {
      'codeOnBackend': "Cash.Internal",
    },
  },
};

final depositVariants = [
  {
    'id': paymentMethods['mPesa'],
    'title': "mPesa",
    'system': "mPesa",
    'src': 'assets/images/payment_logo/mpesa_logo.png',
    'fields': ["Phone", "Surname", "Initials"],
  },
  {
    'id': paymentMethods['MTNMOMO'],
    'title': "MTNMOMO",
    'system': "MTNMOMO",
    'src': 'assets/images/payment_logo/mtn-logo-small.png',
    'fields': ["Phone"],
  },
  {
    'id': paymentMethods['OrangeMoney'],
    'title': "Orange Money",
    'system': "OrangeMoney",
    'src': 'assets/images/payment_logo/om_logo.png',
    'fields': ["Phone"],
    'beforeInstruction': {
      'label':
          "Dial #150*4*4# on your mobile phone and follow the instructions",
    },
  },
  {
    'id': paymentMethods['OrangeMoney2'],
    'title': "OrangeMoney Cameroon",
    'system': "OrangeMoney2",
    'src': 'assets/images/payment_logo/om_cam_logo.png',
    'fields': ["Phone"],
  },
  {
    'id': paymentMethods['mPesaBP'],
    'title': "mPesa Kenya",
    'system': "mPesaBP",
    'src': 'assets/images/payment_logo/mpesa-kenya-logo.png',
    'fields': ["Phone"],
  },
  {
    'id': paymentMethods['HelloCash'],
    'title': "Hello Cash",
    'system': "HelloCash",
    'src': 'assets/images/payment_logo/hellocash.png',
    'fields': ["Phone"],
  },
  {
    'id': paymentMethods['TeleBirr'],
    'title': "telebirr",
    'system': "TeleBirr",
    'src': 'assets/images/payment_logo/telebirr_logo.png',
    'fields': [],
  },
  {
    'id': paymentMethods['CashInternal'],
    'title': config.cashInternalNameDeposit == ""
        ? "Cash Internal"
        : config.cashInternalNameDeposit,
    'system': "CashInternal",
    'src': config.flavorName == "grandbet"
        ? 'assets/images/payment_logo/cash_internal_grandbet.png'
        : 'assets/images/payment_logo/cash_internal_deposit.png',
    'fields': [],
  },
];

final withdrawVariants = [
  {
    'id': paymentMethods['mPesa'],
    'title': "mPesa",
    'system': "mPesa",
    'src': 'assets/images/payment_logo/mpesa_logo.png',
    'fields': ["Phone", "Surname", "Initials"],
    'editProfile': false,
    'afterInstruction': {
      'wait': true,
    },
  },
  {
    'id': paymentMethods['mPesaBP'],
    'title': "mPesa Kenya",
    'system': "mPesaBP",
    'src': 'assets/images/payment_logo/mpesa-kenya-logo.png',
    'fields': ["Phone"],
    'editProfile': false,
    'afterInstruction': {
      'wait': true,
    },
  },
  {
    'id': paymentMethods['MTNMOMO'],
    'title': "MTNMOMO",
    'system': "MTNMOMO",
    'src': 'assets/images/payment_logo/mtn-logo-small.png',
    'fields': ["Phone"],
    'editProfile': false,
    'afterInstruction': {
      'wait': true,
    },
  },
  {
    'id': paymentMethods['OrangeMoney'],
    'title': "Orange Money",
    'src': 'assets/images/payment_logo/om_logo.png',
    'system': "OrangeMoney",
    'fields': [],
    'editProfile': true,
    'afterInstruction': {
      'wait': false,
      'label': "Your request has been submitted to your operator.\n" +
          "You will be notified, when money has been sent to your bank account...",
    },
  },
  {
    'id': paymentMethods['OrangeMoney2'],
    'title': "OrangeMoney Cameroon",
    'system': "OrangeMoney2",
    'src': 'assets/images/payment_logo/om_cam_logo.png',
    'fields': ["Phone"],
    'editProfile': false,
    'afterInstruction': {
      'wait': true,
    },
  },
  {
    'id': paymentMethods['HelloCash'],
    'title': "Hello Cash",
    'system': "HelloCash",
    'src': 'assets/images/payment_logo/hellocash.png',
    'fields': ["Phone"],
    'editProfile': false,
    'afterInstruction': {
      'wait': true,
    },
  },
  {
    'id': paymentMethods['TeleBirr'],
    'title': "telebirr",
    'system': "TeleBirr",
    'src': 'assets/images/payment_logo/telebirr_logo.png',
    'editProfile': true,
    'fields': [],
    'afterInstruction': {
      'wait': false,
    },
  },
  {
    'id': paymentMethods['CashInternal'],
    'title': config.cashInternalNameWithdraw == ""
        ? "Cash Internal"
        : config.cashInternalNameWithdraw,
    'system': "CashInternal",
    'src': config.flavorName == "grandbet"
        ? 'assets/images/payment_logo/cash_internal_grandbet.png'
        : 'assets/images/payment_logo/cash_internal_withdraw.png',
    'fields': [],
    'editProfile': false,
    'afterInstruction': {
      'wait': true,
    },
  },
];
