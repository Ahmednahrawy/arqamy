import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:material_ui/material_ui.dart';

/// Loads business data before exposing the application screens.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    required this.invoiceProvider,
    required this.child,
  });

  final InvoiceProvider invoiceProvider;
  final Widget child;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<void> _loading;

  @override
  void initState() {
    super.initState();
    _loading = widget.invoiceProvider.loadInvoices();
  }

  void _retry() {
    setState(() {
      _loading = widget.invoiceProvider.loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return widget.child;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: snapshot.hasError
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Could not load saved invoices. '
                            'Your invoice history has not been opened.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _retry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
