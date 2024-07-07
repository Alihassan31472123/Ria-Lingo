import 'package:flutter/material.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
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
          'Payments',
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: 310,
                width: 338,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(
                      color: contentGrey.value,
                      width: 4,
                    )),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: contentGrey.value,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Jobs',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'EN-SP infographic',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$76',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 56,
                      width: 318,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: purple.value),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: Image.asset('assets/user.png')),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'interpreter',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'Samantha interpreter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: contentGrey.value,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Jobs',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'EN-SP infographic',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$76',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 56,
                      width: 318,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: purple.value),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    color: contentGrey.value,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  width: 89,
                                  decoration: BoxDecoration(
                                      color: purple.value,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      )),
                                  child: const Center(
                                    child: Text(
                                      'Unpaid',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 30,
                        width: 109,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: purple.value,
                              width: 1,
                            )),
                        child: Center(
                          child: Text(
                            'Action',
                            style: TextStyle(
                              color: purple.value,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: 310,
                width: 338,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(
                      color: contentGrey.value,
                      width: 4,
                    )),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: contentGrey.value,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Jobs',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'EN-SP infographic',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$76',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 56,
                      width: 318,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: purple.value),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: Image.asset('assets/user.png')),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'interpreter',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'Samantha interpreter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: contentGrey.value,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Jobs',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'EN-SP infographic',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 56,
                          width: 154,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: purple.value),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                      color: contentGrey.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$76',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 56,
                      width: 318,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: purple.value),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    color: contentGrey.value,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  width: 89,
                                  decoration: BoxDecoration(
                                      color: purple.value,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      )),
                                  child: const Center(
                                    child: Text(
                                      'Unpaid',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 30,
                        width: 109,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: purple.value,
                              width: 1,
                            )),
                        child: Center(
                          child: Text(
                            'Action',
                            style: TextStyle(
                              color: purple.value,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
