import 'package:flutter/material.dart';

class ScrollableViews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrollable Views'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                'ListView Example',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: EdgeInsets.all(8),
                    color: Colors.teal[100 * (index + 2)],
                    child: Center(
                      child: Text(
                        'Card $index',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(thickness: 2),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                'GridView Example',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 400,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Center(
                      child: Text(
                        'Tile $index',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
