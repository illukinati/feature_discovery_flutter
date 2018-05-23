import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:feature_discovery/layout.dart';

void main() => runApp(new MyApp());

final feature1 = "FEATURE_1";
final feature2 = "FEATURE_2";
final feature3 = "FEATURE_3";
final feature4 = "FEATURE_4";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Feature Discovery",
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new FeatureDiscovery(
      child: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blue,
          leading: new DescribeFeatureOverlay(
            featureId: feature1,
            icon: Icons.menu,
            color: Colors.red,
            title: 'The Title',
            description: 'The Description',
            child: new IconButton(
              icon: new Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
          title: new Text(''),
          actions: <Widget>[
            new DescribeFeatureOverlay(
              featureId: feature2,
              icon: Icons.search,
              color: Colors.red,
              title: 'Search in here',
              description: 'The Description',
              child: new IconButton(
                icon: new Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: new Content(),
        floatingActionButton: new DescribeFeatureOverlay(
          featureId: feature3,
          icon: Icons.add,
          color: Colors.red,
          title: 'Fab in here',
          description: 'The Description',
          child: new FloatingActionButton(
            child: new Icon(
              Icons.add,
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  @override
  _ContentState createState() => new _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Column(
          children: <Widget>[
            new Image.network(
              "https://i.ytimg.com/vi/5KtQuWSOkGs/maxresdefault.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200.0,
            ),
            new Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: new Text(
                      'Starbuck Kyoto',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  new Text(
                    'Coffee Shop',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: new RaisedButton(
                child: new Text('Do Feature Discovery :D'),
                onPressed: () {
                  FeatureDiscovery.discoverFeatures(context, [feature1,feature2,feature3,feature4 ]);
                },
              ),
            ),
          ],
        ),
        new Positioned(
          top: 200.0,
          right: 0.0,
          child: new FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: new DescribeFeatureOverlay(
              featureId: feature4,
              icon: Icons.drive_eta,
              color: Colors.red,
              title: 'Fab in here',
              description: 'The Description',
              child: new FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                child: new Icon(
                  Icons.drive_eta,
                ),
                onPressed: () {
                  // TODO:
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}


