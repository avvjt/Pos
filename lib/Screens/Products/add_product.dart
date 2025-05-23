import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Products/Model/brands_model.dart' as brand;
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/Products/Model/unit_model.dart' as unit;
import 'package:mobile_pos/Screens/Products/Repo/product_repo.dart';
import 'package:mobile_pos/Screens/Products/brands_list.dart';
import 'package:mobile_pos/Screens/Products/category_list_screen.dart';
import 'package:mobile_pos/Screens/Products/unit_list.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Const/api_config.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../vat_&_tax/model/vat_model.dart';
import '../vat_&_tax/provider/text_repo.dart';
import 'Model/category_model.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key, this.productModel});

  final ProductModel? productModel;

  @override
  AddProductState createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {
  CategoryModel? selectedCategory;
  brand.Brand? selectedBrand;
  unit.Unit? selectedUnit;
  late String productName, productStock, productSalePrice, productPurchasePrice, productCode;

  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController productUnitController = TextEditingController();
  TextEditingController productStockController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController discountPriceController = TextEditingController();
  TextEditingController purchaseExclusivePriceController = TextEditingController();
  TextEditingController profitMarginController = TextEditingController();
  TextEditingController purchaseInclusivePriceController = TextEditingController();
  TextEditingController productCodeController = TextEditingController();
  TextEditingController wholeSalePriceController = TextEditingController();
  TextEditingController dealerPriceController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  void initializeControllers() {
    if (widget.productModel != null) {
      nameController = TextEditingController(text: widget.productModel?.productName ?? '');
      if (widget.productModel?.category != null) {
        final givenCategory = widget.productModel;
        categoryController = TextEditingController(text: widget.productModel?.category?.categoryName ?? '');
        selectedCategory = CategoryModel(
          id: widget.productModel?.category?.id,
          variationCapacity: givenCategory?.capacity != null,
          variationColor: givenCategory?.color != null,
          variationSize: givenCategory?.size != null,
          variationType: givenCategory?.type != null,
          variationWeight: givenCategory?.weight != null,
        );
      }
      if (widget.productModel?.brand != null) {
        brandController = TextEditingController(text: widget.productModel?.brand?.brandName ?? '');
        selectedBrand = brand.Brand(id: widget.productModel?.brand?.id);
      }
      if (widget.productModel?.unit != null) {
        productUnitController = TextEditingController(text: widget.productModel?.unit?.unitName ?? '');
        selectedUnit = unit.Unit(id: widget.productModel?.unit?.id);
      }

      productStockController = TextEditingController(text: widget.productModel?.productStock?.toString() ?? '');
      salePriceController = TextEditingController(text: widget.productModel?.productSalePrice?.toString() ?? '');
      selectedTaxType = widget.productModel?.vatType ?? "Exclusive";
      if (widget.productModel?.vatType?.toLowerCase() == 'exclusive') {
        purchaseExclusivePriceController = TextEditingController(text: widget.productModel?.productPurchasePrice?.toStringAsFixed(2));
        purchaseInclusivePriceController =
            TextEditingController(text: ((widget.productModel?.productPurchasePrice ?? 0) + (widget.productModel?.vatAmount ?? 0)).toStringAsFixed(2));
      } else {
        purchaseInclusivePriceController = TextEditingController(text: widget.productModel?.productPurchasePrice?.toStringAsFixed(2));
        purchaseExclusivePriceController =
            TextEditingController(text: ((widget.productModel?.productPurchasePrice ?? 0) - (widget.productModel?.vatAmount ?? 0)).toStringAsFixed(2));
      }
      profitMarginController = TextEditingController(text: widget.productModel?.profitMargin?.toStringAsFixed(2) ?? '');
      productCodeController = TextEditingController(text: widget.productModel?.productCode ?? '');
      wholeSalePriceController = TextEditingController(text: widget.productModel?.productWholeSalePrice?.toStringAsFixed(2) ?? '');
      dealerPriceController = TextEditingController(text: widget.productModel?.productDealerPrice?.toStringAsFixed(2) ?? '');
      manufacturerController = TextEditingController(text: widget.productModel?.productManufacturer ?? '');
      sizeController = TextEditingController(text: widget.productModel?.size ?? '');
      colorController = TextEditingController(text: widget.productModel?.color ?? '');
      weightController = TextEditingController(text: widget.productModel?.weight ?? '');
      typeController = TextEditingController(text: widget.productModel?.type ?? '');
      capacityController = TextEditingController(text: widget.productModel?.capacity ?? '');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    brandController.dispose();
    productUnitController.dispose();
    productStockController.dispose();
    salePriceController.dispose();
    discountPriceController.dispose();
    purchaseExclusivePriceController.dispose();
    profitMarginController.dispose();
    purchaseInclusivePriceController.dispose();
    productCodeController.dispose();
    wholeSalePriceController.dispose();
    dealerPriceController.dispose();
    manufacturerController.dispose();
    sizeController.dispose();
    colorController.dispose();
    weightController.dispose();
    typeController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  VatModel? selectedTax;
  String selectedTaxType = 'Exclusive';
  List<String> codeList = [];
  String promoCodeHint = 'Enter Product Code';

  void calculatePurchaseAndMrp({String? from}) {
    num taxRate = selectedTax?.rate ?? 0;
    num purchaseExc = 0;
    num purchaseInc = 0;
    num profitMargin = num.tryParse(profitMarginController.text) ?? 0;
    num salePrice = 0;

    // Calculate Purchase Exclusive Price if input is 'purchase_inc'
    if (from == 'purchase_inc') {
      purchaseExc = (num.tryParse(purchaseInclusivePriceController.text) ?? 0) / (1 + taxRate / 100);
      purchaseExclusivePriceController.text = purchaseExc.toStringAsFixed(2);
    } else {
      purchaseExc = num.tryParse(purchaseExclusivePriceController.text) ?? 0;
      // Calculate Purchase Inclusive Price if not 'purchase_inc'
      purchaseInc = purchaseExc + (purchaseExc * taxRate / 100);
      purchaseInclusivePriceController.text = purchaseInc.toStringAsFixed(2);
    }

    purchaseInc = num.tryParse(purchaseInclusivePriceController.text) ?? 0;

    // If input is 'mrp', recalculate profit margin based on sale price
    if (from == 'mrp') {
      salePrice = num.tryParse(salePriceController.text) ?? 0;

      // Calculate profit margin as a percentage
      profitMargin =
          ((salePrice - (selectedTaxType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc)) / (selectedTaxType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc)) *
              100;

      // Update the profit margin text field with percentage
      profitMarginController.text = profitMargin.toStringAsFixed(2);
    } else {
      // Calculate Sale Price based on Tax Type
      salePrice = (selectedTaxType.toLowerCase() == 'exclusive') ? purchaseExc + (purchaseExc * profitMargin / 100) : purchaseInc + (purchaseInc * profitMargin / 100);

      // Update the sale price text field
      salePriceController.text = salePrice.toStringAsFixed(2);
    }

    setState(() {});
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  GlobalKey<FormState> key = GlobalKey();
  // GetCategoryAndVariationModel data = GetCategoryAndVariationModel(variations: [], categoryName: CategoryModel());

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          surfaceTintColor: kWhite,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            lang.S.of(context).addNewProduct,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer(builder: (context, ref, __) {
          final taxesData = ref.watch(taxProvider);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Form(
                key: key,
                child: Column(
                  children: [
                    ///___________Name_____________________________
                    _buildTextField(
                      controller: nameController,
                      label: lang.S.of(context).productName,
                      hint: lang.S.of(context).enterProductName,
                      validator: (value) => value!.isEmpty ? lang.S.of(context).pleaseEnterAValidProductName : null,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: TextFormField(
                    //     controller: nameController,
                    //     validator: (value) {
                    //       if (value == null || value.isEmpty) {
                    //         return lang.S.of(context).pleaseEnterAValidProductName;
                    //       }
                    //       return null;
                    //     },
                    //     decoration: kInputDecoration.copyWith(
                    //       floatingLabelBehavior: FloatingLabelBehavior.always,
                    //       labelText: lang.S.of(context).productName,
                    //       hintText: lang.S.of(context).enterProductName,
                    //       border: const OutlineInputBorder(),
                    //     ),
                    //   ),
                    // ),

                    ///_______Category__________________________________
                    // _buildReadOnlyField(
                    //   controller: categoryController,
                    //   label: lang.S.of(context).productCategory,
                    //   hint: lang.S.of(context).selectProductCategory,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       //return 'Please select a category';
                    //       return lang.S.of(context).pleaseSelectACategory;
                    //     }
                    //     return null;
                    //   },
                    //   onTap: () async {
                    //     data = await const CategoryList(
                    //       isFromProductList: false,
                    //     ).launch(context);
                    //     setState(() {
                    //       categoryController.text = data.categoryName.categoryName ?? '';
                    //       selectedCategory = data.categoryName;
                    //     });
                    //   },
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: categoryController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            //return 'Please select a category';
                            return lang.S.of(context).pleaseSelectACategory;
                          }
                          return null;
                        },
                        onTap: () async {
                          selectedCategory = await const CategoryList(
                            isFromProductList: false,
                          ).launch(context);
                          setState(() {
                            categoryController.text = selectedCategory?.categoryName ?? '';
                            // selectedCategory = data.categoryName;
                          });
                        },
                        decoration: kInputDecoration.copyWith(
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          //labelText: 'Product Category',
                          labelText: lang.S.of(context).productCategory,
                          //hintText: 'Select Product Category',
                          hintText: lang.S.of(context).selectProductCategory,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),

                    ///________Size__Color_________________________
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                          controller: sizeController,
                          label: lang.S.of(context).size,
                          hint: lang.S.of(context).enterSize,
                        )).visible(selectedCategory?.variationSize ?? false),
                        Expanded(
                            child: _buildTextField(
                          controller: colorController,
                          label: lang.S.of(context).color,
                          hint: lang.S.of(context).enterColor,
                        )).visible(selectedCategory?.variationColor ?? false),
                      ],
                    ),

                    ///________Capacity_and_weight_____________________________
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                          controller: weightController,
                          label: lang.S.of(context).weight,
                          hint: lang.S.of(context).enterWeight,
                        )).visible(selectedCategory?.variationWeight ?? false),
                        Expanded(
                            child: _buildTextField(
                          controller: capacityController,
                          label: lang.S.of(context).capacity,
                          hint: lang.S.of(context).enterCapacity,
                        )).visible(selectedCategory?.variationCapacity ?? false),
                      ],
                    ),

                    ///___________Type______________________________________
                    _buildTextField(
                      controller: typeController,
                      label: lang.S.of(context).type,
                      hint: lang.S.of(context).enterType,
                    ).visible(selectedCategory?.variationType ?? false),

                    ///_______Brand__________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: brandController,
                        validator: (value) {
                          return null;
                        },
                        onTap: () async {
                          selectedBrand = await const BrandsList(
                            isFromProductList: false,
                          ).launch(context);
                          setState(() {
                            brandController.text = selectedBrand?.brandName ?? '';
                          });
                        },
                        decoration: kInputDecoration.copyWith(
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          // labelText: 'Product Brand',
                          labelText: lang.S.of(context).productBrand,
                          // hintText: 'Select a brand',
                          hintText: lang.S.of(context).selectABrand,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),

                    ///__________Code__________________________
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: productCodeController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  //return 'product code is required';
                                  return lang.S.of(context).productCodeIsRequired;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  productCode = value;
                                  promoCodeHint = value;
                                });
                              },
                              onFieldSubmitted: (value) {
                                if (codeList.contains(value)) {
                                  EasyLoading.showError(
                                    lang.S.of(context).thisProductAlreadyAdded,
                                    // 'This Product Already added!'
                                  );
                                  productCodeController.clear();
                                } else {
                                  setState(() {
                                    productCode = value;
                                    promoCodeHint = value;
                                  });
                                }
                              },
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).productCode,
                                hintText: lang.S.of(context).enterProductCode,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  useSafeArea: true,
                                  builder: (context1) {
                                    MobileScannerController controller = MobileScannerController(
                                      torchEnabled: false,
                                      returnImage: false,
                                    );
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadiusDirectional.circular(6.0),
                                      ),
                                      child: Column(
                                        children: [
                                          AppBar(
                                            backgroundColor: Colors.transparent,
                                            iconTheme: const IconThemeData(color: Colors.white),
                                            leading: IconButton(
                                              icon: const Icon(Icons.arrow_back),
                                              onPressed: () {
                                                Navigator.pop(context1);
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: MobileScanner(
                                              fit: BoxFit.contain,
                                              controller: controller,
                                              onDetect: (capture) {
                                                final List<Barcode> barcodes = capture.barcodes;

                                                if (barcodes.isNotEmpty) {
                                                  final Barcode barcode = barcodes.first;
                                                  debugPrint('Barcode found! ${barcode.rawValue}');
                                                  // productCode = barcode.rawValue!;
                                                  productCodeController.text = barcode.rawValue!;
                                                  // globalKey.currentState!.save();
                                                  Navigator.pop(context1);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 60.0,
                                width: 100.0,
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: kGreyTextColor),
                                ),
                                child: const Image(
                                  image: AssetImage('images/barcode.png'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///_____________Stock__&_Unit__________________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: productStockController,
                              readOnly: widget.productModel != null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  //return 'Enter a valid stock';
                                  return lang.S.of(context).enterAValidStock;
                                }
                                return null;
                              },
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).stock,
                                // hintText: 'Enter stock',
                                hintText: lang.S.of(context).enterStock,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              readOnly: true,
                              controller: productUnitController,
                              validator: (value) {
                                return null;
                              },
                              onTap: () async {
                                selectedUnit = await const UnitList(
                                  isFromProductList: false,
                                ).launch(context);
                                setState(() {
                                  productUnitController.text = selectedUnit?.unitName ?? '';
                                });
                              },
                              decoration: kInputDecoration.copyWith(
                                suffixIcon: const Icon(Icons.keyboard_arrow_down),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                //labelText: 'Product Unit',
                                labelText: lang.S.of(context).productUnit,
                                // hintText: 'Select Product Unit',
                                hintText: lang.S.of(context).selectProductUnit,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///-----------Applicable tax and Type-----------------------------
                    Row(
                      children: [
                        Expanded(
                          child: taxesData.when(
                            data: (dataList) {
                              if (widget.productModel != null && widget.productModel?.vatId != null) {
                                VatModel matched = dataList.firstWhere(
                                  (element) => element.id == widget.productModel?.vatId,
                                  orElse: () => VatModel(),
                                );
                                if (matched.id != null) {
                                  selectedTax = matched;
                                }
                              }
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: DropdownButtonFormField<VatModel>(
                                    hint: const Text(
                                      'Select vat',
                                      style: TextStyle(fontWeight: FontWeight.normal, color: kGreyTextColor),
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                    decoration: kInputDecoration.copyWith(
                                      labelText: "Select Vat",
                                    ),
                                    value: selectedTax,
                                    items: dataList
                                        .where((vat) => vat.status == true)
                                        .map((vat) => DropdownMenuItem<VatModel>(
                                              value: vat,
                                              child: Text(
                                                '${vat.name ?? ''} ${vat.rate}%',
                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      selectedTax = value!;
                                      calculatePurchaseAndMrp();
                                    },
                                  ),
                                ),
                              );
                            },
                            error: (error, stackTrace) {
                              return Text(error.toString());
                            },
                            loading: () {
                              return Expanded(
                                child: Skeletonizer(
                                  enabled: true,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: DropdownButtonFormField<VatModel>(
                                      hint: const Text(
                                        'Select vat',
                                        style: TextStyle(fontWeight: FontWeight.normal, color: kGreyTextColor),
                                      ),
                                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                      decoration: kInputDecoration.copyWith(
                                        labelText: "Select Vat",
                                      ),
                                      items: const [],
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Tax type
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: DropdownButtonFormField<String?>(
                              hint: const Text('Select Type'),
                              decoration: kInputDecoration.copyWith(labelText: "Vat Type"),
                              value: selectedTaxType,
                              icon: const Icon(Icons.keyboard_arrow_down_outlined),
                              items: ["Inclusive", "Exclusive"]
                                  .map((type) => DropdownMenuItem<String?>(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: const TextStyle(fontWeight: FontWeight.normal),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                selectedTaxType = value!;
                                calculatePurchaseAndMrp();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///_________Purchase_price_exclusive_&&_Inclusive____________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: purchaseExclusivePriceController,
                              onChanged: (value) => calculatePurchaseAndMrp(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  //return 'Please enter a valid purchase price';
                                  return lang.S.of(context).pleaseEnterAValidProductName;
                                }
                                // You can add more validation logic as needed
                                return null;
                              },
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Purchase Price Exc.',
                                hintText: lang.S.of(context).enterPurchasePrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: purchaseInclusivePriceController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  //return 'Please enter a valid Sale price';
                                  return lang.S.of(context).pleaseEnterAValidSalePrice;
                                }
                                // You can add more validation logic as needed
                                return null;
                              },
                              onChanged: (value) => calculatePurchaseAndMrp(from: "purchase_inc"),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: "Purchase Price Inc.",
                                //hintText: 'Enter Salting price',
                                hintText: lang.S.of(context).enterSaltingPrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///__________Profit_margin___________________________________________

                    ///_________Purchase_price__&&______mrp_____________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: profitMarginController,
                              onChanged: (value) => calculatePurchaseAndMrp(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  //return 'Please enter a valid purchase price';
                                  return lang.S.of(context).pleaseEnterAValidProductName;
                                }
                                // You can add more validation logic as needed
                                return null;
                              },
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Profit Margin (%)',
                                hintText: lang.S.of(context).enterPurchasePrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: salePriceController,
                              onChanged: (value) => calculatePurchaseAndMrp(from: 'mrp'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  //return 'Please enter a valid Sale price';
                                  return lang.S.of(context).pleaseEnterAValidSalePrice;
                                }
                                // You can add more validation logic as needed
                                return null;
                              },
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).mrp,
                                //hintText: 'Enter Salting price',
                                hintText: lang.S.of(context).enterSaltingPrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///_______-wholesalePrice_dealerprice_________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: wholeSalePriceController,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).wholeSalePrice,
                                //hintText: 'Enter wholesale price',
                                hintText: lang.S.of(context).enterWholesalePrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: dealerPriceController,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).dealerPrice,
                                //hintText: 'Enter dealer price',
                                hintText: lang.S.of(context).enterDealerPrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: discountPriceController,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                            keyboardType: TextInputType.number,
                            decoration: kInputDecoration.copyWith(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).discount,
                              //hintText: 'Enter discount',
                              hintText: lang.S.of(context).enterDiscount,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        )).visible(false),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: manufacturerController,
                              decoration: kInputDecoration.copyWith(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).manufacturer,
                                //hintText: 'Enter manufacturer name',
                                hintText: lang.S.of(context).enterManufacturerName,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    // ignore: sized_box_for_whitespace
                                    child: Container(
                                      height: 200.0,
                                      width: MediaQuery.of(context).size.width - 80,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                pickedImage = await _picker.pickImage(source: ImageSource.gallery);

                                                setState(() {});

                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.photo_library_rounded,
                                                    size: 60.0,
                                                    color: kMainColor,
                                                  ),
                                                  Text(
                                                    lang.S.of(context).gallery,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20.0,
                                                      color: kMainColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 40.0),
                                            GestureDetector(
                                              onTap: () async {
                                                pickedImage = await _picker.pickImage(source: ImageSource.camera);
                                                setState(() {});
                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.camera,
                                                    size: 60.0,
                                                    color: kGreyTextColor,
                                                  ),
                                                  Text(
                                                    lang.S.of(context).camera,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20.0,
                                                      color: kGreyTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54, width: 1),
                                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                                  image: pickedImage == null
                                      ? widget.productModel?.productPicture == null
                                          ? DecorationImage(
                                              image: AssetImage(noProductImageUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: NetworkImage('${APIConfig.domain}${widget.productModel?.productPicture ?? ''}'),
                                              fit: BoxFit.cover,
                                            )
                                      : DecorationImage(
                                          image: FileImage(File(pickedImage!.path)),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: const BorderRadius.all(Radius.circular(120)),
                                    color: kMainColor,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                          // child: Stack(
                          //   children: [
                          //     Container(
                          //       height: 120,
                          //       width: 120,
                          //       decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.black54, width: 1),
                          //         borderRadius: const BorderRadius.all(Radius.circular(120)),
                          //         image: pickedImage == null
                          //             ? DecorationImage(
                          //                 image: AssetImage(noProductImageUrl),
                          //                 fit: BoxFit.cover,
                          //               )
                          //             : DecorationImage(
                          //                 image: FileImage(File(pickedImage!.path)),
                          //                 fit: BoxFit.cover,
                          //               ),
                          //       ),
                          //     ),
                          //     Container(
                          //       height: 120,
                          //       width: 120,
                          //       decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.black54, width: 1),
                          //         borderRadius: const BorderRadius.all(Radius.circular(120)),
                          //         // image: DecorationImage(
                          //         //   image: FileImage(File(pickedImage!.path)),
                          //         //   fit: BoxFit.cover,
                          //         // ),
                          //       ),
                          //       // child: imageFile.path == 'No File' ? null : Image.file(imageFile),
                          //     ),
                          //     Positioned(
                          //       bottom: 0,
                          //       right: 0,
                          //       child: Container(
                          //         height: 35,
                          //         width: 35,
                          //         decoration: BoxDecoration(
                          //           border: Border.all(color: Colors.white, width: 2),
                          //           borderRadius: const BorderRadius.all(Radius.circular(120)),
                          //           color: kMainColor,
                          //         ),
                          //         child: const Icon(
                          //           Icons.camera_alt_outlined,
                          //           size: 20,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     )
                          //   ],
                          // ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    ButtonGlobalWithoutIcon(
                      buttontext: lang.S.of(context).saveNPublish,
                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                      onPressed: () async {
                        if (key.currentState!.validate()) {
                          try {
                            ProductRepo product = ProductRepo();
                            if (widget.productModel == null) {
                              EasyLoading.show(status: lang.S.of(context).adding);
                              await product.addProduct(
                                ref: ref,
                                context: context,
                                productName: nameController.text,
                                categoryId: selectedCategory!.id.toString(),
                                brandId: selectedBrand?.id.toString(),
                                unitId: selectedUnit?.id.toString(),
                                productCode: productCodeController.text,
                                productStock: productStockController.text,
                                productSalePrice: salePriceController.text,
                                productPurchasePrice: selectedTaxType.toLowerCase() == 'exclusive' ? purchaseExclusivePriceController.text : purchaseInclusivePriceController.text,
                                color: colorController.text.isEmptyOrNull ? null : colorController.text,
                                size: sizeController.text.isEmptyOrNull ? null : sizeController.text,
                                type: typeController.text.isEmptyOrNull ? null : typeController.text,
                                weight: weightController.text.isEmptyOrNull ? null : weightController.text,
                                capacity: capacityController.text.isEmptyOrNull ? null : capacityController.text,
                                productDealerPrice: dealerPriceController.text.isEmptyOrNull ? null : dealerPriceController.text,
                                productDiscount: discountPriceController.text.isEmptyOrNull ? null : discountPriceController.text,
                                productManufacturer: manufacturerController.text.isEmptyOrNull ? null : manufacturerController.text,
                                productWholeSalePrice: wholeSalePriceController.text.isEmptyOrNull ? null : wholeSalePriceController.text,
                                image: pickedImage == null ? null : File(pickedImage!.path),
                                vatId: selectedTax?.id.toString(),
                                vatType: selectedTaxType,
                                profitMargin: profitMarginController.text,
                                vatAmount: ((num.tryParse(purchaseInclusivePriceController.text) ?? 0) - (num.tryParse(purchaseExclusivePriceController.text) ?? 0)).toString(),
                              );
                              EasyLoading.dismiss();
                            } else {
                              EasyLoading.show(status: lang.S.of(context).updating);
                              await product.updateProduct(
                                ref: ref,
                                context: context,
                                productId: widget.productModel?.id.toString() ?? '',
                                productName: nameController.text,
                                categoryId: selectedCategory!.id.toString(),
                                brandId: selectedBrand?.id.toString(),
                                unitId: selectedUnit?.id.toString(),
                                productCode: productCodeController.text,
                                productSalePrice: salePriceController.text,
                                productPurchasePrice: selectedTaxType.toLowerCase() == 'exclusive' ? purchaseExclusivePriceController.text : purchaseInclusivePriceController.text,
                                color: colorController.text.isEmptyOrNull ? null : colorController.text,
                                size: sizeController.text.isEmptyOrNull ? null : sizeController.text,
                                type: typeController.text.isEmptyOrNull ? null : typeController.text,
                                weight: weightController.text.isEmptyOrNull ? null : weightController.text,
                                capacity: capacityController.text.isEmptyOrNull ? null : capacityController.text,
                                productDealerPrice: dealerPriceController.text.isEmptyOrNull ? null : dealerPriceController.text,
                                productDiscount: discountPriceController.text.isEmptyOrNull ? null : discountPriceController.text,
                                productManufacturer: manufacturerController.text.isEmptyOrNull ? null : manufacturerController.text,
                                productWholeSalePrice: wholeSalePriceController.text.isEmptyOrNull ? null : wholeSalePriceController.text,
                                image: pickedImage == null ? null : File(pickedImage!.path),
                                vatId: selectedTax?.id.toString(),
                                vatType: selectedTaxType,
                                profitMargin: profitMarginController.text,
                                vatAmount: ((num.tryParse(purchaseInclusivePriceController.text) ?? 0) - (num.tryParse(purchaseExclusivePriceController.text) ?? 0)).toString(),
                              );
                              EasyLoading.dismiss();
                            }
                          } catch (e, stackTrace) {
                            EasyLoading.dismiss();
                            EasyLoading.showError("Something went wrong!");
                            debugPrint("Error: $e\nStackTrace: $stackTrace");
                          }
                        }
                      },
                      buttonTextColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  bool readOnly = false,
  bool? icon,
  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      decoration: kInputDecoration.copyWith(
        labelText: label,
        hintText: hint,
        suffixIcon: (icon ?? false) ? const Icon(Icons.keyboard_arrow_down_outlined) : null,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
//
// Widget _buildReadOnlyField({
//   required TextEditingController controller,
//   required String label,
//   required String hint,
//   String? Function(String?)? validator,
//   VoidCallback? onTap,
// }) {
//   return _buildTextField(
//     controller: controller,
//     label: label,
//     hint: hint,
//     validator: validator,
//     icon: true,
//     readOnly: true,
//     onTap: onTap,
//   );
// }
