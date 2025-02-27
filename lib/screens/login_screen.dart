import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home.dart';
import 'currency_list.dart';
import 'default_currency.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/register_request.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  final bool initiallyShowSignUp;

  const LoginScreen({Key? key, this.initiallyShowSignUp = false})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();
  final FocusNode _birthDateFocus = FocusNode();
  late bool _isLogin;
  bool _isLoading = false;
  bool _obscurePassword = true; // For password visibility toggle
  Map<String, bool> _fieldsTouched = {};
  bool _hasLoginError = false;

  @override
  void initState() {
    super.initState();
    _isLogin = !widget.initiallyShowSignUp;
    _fieldsTouched = {};

    // Delay to ensure this runs after navigation
    Future.delayed(Duration.zero, () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Dark icons for light background
        statusBarBrightness: Brightness.light, // Light background (iOS)
      ));
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _birthDateController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _countryFocus.dispose();
    _birthDateFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle:
            SystemUiOverlayStyle.dark, // This should force dark icons
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: !_isLogin
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isLogin = true;
                  });
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Page Title
              Text(
                _isLogin ? 'Login' : 'Sign Up',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xFF191B1E),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 20),

              // Social Login Buttons
              // Commenting out social login buttons for now - will be implemented later
              /*
              buildSocialButton(
                text: '${_isLogin ? "Login" : "Sign up"} with Google',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () {
                  // TODO: Implement Google auth
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google auth coming soon')),
                  );
                },
              ),
              const SizedBox(height: 12),
              buildSocialButton(
                text: '${_isLogin ? "Login" : "Sign up"} with Apple',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  // TODO: Implement Apple auth
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Apple auth coming soon')),
                  );
                },
              ),
              */
              const SizedBox(height: 20),

              // Divider
              // const Divider(color: Color(0xFFC6C6C8), thickness: 1),
              // const SizedBox(height: 11),

              // Email Login Section
              Text(
                _isLogin 
                  ? (_hasLoginError 
                      ? "Invalid username or password"
                      : "Login with email or username")
                  : "Sign up",
                style: TextStyle(
                  fontSize: 15,
                  color: _hasLoginError ? Colors.red : const Color(0xFF737A86),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 11),

              // Input Fields
              if (_isLogin) ...[
                buildInputField(
                  'Email or Username',
                  _usernameController,
                  focusNode: _emailFocus,
                  nextFocus: _passwordFocus,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 11),
                buildInputField(
                  'Password',
                  _passwordController,
                  isPassword: true,
                  focusNode: _passwordFocus,
                  onChanged: (value) => setState(() {}),
                ),
              ] else ...[
                buildInputField('Email', _emailController),
                const SizedBox(height: 11),
                buildInputField('Username', _usernameController),
                const SizedBox(height: 11),
                buildInputField('Password', _passwordController,
                    isPassword: true),
                const SizedBox(height: 11),
                buildInputField('Phone Number', _phoneController),
                const SizedBox(height: 11),
                _buildCountryField(),
                const SizedBox(height: 11),
                buildInputField(
                  'Birth Date (DD/MM/YYYY)',
                  _birthDateController,
                  keyboardType: TextInputType.datetime,
                  focusNode: _birthDateFocus,
                ),
              ],
              const SizedBox(height: 30),

              // Continue Button
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _isLogin
                      ? (_usernameController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty)
                          ? _handleSubmit
                          : null
                      : (_isValidSignUpForm())
                          ? _handleSubmit
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                  ),
                  child: Text(_isLogin ? "Login" : "Sign Up"),
                ),

              // Toggle Login/Signup
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    // Clear all text fields when switching modes
                    _emailController.clear();
                    _usernameController.clear();
                    _passwordController.clear();
                    _phoneController.clear();
                    _countryController.clear();
                    _birthDateController.clear();
                    // Reset touched states
                    _fieldsTouched.clear();
                  });
                },
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 number, 1 special character
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  bool _isValidPhoneNumber(String phone) {
    // Basic international phone number format
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  bool _isValidBirthDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return false;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      // Check basic date validity
      if (day < 1 || day > 31) return false;
      if (month < 1 || month > 12) return false;
      if (year < 1900 || year > DateTime.now().year) return false;
      
      // Check for valid day in month
      final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      
      // Adjust February for leap years
      if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        daysInMonth[1] = 29;
      }
      
      return day <= daysInMonth[month - 1];
    } catch (e) {
      return false;
    }
  }

  bool _isValidCountry(String country) {
    final validCountries = [
      'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan',
      'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi',
      'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus', 'Czech Republic',
      'Democratic Republic of the Congo', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic',
      'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia',
      'Fiji', 'Finland', 'France',
      'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana',
      'Haiti', 'Honduras', 'Hungary',
      'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Ivory Coast',
      'Jamaica', 'Japan', 'Jordan',
      'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan',
      'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg',
      'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar',
      'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia', 'Norway',
      'Oman',
      'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal',
      'Qatar',
      'Romania', 'Russia', 'Rwanda',
      'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'South Korea', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria',
      'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu',
      'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan',
      'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam',
      'Yemen',
      'Zambia', 'Zimbabwe'
    ];
    
    return validCountries.any((c) => c.toLowerCase() == country.trim().toLowerCase());
  }

  bool _isValidSignUpForm() {
    return _emailController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _countryController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _isValidPassword(_passwordController.text) &&
        _isValidPhoneNumber(_phoneController.text) &&
        _isValidBirthDate(_birthDateController.text);
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _hasLoginError = false;
    });

    try {
      bool success;
      if (_isLogin) {
        success = await AuthService.login(
          _usernameController.text,
          _passwordController.text,
        );
        
        if (success && mounted) {
          // Route directly to HomeScreen after login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        // For signup, store the registration data but don't send it yet
        final registrationData = RegisterRequest(
          email: _emailController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text,
          country: _countryController.text,
          birthDate: _birthDateController.text,
        );
        
        // Navigate to DefaultCurrency screen with registration data
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DefaultCurrency(
                registrationData: registrationData,
                isSignUp: true,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasLoginError = _isLogin;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Social Login Button
  Widget buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: backgroundColor == Colors.white
              ? Border.all(color: Colors.grey[300]!)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              SvgPicture.asset(
                text.contains('Google')
                    ? 'assets/images/google_icon.svg'
                    : 'assets/images/apple_icon.svg',
                width: 24,
                height: 24,
                color: text.contains('Apple') ? textColor : null,
              ),
              SizedBox(width: 12),
              // Text
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field
  Widget buildInputField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    final hasError = _fieldsTouched[label] == true && 
        _getErrorText(label, controller.text) != null;

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() {
            _fieldsTouched[label] = true;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0x288B929B),
              borderRadius: BorderRadius.circular(16),
              border: focusNode?.hasFocus ?? false
                  ? Border.all(color: Colors.blue, width: 1)
                  : hasError 
                      ? Border.all(color: Colors.red, width: 1)
                      : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: hasError ? Colors.red : null,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        )
                      : null,
                ),
                obscureText: isPassword && _obscurePassword,
                keyboardType: keyboardType,
                textInputAction:
                    nextFocus != null ? TextInputAction.next : TextInputAction.done,
                onChanged: (value) {
                  if (onChanged != null) onChanged(value);
                  setState(() {}); // Trigger rebuild to update submit button state
                },
                onSubmitted: (_) {
                  if (nextFocus != null) {
                    FocusScope.of(context).requestFocus(nextFocus);
                  } else if (_isValidSignUpForm()) { // Only submit if form is valid
                    _handleSubmit();
                  }
                },
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                _getErrorText(label, controller.text)!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _getErrorText(String label, String value) {
    if (value.isEmpty) return null;
    
    // Skip validation for login fields
    if (_isLogin && (label == 'Email or Username' || label == 'Password')) {
      return null;
    }
    
    switch (label) {
      case 'Email':
        return _isValidEmail(value) ? null : 'Invalid email address';
      case 'Password':
        return _isValidPassword(value) ? null : 'Password requirements not met';
      case 'Phone Number':
        return _isValidPhoneNumber(value) ? null : 'Invalid phone number';
      case 'Birth Date (DD/MM/YYYY)':
        return _isValidBirthDate(value) ? null : 'Invalid birth date';
      case 'Country':
        return _isValidCountry(value) ? null : 'Invalid country';
      default:
        return null;
    }
  }

  // Add a method to handle country selection
  void _selectCountry() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyListScreen(
        mode: "Fiat",
        isCountrySelect: true,  // Set this to true for country selection
      ),
    );
    
    if (selected != null) {
      final currencyToCountry = {
        'USD': 'United States',
        'EUR': 'European Union',
        'GBP': 'United Kingdom',
        'JPY': 'Japan',
        'CAD': 'Canada',
        'AUD': 'Australia',
        'CHF': 'Switzerland',
        'CNY': 'China',
        'HKD': 'Hong Kong',
        'NZD': 'New Zealand',
        'SGD': 'Singapore',
        'INR': 'India',
        'BRL': 'Brazil',
        'RUB': 'Russia',
        'ZAR': 'South Africa',
        'AED': 'United Arab Emirates',
        'TWD': 'Taiwan',
        'KRW': 'South Korea',
        'MXN': 'Mexico',
        'SAR': 'Saudi Arabia',
        'THB': 'Thailand',
        // Add more mappings as needed
      };
      
      setState(() {
        _countryController.text = currencyToCountry[selected] ?? selected;
        _fieldsTouched['Country'] = true;
      });
    }
  }

  Widget _buildCountryField() {
    return GestureDetector(
      onTap: _selectCountry,
      child: AbsorbPointer(
        child: buildInputField(
          'Country',
          _countryController,
          focusNode: _countryFocus,
          nextFocus: _birthDateFocus,
        ),
      ),
    );
  }
}
