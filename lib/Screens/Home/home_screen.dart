import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Customers/Provider/customer_provider.dart';
import 'package:mobile_pos/Screens/DashBoard/dashboard.dart';
import 'package:mobile_pos/Screens/Expense/Providers/all_expanse_provider.dart';
import 'package:mobile_pos/Screens/Home/components/grid_items.dart';
import 'package:mobile_pos/Screens/Income/Providers/all_income_provider.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:mobile_pos/Screens/vat_&_tax/provider/text_repo.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../model/business_info_model.dart' as business;
import '../subscription/package_screen.dart';
import '../subscription/purchase_premium_plan_screen.dart';
import 'Provider/banner_provider.dart';
import '../Home/Model/banner_model.dart' as b;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController = PageController(initialPage: 0);

  //premium pop dialog
  void getUpgradeDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kWhite,
            surfaceTintColor: kWhite,
            elevation: 0.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: const EdgeInsets.all(20),
            titlePadding: const EdgeInsets.all(0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: kGreyTextColor,
                        )),
                  ],
                ),
                SvgPicture.asset(
                  'assets/onbord3.svg',
                  height: 198,
                  width: 238,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  lang.S.of(context).endYourFreePlan,
                  textAlign: TextAlign.center,
                  // 'End your Free plan',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kTitleColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  lang.S.of(context).yourFree,
                  // 'Your Free Package is almost done, buy your next plan Thanks.',
                  style: gTextStyle.copyWith(color: kGreyTextColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                UpdateButton(
                    text: lang.S.of(context).upgradeNow,
                    //'Upgrade Now',
                    onpressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PackageScreen()));
                    }),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
        });
  }

  // get subs status
  String getSubscriptionStatus(String? subscriptionDate, String expireDate, business.EnrolledPlan? enrolledPlan, BuildContext context) {
    if (subscriptionDate == null || enrolledPlan == null) {
      return 'Expired';
    }
    DateTime parsedSubscriptionDate = DateTime.parse(subscriptionDate);
    num duration = enrolledPlan.duration ?? 0;
    DateTime expirationDate = parsedSubscriptionDate.add(Duration(days: duration.toInt()));
    num daysLeft = expirationDate.difference(DateTime.now()).inDays;
    if (daysLeft < 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchasePremiumPlanScreen(
              isExpired: true,
              isCameBack: false,
              enrolledPlan: enrolledPlan,
              willExpire: expireDate,
            ),
          ),
        );
      });
      return 'Expired';
    } else {
      return '$daysLeft Days Left';
    }
  }

  bool _isRefreshing = false;

  Future<void> refreshAllProviders({required WidgetRef ref}) async {
    if (_isRefreshing) return; // Prevent multiple refresh calls

    _isRefreshing = true;
    try {
      ref.refresh(summaryInfoProvider);
      ref.refresh(bannerProvider);
      ref.refresh(businessInfoProvider);
      await Future.delayed(const Duration(seconds: 3));
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, ref, __) {
      final businessInfo = ref.watch(businessInfoProvider);
      final summaryInfo = ref.watch(summaryInfoProvider);
      final banner = ref.watch(bannerProvider);
      return businessInfo.when(data: (details) {
        return Scaffold(
            backgroundColor: kBackgroundColor,
            ///-------Appbar--------///
            appBar: AppBar(
              backgroundColor: kWhite,
              titleSpacing: 5,
              surfaceTintColor: kWhite,
              actions: [IconButton(onPressed: () async => refreshAllProviders(ref: ref), icon: const Icon(Icons.notifications_outlined))],
              leading: Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    const ProfileDetails().launch(context);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: details.pictureUrl == null
                        ? BoxDecoration(
                            image: const DecorationImage(image: AssetImage('images/no_shop_image.png'), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(50),
                          )
                        : BoxDecoration(
                            image: DecorationImage(image: NetworkImage('${APIConfig.domain}${details.pictureUrl}'), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(50),
                          ),
                  ),
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.user?.role == 'staff' ? '${details.companyName ?? ''} [${details.user?.name ?? ''}]' : details.companyName ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
            ///-------RefreshIndicator--------///
            body: RefreshIndicator.adaptive(
              color: kMainColor,
              onRefresh: () async => refreshAllProviders(ref: ref),
              ///-------Scrollview--------///
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: details.user?.visibility?.dashboardPermission ?? true,
                        child: summaryInfo.when(data: (summary) {
                          ///-------summary section started -> Display successfully fetched data--------///
                          return Container(
                            padding: const EdgeInsets.all(35),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [gradientStart, gradientEnd], // Define your gradient colors
                                begin: Alignment.topLeft, // Define the starting point of the gradient
                                end: Alignment.bottomRight, // Define the ending point of the gradient
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        lang.S.of(context).todaySummary,
                                        //'Today’s Summary',
                                        style: gTextStyle.copyWith(fontWeight: FontWeight.bold, color: kWhite, fontSize: 18),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),

                                    //see all part comment

                                    /*Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                                          },
                                          child: Text(
                                            lang.S.of(context).sellAll,

                                            //'Sell All >',
                                            style: const TextStyle(color: kWhite, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                          )),
                                    ),*/
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    // First Column (Sales and Profit/Loss)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Sales Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.blue.withOpacity(0.2),
                                              child: Icon(Icons.attach_money, size: 16, color: Colors.blue),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).sales,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  '$currency ${summary.data?.sales?.toStringAsFixed(2) ?? 0}',
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Profit/Loss Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: summary.data!.income! >= 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                              child: Icon(
                                                summary.data!.income! >= 0 ? Icons.trending_up : Icons.trending_down,
                                                size: 16,
                                                color: summary.data!.income! >= 0 ? Colors.green : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  summary.data!.income! >= 0 ? 'Profit' : 'Loss',
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  '$currency ${summary.data?.income?.abs().toStringAsFixed(2) ?? 0}',
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Second Column (Purchased and Expense)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Purchased Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.orange.withOpacity(0.2),
                                              child: Icon(Icons.shopping_cart, size: 16, color: Colors.orange),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).purchased,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  '$currency ${summary.data?.purchase?.toStringAsFixed(2) ?? 0}',
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Expense Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.purple.withOpacity(0.2),
                                              child: Icon(Icons.money_off, size: 16, color: Colors.purple),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).expense,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  '$currency ${summary.data?.expense?.toStringAsFixed(2) ?? 0}',
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 30),
                                  ],
                                )
                              ],
                            ),
                          );
                        }, error: (e, stack) {
                          ///-------Display not found to all value--------///
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kMainColor),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      lang.S.of(context).todaySummary,
                                      //'Today’s Summary',
                                      style: gTextStyle.copyWith(fontWeight: FontWeight.bold, color: kWhite, fontSize: 18),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                                        },
                                        child: Text(
                                          lang.S.of(context).sellAll,
                                          //'Sell All >',
                                          style: const TextStyle(color: kWhite, fontWeight: FontWeight.w500),
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    // First Column (Sales and Income)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Sales Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.blue.withOpacity(0.2),
                                              child: Icon(Icons.attach_money, size: 16, color: Colors.blue),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).sales,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).notFound,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Income Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.green.withOpacity(0.2),
                                              child: Icon(Icons.trending_up, size: 16, color: Colors.green),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).income,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).notFound,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Second Column (Purchased and Expense)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Purchased Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.orange.withOpacity(0.2),
                                              child: Icon(Icons.shopping_cart, size: 16, color: Colors.orange),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).purchased,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).notFound,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Expense Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.purple.withOpacity(0.2),
                                              child: Icon(Icons.money_off, size: 16, color: Colors.purple),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).expense,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).notFound,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 30),
                                  ],
                                )
                              ],
                            ),
                          );
                        }, loading: () {
                          ///-------Display Loading to all value--------///
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kMainColor),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      lang.S.of(context).todaySummary,
                                      // 'Today’s Summary',
                                      style: gTextStyle.copyWith(fontWeight: FontWeight.bold, color: kWhite, fontSize: 18),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                                        },
                                        child: Text(
                                          lang.S.of(context).sellAll,
                                          //'Sell All >',
                                          style: const TextStyle(color: kWhite, fontWeight: FontWeight.w500),
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                Row(
                                  children: [
                                    // First Column (Sales and Income)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Sales Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.blue.withOpacity(0.2),
                                              child: Icon(Icons.attach_money, size: 16, color: Colors.blue),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).sales,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).loading,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Income Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.green.withOpacity(0.2),
                                              child: Icon(Icons.trending_up, size: 16, color: Colors.green),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).income,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).loading,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Second Column (Purchased and Expense)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Purchased Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.orange.withOpacity(0.2),
                                              child: Icon(Icons.shopping_cart, size: 16, color: Colors.orange),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).purchased,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).loading,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Expense Row with Icon
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.purple.withOpacity(0.2),
                                              child: Icon(Icons.money_off, size: 16, color: Colors.purple),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lang.S.of(context).expense,
                                                  style: gTextStyle.copyWith(color: kWhite),
                                                ),
                                                Text(
                                                  lang.S.of(context).loading,
                                                  style: gTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 30),
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      ///-------subscription section--------///
                      /*const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          getUpgradeDialog();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: kWhite,
                              boxShadow: [BoxShadow(color: const Color(0xffC52127).withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 10))]),
                          child: ListTile(
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            horizontalTitleGap: 20,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            leading: SvgPicture.asset(
                              'assets/plan.svg',
                              height: 38,
                              width: 38,
                            ),
                            title: RichText(
                              text: TextSpan(
                                text: '${details.enrolledPlan?.plan?.subscriptionName} ${lang.S.of(context).package} ',
                                style: gTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: getSubscriptionStatus(details.subscriptionDate, details.willExpire, details.enrolledPlan, context),
                                      // '(${((DateTime.tryParse(details.subscriptionDate ?? '') ?? DateTime.now()).difference(DateTime.now()).inDays.abs() - (details.enrolledPlan?.duration ?? 0)).abs()} Days Left)',
                                      style: gTextStyle.copyWith(color: kGreyTextColor, fontWeight: FontWeight.w400))
                                ],
                              ),
                            ),
                            subtitle: Text(
                              lang.S.of(context).updateYourSubscription,
                              //'Update your subscription',
                              style: gTextStyle.copyWith(color: kGreyTextColor, fontSize: 14),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: kGreyTextColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),*/
                      const SizedBox(height: 20),

                      ///-------GridView--------///
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        childAspectRatio: 3.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        children: List.generate(
                          getFreeIcons(context: context).length,
                          (index) => HomeGridCards(
                            gridItems: getFreeIcons(context: context)[index],
                            visibility: businessInfo.value?.user?.visibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///________________Divider (after this banner is showing)__________________
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 10),

                      ///________________Banner_______________________________________
                      banner.when(data: (imageData) {
                        List<b.Banner> images = [];
                        if (imageData.isNotEmpty) {
                          images.addAll(imageData.where(
                            (element) => element.status == 1,
                          ));
                        }

                        if (images.isNotEmpty) {
                          return SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  lang.S.of(context).whatNew,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      child: const Icon(Icons.keyboard_arrow_left),
                                      onTap: () {
                                        pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
                                      },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 150,
                                      width: MediaQuery.of(context).size.width - 80,
                                      child: PageView.builder(
                                        pageSnapping: true,
                                        itemCount: images.length,
                                        controller: pageController,
                                        itemBuilder: (_, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              const PackageScreen().launch(context);
                                            },
                                            child: Image(
                                              image: NetworkImage(
                                                "${APIConfig.domain}${images[index].imageUrl}",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      child: const Icon(Icons.keyboard_arrow_right),
                                      onTap: () {
                                        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 150,
                              width: 320,
                              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('images/banner1.png'))),
                            ),
                          );
                        }
                      }, error: (e, stack) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 150,
                            width: 320,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Text(
                                lang.S.of(context).noDataFound,
                                //'No Data Found'
                              ),
                            ),
                          ),
                        );
                      }, loading: () {
                        return const CircularProgressIndicator();
                      }),
                    ],
                  ),
                ),
              ),
            ));
      }, error: (e, stack) {
        return Text(e.toString());
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}

class HomeGridCards extends StatefulWidget {
  const HomeGridCards({
    Key? key,
    required this.gridItems,
    this.visibility,
  }) : super(key: key);
  final GridItems gridItems;
  final business.Visibility? visibility;

  @override
  State<HomeGridCards> createState() => _HomeGridCardsState();
}

class _HomeGridCardsState extends State<HomeGridCards> {
  bool checkPermission({required String item}) {
    if (item == 'Sales' && (widget.visibility?.salePermission ?? true)) {
      return true;
    } else if (item == 'Parties' && (widget.visibility?.partiesPermission ?? true)) {
      return true;
    } else if (item == 'Purchase' && (widget.visibility?.purchasePermission ?? true)) {
      return true;
    } else if (item == 'Products' && (widget.visibility?.productPermission ?? true)) {
      return true;
    } else if (item == 'Due List' && (widget.visibility?.dueListPermission ?? true)) {
      return true;
    } else if (item == 'Stock' && (widget.visibility?.stockPermission ?? true)) {
      return true;
    } else if (item == 'Reports' && (widget.visibility?.reportsPermission ?? true)) {
      return true;
    } else if (item == 'Sales List' && (widget.visibility?.salesListPermission ?? true)) {
      return true;
    } else if (item == 'Purchase List' && (widget.visibility?.purchaseListPermission ?? true)) {
      return true;
    } else if (item == 'Loss/Profit' && (widget.visibility?.lossProfitPermission ?? true)) {
      return true;
    } else if (item == 'Expense' && (widget.visibility?.addExpensePermission ?? true)) {
      return true;
    } else if (item == 'Income' && (widget.visibility?.addIncomePermission ?? true)) {
      return true;
    } else if (item == 'tax') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return GestureDetector(
        onTap: () async {
          if (checkPermission(item: widget.gridItems.route)) {
            Navigator.of(context).pushNamed('/${widget.gridItems.route}');
          } else {
            EasyLoading.showError(
              lang.S.of(context).permissionNotGranted,
              // 'Permission not granted!'
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: kWhite,
              boxShadow: [BoxShadow(color: const Color(0xff171717).withOpacity(0.07), offset: const Offset(0, 3), blurRadius: 50, spreadRadius: -4)]),
          child: Row(
            children: [
              SvgPicture.asset(
                widget.gridItems.icon.toString(),
                height: 40,
                width: 40,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                  child: Text(
                widget.gridItems.title.toString(),
                style: gTextStyle.copyWith(fontSize: 16, color: const Color(0xff4D4D4D)),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ))
            ],
          ),
        ),
      );
    });
  }
}
