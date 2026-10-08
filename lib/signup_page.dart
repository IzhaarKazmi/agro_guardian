import 'package:agro_guardian/img_picker.dart';
import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/l10n/locale_scope.dart';
import 'package:agro_guardian/login_page.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:agro_guardian/widgets/auth_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String _authErrorMessage(FirebaseAuthException exception, AppStrings s) {
    switch (exception.code) {
      case 'email-already-in-use':
        return s.emailInUse;
      case 'invalid-email':
        return s.invalidEmail;
      case 'weak-password':
        return s.weakPassword;
      case 'operation-not-allowed':
        return s.signupNotAllowed;
      default:
        return s.signupFailed;
    }
  }

  Future<void> _signUpUser() async {
    final strings = AppStrings.of(context);
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final password = _passwordController.text;
    if (password.length < 6) {
      setState(() {
        _errorMessage = strings.weakPassword;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _authErrorMessage(e, strings);
      });
      return;
    } catch (e) {
      if (FirebaseAuth.instance.currentUser == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _errorMessage = strings.signupFailed;
        });
        return;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ImagePickerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final localeController = LocaleScope.of(context);

    return AuthScaffold(
      controller: localeController,
      title: strings.pleaseSignup,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              style: const TextStyle(color: AppColors.textPrimary),
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty || !AppStrings.emailPattern.hasMatch(email)) {
                  return strings.invalidEmail;
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: strings.email,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              style: const TextStyle(color: AppColors.textPrimary),
              onFieldSubmitted: (_) {
                if (!_isLoading) {
                  _signUpUser();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return strings.enterEmailPassword;
                }
                if (value.length < 6) {
                  return strings.weakPassword;
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: strings.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _signUpUser,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFF052E16),
                        ),
                      )
                    : Text(strings.signup),
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
              child: Text.rich(
                TextSpan(
                  text: '${strings.alreadyHaveAccount} ',
                  style: const TextStyle(color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: strings.login,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
