import 'package:flutter/material.dart';

class SportTournaments extends StatelessWidget {
  SportTournaments(this.sportData, this.sportName, this.nextPage,
      this.previousPage, this.changeTournamentIndex);

  final List sportData;
  final String sportName;
  final Function nextPage;
  final Function previousPage;
  final Function changeTournamentIndex;

  Widget listItem(sportData, index, context) {
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
                child: Text(
              sportData['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17, color: Theme.of(context).colorScheme.onPrimary),
            )),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: sportData['size'].toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.navigate_next,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            )
          ])),
      onTap: () {
        changeTournamentIndex(index);
        nextPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(sportName),
          backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => previousPage(),
          ),
        ),
        body: ListView.builder(
            itemCount: sportData.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext ctxt, int index) {
              return listItem(sportData[index], index, context);
            }));
  }
}
