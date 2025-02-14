import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class GridItems {
  final String title, icon, route;

  GridItems({required this.title, required this.icon, required this.route});
}

List<GridItems> quickTransactions({required BuildContext context}) {
  List<GridItems> quickTransactions = [
    GridItems(
      title: lang.S.of(context).sale,
      icon: 'assets/sales.svg',
      route: 'Sales',
    ),
    GridItems(
      title: lang.S.of(context).parties,
      icon: 'assets/parties.svg',
      route: 'Parties',
    ),
    GridItems(
      title: lang.S.of(context).purchase,
      icon: 'assets/purchase.svg',
      route: 'Purchase',
    ),
    GridItems(
      title: lang.S.of(context).product,
      icon: 'assets/products.svg',
      route: 'Products',
    ),
    GridItems(
      title: lang.S.of(context).dueList,
      icon: 'assets/duelist.svg',
      route: 'Due List',
    ),
    GridItems(
      title: lang.S.of(context).stockList,
      icon: 'assets/stock.svg',
      route: 'Stock',
    ),
    GridItems(
      title: lang.S.of(context).reports,
      icon: 'assets/reports.svg',
      route: 'Reports',
    ),

  ];
  return quickTransactions;
}

List<GridItems> businessIcons = [
  GridItems(
    title: 'Warehouse',
    icon: 'images/warehouse.png',
    route: 'Warehouse',
  ),
  GridItems(
    title: 'SalesReturn',
    icon: 'images/salesreturn.png',
    route: 'SalesReturn',
  ),
  GridItems(
    title: 'SalesList',
    icon: 'images/salelist.png',
    route: 'SalesList',
  ),
  GridItems(
    title: 'Quotation',
    icon: 'images/quotation.png',
    route: 'Quotation',
  ),
  GridItems(
    title: 'OnlineStore',
    icon: 'images/onlinestore.png',
    route: 'OnlineStore',
  ),
  GridItems(
    title: 'Supplier',
    icon: 'images/supplier.png',
    route: 'Supplier',
  ),
  GridItems(
    title: 'Invoice',
    icon: 'images/invoice.png',
    route: 'Invoice',
  ),
  GridItems(
    title: 'Stock',
    icon: 'images/stock.png',
    route: 'Stock',
  ),
  GridItems(
    title: 'Ledger',
    icon: 'images/ledger.png',
    route: 'Ledger',
  ),
  GridItems(
    title: 'Dashboard',
    icon: 'images/dashboard.png',
    route: 'Dashboard',
  ),
  GridItems(
    title: 'Bank',
    icon: 'images/bank.png',
    route: 'Bank',
  ),
  GridItems(
    title: 'Barcode',
    icon: 'images/barcodescan.png',
    route: 'Barcode',
  )
];


