import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/presentation/widgets/circular_chart.dart';
import 'package:expanse_management/presentation/widgets/column_chart.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

ValueNotifier<int> notifier = ValueNotifier<int>(0);

class _StatisticsState extends State<Statistics>
    with SingleTickerProviderStateMixin {
  final box = Hive.box<Transaction>('transactions');

  List<String> day = ['Day', 'Week', 'Month', 'Year'];
  List<List<Transaction>> listTransaction = [[], [], [], []];
  List<Transaction> currListTransaction = [];
  int indexColor = 0;

  DateTime selectedDate = DateTime.now();
  late int totalIn;
  late int totalEx;
  late int total;

  late TabController _tabController;
  late bool isCircularChartSelected;

  @override
  void initState() {
    super.initState();
    notifier.value = 0;
    isCircularChartSelected = false;
    _tabController = TabController(length: 2, vsync: this);
    box.listenable().addListener(updateNotifier);
    fetchTransactions();
  }

  @override
  void dispose() {
    box.listenable().removeListener(updateNotifier);
    _tabController.dispose();
    super.dispose();
  }

  void updateNotifier() {
    fetchTransactions();
  }

  void fetchTransactions() {
    listTransaction[0] = getTransactionToday(selectedDate);
    listTransaction[1] = getTransactionWeek(selectedDate);
    listTransaction[2] = getTransactionMonth(selectedDate);
    listTransaction[3] = getTransactionYear(selectedDate);
    currListTransaction = listTransaction[indexColor];
    totalIn = totalFilteredIncome(currListTransaction);
    totalEx = totalFilteredExpense(currListTransaction);
    total = totalIn - totalEx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder: (BuildContext context, int value, Widget? child) {
              currListTransaction = listTransaction[value];
              totalIn = totalFilteredIncome(currListTransaction);
              totalEx = totalFilteredExpense(currListTransaction);
              total = totalIn - totalEx;
              fetchTransactions();
              return customScrollView();
            },
          )),
    );
  }

  CustomScrollView customScrollView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(children: [
            const SizedBox(height: 20),
            const Text('Statistics',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        indexColor = index;
                        notifier.value = index;
                        selectedDate = index == 1
                            ? DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1))
                            : DateTime.now();
                        fetchTransactions();
                      });
                    },
                    child: Container(
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: indexColor == index
                            ? const Color.fromARGB(255, 47, 125, 121)
                            : Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day[index],
                        style: TextStyle(
                          color: indexColor == index ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getFormattedDate(indexColor, selectedDate),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = updateSelectedDate(selectedDate, indexColor, false);
                              fetchTransactions();
                            });
                          },
                          icon: const Icon(Icons.arrow_back_ios_new)),
                      const SizedBox(width: 15),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = updateSelectedDate(selectedDate, indexColor, true);
                              fetchTransactions();
                            });
                          },
                          icon: const Icon(Icons.arrow_forward_ios)),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(text: 'Column'),
                  Tab(text: 'Circular'),
                ],
                onTap: (index) {
                  setState(() {
                    isCircularChartSelected = index == 1;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            isCircularChartSelected
                ? Column(
              children: [
                CircularChart(title: "Income", currIndex: indexColor, transactions: currListTransaction),
                CircularChart(title: "Expense", currIndex: indexColor, transactions: currListTransaction),
              ],
            )
                : ColumnChart(transactions: currListTransaction, currIndex: indexColor),
          ]),
        )
      ],
    );
  }
}

DateTime updateSelectedDate(DateTime date, int index, bool forward) {
  int modifier = forward ? 1 : -1;
  if (index == 0) {
    return date.add(Duration(days: modifier));
  } else if (index == 1) {
    return date.add(Duration(days: 7 * modifier));
  } else if (index == 2) {
    return DateTime(date.year, date.month + modifier, date.day);
  } else {
    return DateTime(date.year + modifier, date.month, date.day);
  }
}
