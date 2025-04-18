import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget{

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

  const FormContainerWidget(
    {
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
    }
    );

  @override
  State<StatefulWidget> createState() {
    return _FormContainerWidgetState();
  }
}

class _FormContainerWidgetState extends State<FormContainerWidget>{

  bool _obscureText = true;

  @override
  Widget build(context){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: widget.controller,
        keyboardType: widget.inputType,
        key: widget.fieldKey,
        obscureText: widget.isPasswordField == true? _obscureText : false,
        onSaved: widget.onSaved,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.black45),
          suffix: GestureDetector(
            onTap: (){
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: 
            widget.isPasswordField == true? Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: _obscureText == false ? Colors.blue : Colors.grey,) : Text("")
          ),
        ),
      ),
    );
  }
}