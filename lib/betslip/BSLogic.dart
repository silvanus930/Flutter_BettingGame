import '../config/defaultConfig.dart' as config;

systemTipSize(tournamentsCount) {
  return ((tournamentsCount).length > 1) ? (tournamentsCount).length - 2 : 0;
}

coefsCalc(String string, List arrayOfCoefs) {
  double result = 1;
  for (var i = 0; i < string.length; i++) {
    result *= arrayOfCoefs[string.codeUnitAt(i) - 65];
  }
  return result;
}

totalSystemCoef(List arr, List lettersArr, List matchObj) {
  final onlyLetters = RegExp(r"\d+");

  var onlyLettersArr =
      lettersArr.where((element) => !onlyLetters.hasMatch(element)).toList();

  var res = ((arr.reduce((a, b) => a + b)) / arr.length);
  if (onlyLettersArr.length == lettersArr.length)
    return res;
  else {
    var max = 1;
    var helper = matchObj
        .map((e) => matchObj
                    .where((val) => val['matchId'] == e['MatchId'])
                    .toList()
                    .length >
                1
            ? 1
            : 0)
        .toList();

    matchObj.asMap().entries.forEach((e) => {
          if (e.value['Value'] > max && helper[e.key] == 1)
            {max = e.value['Value']}
        });
    return (res * max);
  }
}

systemCombinations(array, length, List bankers, List matchObjArray) {
  List arrayofarray = [];
  List res = [];
  combine(input, int len, start) {
    if (len == 0) {
      arrayofarray.add(res.join(""));
      return;
    }
    for (int i = start; i <= input.length - len; i++) {
      res[res.length - len] = input[i];
      combine(input, len - 1, i + 1);
    }
  }

  if (length >= 0) {
    res.length = length;
  }
  if (array != null) {
    combine(array, res.length, 0);
  }

  if (bankers.length > 0) {
    //length += bankers.length;
    arrayofarray = arrayofarray.where((val) {
      bool checkBankers = true;

      bankers.forEach((element) {
        var letterIndex =
            matchObjArray.indexWhere((e) => e['OddId'] == element);
        if (letterIndex != -1) {
          checkBankers = checkBankers && !val.contains(array[letterIndex]);
        } else {
          checkBankers = false;
        }
      });
      return checkBankers;
    }).toList();
  }
  return arrayofarray;
}

getSystemBetsCount(a, b) {
  if (a < b) {
    factorial(length) {
      var array = [];
      for (var i = 1; i <= length; i++) {
        array.add(i);
      }
      if (array.length > 0) {
        return array.reduce((a, b) => a * b);
      }
    }

    rowsCount(a, b) {
      var count = factorial(b) / (factorial(a) * factorial(b - a));
      return count;
    }

    return rowsCount(a, b);
  }
}

getBonusAmount(tipSize, array) {
  var _result;
  if (array.isNotEmpty)
    _result = array['bonuses'].firstWhere(
        (e) => tipSize >= e['tipSize'] ? true : false,
        orElse: () => null);
  if (_result != null)
    return _result['bonus'];
  else
    return 0;
}

minusVAT(n, p) {
  return double.parse((n - (n / (100 + p)) * p).toStringAsFixed(2));
}

minusProfitTax(n, p, stake) {
  double sum = config.profitTaxCalculateFromWin ? n : (n - stake);
  if(sum < 0) {
    sum = 0;
  }
  return double.parse(((p / 100) * sum).toStringAsFixed(2));
}
