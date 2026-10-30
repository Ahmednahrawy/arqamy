import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/customer_list_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerNameAutoComplete extends StatefulWidget {
  final Function(String?) onCustomerSelected;
  final String? initialValue;
  const CustomerNameAutoComplete(
      {super.key, required this.onCustomerSelected, this.initialValue});
  @override
  _CustomerNameAutoCompleteState createState() =>
      _CustomerNameAutoCompleteState();
}

class _CustomerNameAutoCompleteState extends State<CustomerNameAutoComplete> {
  List<String> _customers = CustomerNameConstants.customerNames;
  // late TextEditingController _controller;
  late SharedPreferences _prefs;
  // final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('Init with initialValue: ${widget.initialValue}');
    }
    // _controller = TextEditingController(text: widget.initialValue ?? '');
    _loadSuggestions();
  }

  /// Central handler for submitting a value from any source (onSelected, onFieldSubmitted, focus loss)
  void _handleSubmit(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      // _controller.text = trimmedValue;
      _saveSuggestions();
      _addSuggestion(trimmedValue);
      widget.onCustomerSelected(trimmedValue);
    } else {
      // _controller.clear();
      widget.onCustomerSelected(null);
    }
  }

  // Load suggestions from SharedPreferences
  Future<void> _loadSuggestions() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _customers = _prefs.getStringList('suggestions') ?? _customers;
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Error loading suggestions: $e', isError: true);
    }
    if (kDebugMode) {
      print('load done #########################');
    }
  }

  // Save suggestions to SharedPreferences
  Future<void> _saveSuggestions() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      await _prefs.setStringList('suggestions', _customers);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Error saving suggestions: $e', isError: true);
    }
    if (kDebugMode) {
      print('save done ##############################');
    }
  }

  // Add new suggestion if it doesn't exist
  void _addSuggestion(String suggestion) {
    try {
      if (!_customers.contains(suggestion)) {
        setState(() {
          _customers.add(suggestion);
          _saveSuggestions();
        });
      }
      if (kDebugMode) {
        print('add done ###################################################');
      }
    } catch (e) {
      showAppSnackBar(context, 'Error adding suggestions: $e', isError: true);
    }
  }

  void _removeSuggestion(String suggestion) {
    setState(() {
      _customers.remove(suggestion);
    });
    _saveSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.initialValue ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        // Return the list of customers that match the typed value
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _customers.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        _handleSubmit(selection);
        // _focusNode.unfocus();
        _addSuggestion(selection);
        // FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        final colors = Theme.of(context).colorScheme;
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            _handleSubmit(controller.text);
          }
        });
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.name,
          onFieldSubmitted: (String value) {
            try {
              if (value.isNotEmpty && !_customers.contains(value)) {
                _addSuggestion(value);
                _handleSubmit(value);
              }
              if (kDebugMode) {
                print('Field submitted #############################');
              }
            } catch (e) {
              showAppSnackBar(
                context,
                'Error submitting suggestions: $e',
                isError: true,
              );
            }
          },
          decoration: InputDecoration(
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      widget.onCustomerSelected(null);
                    }),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: colors.primary,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.outline, width: 1.3),
              borderRadius: BorderRadius.circular(15),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colors.error,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colors.error,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            labelText: 'إسم العميل',
          ),
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 4) {
              return 'اكتب على الأقل 4 حروف';
            }
            return null;
          },
        );
      },
      optionsViewBuilder: (context, Function(String) onSelected, customers) {
        final colors = Theme.of(context).colorScheme;
        return Material(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final option = customers.elementAt(index);
              return Dismissible(
                key: Key(option),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: colors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: colors.onError),
                ),
                onDismissed: (direction) {
                  // Handle what happens when an item is dismissed
                  _removeSuggestion(option);
                  showAppSnackBar(context, '$option has been dismissed');
                },
                child: ListTile(
                  title: Text(option),
                  onTap: () {
                    onSelected(option);
                  },
                ),
              );
            },
            itemCount: customers.length,
          ),
        );
      },
    );
  }
}
