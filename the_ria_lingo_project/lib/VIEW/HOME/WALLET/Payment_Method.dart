import 'package:flutter/material.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
            )),
        centerTitle: true,
        title: const Text(
          'Payment Method',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                  height: 50, width: 50, child: Image.asset('assets/Card.png')),
              const SizedBox(
                width: 10,
              ),
              const Text(
                'Add Card',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 35, top: 30),
            child: Row(
              children: [
                Text(
                  'Name on Card',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30),
            height: 45,
            width: 331,
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 1,
                  color: Colors.white,
                  offset: Offset(1, 1)),
            ]),
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 35, top: 30),
            child: Row(
              children: [
                Text(
                  'Credit Card Number',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 45,
            width: 331,
            padding: const EdgeInsets.only(left: 30, right: 30),
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 1,
                  color: Colors.white,
                  offset: Offset(1, 1)),
            ]),
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 35, top: 30),
            child: Row(
              children: [
                Text(
                  'Expiration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 45,
            width: 331,
            padding: const EdgeInsets.only(left: 30, right: 30),
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 1,
                  color: Colors.white,
                  offset: Offset(1, 1)),
            ]),
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 45,
                width: 155,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: purple.value,
                    surfaceTintColor: purple.value,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => Payments()),
                    // );
                  },
                  child: const Text(
                    'Add Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 45,
                width: 155,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(6), // Add border radius
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Cancel',
                        style: TextStyle(
                          color: purple.value,
                          fontSize: 17,
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
    );
  }
}
