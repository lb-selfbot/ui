import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoIconButton extends StatelessWidget {
  const InfoIconButton({
    Key? key,
    required this.info,
  }) : super(key: key);

  final String info;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          Icon(Icons.info_outline, color: Theme.of(context).primaryColorLight),
      splashRadius: 20,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Information"),
            content: Text(info),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TextFieldConfigCol extends StatelessWidget {
  const TextFieldConfigCol({
    Key? key,
    required this.name,
    required this.info,
    required this.defaultValue,
    this.numeric = false,
    this.obscure = false,
    required this.onChanged,
  }) : super(key: key);

  final String name;
  final String info;
  final String defaultValue;
  final bool numeric;
  final bool obscure;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: name,
        suffix: InfoIconButton(info: info),
      ),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : [],
      obscureText: obscure,
      controller: TextEditingController()..text = defaultValue,
      onChanged: onChanged,
    );
  }
}

class SwitchConfigCol extends StatefulWidget {
  const SwitchConfigCol({
    Key? key,
    required this.name,
    required this.info,
    required this.defaultValue,
    required this.onChanged,
  }) : super(key: key);
  final String name;
  final String info;
  final bool defaultValue;
  final void Function(bool) onChanged;

  @override
  State<SwitchConfigCol> createState() => _SwitchConfigColState();
}

class _SwitchConfigColState extends State<SwitchConfigCol> {
  bool isSwitched = false;
  bool first = true;
  @override
  Widget build(BuildContext context) {
    if (first) {
      isSwitched = widget.defaultValue;
      first = false;
    }

    return InputDecorator(
      decoration: const InputDecoration(),
      child: Row(
        children: [
          Transform.scale(
            scale: 1, // 0.75 for Material 3 switch
            child: Switch(
              value: isSwitched,
              activeColor: Theme.of(context).primaryColorLight,
              activeTrackColor: Theme.of(context).primaryColorDark,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
                widget.onChanged(value);
              },
            ),
          ),
          Text(widget.name),
          Expanded(child: Container()),
          InfoIconButton(info: widget.info),
        ],
      ),
    );
  }
}

class DropdownConfigCol extends StatefulWidget {
  const DropdownConfigCol({
    Key? key,
    required this.name,
    required this.info,
    required this.options,
    required this.defaultValue,
    required this.onChanged,
  }) : super(key: key);

  final String name;
  final String info;
  final List<Map<String, dynamic>> options;
  final String defaultValue;
  final void Function(String) onChanged;

  @override
  State<DropdownConfigCol> createState() => _DropdownConfigColState();
}

class _DropdownConfigColState extends State<DropdownConfigCol> {
  String dropdownValue = "";
  bool first = true;

  @override
  Widget build(BuildContext context) {
    if (first) {
      dropdownValue = widget.defaultValue;
      first = false;
    }
    return DropdownButtonFormField(
      value: dropdownValue,
      icon: Container(),
      elevation: 16,
      decoration: InputDecoration(
        labelText: widget.name,
        suffix: InfoIconButton(info: widget.info),
      ),
      isExpanded: true,
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
        widget.onChanged(newValue!);
      },
      items: widget.options.map((Map<String, dynamic> value) {
        return DropdownMenuItem(
          value: value['value'] as String,
          child: Text(value['label'] as String),
        );
      }).toList(),
    );
  }
}
