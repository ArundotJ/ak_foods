import 'package:ak_foods/item_selection_popup.dart';
import 'package:flutter/material.dart';

typedef ListItemCallBack = void Function(ListItemData);

final class DropDownSearchView extends StatefulWidget {
  List<ListItemData> items;
  ListItemCallBack didSelectItem;
  ListItemData selectedItem;
  bool isDisabled = false;
  bool showDefaultValue = true;

  DropDownSearchView(
      {super.key,
      required this.items,
      required this.selectedItem,
      required this.didSelectItem,
      required this.isDisabled,
      required this.showDefaultValue});

  @override
  State<DropDownSearchView> createState() => _DropDownSearchView();
}

class _DropDownSearchView extends State<DropDownSearchView> {
  ListItemData selectedItem = ListItemData("", "");

  @override
  void initState() {
    selectedItem = widget.selectedItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () async {
          if (!widget.isDisabled) {
            await didTapDropdown(context);
          }
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(widget.showDefaultValue
                  ? widget.selectedItem.title
                  : selectedItem.title.trim()),
              Spacer(),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> didTapDropdown(BuildContext context) async {
    final result = await showModalBottomSheet<ListItemData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemSelectionPopup(
        allItems: widget.items,
      ),
    );
    if (result != null) {
      setState(() {
        selectedItem = result;
      });
      widget.didSelectItem(result);
    }
  }
}
