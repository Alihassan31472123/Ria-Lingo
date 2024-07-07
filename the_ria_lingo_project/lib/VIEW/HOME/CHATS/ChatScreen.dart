import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/CHATS/ChatDetailsByID.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart'; // Import for internet connection checking
import '../../../PROVIDERS/Providers.dart'; // Import the provider

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  Future<void> _retryLoadingChats() async {
    final isConnected = await InternetConnectionChecker().hasConnection;
    if (isConnected) {
      // ignore: unused_result
      ref.refresh(chatListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatListAsyncValue = ref.watch(chatListProvider);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar container
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: purple.value,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon: Image.asset('assets/search.png'),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          // Expanded widget to hold the chat list
          Expanded(
            child: FutureBuilder<InternetConnectionStatus>(
              future: InternetConnectionChecker().connectionStatus,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CardListSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                      length: 10,
                    ),
                  );
                }

                if (snapshot.hasData &&
                    snapshot.data == InternetConnectionStatus.connected) {
                  return RefreshIndicator(
                    onRefresh: _retryLoadingChats,
                    child: chatListAsyncValue.when(
                      data: (chats) {
                        if (chats.isEmpty) {
                          return const Center(child: Text('No Chats Available'));
                        }

                        return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];

                            // Extract last message and members
                            final lastMessage =
                                chat['lastMessage']?['content'] ?? '';
                            final members = chat['members'] as List<dynamic>?;

                            // Find the client member
                            final clientMember = members?.firstWhere(
                              (member) =>
                                  (member['firstName'] as String?)
                                      ?.toLowerCase() ==
                                  'client',
                              orElse: () => null,
                            );

                            // Extract client name and profile picture URL
                            final clientName = clientMember != null
                                ? '${clientMember['firstName'] ?? ''} ${clientMember['lastName'] ?? ''}'
                                : 'Unknown Client';

                            // Create the ListTile for each chat
                            return ListTile(
                              leading: clientMember != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        'https://pub-006088b579004a638bd977f54a8cf45f.r2.dev/' +
                                            (clientMember['profileUrl'] ?? ''),
                                      ),
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.person)),
                              title: Text(
                                clientName +
                                    (chat['job'] != null &&
                                            chat['job']['title'] != null
                                        ? ' - ${chat['job']['title']}'
                                        : ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(lastMessage),
                              trailing: Text(chat['updatedAt'] != null
                                  ? DateFormat('h:mm a')
                                      .format(DateTime.parse(chat['updatedAt']))
                                  : ''),
                              onTap: () {
                                // Navigate to the chat details screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetails(
                                      chatId: chat['_id'],
                                      profilepicture: clientMember != null
                                          ? clientMember['profileUrl']
                                          : '',
                                      firstName: clientMember != null
                                          ? clientMember['firstName']
                                          : '',
                                      lastName: clientMember != null
                                          ? clientMember['lastName']
                                          : '',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      loading: () => Center(
                          child: CardListSkeleton(
                        isCircularImage: true,
                        isBottomLinesActive: true,
                        length: 10,
                      )),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $error'),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                surfaceTintColor: Colors.purple,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.purple,
                              ),
                              onPressed: _retryLoadingChats,
                              child: const Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.purple,
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.purple,
                      ),
                      onPressed: _retryLoadingChats,
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


