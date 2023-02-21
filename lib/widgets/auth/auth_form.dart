import 'dart:io';
import 'package:flutter/material.dart';
import '../../widgets/pickers/user_image_picker.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);
  final bool isLoading;
  final void Function(String email, String userName, String password,
      File image, bool isLogin, BuildContext ctx) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  File _userImageFile;
  AnimationController _animationController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (_userImageFile == null && !_isLogin) {}
    if (isValid) {
      print('isValid');
      _formKey.currentState.save();
      widget.submitFn(_userEmail.trim(), _userName.trim(), _userPassword.trim(),
          _userImageFile, _isLogin, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final passNotifier = ValueNotifier<PasswordStrength>(null);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      height: _isLogin
          ? deviceSize.height * (deviceSize.height < 680 ? 0.45 : 0.40)
          : deviceSize.height * (deviceSize.height < 680 ? 0.80 : 0.68),
      child: Card(
        elevation: 15,
        shadowColor: const Color.fromARGB(255, 255, 247, 22),
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isLogin)
                  Expanded(
                    flex: 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      constraints: BoxConstraints(
                        minHeight: !_isLogin ? 20 : 0,
                        maxHeight: !_isLogin ? 40 : 0,
                      ),
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: UserImagePicker(_pickedImage),
                      ),
                    ),
                  ),
                TextFormField(
                  key: const ValueKey('email'),
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  cursorColor: Theme.of(context).accentColor,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                  ),
                  onSaved: (value) {
                    _userEmail = value;
                  },
                ),
                if (!_isLogin)
                  const SizedBox(
                    height: 8,
                  ),
                if (!_isLogin)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      constraints: BoxConstraints(
                        minHeight: !_isLogin ? 40 : 0,
                        maxHeight: !_isLogin ? 50 : 0,
                      ),
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextFormField(
                          key: const ValueKey('Username'),
                          validator: (value) {
                            if (!_isLogin &&
                                (value.isEmpty || value.length < 4)) {
                              return 'Please enter at least 4 characters';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          onSaved: (value) {
                            _userName = value;
                          },
                        ),
                      ),
                    ),
                  ),
                TextFormField(
                  key: const ValueKey('Password'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return 'Password must be at least 7 characters long';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  onSaved: (value) {
                    _userPassword = value;
                  },
                  onChanged: (value) {
                    if (!_isLogin) {
                      passNotifier.value =
                          PasswordStrength.calculate(text: value);
                    }
                  },
                ),
                if (!_isLogin)
                  const SizedBox(
                    height: 20,
                  ),
                if (!_isLogin)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      constraints: BoxConstraints(
                        minHeight: !_isLogin ? 10 : 0,
                        maxHeight: !_isLogin ? 50 : 0,
                      ),
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: PasswordStrengthChecker(
                          strength: passNotifier,
                          configuration: PasswordStrengthCheckerConfiguration(
                            borderColor: Colors.grey[100],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.isLoading)
                  ElevatedButton(
                    onPressed: null,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                      (states) => Colors.white,
                    )),
                    child: const CircularProgressIndicator(),
                  ),
                if (!widget.isLoading)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _trySubmit,
                        child: Text(
                          _isLogin ? 'Login' : 'Signup',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(47, 149, 153, 1)),
                        ),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _isLogin
                                ? _animationController.reverse()
                                : _animationController.forward();
                          });
                        },
                        child: Text(_isLogin
                            ? 'Create new account'
                            : 'I already have an account'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
