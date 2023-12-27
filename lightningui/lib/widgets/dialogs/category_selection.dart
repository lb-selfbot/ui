import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/api.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/config_fields.dart';
import 'package:searchfield/searchfield.dart';

class CategorySelectionConfig extends StatefulWidget {
  const CategorySelectionConfig({
    Key? key,
    required this.selectedCategories,
    required this.jsonQuery,
    required this.name,
    required this.info,
    required this.setConfig,
  }) : super(key: key);

  final List<dynamic> selectedCategories;
  final String jsonQuery;
  final String name;
  final String info;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<CategorySelectionConfig> createState() =>
      _CategorySelectionConfigState();
}

class _CategorySelectionConfigState extends State<CategorySelectionConfig> {
  List<dynamic> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.selectedCategories;
  }

  String addS(int number) {
    return number == 1 ? "" : "s";
  }

  String getLabelText() {
    final categoryText =
        selectedCategories.length == 1 ? "category" : "categories";
    return '${selectedCategories.length} $categoryText selected';
  }

  void onUpdate(selectedCategories) {
    setState(() {
      this.selectedCategories = selectedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: getLabelText());

    controller.addListener(() {
      controller.text = getLabelText();
    });

    return TextField(
      decoration: InputDecoration(
        labelText: widget.name,
        suffix: InfoIconButton(
          info: widget.info,
        ),
      ),
      controller: controller,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (context) => CategorySelectionDialog(
            name: widget.name,
            selectedCategories: selectedCategories,
            onUpdate: onUpdate,
            setConfig: widget.setConfig,
          ),
        );
      },
    );
  }
}

class CategorySelectionDialog extends StatefulWidget {
  const CategorySelectionDialog({
    Key? key,
    required this.name,
    required this.selectedCategories,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final List<dynamic> selectedCategories;
  final void Function(List<dynamic>) onUpdate;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<CategorySelectionDialog> createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  List<dynamic> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.selectedCategories;
  }

  Widget buildCategoryListItem(dynamic category) {
    return Chip(
      label: Text(category.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          selectedCategories.remove(category);
          getIt<ConfigService>().config = widget.setConfig(
            getIt<ConfigService>().config,
            selectedCategories,
          );
        });
      },
    );
  }

  List<Widget> categoryListItems() {
    return selectedCategories.map(buildCategoryListItem).toList();
  }

  Widget addCategoryButton(
      BuildContext contect, TextEditingController controller) {
    return IconButton(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.primary,
      ),
      splashRadius: 20,
      onPressed: () {
        if (!API.categories.contains(controller.text)) return;

        setState(() {
          selectedCategories.add(controller.text);
          getIt<ConfigService>().config = widget.setConfig(
            getIt<ConfigService>().config,
            selectedCategories,
          );
        });
        controller.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: Text(widget.name),
      content: SizedBox(
        width: 575,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Categories",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 5, runSpacing: 5, children: categoryListItems()),
            const Divider(height: 30),
            Text(
              "Add Category",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            SizedBox(
              //height: 60,
              width: 400,
              child: SearchField<String>(
                suggestions: API.categories
                    .where((e) => !selectedCategories.contains(e))
                    .map((e) => SearchFieldListItem<String>(e,
                        item: e, child: Text("  $e")))
                    .toList(),
                controller: controller,
                searchInputDecoration: InputDecoration(
                  labelText: "Category",
                  suffix: addCategoryButton(context, controller),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
