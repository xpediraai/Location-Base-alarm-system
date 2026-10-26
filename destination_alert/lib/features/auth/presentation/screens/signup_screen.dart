import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

/// Production-ready registration screen for Destination Alert.
class SignUpScreen extends StatefulWidget {
  final AuthProvider? authProvider;

  const SignUpScreen({
    super.key,
    this.authProvider,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final AuthProvider _authProvider;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _authProvider = widget.authProvider ?? AuthProvider();
    _authProvider.addListener(_onAuthStateChanged);

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _emailFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    final errorMessage = _authProvider.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _authProvider.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _authProvider.successMessage ?? 'Account created successfully!',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Terms & Privacy',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Destination Alert Privacy Commitment',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your location data is utilized strictly for triggering local arrival notifications and alarms on your device. We respect your privacy and never sell or distribute your personal data.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'By creating an account, you agree to use Destination Alert responsibly while commuting. Ensure your device volume and notification permissions are configured for timely alerts.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _authProvider,
          builder: (context, _) {
            final bool isLoading = _authProvider.isLoading;

            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign up to set alarms for your favorite stops',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Full Name Field
                        AuthTextField(
                          label: 'Full Name',
                          hintText: 'John Doe',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateName,
                          onFieldSubmitted: (_) =>
                              _emailFocusNode.requestFocus(),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        AuthTextField(
                          label: 'Email Address',
                          hintText: 'name@example.com',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateEmail,
                          onFieldSubmitted: (_) =>
                              _phoneFocusNode.requestFocus(),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number Field (Optional)
                        AuthTextField(
                          label: 'Phone Number (Optional)',
                          hintText: '+1 555 123 4567',
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (val) =>
                              Validators.validatePhone(val, required: false),
                          onFieldSubmitted: (_) =>
                              _passwordFocusNode.requestFocus(),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        AuthTextField(
                          label: 'Password',
                          hintText: 'At least 6 characters',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validatePassword,
                          onFieldSubmitted: (_) =>
                              _confirmPasswordFocusNode.requestFocus(),
                          enabled: !isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        AuthTextField(
                          label: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_reset_rounded,
                          textInputAction: TextInputAction.done,
                          validator: (val) => Validators.validateConfirmPassword(
                            val,
                            _passwordController.text,
                          ),
                          onFieldSubmitted: (_) => _handleSignUp(),
                          enabled: !isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Terms and Privacy Note
                        Center(
                          child: GestureDetector(
                            onTap: _showTermsDialog,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'By signing up, you agree to our ',
                                  ),
                                  TextSpan(
                                    text: 'Terms & Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Primary Create Account Button
                        PrimaryButton(
                          text: 'Create Account',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _handleSignUp,
                        ),
                        const SizedBox(height: 24),

                        // Back to Login Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).maybePop();
                                    },
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
