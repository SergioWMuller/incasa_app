import 'package:flutter/material.dart';
import 'package:incasa_app/features/sell/widgets/sell_wizard_widget.dart';

/// View do Vender — tela 03 do design_handoff_incasa (wizard de 4 passos).
/// O wizard vive em SellWizardWidget e hoje é embutido como 3ª tab do
/// Minha Loja; esta view fica como wrapper para o futuro modal central
/// "Vender" previsto no design final.
class SellView extends StatelessWidget {
  const SellView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SellWizardWidget());
  }
}
