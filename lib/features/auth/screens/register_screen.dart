import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/logo_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implementar registro
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Navegar al login después del registro exitoso
        Navigator.pop(context);
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(AppSizes.paddingLarge),
            padding: const EdgeInsets.all(AppSizes.paddingExtraLarge),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoWidget(size: 200),
                  const SizedBox(height: AppSizes.paddingLarge),
                  const Text(
                    'Regístrate',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                        vertical: AppSizes.paddingMedium,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Por favor ingrese un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nombres y apellidos',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                        vertical: AppSizes.paddingMedium,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese sus nombres y apellidos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                        vertical: AppSizes.paddingMedium,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Expanded(
                        child: Text('Acepto los términos y condiciones'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar registro con Google
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        ),
                      ),
                      icon: const Icon(Icons.g_mobiledata, color: AppColors.textLight),
                      label: const Text(
                        'Registrarse con google',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.textLight,
                            )
                          : const Text(
                              'Registrarse',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      '¿Ya tienes una cuenta? Inicia sesión',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}