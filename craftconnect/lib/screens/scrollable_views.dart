import 'package:flutter/material.dart';

class ScrollableViews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollable Views'),
        // removed backgroundColor (now uses global theme)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --------------------
            // ListView title
            // --------------------
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'ListView Example',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // --------------------
            // Horizontal ListView
            // --------------------
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Card $index',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(thickness: 2),

            // --------------------
            // GridView title
            // --------------------
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'GridView Example',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // --------------------
            // GridView
            // --------------------
            SizedBox(
              height: 400,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Tile $index',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
