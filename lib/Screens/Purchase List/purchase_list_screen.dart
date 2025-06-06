import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/generate_pdf.dart';
import 'package:mobile_pos/Screens/Purchase/add_and_edit_purchase.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/add_to_cart_purchase.dart';
import '../../currency.dart';
import '../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../Home/home.dart';
import '../invoice_details/purchase_invoice_details.dart';
import '../invoice return/invoice_return_screen.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  PurchaseReportState createState() => PurchaseReportState();
}

class PurchaseReportState extends State<PurchaseListScreen> {
  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.refresh(purchaseTransactionProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await const Home().launch(context, isNewTask: true);
      },
      child: GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).purchaseList,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20.0,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Consumer(builder: (context, ref, __) {
            final providerData = ref.watch(purchaseTransactionProvider);
            final printerData = ref.watch(thermalPrinterProvider);
            final profile = ref.watch(businessInfoProvider);
            final businessSetting = ref.watch(businessSettingProvider);
            return RefreshIndicator.adaptive(
              onRefresh: () => refreshData(ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: providerData.when(data: (purchaseTransactions) {
                  return purchaseTransactions.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: purchaseTransactions.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                PurchaseInvoiceDetails(
                                  businessInfo: profile.value!,
                                  transitionModel: purchaseTransactions[index],
                                ).launch(context);
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    width: context.width(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              purchaseTransactions[index].party?.name ?? '',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            Text('#${purchaseTransactions[index].invoiceNumber}'),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      color: purchaseTransactions[index].dueAmount! <= 0
                                                          ? const Color(0xff0dbf7d).withOpacity(0.1)
                                                          : const Color(0xFFED1A3B).withOpacity(0.1),
                                                      borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                  child: Text(
                                                    purchaseTransactions[index].dueAmount! <= 0 ? lang.S.of(context).paid : lang.S.of(context).unPaid,
                                                    style: TextStyle(color: purchaseTransactions[index].dueAmount! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                                  ),
                                                ),

                                                ///________Return_tag_________________________________________
                                                Visibility(
                                                  visible: purchaseTransactions[index].purchaseReturns?.isNotEmpty ?? false,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 20, right: 20),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                      child: Text(
                                                        lang.S.of(context).returned,
                                                        style: const TextStyle(color: Colors.orange),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              DateFormat.yMMMd().format(DateTime.parse(purchaseTransactions[index].purchaseDate ?? '')),
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${lang.S.of(context).total} : $currency ${purchaseTransactions[index].totalAmount.toString()}',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${lang.S.of(context).paid} : $currency ${purchaseTransactions[index].totalAmount!.toDouble() - purchaseTransactions[index].dueAmount!.toDouble()}',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${lang.S.of(context).due}: $currency ${purchaseTransactions[index].dueAmount.toString()}',
                                              style: const TextStyle(fontSize: 16),
                                            ).visible(purchaseTransactions[index].dueAmount!.toInt() != 0),
                                            profile.when(data: (data) {
                                              return Row(
                                                children: [
                                                  IconButton(
                                                      padding: EdgeInsets.zero,
                                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                      onPressed: () async {
                                                        ///________Print_______________________________________________________

                                                        PrintPurchaseTransactionModel model =
                                                            PrintPurchaseTransactionModel(purchaseTransitionModel: purchaseTransactions[index], personalInformationModel: data);

                                                        await printerData.printPurchaseThermalInvoiceNow(
                                                          transaction: model,
                                                          productList: model.purchaseTransitionModel!.details,
                                                          context: context,
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        FeatherIcons.printer,
                                                        color: Colors.grey,
                                                      )),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  businessSetting.when(data: (bussiness) {
                                                    return IconButton(
                                                        padding: EdgeInsets.zero,
                                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                        onPressed: () => GeneratePdf().generatePurchaseDocument(purchaseTransactions[index], data, context, bussiness),
                                                        icon: const Icon(
                                                          Icons.picture_as_pdf,
                                                          color: Colors.grey,
                                                        ));
                                                  }, error: (e, statck) {
                                                    return Text(e.toString());
                                                  }, loading: () {
                                                    return const Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                                  }),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),

                                                  ///_________Edit_purchase______________________________
                                                  Visibility(
                                                    visible: !(purchaseTransactions[index].purchaseReturns?.isNotEmpty ?? false),
                                                    child: IconButton(
                                                        padding: EdgeInsets.zero,
                                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                        onPressed: () {
                                                          ref.refresh(cartNotifierPurchaseNew);
                                                          AddAndUpdatePurchaseScreen(
                                                            transitionModel: purchaseTransactions[index],
                                                            customerModel: null,
                                                          ).launch(context);
                                                        },
                                                        icon: const Icon(
                                                          FeatherIcons.edit,
                                                          color: Colors.grey,
                                                        )),
                                                  ),

                                                  ///_____More____________________________________________
                                                  PopupMenuButton(
                                                    offset: const Offset(0, 30),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (BuildContext bc) => [
                                                      ///________Sale List Delete_______________________________
                                                      // PopupMenuItem(
                                                      //   child: GestureDetector(
                                                      //     onTap: () async {
                                                      //       bool? result = await invoiceDeleteAlert(context: context, type: 'Purchase Invoice');
                                                      //       Navigator.pop(bc);
                                                      //       if (result != null && result) {}
                                                      //     },
                                                      //     child: const Row(
                                                      //       children: [
                                                      //         Icon(
                                                      //           Icons.delete,
                                                      //           color: kGreyTextColor,
                                                      //         ),
                                                      //         SizedBox(
                                                      //           width: 10.0,
                                                      //         ),
                                                      //         Text(
                                                      //           'Delete',
                                                      //           style: TextStyle(color: kGreyTextColor),
                                                      //         ),
                                                      //       ],
                                                      //     ),
                                                      //   ),
                                                      // ),

                                                      ///________Purchase Return___________________________________
                                                      PopupMenuItem(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => InvoiceReturnScreen(purchaseTransaction: purchaseTransactions[index]),
                                                              ),
                                                            );
                                                            Navigator.pop(bc);
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.keyboard_return_outlined,
                                                                color: kGreyTextColor,
                                                              ),
                                                              SizedBox(
                                                                width: 10.0,
                                                              ),
                                                              Text(
                                                                'Purchase return',
                                                                style: TextStyle(color: kGreyTextColor),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      Navigator.pushNamed(context, '$value');
                                                    },
                                                    child: const Icon(
                                                      FeatherIcons.moreVertical,
                                                      color: kGreyTextColor,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }, error: (e, stack) {
                                              return Text(e.toString());
                                            }, loading: () {
                                              //return  Text('Loading');
                                              return Text(lang.S.of(context).loading);
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 0.5,
                                    width: context.width(),
                                    color: Colors.grey,
                                  )
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            lang.S.of(context).addAPurchase,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        );
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
