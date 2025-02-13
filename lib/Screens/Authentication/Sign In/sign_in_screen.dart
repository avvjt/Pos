import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/GlobalComponents/glonal_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant.dart';
import '../Sign Up/sign_up_screen.dart';
import '../forgot password/forgot_password.dart';
import 'Repo/sign_in_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool showPassword = true;
  bool _isChecked = false;
  bool isClicked = false;
  bool _isSheetExpanded = false; // To track if the sheet is expanded
  String _inputType = ''; // To track the type of input (email or password)

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode(); // FocusNode for email TextField
  final FocusNode _passwordFocusNode = FocusNode(); // FocusNode for password TextField



  // Ensure this matches exactly one of the DropdownMenuItem values
  String selectedLanguage = 'EN';



  @override
  void initState() {
    super.initState();
    _loadUserCredentials();

    // Listen for focus changes on the email TextField
    _emailFocusNode.addListener(() {
      setState(() {
        _isSheetExpanded = _emailFocusNode.hasFocus;
        _inputType = _emailFocusNode.hasFocus ? 'email' : '';
      });
    });

    // Listen for focus changes on the password TextField
    _passwordFocusNode.addListener(() {
      setState(() {
        _isSheetExpanded = _passwordFocusNode.hasFocus;
        _inputType = _passwordFocusNode.hasFocus ? 'password' : '';
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();

    _emailFocusNode.dispose(); // Dispose the email FocusNode
    _passwordFocusNode.dispose(); // Dispose the password FocusNode
  }

  void _loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = prefs.getBool('remember_me') ?? false;
      if (_isChecked) {
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _saveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember_me', _isChecked);
    if (_isChecked) {
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
    } else {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  Future<void> _handleSignIn() async {
    if (isClicked) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        isClicked = true;
      });

      EasyLoading.show();
      LogInRepo repo = LogInRepo();
      bool success = await repo.logIn(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );

      if (success) {
        _saveUserCredentials();
        EasyLoading.showSuccess('Login Successful');
      } else {
        setState(() {
          isClicked = false;
        });
      }
    }
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
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      'Sign in and get started',
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
                key: _formKey, // Assign the GlobalKey<FormState>
                child: Column(
                  children: [
                    const SizedBox(height: 60.0),
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

                    TextFormField(
                      focusNode: _emailFocusNode, // Assign email FocusNode
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: kInputDecoration.copyWith(

                        hintText: lang.S.of(context).hintEmail,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.S.of(context).emailCannotBeEmpty;
                        } else if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$").hasMatch(value)) {
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

                    TextFormField(
                      focusNode: _passwordFocusNode, // Assign password FocusNode
                      controller: passwordController,
                      obscureText: showPassword,
                      decoration: kInputDecoration.copyWith(

                        hintText: lang.S.of(context).hintPassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => showPassword = !showPassword),
                          icon: Icon(showPassword ? FeatherIcons.eyeOff : FeatherIcons.eye, color: kGreyTextColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.S.of(context).passwordCannotBeEmpty;
                        } else if (value.length < 6) {
                          return lang.S.of(context).pleaseEnterABiggerPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Checkbox(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          checkColor: Colors.white,
                          activeColor: kMainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          fillColor: MaterialStateProperty.all(_isChecked ? kMainColor : Colors.transparent),
                          visualDensity: const VisualDensity(horizontal: -4),
                          side: const BorderSide(color: kGreyTextColor),
                          value: _isChecked,
                          onChanged: (newValue) {
                            setState(() {
                              _isChecked = newValue!;
                            });
                          },
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          lang.S.of(context).rememberMe,
                          //'Remember me',
                          style: textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                        ),
                        const Spacer(),
                        TextButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPassword(),
                            ),
                          ),
                          child: Text(
                            lang.S.of(context).forgotPassword,
                            //'Forgot password?',
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 16),
                    UpdateButton(
                      onpressed: _handleSignIn,
                      text: lang.S.of(context).signIn,
                    ),
                    const SizedBox(height: 16),
                    GoogleSignInButton(),
                    const SizedBox(height: 24.0),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          highlightColor: kMainColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3.0),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return const SignUpScreen();
                              },
                            ));
                          },
                          hoverColor: kMainColor.withOpacity(0.1),
                          child: RichText(
                            text: TextSpan(
                              text:
                              lang.S.of(context).donNotHaveAnAccount,
                              //'Don’t have an account? ',
                              style: textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                              children: [
                                TextSpan(
                                  text:lang.S.of(context).signUp,
                                  // text:'Sign Up',
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





