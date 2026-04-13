import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PedagogiqueApp());
}

class PedagogiqueApp extends StatelessWidget {
  const PedagogiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedagogique App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: Padding(
          padding: AppSpacing.screenPadding,
          child: Center(
            child: AppSurfaceCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedagogique App',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Status: minimal scaffold only for ${UserRole.pedagogique.name}.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
