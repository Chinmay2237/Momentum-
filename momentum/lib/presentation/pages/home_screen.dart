
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/presentation/provider/task_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet!'),
            );
          }

          return ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
              );
            },
          );
        },
      ),
    );
  }
}
