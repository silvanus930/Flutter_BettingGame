import 'package:flutter/material.dart';
import 'package:flutter_betting_app/generated/locale_keys.g.dart';
import '../../config/defaultConfig.dart' as config;
import 'package:sliver_tools/sliver_tools.dart';
import '../../redux/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class Rules extends StatefulWidget {
  final from;
  const Rules({Key? key, this.from}) : super(key: key);
  @override
  State<Rules> createState() => RulesState();
}

class RulesState extends State<Rules> {
  String selectedText = "bonus";

  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getBonusText(type) {
    if (config.flavorName == "demo7" || config.flavorName == "koolbet") {
      if (type == 'bonus') {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SIGNUP BONUS CONDITIONS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text(
                  "Can’t wait to get your hands on the Welcome Bonus? Sign up and get up to 200% Welcome bonus on your first deposit"),
              StyledText(
                text: '<bold>REGISTER NOW</bold> with Koolbet237',
                tags: {
                  'bold': StyledTextTag(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).indicatorColor)),
                },
              ),
              Text("Deposit at least 500 XAF."),
              Text("The bonus amount does not exceed 5,000 XAF."),
              Text(
                  "The bonus will be automatically deposited into your bonus balance after deposit."),
              Text("You can place any bets to unblock your bonus."),
              Text("Always select FIRST DEPOSIT BONUS on placing bet."),
              Text(
                  "You must rollover your first deposit amount 4 times to unblock your bonus. Then you can place bets using bonus balance."),
              Text(
                  "For example, if you deposit 1,000 XAF, then you should place bets for total amount of 4,000 XAF. Now you can bet with total amount of bonus."),
              Text(
                  "The Rollover requirements for this bonus include four (4) times the deposit and bonus amount before withdrawal of bonus winnings could be processed. For example:"),
              Text(
                  "A 1,000 XAF first deposit allows you to use your bonus of 2,000 XAF. As the wagering requirement is x4, this would require a total stake of 12,000 XAF to convert your bonus into cash available for withdrawal."),
              Text(
                  "You can use your bonus balance to place bet several times. For example:"),
              Text(
                  "You placed stake 1,000 XAF using you bonus balance for the ticket with odds 5.0. The ticket has won and you now have 5,000 XAF on your bonus balance."),
              Text(
                  "All winnings go directly to your respective balance. If the bet is made from real balance, then you get winning on your real balance. And if a bet is made from your bonus balance, then the winnings go to bonus balance."),
              Text(
                  "After claiming the bonus, you have 7 days to meet rollover requirements or you'll lose your full bonus on 8th day."),
              Text(
                  "All bets placed with the bonus offering must be at least multiples of 3 and have odds of at least 1.40. You cannot place non-qualifying bets using your bonus balance."),
              Text(
                  "Void/Cancelled/Draw bets, Cashed-Out bets or bets placed with a Free Bet do not count towards the deposit."),
              Text(
                  "This offer cannot be used in conjunction with any other bonus offer."),
              Text(
                  "We’re all for fair play, so General Terms and Conditions apply."),
              StyledText(
                text:
                    '<bold>REGISTER NOW</bold> and deposit at least 500 XAF to get your welcome bonus immediately.',
                tags: {
                  'bold': StyledTextTag(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).indicatorColor)),
                },
              ),
              SizedBox(height: 20),
              Text("WEEKLY BONUS CONDITIONS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text("Play and get regular rewards from Koolbet237."),
              Text(
                  "5% of your losses will be returned to your account each Monday for the previous week."),
              Text(
                  "You can use this amount to continue playing. The minimum bet in this case is 200.00 XAF."),
              Text(
                  "Ordinary bonus conditions apply: all bets placed for bonus must be at least multiples of 3 and have odds of at least 1.4. You cannot place non-qualifying bets using your bonus."),
              Text(
                  "Always select WEEKLY BONUS for placing bet with our bonus offering."),
              Text(
                  "All winnings go directly to your principal account and you will be able to withdraw your winnings."),
              StyledText(
                text:
                    'Maximum winnings of either bet, placed with <bold> WEEKLY BONUS</bold> is <bold>500,000 XAF</bold>',
                tags: {
                  'bold': StyledTextTag(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).indicatorColor)),
                },
              ),
              Text(
                  "If the bonus is not used for 3 days completely or partly, then not used amount expires and removed from your account automatically."),
              Text(
                  "This offer cannot be used in conjunction with any other bonus offer."),
              Text(
                  "We’re all for fair play, so General Terms and Conditions apply."),
            ]);
      }

      if (type == 'policy') {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("RESPONSIBLE GAMING POLICY",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text("Introduction",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 15)),
              Text(
                  "Betting has to be done in moderation in the same way as eating, drinking alcohol or any other kind of consumption."),
              Text("Please follow the guidelines below:"),
              Text(
                  "• Gaming is for entertainment and not to make money or replace an income from a job"),
              Text("• Only gamble the amount of money you can afford to lose"),
              Text("• Monitor how much time you spend with gambling"),
              Text("• Monitor if your gambling frequency rises after losses"),
              Text(
                  "People who have problems controlling their desire to place bets or have in any way problems to control the financial risk of betting have to refrain from using this or any other sports betting system."),
              Text(
                  "If you feel that you are one of these people, we recommend that you turn to an institution that delivers professional assistance against gambling addiction."),
              Text(
                  "In this case we also recommend you to block your account. The account can be blocked by the local support in your betting shop. They support will make sure that this process is documented and you cannot re-open a new account again."),
              SizedBox(height: 20),
              Text("Under 18 Warning",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 15)),
              Text(
                  "People under the age of 18 are not allowed to place any bets on this system as it is against the law of this jurisdiction. This system is only permitted for operation at venues which are restricted for people under 18 or at venues where operators verify your age during the registration process."),
              Text("If you are below the age of 18 stop using this system."),
            ]);
      }
    } else if (config.flavorName == "grandbet") {
      if (type == 'bonus') {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MULTIBET BONUS FROM 5% TO 50%",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text(
                  "Odds of each selection on a bet should be over 1.5 to benefit from Multibet Bonus."),
              Text("Add more selections and get higher bonus as following:"),
              SizedBox(height: 5),
              DataTable(
                  columnSpacing: 20.0,
                  dataRowHeight: 30,
                  headingRowHeight: 20,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        'No of events',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Bonus',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: <DataRow>[
                    DataRow(cells: [
                      DataCell(
                        Text('4-9'),
                      ),
                      DataCell(
                        Text('5%'),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Text('10-14'),
                      ),
                      DataCell(
                        Text('15%'),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Text('15-19'),
                      ),
                      DataCell(
                        Text('20%'),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Text('20-25'),
                      ),
                      DataCell(
                        Text('30%'),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Text('26-30'),
                      ),
                      DataCell(
                        Text('40%'),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Text('30+'),
                      ),
                      DataCell(
                        Text('50%'),
                      ),
                    ])
                  ]),
              SizedBox(height: 20),
              Text("FIRST DEPOSIT BONUS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              StyledText(
                text:
                    'First deposit is only available for users, who register in <bold>Grandbet APP</bold>',
                tags: {
                  'bold': StyledTextTag(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).indicatorColor)),
                },
              ),
              Text("Deposit at least 50 ETB."),
              Text("The maximum bonus is 5000 ETB."),
              Text(
                  "The bonus will be automatically deposited into your bonus balance after deposit."),
              Text(
                  "The Rollover requirements for this bonus include three (3) times the deposit and bonus amount before withdrawal of bonus winnings could be processed. For example:"),
              Text(
                  "A 1,000 ETB first deposit allows you to use your bonus of 1,000 ETB. As the wagering requirement is x3, this would require a total stake of 6,000 ETB to convert your bonus into cash available for withdrawal."),
              Text(
                  "You can use your bonus balance to place bet several times. For example:"),
              Text(
                  "You placed stake 1,000 ETB using you bonus balance for the ticket with odds 5.0. The ticket has won and you now have 5,000 ETB on your bonus balance."),
              Text(
                  "All winnings go directly to your respective balance. If the bet is made from main balance, then you get winning on your main balance. And if a bet is made from your bonus balance, then the winnings go to bonus balance."),
              Text(
                  "After claiming the bonus, you have 30 days to meet rollover requirements or you'll lose your full bonus on 31th day."),
              Text(
                  "All bets placed with the bonus offering must be at least multiples of 4 and have all odds of at least 1.35 and total odds of at least 3.0. You cannot place non-qualifying bets using your bonus balance."),
              Text(
                  "Void/Cancelled/Draw bets, Cashed-Out bets or bets placed with a Free Bet do not count towards the deposit."),
              Text(
                  "This offer cannot be used in conjunction with any other bonus offer."),
              Text(
                  "We’re all for fair play, so General Terms and Conditions apply."),
              Text(
                  "REGISTER NOW and deposit at least 50 ETB to get your FIRST DEPOSIT bonus immediately."),
              SizedBox(height: 20),
              Text("WEEKLY CASHBACK BONUS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text(
                  "10% of your losses will be returned to your account each Monday for the previous week."),
              Text(
                  "Bonus conditions apply: all bets placed for bonus must be at least multiples of 4 and have odds of at least 1.35 and total odds of at least 5.0."),
              Text("You cannot place non-qualifying bets using your bonus."),
              Text(
                  "Always select WEEKLY BONUS for placing bet with our bonus offering."),
              Text(
                  "All winnings go directly to your principal account and you will be able to withdraw your winnings immediately."),
              Text(
                  "If the bonus is not used for 5 days completely or partly, then not used amount expires and removed from your account automatically."),
              Text(
                  "This offer cannot be used in conjunction with any other bonus offer."),
              Text(
                  "We’re all for fair play, so General Terms and Conditions apply."),
            ]);
      }
      } else if (config.flavorName == "betpalace") {

       if (type == 'bonus') {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MULTIBET SUPERBONUS FROM 3% TO 10%",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text(
                  "Odds of each selection on a bet should be over 1.5 to benefit from Multibet Superbonus."),
              Text("Add more selections and get higher bonus as following:"),
              SizedBox(height: 5),
              DataTable(
                  columnSpacing: 20.0,
                  dataRowHeight: 30,
                  headingRowHeight: 20,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Events',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Superbonus',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: <DataRow>[
                    DataRow(cells: [
                      DataCell(
                        Text('3-9'),
                      ),
                      DataCell(
                        Text('3 %'),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Text('10-19'),
                      ),
                      DataCell(
                        Text('5 %'),
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Text('20+'),
                      ),
                      DataCell(
                        Text('10 %'),
                      ),
                    ])
                  ]),
              SizedBox(height: 20),
              Text("FIRST DEPOSIT BONUS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              StyledText(
                text:
                    'First deposit is only available for users, who register in <bold>Bet Palace</bold>',
                tags: {
                  'bold': StyledTextTag(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).indicatorColor)),
                },
              ),
              Text("Deposit at least 200 KSh"),
              Text("The maximum bonus is 5,000 KSh"),
              Text(
                  "The bonus will be automatically deposited into your bonus balance after deposit."),
              Text(
                  "The Rollover requirements for this bonus include three (4) times the deposit and bonus amount before withdrawal of bonus winnings could be processed. For example:"),
              Text(
                  "A 1,000 KSh first deposit allows you to use your bonus of 1,000 KSh. As the wagering requirement is x4, this would require a total stake of 8,000 KSh to convert your bonus into cash available for withdrawal."),
              Text(
                  "You can use your bonus balance to place bet several times. For example:"),
              Text(
                  "You placed stake 1,000 KSh using you bonus balance for the ticket with odds 5.0. The ticket has won and you now have 5,000 KSh on your bonus balance."),
              Text(
                  "All winnings go directly to your respective balance. If the bet is made from main balance, then you get winning on your main balance. And if a bet is made from your bonus balance, then the winnings go to bonus balance."),
              Text(
                  "After getting your bonus, you have 7 days to meet rollover requirements or you'll lose your full bonus on 8th day."),
              Text(
                  "All bets placed with the bonus offering must be at least multiples of 3 and have all odds of at least 1.5. You cannot place non-qualifying bets using your bonus balance."),
              Text(
                  "Void/Cancelled/Draw bets, Cashed-Out bets or bets placed with a Free Bet do not count towards the rollover requirement."),
              Text(
                  "This offer cannot be used in conjunction with any other bonus offer."),
              Text(
                  "We’re all for fair play, so General Terms and Conditions apply."),
              Text(
                  "REGISTER NOW and deposit at least 200 KSh to get your FIRST DEPOSIT bonus immediately."),
              SizedBox(height: 20),
              Text("WEEKLY CASHBACK BONUS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text(
                  "5% of your losses will be returned to your account each Monday for the previous week."),
              Text(
                  "Bonus conditions apply: all bets placed for bonus must be at least multiples of 3 and have odds of at least 1.5."),
              Text("You cannot place non-qualifying bets using your bonus."),
              Text(
                  "All winnings go directly to your principal account and you will be able to withdraw your winnings immediately."),
              Text(
                  "If the bonus is not used for 3 days completely or partly, then not used amount expires and removed from your account automatically."),
              Text(
                  "This offer cannot be used in conjunction with any other bonus offer."),
              Text(
                  "We’re all for fair play, so General Terms and Conditions apply."),
            ]);
      }

      if (type == 'policy') {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("RESPONSIBLE GAMING POLICY",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20)),
              SizedBox(height: 5),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                  indent: 0,
                  endIndent: 20),
              SizedBox(height: 5),
              Text("Introduction",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 15)),
              Text(
                  "Gambling is a demerit good/service and there is need to ensure that consumers a made fully aware of the same. We shall ensure that we provide information and support to both our staff and customers, through regular training and availing relevant materials in our gaming premises."),

              SizedBox(height: 20),
              Text("SELF EXCLUSION",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 15)),
              Text(
                  "Our customers will be provided with the necessary information that would range from setting gambling budget per day or per week and even self -exclusion either permanently or for a period of time."),
              Text("Our employees will also be provided with the necessary training to recognize people with a gambling problem and offer necessary advice and support."),
              Text("Our intention is to provide entertainment and we promise to uphold this through responsible operation that cares for the customers through KYC."), SizedBox(height: 20),
              SizedBox(height: 20),

              Text("RESPONSIBLE GAMING",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 15)),
              Text(
                  "Our vision is that all those who choose to gamble are able to do so responsibly, and without harming themselves or others. To achieve this outcome, The nature of betting-related harm, and its effects on individuals, children, families, friends and communities, is well understood. There is a similarly good understanding of the personal and social determinants of betting-related harm. iii. Regulatory, educational, physical and social environments all encourage players’ to be responsible. Reliable means exist to identify individuals who may be betting harmfully. Effective steps are being taken to reduce or mitigate betting-related harm through well-developed, tested intervention and treatment strategies. Good industry data are available about all forms of betting, freely shared with those with a legitimate interest, restricted only by reasonable constraints related to commercial confidentiality. vii. Effective information, advice and treatment are available within reasonable time frames to all those in need of help with their betting, and to their families, friends and others affected by their betting. viii. In addition to operators, a wide range of organizations and agencies in the public and private sectors accept their responsibility to use their expertise and resources to inhibit harmful betting or to mitigate its effects. The issue of responsibility in betting is approached by all who have a stake in its availability and impact in a balanced, supportive and open-minded way, with positive engagement and mutual respect. Innovation is welcomed. But the precautionary principle is applied to new products, or to innovation in other areas, when there is good reason to believe they might cause harm disproportionate to any benefits they might bring. Such judgments are made after discussion between relevant stakeholders and careful consideration of the potential consequences of any change in policy or regulation. Children and young persons are able to grow up in an environment where they are protected from betting-related harm. We don’t claim that we have the capacity nor the expertise to mitigate this problem but we have the will and purpose to make responsible betting/gaming in Kenya a reality. We will endeavor to achieve with effort by: - Lobbying for the establishment of a Responsible Gaming Foundation with participation from all industry stake holders. It will be financed by an agreed voluntary subscription from industry players. The stakeholders will be composed of sector leaders, regulatory officials and members of the health sector. Its primary purpose will be continuously probing the industry’s efforts at responsible gaming as well as give overall guidance on responsible gaming policy and guidelines for the industry as well as best practice standards. This will form the backbone of self-regulation that will see the sector move towards responsibility and accountability. - Rallying industry players to participate in an annual responsible gaming conference where specialists and resource persons in the area of relevance can share teach and impart their experiences and knowledge to all in attendance for the mass awareness of the pertinent issues at hand and how to best mitigate problems that may arise. - Engaging health sector partners from Europe who have long and immense experience in identifying and mitigating betting related problems. By offering these possibilities for collaboration with Kenyan practitioners there will be a buildup of human capital capacity to assist Kenyans and thus for the benefit of the gaming industry as a whole. - Having an internal 24-7-365 internal on-call counselor at our disposal that will both assess at-risk clients as well as offer the first line of help to those with a betting problem. - Continuously training our staff on how to assess clients with potential betting related problems as well as report to management for further action. This is in addition to implementing analytics on customer records/profiles in the casino for early warnings from tell-tale signs of problems."),
              SizedBox(height: 20),

              Text("Under 18 Warning",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).indicatorColor,
                      fontSize: 15)),
              Text(
                  "People under the age of 18 are not allowed to place any bets on this system as it is against the law of this jurisdiction. This system is only permitted for operation at venues which are restricted for people under 18 or at venues where operators verify your age during the registration process. If you are below the age of 18 stop using this system."),

            ]);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
              extendBodyBehindAppBar: true,
              body: CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.onBackground,
                  shape: ContinuousRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  title: Text(LocaleKeys.rules.tr()),
                  pinned: true,
                  elevation: 0,
                  expandedHeight: 200,
                  collapsedHeight: 70,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                        margin: const EdgeInsets.only(bottom: 50.0),
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                            config.imageLocation + "logo/logo.png",
                            fit: BoxFit.contain,
                            height: 60)),
                  ),
                ),
                SliverPinnedHeader(
                    child: DefaultTextStyle(
                        style: TextStyle(color: Colors.grey, fontSize: 8),
                        child: Container(
                            padding: EdgeInsets.only(bottom: 10.0, top: 5.0),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.4, 0.0],
                              colors: [
                                Theme.of(context).colorScheme.onBackground,
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      RawMaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedText = "bonus";
                                          });
                                        },
                                        elevation: 2.0,
                                        fillColor: Colors.grey[800],
                                        child: Icon(Icons.card_giftcard,
                                            size: 30.0, color: Colors.white),
                                        padding: EdgeInsets.all(10.0),
                                        shape: CircleBorder(),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                          width: 80,
                                          child: Text(
                                            "Bonus",
                                            textAlign: TextAlign.center,
                                          ))
                                    ])),
                                Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      RawMaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedText = "policy";
                                          });
                                        },
                                        elevation: 2.0,
                                        fillColor: Colors.grey[800],
                                        child: Icon(Icons.gavel,
                                            size: 30.0, color: Colors.white),
                                        padding: EdgeInsets.all(10.0),
                                        shape: CircleBorder(),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                          width: 80,
                                          child: Text(
                                            "Betting Rules\n(Policy)",
                                            textAlign: TextAlign.center,
                                          ))
                                    ])),
                                Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      RawMaterialButton(
                                        onPressed: () {
                                          launch(
                                              "${config.protocol}://${config.linkShareDomainUrl}/pages/info/sport-betting-rules-general");
                                        },
                                        elevation: 2.0,
                                        fillColor: Colors.grey[800],
                                        child: Icon(Icons.content_paste,
                                            size: 30.0, color: Colors.white),
                                        padding: EdgeInsets.all(10.0),
                                        shape: CircleBorder(),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                          width: 80,
                                          child: Text(
                                            "Betting Rules\n(General)",
                                            textAlign: TextAlign.center,
                                          ))
                                    ])),
                                Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      RawMaterialButton(
                                        onPressed: () {
                                          launch(
                                              "${config.protocol}://${config.linkShareDomainUrl}/pages/info/faq");
                                        },
                                        elevation: 2.0,
                                        fillColor: Colors.grey[800],
                                        child: Icon(Icons.contact_support,
                                            size: 30.0, color: Colors.white),
                                        padding: EdgeInsets.all(10.0),
                                        shape: CircleBorder(),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                          width: 80,
                                          child: Text(
                                            "FAQ",
                                            textAlign: TextAlign.center,
                                          ))
                                    ])),
                              ],
                            )))),
                SliverToBoxAdapter(
                    child: SingleChildScrollView(
                        child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                      DefaultTextStyle(
                          style: TextStyle(
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onPrimary),
                          child: Container(
                              padding: EdgeInsets.all(20.0),
                              child: getBonusText(selectedText)))
                    ])))
              ]));
        });
  }
}
