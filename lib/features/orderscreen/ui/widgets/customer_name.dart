import 'package:flutter/material.dart';
import 'package:arqamy/config/theme/colors.dart';
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
    print('Init with initialValue: ${widget.initialValue}');
    // _controller = TextEditingController(text: widget.initialValue ?? '');
    _initialize();
    // _focusNode.addListener(_onFocusChange);
    super.initState();
    // _loadSuggestions();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSuggestions();
  }

  // void _onFocusChange() {
  //   // When focus is lost, treat it as a submission
  //   if (!_focusNode.hasFocus) {
  //     _handleSubmit(_controller.text);
  //   }
  // }

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

  // @override
  // void didUpdateWidget(covariant CustomerNameAutoComplete oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.initialValue != oldWidget.initialValue) {
  //     setState(() {
  //       _controller.text = widget.initialValue ?? '';
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // Load suggestions from SharedPreferences
  Future<void> _loadSuggestions() async {
    _prefs = await SharedPreferences.getInstance();

    try {
      setState(() {
        _customers = _prefs.getStringList('suggestions') ?? _customers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading suggestions: $e ###'),
        ),
      );
    }
    print('load done #########################');
  }

  // Save suggestions to SharedPreferences
  Future<void> _saveSuggestions() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      await _prefs.setStringList('suggestions', _customers);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving suggestions: $e'),
        ),
      );
    }
    print('save done ##############################');
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
      print('add done ###################################################');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding suggestions: $e'),
        ),
      );
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
              print('Field submitted #############################');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error submitting suggestions: $e'),
                ),
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
                borderSide: const BorderSide(
                  color: ColorsManager.mainBlue,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: ColorsManager.lightBlue, width: 1.3),
              borderRadius: BorderRadius.circular(15),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 166, 19, 5),
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
        return Material(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final option = customers.elementAt(index);
              return Dismissible(
                key: Key(option),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: ColorsManager.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Handle what happens when an item is dismissed
                  _removeSuggestion(option);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$option has been dismissed')),
                  );
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
