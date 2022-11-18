import 'package:flutter/material.dart';
import 'package:flutter_betting_app/presentation/app_icons.dart';

class SportCategories extends StatelessWidget {
  SportCategories(
      this.sportData, this.nextPage, this.changeSportIndex, this.index);

  final Map sportData;
  final Function nextPage;
  final Function changeSportIndex;
  final index;

  getIcon(id) {
    switch (id) {
      case 1:
        return CategoryIcon(1, AppIcons.uniE925);
      case 2:
        return CategoryIcon(2, AppIcons.uniE936);
      case 3:
        return CategoryIcon(3, AppIcons.uniE935);
      case 4:
        return CategoryIcon(4, AppIcons.uniE93F);
      case 5:
        return CategoryIcon(5, AppIcons.uniE943);
      case 6:
        return CategoryIcon(6, AppIcons.uniE947);
      case 8:
        return CategoryIcon(8, AppIcons.uniE93D);
      case 9:
        return CategoryIcon(9, AppIcons.motorsport);
      case 10:
        return CategoryIcon(11, AppIcons.uniE946);
      case 11:
        return CategoryIcon(11, AppIcons.uniE949);
      case 13:
        return CategoryIcon(13, AppIcons.snooker);
      case 15:
        return CategoryIcon(15, AppIcons.uniE93A);
      case 20:
        return CategoryIcon(20, AppIcons.I44);
      case 22:
        return CategoryIcon(22, AppIcons.I56);
      case 24:
        return CategoryIcon(24, AppIcons.I34);
      case 25:
        return CategoryIcon(25, AppIcons.soccer_ball);
      case 34:
        return CategoryIcon(34, AppIcons.uniE947);
      case 36:
        return CategoryIcon(36, AppIcons.uniE941);
      default:
        return CategoryIcon(1, AppIcons.uniE925);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            //
            RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(getIcon(sportData['id']).icon, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                      )),
                  TextSpan(
                    style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).colorScheme.onPrimary),
                    text: sportData['name'],
                  ),
                ],
              ),
            ),
            RichText(
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
            )
          ])),
      onTap: () {
        changeSportIndex(index);
        nextPage();
      },
    );
  }
}

class CategoryIcon {
  int index;
  IconData icon;

  CategoryIcon(this.index, this.icon);
}
