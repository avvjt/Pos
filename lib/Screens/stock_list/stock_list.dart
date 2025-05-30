import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/invoice_constant.dart';
import '../../Provider/product_provider.dart';
import '../../currency.dart';

class StockList extends StatefulWidget {
  const StockList({super.key, required this.isFromReport});
  final bool isFromReport;

  @override
  StockListState createState() => StockListState();
}

class StockListState extends State<StockList> {
  String productSearch = '';
  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.refresh(productProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {

    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(productProvider);
      return providerData.when(

        data: (product) {
          double totalParPrice = 0;
          List<ProductModel> showableProducts = [];
          for (var element in product) {
            if (element.productName!.toLowerCase().contains(productSearch.toLowerCase().trim())) {
              showableProducts.add(element);
              totalParPrice += (element.productPurchasePrice ?? 0) * (element.productStock ?? 0);
            }
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                lang.S.of(context).stockList,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            body: RefreshIndicator(
              onRefresh: () => refreshData(ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: product.isNotEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            height: 50,
                            color: const Color(0xffFEF0F1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      lang.S.of(context).product,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            lang.S.of(context).cost,
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            lang.S.of(context).qty,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            lang.S.of(context).sale,
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListView.builder(
                              itemCount: showableProducts.length,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            showableProducts[index].productName.toString(),
                                            textAlign: TextAlign.start,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          Text(
                                            showableProducts[index].brand?.brandName ?? '',
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.poppins(
                                              color: kGreyTextColor,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '$currency${showableProducts[index].productPurchasePrice}',
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.poppins(
                                                color: (showableProducts[index].productStock ?? 0) < 20 ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              showableProducts[index].productStock.toString(),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: (showableProducts[index].productStock ?? 0) < 20 ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '$currency ${showableProducts[index].productSalePrice}',
                                              textAlign: TextAlign.end,
                                              style: GoogleFonts.poppins(
                                                color: (showableProducts[index].productStock ?? 0) < 20 ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          lang.S.of(context).noProductFound,
                        ),
                      ),
              ),
            ),
            bottomNavigationBar: Container(
              color: const Color(0xffFEF0F1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.S.of(context).stockValue,
                      style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor, fontSize: 14),
                    ),
                    Text(
                      '$currency${totalParPrice.toInt().toString()}',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        error: (e, stack) {
          return Text(e.toString());
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      );
    });
  }
}
