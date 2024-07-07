import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/WALLET/Payment_Method.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/WALLET/Payments.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final walletProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken != null) {
    const url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/wallets/getOwnWallet';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to fetch wallet data: ${response.statusCode}');
    }
  } else {
    throw Exception('Bearer token not found.');
  }
});

final recentTransactionsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken != null) {
    const url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/wallets/getOwnWalletTransactions?page=1&pageSize=10';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      print(response.body);
      final responseBody = response.body;
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to fetch wallet data: ${response.statusCode}');
    }
  } else {
    throw Exception('Bearer token not found.');
  }
});

class Wallet extends ConsumerWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, dynamic>> walletData =
        ref.watch(walletProvider);
    final AsyncValue<Map<String, dynamic>> recentTransactionsData =
        ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Wallet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: walletData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (wallet) {
          final balance = wallet['wallet']['balance']?.toDouble() ?? 0.0;

          return ListView(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 257,
                  width: 330,
                  decoration: BoxDecoration(
                    color: purple.value,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: purple.value,
                      width: 1,
                    ), // Add black border
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Your Balance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '\$${balance.toStringAsFixed(2)}', // Formats the balance to have 2 digits after the decimal point
                          style: const TextStyle(
                            fontSize: 37,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 140,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                //    elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Payments()),
                                );
                              },
                              child: const Text(
                                'Payments',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 50,
                            width: 140,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                //   elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PaymentMethod()),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Payment',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Method',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              recentTransactionsData.when(
                loading: () => Center(
                    child: CardPageSkeleton(
                  totalLines: 5,
                )),
                error: (error, stackTrace) =>
                    Center(child: Text('Error: $error')),
                data: (transactions) {
                  final transactionList = transactions['data'] as List<dynamic>;

                  return Column(
                    children: transactionList.map((transaction) {
                      final amount = transaction['amount']?.toDouble() ?? 0.0;
                      final isPositive = amount >= 0;
                      final amountText = isPositive
                          ? '\$${amount.toStringAsFixed(2)}'
                          : '-\$${(-amount).toStringAsFixed(2)}';

                      return SizedBox(
                        height: 80,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                children: [
                                  // Container(
                                  //   height: 60,
                                  //   width: 60,
                                  //   decoration: const BoxDecoration(
                                  //       shape: BoxShape.circle),
                                  //   child: Image.asset('assets/wallet1.png'),
                                  // ),

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction['jobContract'] != null
                                            ? transaction['jobContract']
                                                ['title']
                                            : 'No Job Title',
                                        style: TextStyle(
                                            color: tileBlack.value,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        transaction['createdAt'],
                                        style: TextStyle(
                                            color: contentGrey.value,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    amountText,
                                    style: TextStyle(
                                        color: isPositive
                                            ? Colorgreen.value
                                            : Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
