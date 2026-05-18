import 'package:flutter/material.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  Widget accountCard(
    String title,
    String balance,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.credit_card,
          color: Colors.indigo,
        ),
        title: Text(title),
        subtitle: Text(balance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            accountCard(
              "Savings Account",
              "\$8,200",
            ),

            accountCard(
              "Current Account",
              "\$4,250",
            ),

            accountCard(
              "Business Account",
              "\$18,900",
            ),
          ],
        ),
      ),
    );
  }
}