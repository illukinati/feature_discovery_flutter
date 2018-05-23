import 'package:feature_discovery/layout.dart';
import 'package:flutter/material.dart';

class FeatureDiscovery extends StatefulWidget {
  static String activeStep(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedFeatureDiscovery)
            as _InheritedFeatureDiscovery)
        .activeStepId;
  }

  static void discoverFeatures(BuildContext context, List<String> steps) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.discoverFeatures(steps);
  }

  static void markStepComplete(BuildContext context, String stepid) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.markStepComplete(stepid);
  }

  static void dismiss(BuildContext context) {
    _FeatureDiscoveryState state =
        context.ancestorStateOfType(new TypeMatcher<_FeatureDiscoveryState>())
            as _FeatureDiscoveryState;

    state.dismiss();
  }

  final Widget child;
  FeatureDiscovery({this.child});

  @override
  _FeatureDiscoveryState createState() => new _FeatureDiscoveryState();
}

class _FeatureDiscoveryState extends State<FeatureDiscovery> {
  List<String> steps;
  int activeStepIndex;

  void discoverFeatures(List<String> steps) {
    setState(() {
      this.steps = steps;
      activeStepIndex = 0;
    });
  }

  void markStepComplete(String stepId) {
    if (steps != null && steps[activeStepIndex] == stepId) {
      setState(() {
        ++activeStepIndex;
        if (activeStepIndex >= steps.length) {
          _cleanupAfterSteps();
        }
      });
    }
  }

  void dismiss() {
    setState(() {
      _cleanupAfterSteps();
    });
  }

  void _cleanupAfterSteps() {
    steps = null;
    activeStepIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedFeatureDiscovery(
      activeStepId: steps?.elementAt(activeStepIndex),
      child: widget.child,
    );
  }
}

class _InheritedFeatureDiscovery extends InheritedWidget {
  final String activeStepId;
  _InheritedFeatureDiscovery({
    this.activeStepId,
    child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedFeatureDiscovery oldWidget) {
    // TODO: implement updateShouldNotify
    return oldWidget.activeStepId != activeStepId;
  }
}

class DescribeFeatureOverlay extends StatefulWidget {
  final String featureId;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Widget child;

  DescribeFeatureOverlay(
      {this.featureId,
      this.icon,
      this.color,
      this.title,
      this.description,
      this.child});

  @override
  _DescriberFeatureOverlayState createState() =>
      _DescriberFeatureOverlayState();
}

enum DescribedFeatureContentOrientation { above, below }

class _DescriberFeatureOverlayState extends State<DescribeFeatureOverlay> {
  Size screenSize;
  bool showOverlay = false;

  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    showOverllayIfActiveStep();
  }

  void showOverllayIfActiveStep() {
    String activeStep = FeatureDiscovery.activeStep(context);
    setState(() => showOverlay = activeStep == widget.featureId);
  }

  bool isCloseToTheTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset position) {
    return position.dx < (screenSize.width / 2.0);
  }

  DescribedFeatureContentOrientation getContentOrientation(Offset position) {
    if (isCloseToTheTopOrBottom(position)) {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.below;
      } else {
        return DescribedFeatureContentOrientation.above;
      }
    } else {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.above;
      } else {
        return DescribedFeatureContentOrientation.below;
      }
    }
  }

  void activate() {
    FeatureDiscovery.markStepComplete(context, widget.featureId);
  }

  void dismiss() {
    FeatureDiscovery.dismiss(context);
  }

  Widget buildOverlay(Offset anchor){
    return new Stack(
          children: <Widget>[
            new GestureDetector(
              onTap: dismiss,
              child: new Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            new _Background(
              anchor: anchor,
              color: widget.color,
              screenSize: screenSize,
            ),
            new _Content(
              anchor: anchor,
              screenSize: screenSize,
              title: widget.title,
              description: widget.description,
              touchTargetRadius: 44.0,
              touchTargetToContentPadding: 20.0,
            ),
            new _TouchTarget(
              anchor: anchor,
              icon: widget.icon,
              color: widget.color,
              onPressed: activate,
            ),
          ],
        );
  }

  @override
  Widget build(BuildContext context) {
    return new AnchoredOverlay(
      showOverlay: showOverlay,
      overlayBuilder: (BuildContext context, Offset anchor) {
        return buildOverlay(anchor);
      },
      child: widget.child,
    );
  }
}

class _Background extends StatelessWidget {
  final Offset anchor;
  final Color color;
  final Size screenSize;

  _Background({this.anchor, this.color, this.screenSize});

  bool isCloseToTheTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset position) {
    return position.dx < (screenSize.width / 2.0);
  }

  @override
  Widget build(BuildContext context) {
    final isBackgroundCentered = isCloseToTheTopOrBottom(anchor);
    final backgroundRadius =
        screenSize.width * (isBackgroundCentered ? 1.0 : 0.75);
    final backgroundPosition = isBackgroundCentered
        ? anchor
        : new Offset(
            screenSize.width / 2.0 +
                (isOnLeftHalfOfScreen(anchor) ? -20.0 : 20.0),
            anchor.dy +
                (isOnTopHalfOfScreen(anchor)
                    ? -(screenSize.width / 2.0)
                    : (screenSize.width / 2.0)));
    return new CenterAbout(
      position: anchor,
      child: new Container(
        width: 2 * backgroundRadius,
        height: 2 * backgroundRadius,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.90),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Offset anchor;
  final Size screenSize;
  final String title;
  final String description;
  final double touchTargetRadius;
  final double touchTargetToContentPadding;

  _Content({
    this.anchor,
    this.screenSize,
    this.title,
    this.description,
    this.touchTargetRadius,
    this.touchTargetToContentPadding,
  });

  bool isCloseToTheTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  bool isOnLeftHalfOfScreen(Offset position) {
    return position.dx < (screenSize.width / 2.0);
  }

  DescribedFeatureContentOrientation getContentOrientation(Offset position) {
    if (isCloseToTheTopOrBottom(position)) {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.below;
      } else {
        return DescribedFeatureContentOrientation.above;
      }
    } else {
      if (isOnTopHalfOfScreen(position)) {
        return DescribedFeatureContentOrientation.above;
      } else {
        return DescribedFeatureContentOrientation.below;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = getContentOrientation(anchor);
    final contentOffsetMultiplier =
        contentOrientation == DescribedFeatureContentOrientation.below
            ? 1.0
            : -1.0;
    final contentY =
        anchor.dy + (contentOffsetMultiplier * (touchTargetRadius + 20.0));
    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

    return new Positioned(
      top: contentY,
      child: new FractionalTranslation(
        translation: new Offset(0.0, contentFractionalOffset),
        child: new Material(
          color: Colors.transparent,
          child: new Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: new Text(
                    title,
                    style: new TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
                new Text(
                  description,
                  style: new TextStyle(
                      fontSize: 18.0, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TouchTarget extends StatelessWidget {
  final Offset anchor;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  _TouchTarget({this.anchor, this.icon, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final touchTargetRadius = 44.0;

    return new CenterAbout(
      position: anchor,
      child: new Container(
        width: 2 * touchTargetRadius,
        height: 2 * touchTargetRadius,
        child: new RawMaterialButton(
          shape: new CircleBorder(),
          fillColor: Colors.white,
          child: new Icon(
            icon,
            color: color,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
