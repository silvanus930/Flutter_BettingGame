import 'const.dart';

mappedPaymentMethodCodeFromBackend(codeFromBackend) {
  Map properties = paymentMethods;
  List val = [];
  properties['properties'].keys.forEach((paymentMethodCode) {
    if (properties['properties'][paymentMethodCode]['codeOnBackend'] ==
        codeFromBackend) {
      val.add(paymentMethodCode);
    }
  });
  return val.length > 0 ? val[0] : null;
}

extractPaymentMethodDetails(paymentMethodsDetails, paymentMethodCode) {
  List e = [];
  if (paymentMethodCode == null) return;
  paymentMethodsDetails.forEach((el) {
    var codeFromBackend = el['paymentMethod'];

    if (paymentMethodCode ==
        mappedPaymentMethodCodeFromBackend(codeFromBackend)) {
      e.add(el);
    }
  });
  return e.length > 0 ? e[0] : null;
}
