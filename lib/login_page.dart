import 'package:agro_guardian/img_picker.dart';
import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/l10n/locale_scope.dart';
import 'package:agro_guardian/signup_page.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:agro_guardian/widgets/auth_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      case 'user-not-found':
        return s.noAccountFound;
      case 'wrong-password':
      case 'invalid-credential':
        return s.incorrectCredentials;
      case 'invalid-email':
        return s.invalidEmail;
      case 'user-disabled':
        return s.accountDisabled;
      default:
        return s.loginFailed;
    }
  }

  Future<void> _forgotPassword() async {
    final strings = AppStrings.of(context);
    final controller = TextEditingController(text: _emailController.text.trim());

    try {
      final email = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(strings.resetPassword),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.resetPasswordPrompt),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: strings.email,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                child: Text(strings.resetPassword),
              ),
            ],
          );
        },
      );

      if (!mounted || email == null) {
        return;
      }

      if (email.isEmpty || !AppStrings.emailPattern.hasMatch(email)) {
        setState(() {
          _errorMessage = strings.invalidEmail;
        });
        return;
      }

      FocusScope.of(context).unfocus();
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.passwordResetSent)),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.code == 'invalid-email'
            ? strings.invalidEmail
            : strings.passwordResetFailed;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = strings.passwordResetFailed;
      });
    } finally {
      controller.dispose();
    }
  }

  Future<void> _loginUser() async {
    final strings = AppStrings.of(context);
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
          _errorMessage = strings.loginFailed;
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
      title: strings.pleaseLogin,
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
                  _loginUser();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return strings.enterEmailPassword;
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
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _isLoading ? null : _forgotPassword,
                child: Text(strings.forgotPassword),
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
                onPressed: _isLoading ? null : _loginUser,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFF052E16),
                        ),
                      )
                    : Text(strings.login),
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
              child: Text.rich(
                TextSpan(
                  text: '${strings.dontHaveAccount} ',
                  style: const TextStyle(color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: strings.signup,
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
