import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mobile_pos/Screens/Authentication/Sign%20Up/repo/sign_up_repo.dart';
import 'package:mobile_pos/Screens/Authentication/Sign%20Up/verify_email.dart';
import '../../../GlobalComponents/button_global.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../constant.dart';
import '../Sign In/sign_in_screen.dart';
import '../Wedgets/check_email_for_otp_popup.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  ///__________Variables________________________________
  bool showPassword = true;
  bool isClicked = false;

  ///________Key_______________________________________
  GlobalKey<FormState> key = GlobalKey<FormState>();

  ///___________Controllers______________________________
  TextEditingController nameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController confirmPasswordTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();

  // Ensure this matches exactly one of the DropdownMenuItem values
  String selectedLanguage = 'EN';

  ///________Dispose____________________________________
  @override
  void dispose() {
    super.dispose();
    nameTextController.dispose();
    passwordTextController.dispose();
    emailTextController.dispose();
  }




  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    // Set the status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: kMainColor, // Set your desired color
        statusBarIconBrightness: Brightness.light, // Set icon color (light for dark backgrounds)
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Blue Background with Two Vertical Texts
          Container(
            color: kMainColor,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ),
          ),

          // Background Color
          Container(
            color: kMainColor, // Replace with kMainColor if defined
          ),

          // Text and Dropdown Positioned
          Positioned(
            top: 100,
            left: 20,
            right: 20, // Ensures content spans across the screen width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Your Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      'Sign up to get started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                Chip(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),  // Increase value for more rounded edges
                  ),
                  label: InkWell(  // Wrap with InkWell for full clickable area
                    onTap: () {
                      // Trigger the dropdown manually
                    },
                    child: Transform.scale(
                      scale: 1.0,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLanguage,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 18),
                          dropdownColor: Colors.white,
                          items: [
                            {'name': 'EN', 'icon': Icons.language,},
                            {'name': 'HI', 'icon': Icons.translate},
                            {'name': 'SP', 'icon': Icons.language},
                            {'name': 'FH', 'icon': Icons.language},
                          ].map((item) {
                            return DropdownMenuItem<String>(
                              value: item['name'] as String,
                              child: Row(
                                children: [
                                  Icon(item['icon'] as IconData, color: kMainColor, size: 16),
                                  SizedBox(width: 6),
                                  Text(item['name'] as String, style: TextStyle(color: Colors.black, fontSize: 14)),

                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedLanguage = newValue!;
                            });
                          },
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Form(
                key: key, // Assign the GlobalKey<FormState>
                child: Column(
                  children: [
                    const SizedBox(height: 60.0),
                    Align(
                      alignment: Alignment.centerLeft, // Aligns text to the start (left)
                      child: Text(
                        'Full Name',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    ///____________Name______________________________________________
                    TextFormField(
                      controller: nameTextController,
                      keyboardType: TextInputType.name,
                      decoration: kInputDecoration.copyWith(

                        //hintText: 'Enter your full name',
                        hintText: lang.S.of(context).enterYourFullName,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          //return 'name can\'n be empty';
                          return lang.S.of(context).nameCanNotBeEmpty;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20.0),

                    Align(
                      alignment: Alignment.centerLeft, // Aligns text to the start (left)
                      child: Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    ///__________Email______________________________________________
                    TextFormField(
                      controller: emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: kInputDecoration.copyWith(
                        // border: OutlineInputBorder(),

                        //hintText: 'Enter email address',
                        hintText: lang.S.of(context).hintEmail,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          //return 'Email can\'n be empty';
                          return lang.S.of(context).emailCannotBeEmpty;
                        } else if (!value.contains('@')) {
                          //return 'Please enter a valid email';
                          return lang.S.of(context).pleaseEnterAValidEmail;
                        }
                        return null;
                      },
                    ),


                    const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft, // Aligns text to the start (left)
                      child: Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    ///___________Password_____________________________________________
                    TextFormField(
                      controller: passwordTextController,
                      keyboardType: TextInputType.text,
                      obscureText: showPassword,
                      decoration: kInputDecoration.copyWith(

                        // hintText: 'Enter password',
                        hintText: lang.S.of(context).hintPassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword ? FeatherIcons.eyeOff : FeatherIcons.eye,
                            color: kGreyTextColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          //return 'Password can\'t be empty';
                          return lang.S.of(context).passwordCannotBeEmpty;
                        } else if (value.length < 6) {
                          //return 'Please enter a bigger password';
                          return lang.S.of(context).pleaseEnterABiggerPassword;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20.0),

                    Align(
                      alignment: Alignment.centerLeft, // Aligns text to the start (left)
                      child: Text(
                        'Confirm Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    ///___________Confirm Password_____________________________________________
                    TextFormField(
                      controller: confirmPasswordTextController,
                      keyboardType: TextInputType.text,
                      obscureText: showPassword,
                      decoration: kInputDecoration.copyWith(

                        // hintText: 'Enter password',
                        hintText: lang.S.of(context).hintConfirmPassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword ? FeatherIcons.eyeOff : FeatherIcons.eye,
                            color: kGreyTextColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          //return 'Password can\'t be empty';
                          return lang.S.of(context).passwordCannotBeEmpty;
                        } else if (value.length < 6) {
                          //return 'Please enter a bigger password';
                          return lang.S.of(context).pleaseEnterABiggerPassword;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20.0),

                    ///________Button___________________________________________________
                    UpdateButton(
                      onpressed: () async {
                        if (isClicked) {
                          return;
                        }
                        if (key.currentState?.validate() ?? false) {
                          isClicked = true;
                          EasyLoading.show();
                          SignUpRepo repo = SignUpRepo();
                          if (await repo.signUp(name: nameTextController.text, email: emailTextController.text, password: passwordTextController.text, context: context)) {
                            if (await checkEmailForCodePupUp(email: emailTextController.text, context: context, textTheme: textTheme)) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyEmail(
                                    email: emailTextController.text,
                                    isFormForgotPass: false,
                                  ),
                                ),
                              );
                            }
                          } else {
                            isClicked = false;
                          }
                        }
                      },
                      text: lang.S.of(context).signUp,
                      //'Sign Up',
                    ),
                    const SizedBox(height: 20,),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          highlightColor: kMainColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3.0),
                          onTap: () => Navigator.pop(context),
                          hoverColor: kMainColor.withOpacity(0.1),
                          child: RichText(
                            text: TextSpan(
                              text:
                              lang.S.of(context).alreadyHaveAnAccount,
                              //'Already have an account? ',
                              style: textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              children: [
                                TextSpan(
                                  text:lang.S.of(context).signIn,
                                  //'Sign In',
                                  style: textTheme.bodyMedium?.copyWith(color: kMainColor, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ),
          ),





        ],
      ),
    );
  }
}
