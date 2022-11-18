import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SportCountries extends StatefulWidget {
  final List sportData;
  final String sportName;
  final Function nextPage;
  final Function previousPage;
  final Function changeCountryIndex;

  const SportCountries(
      {Key? key,
      required this.sportData,
      required this.sportName,
      required this.nextPage,
      required this.previousPage,
      required this.changeCountryIndex})
      : super(key: key);

  @override
  SportCountriesState createState() => SportCountriesState();
}

class SportCountriesState extends State<SportCountries> {
  List countries = [];

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/countries/countries.json');
    final data = await json.decode(response);
    setState(() {
      countries = data;
    });
  }

  initState() {
    super.initState();
    readJson();
  }

  Widget listItem(sportData, index, context) {
    String countryCode = countries.firstWhere(
                (e) => e['alpha3'] == sportData['iso3'].toLowerCase(),
                orElse: () => "") !=
            ""
        ? countries.firstWhere(
            (e) => e['alpha3'] == sportData['iso3'].toLowerCase(),
            orElse: () => "")['alpha2']
        : "";
    return InkWell(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF333549), width: 2),
            ),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                flex: 1,
                child: countryCode == 'kos' || countryCode == 'int'
                    ? Image.asset('assets/countries/$countryCode.png',
                        height: 20, width: 30, fit: BoxFit.fill)
                    : countryCode != "" ? Image.asset('icons/flags/png/$countryCode.png',
                        package: 'country_icons') : SizedBox()),
            Expanded(
                flex: 7,
                child: Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: Text(
                      sportData['name'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ))),
            Expanded(
                flex: 2,
                child: RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: sportData['size'].toString(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary)),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.navigate_next,
                            size: 20,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ))
          ])),
      onTap: () {
        widget.changeCountryIndex(index);
        widget.nextPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sportData.length > 0) {
      widget.sportData.sort((a, b) => a["name"].compareTo(b["name"]));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.sportName),
          backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => widget.previousPage(),
          ),
        ),
        body: ListView.builder(
            itemCount: widget.sportData.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext ctxt, int index) {
              return listItem(widget.sportData[index], index, context);
            }));
  }
}
