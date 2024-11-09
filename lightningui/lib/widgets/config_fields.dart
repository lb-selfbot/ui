import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lightningui/utils.dart';
import 'package:lightningui/widgets/dialogs/login_dialog.dart';
import 'package:searchfield/searchfield.dart';

class InfoIconButton extends StatelessWidget {
  const InfoIconButton({
    super.key,
    required this.info,
  });

  final String info;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      splashRadius: 20,
      onPressed: () {
        Utils.showAlertDialog(
          context,
          "Information",
          info,
        );
      },
    );
  }
}

class LoginIconButton extends StatelessWidget {
  const LoginIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.login,
        color: Theme.of(context).colorScheme.primary,
      ),
      splashRadius: 20,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const LoginDialog(),
        );
      },
    );
  }
}

class TextFieldConfigCol extends StatelessWidget {
  const TextFieldConfigCol({
    super.key,
    required this.name,
    required this.info,
    required this.defaultValue,
    this.numeric = false,
    this.obscure = false,
    required this.onChanged,
  });

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

class TokenConfigCol extends StatelessWidget {
  const TokenConfigCol({
    super.key,
    required this.name,
    required this.info,
    required this.defaultValue,
    this.numeric = false,
    this.obscure = false,
    required this.onChanged,
  });

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
        suffix: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoginIconButton(),
            InfoIconButton(info: info),
          ],
        ),
      ),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : [],
      obscureText: obscure,
      controller: TextEditingController()..text = defaultValue,
      onChanged: onChanged,
    );
  }
}

class TextFieldAutoCompleteConfigCol extends StatelessWidget {
  const TextFieldAutoCompleteConfigCol({
    super.key,
    required this.name,
    required this.info,
    required this.defaultValue,
    required this.options,
    required this.onChanged,
  });

  final String name;
  final String info;
  final String defaultValue;
  final List<String> options;
  final void Function(String) onChanged;

  SearchFieldListItem<String> optionMapper(String option) {
    return SearchFieldListItem(option);
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: defaultValue);

    return SearchField<String>(
      suggestions: options.map(optionMapper).toList(),
      controller: controller,
      searchInputDecoration: SearchInputDecoration(
        labelText: name,
        labelStyle: const TextStyle(height: 3),
        suffix: InfoIconButton(info: info),
        isDense: true,
      ),
      onSuggestionTap: (suggestion) {
        // controller.text = suggestion.value;
        onChanged(suggestion.searchKey);
      },
      onSubmit: onChanged,
    );
  }
}

class SwitchConfigCol extends StatefulWidget {
  const SwitchConfigCol({
    super.key,
    required this.name,
    required this.info,
    required this.defaultValue,
    required this.onChanged,
  });
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
            scale: 0.75,
            child: Switch(
              value: isSwitched,
              activeColor: Theme.of(context).colorScheme.primary,
              activeTrackColor: Theme.of(context).colorScheme.inversePrimary,
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
    super.key,
    required this.name,
    required this.info,
    required this.options,
    required this.defaultValue,
    required this.onChanged,
  });

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
