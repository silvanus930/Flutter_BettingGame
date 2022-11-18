import 'package:flutter/material.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:styled_text/styled_text.dart';
import '../../config/defaultConfig.dart' as config;

class PromoItem extends StatefulWidget {
  final promoName;

  const PromoItem({Key? key, this.promoName}) : super(key: key);
  @override
  State<PromoItem> createState() => PromoItemState();
}

class PromoItemState extends State<PromoItem> {
  bool showMore = false;
  Map bonusLimits = {};

  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPromoName(type) {
    switch (type) {
      case 'cash_prize':
        return Text("Cash Prize",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'cut1':
        return Text("CUT1",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'bet1_get1':
        return StyledText(
          style: TextStyle(color: Colors.black87),
          text: 'Cash back - <bold>"BET 1 GET 1"</bold>',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
          },
        );
      case 'welcome_back':
        return StyledText(
          style: TextStyle(color: Colors.black87),
          text: 'Cash back - <bold>"WELCOME BACK"</bold>',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
          },
        );
      case 'cashout':
        return Text("Cashout",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'refund_on_lost':
        return Text("Refund 20% on lost bet",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'betpalace_cashout':
        return Text("Cashout",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'betpalace_refund_on_lost':
        return Text("Refund Bonus",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      default:
        return Text('');
    }
  }

  getPromoNameFR(type) {
    switch (type) {
      case 'cash_prize':
        return Text("Cash Prize",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'cut1':
        return Text("LE CUT1",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'bet1_get1':
        return StyledText(
          style: TextStyle(color: Colors.black87),
          text: 'Cash back - <bold>"MISE 1 ET GAGNE 1"</bold>',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
          },
        );
      case 'welcome_back':
        return StyledText(
          style: TextStyle(color: Colors.black87),
          text: 'Cash back - <bold>"WELCOME BACK"</bold>',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
          },
        );
      case 'cashout':
        return Text("Cashout",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      case 'refund_on_lost':
        return Text("Refund 20% on lost bet",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
      default:
        return Text('');
    }
  }

  getPromoInfo(type) {
    switch (type) {
      case 'cash_prize':
        return Text(
            "This is Free cash amount made available to players. It’s a PRIZE that any player can win.");
      case 'cut1':
        return StyledText(
          text:
              'Did 1 game burn your ticket? Relax, <bold>${config.appTitle}</bold> got you covered. We pay you even when 1 game spoils your ticket.',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor)),
          },
        );
      case 'bet1_get1':
        return Text(
            "The catch-up bonus is a bonus offered to regular customers who place larger or smaller bets.\nOne way to gratify their regular presence on our platform.\nThis is a bonus that allows the customer to try to catch their bet");
      case 'welcome_back':
        return Text(
            "We know how difficult the temporary or total outage of leagues was.\n" +
                "Now football is back and you must take advantage of it.\n" +
                "Then we give you 100% Bonus on your first for this new season (2021-2022).");
      case 'cashout':
        return StyledText(
          text:
              '<bold>${config.appTitle}</bold> gives control on bets to you.\nA bet must be contained from selections, which are eligible for cashout. You can recognize allowed markets by an icon <cashout/>.\nIf markets are opened, you can always see the price, which we offer for your bet and cashout',
          tags: {
            'cashout': StyledTextIconTag(Icons.monetization_on),
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor)),
          },
        );
      case 'refund_on_lost':
        return StyledText(
          text:
              'Did 1 game burn your ticket? Relax, <bold>${config.appTitle}</bold> got you covered. We pay you even when 1 game spoils your ticket',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor)),
          },
        );
      case 'betpalace_cashout':
        return StyledText(
          text:
              '<bold>${config.appTitle}</bold> gives control on bets to you.\nA bet must be contained from selections, which are eligible for cashout. You can recognize allowed markets by an icon <cashout/>.\nIf markets are opened, you can always see the price, which we offer for your bet and cashout',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor)),
          },
        );
      case 'betpalace_refund_on_lost':
        return StyledText(
          text:
              'Did 1 game burn your ticket? Relax, <bold>${config.appTitle}</bold> got you covered. We pay you even when 1 game spoils your ticket',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor)),
          },
        );
      default:
        return Text('');
    }
  }

  getPromoInfoFR(type) {
    switch (type) {
      case 'cash_prize':
        return Text(
            "C’est un montant de gratification mis à la disposition des joueurs. C’est un gros lot que n’importe quel joueur peut remporter.");
      case 'cut1':
        return Text(
          "Un match ndem ton ticket, ce n’est pas grave ; on te paye quand même.\nUn résultat a gâché le ticket? L'utilisateur est extrêmement contrarié.\nPour rendre ce malheur un peu plus doux, nous voulons donner de l'argent à l'utilisateur dans ce cas. Bien sûr, le billet doit remplir certaines conditions.",
        );
      case 'bet1_get1':
        return Text(
            "Le bonus rattrapage est un bonus offert aux clients réguliers et qui placent des mises plus ou moins importantes.\nUne façon de gratifier leur présence régulière sur notre plateforme.\nC’est un bonus qui permet au client de tenter de rattraper sa mise.");
      case 'welcome_back':
        return Text("Nous savons à quel point l’arrêt temporaire ou totale des championnats a été difficile.\n" +
            "Maintenant, les championnats sont de retour  et vous devez  en profiter.\n" +
            "Alors nous vous offrons 100% de Bonus sur votre premier dépôt pour le compte de la nouvelle saison (2021-2022).");
      case 'cashout':
        return StyledText(
          text:
              '<bold>${config.appTitle}</bold> give control on bets to you.\nA bet must be contained from selections, which are eligible for cashout. You can recognize allowed markets by an icon <cashout/>.\nIf markets are opened, you can always see the price, which we offer for your bet and cashout',
          tags: {
            'cashout': StyledTextIconTag(Icons.monetization_on),
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor)),
          },
        );
      case 'refund_on_lost':
        return StyledText(
          text:
              'Did 1 game burn your ticket? Relax, <bold>${config.appTitle}</bold> got you covered. We pay you even when 1 game spoils your ticket',
          tags: {
            'bold': StyledTextTag(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor)),
          },
        );
      default:
        return Text('');
    }
  }

  getMorePromoText(type) {
    if (type == 'cash_prize') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Rules",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• The Amount starts from <bold>5000 F</bold> and could be won several times within the day',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("• This Offer exists only on Fridays"),
            StyledText(
              text:
                  '• Any one betting on <bold>${config.appTitle}</bold> can win it',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• Once won, a message is displayed and the beneficiary player collects his <bold>Cash prize</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("B.Others measures",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• The <bold>CASH PRIZE</bold> is only available at <bold>${config.appTitle}</bold> and no where else',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("• User will receive notification in case of win"),
            Text("• The client must read the rules before betting"),
            Text(
                "• The client must be well informed and ask questions in case of misunderstanding"),
            StyledText(
              text:
                  '• The operator can end the <bold>CASH PRIZE</bold> campaign at any time without any notification',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                "• The rules and instructions are published for information and ease of understanding by the players"),
          ]);
    }

    if (type == 'cut1') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Rules",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Tickets eligible for <bold>Cut1</bold> must respect the following conditions',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• Match <bold>selections</bold> must be from <bold>10</bold> and above',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• It applies only to tickets with match selections of odds not lower than <bold>1.4</bold> per game',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• Lost match will not involved in the multiplication of payment'),
            Text('• Super bonus is not involved in calculation of such ticket'),
            StyledText(
              text:
                  '• We calculate the winning odds only and pay <bold>25%</bold> of it',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• All ticket stakes are eligible for <bold>Cut1</bold> ticket',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("B.Others measures",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• <bold>Cut1</bold> amount is calculated automatically by the system and payout amount will be given to player by cashier',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• Operator can stop this campaign whenever deem necessary'),
            Text('• Client must read rules before betting'),
            Text(
                '• Client must be well informed and ask questions in case of misunderstanding'),
            Text(
                '• The rules and instructions are published to give better insights and understanding to the players'),
          ]);
    }

    if (type == 'bet1_get1') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Rules",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• The catch-up bonus is up to <bold>10%</bold> (applied to the amount of the stake)',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• It concerns tickets with a total odd greater than or equal to 3 and therefore the odds for each match must be greater than or equal to 1.4'),
            StyledText(
              text: '• The minimum stake is <bold>2 000 XAF</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• Once the conditions are met the bonus balance is credited'),
            Text('• It can be used as soon as credited'),
            Text(
                '• Once used, the potential payout cannot be greater than the initial stake'),
            Text("B.Others measures",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• The <bold>CASH BACK</bold> is only available at <bold>${config.appTitle}</bold> and nowhere else',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text: '• <bold>The offer valid only on Fridays</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text: '• <bold>All Bonus conditions apply</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• The client must read the rules before betting'),
            Text(
                '• The client must be well informed and ask questions in case of misunderstanding'),
            StyledText(
              text:
                  '• The operator can end the <bold>CASH BACK</bold> campaign at any time without any notification',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• The rules and instructions are published for information and ease of understanding by the players.'),
          ]);
    }
    if (type == 'welcome_back') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Rules",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text: '• 1-	Deposit at least <bold>500 XAF</bold>.',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• The bonus amount does not exceed 10,000 XAF'),
            Text(
                '• The bonus will be automatically credited into your bonus balance after deposit.'),
            Text(
                '• To use bonus, user must select at least 3 events, with odds not lower than 1.4'),
            Text('• 7-	Maximum bonus win will not exceed 100.000 XAF'),
            Text("B.Others measures",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("• The Bonus expires 3 days after you've recieved it"),
            StyledText(
              text:
                  '• All FIRST DEPOSIT Bonus conditions apply AFTER BONUS WIN',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• The client must read the rules before betting.'),
            Text(
                '• The client must be well informed and ask questions in case of misunderstanding.'),
            Text(
                '• The operator can end the 100% bonus campaign at any time without any notification.'),
            Text(
                '• The rules and instructions are published for information and ease of understanding by the players.'),
          ]);
    }

    if (type == 'refund_on_lost') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Rules",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Tickets eligible for <bold>20%</bold> refund must respect the following conditions',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• The ticket must be multiple and have at least <bold>12</bold> selections from different matches',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• It applies only to tickets with match selections of odds not lower than <bold>1.2</bold> per game',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• Lost match will not involved in the multiplication of payment'),
            Text('• Super bonus is not involved in calculation of such ticket'),
            StyledText(
              text:
                  '• We calculate the winning odds only and pay <bold>20%</bold> of it',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("B.Others measures",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• <bold>20%</bold> Refund amount is calculated automatically by the system and payout amount will be deposited to player’s principal balance',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• Operator can stop this campaign whenever deem necessary'),
            StyledText(
              text:
                  '• It applies only to tickets with match selections of odds not lower than <bold>1.2</bold> per game',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• The client must read the rules before betting'),
            Text(
                '• The client must be well informed and ask questions in case of misunderstanding'),
            Text(
                '• The rules and instructions are published to give better insights and understanding'),
          ]);
    }

    return null;
  }

  getMorePromoTextFR(type) {
    if (type == 'cash_prize') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Règles",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Le Montant commence à partir de <bold>5000 F</bold> et peut grandir en fonction de la fréquence des mises',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("• Le Cash Prize se gagne uniquement les Vendredis"),
            Text("• Il se renouvèle instantanément une fois encaissé"),
            StyledText(
              text:
                  '• Toute personne validant son ticket sur <bold>${config.appTitle}</bold> peut le gagner',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                "• Une fois gagné, un message s’affiche et le joueur bénéficiaire encaisse son Cash prize"),
            Text("B.Disposition particulières",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Le Cash Prize est disponible uniquement sur <bold>${config.appTitle}</bold> et nulle part ailleurs',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• Les gagnants du <bold>CASH PRIZE</bold> recevront toujours une notification',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("• L’offre est valable Uniquement les vendredis"),
            Text(
                "• Le client doit lire les règles de jeu avant de s’y engager"),
            Text(
                "• Le client doit bien se renseigner et poser des questions en cas d’incompréhension"),
            StyledText(
              text:
                  '• L’opérateur peut mettre fin au <bold>Cash Prize</bold> à tout moment sans aucune notification',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                "• Les règles et les instructions sont publiées à des fins d'information et de facilité de compréhension par les joueurs."),
          ]);
    }

    if (type == 'cut1') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Règles",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Les tickets ayant bénéficiant déjà d’autres Bonus ne sont pas éligibles au <bold>CUT1</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• Toutes les côtes sur le ticket doivent être supérieures ou égales à <bold>1.4</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• Le nombre minimum de match par ticket doit être supérieur ou égale à <bold>10</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text: '• La mise minimale doit être de <bold>300 F</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                "Le Bonus se déclenche tout seul une fois que les conditions sont remplies"),
            StyledText(
              text:
                  '• Le montant payé est <bold>25%</bold> du gain potentiel (après avoir retiré le match perdu)',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("IL peut être utilisé directement dès son activation"),
            Text("B.Disposition particulières",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('• Le bonus ne se donne pas à la caisse'),
            StyledText(
              text:
                  '• L’opérateur peut mettre fin au bonus <bold>CUT1</bold> à tout moment sans aucune notification',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• Le client doit lire les règles de jeu avant de s’y engager'),
            Text('• Client must read rules before betting'),
            Text(
                '• Le client doit bien se renseigner et poser des questions en cas d’incompréhensio'),
            Text(
                "• Les règles et les instructions sont publiées à des fins d'information et de facilité de compréhension par les joueurs"),
          ]);
    }

    if (type == 'bet1_get1') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Règles",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text: '• 1-	Déposez au moins <bold>500 XAF</bold>.',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• Le montant du bonus ne dépasse pas <bold>10 000 XAF</bold>.',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• Le bonus sera automatiquement déposé sur votre solde bonus après le dépôt.'),
            Text(
                '• Pour utiliser le bonus, sélectionnez au moins 3 matchs, avec des cotes supérieures ou égales à 1.4.'),
            Text(
                '• Le gain maximum pour ce bonus ne dépassera pas 100.000 XAF'),
            Text("B.Disposition particulières",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text: '• L2.	Le Bonus a une durée de <bold>3 jours</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• <bold>Toutes les conditions de bonus de premier dépôt  sont d’application une fois que vous ayez reçu le Bonus 100%.</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• Le client doit lire les règles de jeu avant de s’y engager.'),
            Text(
                '• Le client doit bien se renseigner et poser des questions en cas d’incompréhension.'),
            Text(
                '• L’opérateur peut mettre fin au Bonus 100% à tout moment sans aucune notification.'),
            Text(
                "• Les  règles  et les instructions  sont publiées  à des fins d'information et de facilité de compréhension par les joueurs."),
          ]);
    }
    if (type == 'welcome_back') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Règles",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Le Bonus rattrapage est à hauteur de <bold>10%</bold> (appliqué sur le montant de la mise)',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• Il s’applique sur les tickets ayant une cote totale supérieure ou égale à <bold>3</bold> et donc les cotes sont supérieures ou égales à <bold>1.4</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text: '• La mise minimale doit être de <bold>2 000 XAF</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• Le Bonus se déclenche tout seul une fois que les conditions sont remplies'),
            Text('• IL peut être utilisé directement dès son activation'),
            Text(
                '• Une fois utilisé, le gain potentiel ne saurait être supérieur à la mise initiale'),
            Text("B.Disposition particulières",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Le <bold>CASH BACK</bold> est disponible uniquement sur <bold>${config.appTitle}</bold> et nulle part ailleurs',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text: '• <bold>L’offre est valable uniquement le Vendredi</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• <bold>Les conditions générales de Bonus sont d’application</bold>',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• L’opérateur peut mettre fin au bonus cash back à tout moment sans aucune notification'),
            Text(
                '• Le client doit lire les règles de jeu avant de s’y engager'),
            Text(
                '• Le client doit bien se renseigner et poser des questions en cas d’incompréhension'),
            Text(
                "• Les règles et les instructions sont publiées à des fins d'information et de facilité de compréhension par les joueurs"),
          ]);
    }

    if (type == 'refund_on_lost') {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A.Rules",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• Tickets eligible for <bold>20%</bold> refund must respect the following conditions',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• The ticket must be multiple and have at least <bold>12</bold> selections from different matches',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            StyledText(
              text:
                  '• It applies only to tickets with match selections of odds not lower than <bold>1.2</bold> per game',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text(
                '• Lost match will not involved in the multiplication of payment'),
            Text('• Super bonus is not involved in calculation of such ticket'),
            StyledText(
              text:
                  '• We calculate the winning odds only and pay <bold>20%</bold> of it',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text("B.Others measures",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StyledText(
              text:
                  '• <bold>20%</bold> Refund amount is calculated automatically by the system and payout amount will be deposited to player’s principal balance',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• Operator can stop this campaign whenever deem necessary'),
            StyledText(
              text:
                  '• It applies only to tickets with match selections of odds not lower than <bold>1.2</bold> per game',
              tags: {
                'bold': StyledTextTag(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).indicatorColor)),
              },
            ),
            Text('• The client must read the rules before betting'),
            Text(
                '• The client must be well informed and ask questions in case of misunderstanding'),
            Text(
                '• The rules and instructions are published to give better insights and understanding'),
          ]);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                decoration: new BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 1.0,
                          offset: Offset(0.0, 0.75))
                    ],
                    color: Theme.of(context).indicatorColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: ListTile(
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      context.locale.toString() == "fr"
                          ? getPromoNameFR(widget.promoName)
                          : getPromoName(widget.promoName)
                    ]))),
            Container(
                padding:
                    const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
                child: ListTile(
                    subtitle: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: DefaultTextStyle(
                          child: context.locale.toString() == "fr"
                              ? getPromoInfoFR(widget.promoName)
                              : getPromoInfo(widget.promoName),
                          style: TextStyle(height: 1.5),
                        )))),
            AnimatedClipRect(
                open: showMore,
                horizontalAnimation: false,
                verticalAnimation: true,
                alignment: Alignment.center,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: DefaultTextStyle(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 15.0, bottom: 15.0, right: 15.0),
                      child: DefaultTextStyle(
                        child: context.locale.toString() == "fr"
                            ? (getMorePromoTextFR(widget.promoName) != null
                                ? getMorePromoTextFR(widget.promoName)
                                : SizedBox())
                            : (getMorePromoText(widget.promoName) != null
                                ? getMorePromoText(widget.promoName)
                                : SizedBox()),
                        style: TextStyle(height: 1.5),
                      ),
                    ))),
            getMorePromoText(widget.promoName) != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      const SizedBox(width: 8),
                      TextButton(
                        child: Text(showMore
                            ? LocaleKeys.less.tr().toUpperCase()
                            : LocaleKeys.more.tr().toUpperCase()),
                        onPressed: () {
                          setState(() {
                            showMore = !showMore;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                : SizedBox(),
          ],
        ));
  }
}

class AnimatedClipRect extends StatefulWidget {
  @override
  _AnimatedClipRectState createState() => _AnimatedClipRectState();

  final Widget child;
  final bool open;
  final bool horizontalAnimation;
  final bool verticalAnimation;
  final Alignment alignment;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve? reverseCurve;

  ///The behavior of the controller when [AccessibilityFeatures.disableAnimations] is true.
  final AnimationBehavior animationBehavior;

  const AnimatedClipRect({
    Key? key,
    required this.child,
    required this.open,
    this.horizontalAnimation = true,
    this.verticalAnimation = true,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.animationBehavior = AnimationBehavior.normal,
  }) : super(key: key);
}

class _AnimatedClipRectState extends State<AnimatedClipRect>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(
        duration: widget.duration,
        reverseDuration: widget.reverseDuration ?? widget.duration,
        vsync: this,
        value: widget.open ? 1.0 : 0.0,
        animationBehavior: widget.animationBehavior);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve ?? widget.curve,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.open
        ? _animationController.forward()
        : _animationController.reverse();

    return ClipRect(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return Align(
            alignment: widget.alignment,
            heightFactor: widget.verticalAnimation ? _animation.value : 1.0,
            widthFactor: widget.horizontalAnimation ? _animation.value : 1.0,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
