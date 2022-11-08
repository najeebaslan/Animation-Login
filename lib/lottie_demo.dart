import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'bunny.dart';

class LottieDemo extends StatefulWidget {
  const LottieDemo({
    super.key,
  });

  @override
  State<LottieDemo> createState() => _LottieDemoState();
}

const Color _primaryColor = Color(0xff3d63ff);
const Color _backgroundColor = Color(0xff3d63ff);
const Color _textColor = Color.fromARGB(255, 45, 41, 41);

class _LottieDemoState extends State<LottieDemo> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Bunny _bunny;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.stop();
    _bunny = Bunny(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// يتم حساب عرض مربع الإدخال بطرح المساحة المتروكة 16 على اليسار واليمين من عرض الشاشة.
    final double textFieldWidth = MediaQuery.of(context).size.width - 32;

    final Widget content = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: _backgroundColor,
        title: const Text(
          'Animation Login',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: _textColor),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32.0),
            Lottie.asset(
              'assets/lottie/bunny_new_mouth.json',
              width: 250,
              height: 250,
              controller: _controller,
              fit: BoxFit.fill,
              onLoaded: (composition) {
                setState(() {
                  ///تعيين مدة الرسوم المتحركة
                  _controller.duration = composition.duration;
                });
              },
            ),
            _MyTextField(
              labelText: 'البريد الإلكتروني',
              keyboardType: TextInputType.emailAddress,
              onHasFocus: (isObscure) {
                ///احصل على التركيز ، وابدأ حالة تتبع النص
                _bunny.setTrackingState();
              },
              onChanged: (text) {
                /// احسب نسبة عرض نص الإدخال إلى عرض مربع الإدخال
                _bunny.setEyesPosition(_getTextSize(text) / textFieldWidth);
              },
            ),
            _MyTextField(
              labelText: 'كلمة المرور',
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              onHasFocus: (isObscure) {
                /// احصل على التركيز ، حدد الحالة
                if (isObscure) {
                  _bunny.setShyState();
                } else {
                  _bunny.setPeekState();
                }
              },
              onObscureText: (isObscure) {
                if (isObscure) {
                  _bunny.setShyState();
                } else {
                  _bunny.setPeekState();
                }
              },
            ),
          ],
        ),
      ),
    );

    return Theme(
      data: ThemeData(
        primaryColor: _primaryColor,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: _primaryColor.withAlpha(70),
          selectionHandleColor: _primaryColor,
          cursorColor: _primaryColor,
        ),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: _primaryColor),
      ),
      child: Directionality(textDirection: TextDirection.rtl, child: content),
    );
  }

  /// الحصول على عرض النص
  double _getTextSize(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 16.0,
          )),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size.width;
  }
}

class _MyTextField extends StatefulWidget {
  const _MyTextField(
      {required this.labelText,
      this.obscureText = false,
      this.keyboardType,
      this.onHasFocus,
      this.onObscureText,
      this.onChanged});

  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;

  /// احصل على التركيز المستمع
  final Function(bool isObscure)? onHasFocus;

  /// مراقبة كلمة المرور المرئية
  final Function(bool isObscure)? onObscureText;

  /// مراقبة إدخال النص
  final Function(String text)? onChanged;

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<_MyTextField> {
  bool _isObscure = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_refresh);
  }

  void _refresh() {
    if (_focusNode.hasFocus && widget.onHasFocus != null) {
      widget.onHasFocus?.call(_isObscure);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Listener(
        onPointerDown: (e) => FocusScope.of(context).requestFocus(_focusNode),
        child: TextField(
          focusNode: _focusNode,
          style: const TextStyle(
              color: _textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              color: _focusNode.hasFocus ? _primaryColor : _textColor,
            ),
            contentPadding: const EdgeInsets.only(left: 8.0),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: _textColor,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: _primaryColor,
              ),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: _focusNode.hasFocus ? _primaryColor : _textColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                      if (widget.onObscureText != null) {
                        widget.onObscureText?.call(_isObscure);
                      }
                    },
                  )
                : null,
          ),
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText ? _isObscure : widget.obscureText,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
