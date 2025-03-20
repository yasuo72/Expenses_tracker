import 'package:expanse_management/Constants/days.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:expanse_management/presentation/screens/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final box = Hive.box<Transaction>('transactions');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, value, child) {
            return CustomScrollView(
              slivers: [
                // Dashboard Header
                SliverToBoxAdapter(
                  child: SizedBox(height: 340, child: _buildDashboardHeader()),
                ),

                // Transaction History Title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transactions History',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 19,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transaction List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final transaction = box.values.toList()[index];
                      return _buildTransactionTile(transaction, index);
                    },
                    childCount: box.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 🟢 Build Transaction Tile
  Widget _buildTransactionTile(Transaction transaction, int index) {
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you want to delete this transaction?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    transaction.delete();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        transaction.delete();
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: transaction.category?.categoryImage != null
              ? Image.asset(
            'images/${transaction.category!.categoryImage}',
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported, size: 40);
            },
          )
              : const Icon(Icons.image, size: 40),
        ),
        title: Text(
          transaction.notes ?? 'No Notes',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${days[transaction.createAt.weekday - 1]}  ${transaction.createAt.day}/${transaction.createAt.month}/${transaction.createAt.year}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          formatCurrency(int.tryParse(transaction.amount ?? '0') ?? 0),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: transaction.type == 'Expense' ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  /// 🟢 Build Dashboard Header
  Widget _buildDashboardHeader() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: const BoxDecoration(
                color: Color(0xff368983),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            right: 30,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40, left: 30),
            child: Text(
              "Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),


            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Container(
              height: 180,
              width: 360,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(47, 125, 121, 0.3),
                    offset: Offset(0, 6),
                    blurRadius: 12,
                    spreadRadius: 6,
                  ),
                ],
                color: const Color(0xff368983),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.more_horiz, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Text(
                          formatCurrency(totalBalance()),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildIncomeExpenseSection(),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  /// 🟢 Build Income and Expense Section
  Widget _buildIncomeExpenseSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IncomeExpenseItem(icon: Icons.arrow_upward, text: 'Income', color: Colors.green),
              _IncomeExpenseItem(icon: Icons.arrow_downward, text: 'Expenses', color: Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatCurrency(totalIncome()), style: _balanceTextStyle()),
              Text(formatCurrency(totalExpense()), style: _balanceTextStyle()),
            ],
          ),
        ),
      ],
    );
  }

  static TextStyle _balanceTextStyle() {
    return const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white);
  }
}

class _IncomeExpenseItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _IncomeExpenseItem({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 13, backgroundColor: color, child: Icon(icon, color: Colors.black, size: 19)),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
      ],
    );
  }
}
