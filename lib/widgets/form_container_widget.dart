import 'package:demo/main.dart';
import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;

  const FormContainerWidget({
    this.controller,
    this.fieldKey,
    this.helperText,
    this.hintText,
    this.inputType,
    this.isPasswordField,
    this.labelText,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
  });

  @override
  State<StatefulWidget> createState() {
    return _FormContainerWidgetState();
  }
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: widget.controller,
        keyboardType: widget.inputType,
        key: widget.fieldKey,
        obscureText: widget.isPasswordField == true ? _obscureText : false,
        onSaved: widget.onSaved,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          filled: true,
          fillColor:
              color1 != Colors.black87
                  ? const Color.fromARGB(204, 253, 174, 251)
                  : const Color.fromARGB(71, 123, 31, 162),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.black45),
          suffix: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child:
                widget.isPasswordField == true
                    ? Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _obscureText == false ? Colors.blue : Colors.grey,
                    )
                    : Text(""),
          ),
        ),
      ),
    );
  }
}
