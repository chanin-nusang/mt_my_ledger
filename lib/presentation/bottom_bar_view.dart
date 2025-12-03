import 'dart:math' as math;
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:mt_my_ledger/models/tab_icon_data.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({
    super.key,
    this.tabIconsList,
    this.changeIndex,
    this.addClick,
  });

  final Function(int index)? changeIndex;
  final Function()? addClick;
  final List<TabIconData>? tabIconsList;
  @override
  State<BottomBarView> createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animationController?.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController!,
          builder: (BuildContext context, Widget? child) {
            return Transform(
              transform: Matrix4.translationValues(0.0, 0.0, 0.0),
              child: PhysicalShape(
                color: Theme.of(context).colorScheme.onSecondary,
                elevation: 16.0,
                clipper: TabClipper(
                  radius:
                      Tween<double>(begin: 0.0, end: 1.0)
                          .animate(
                            CurvedAnimation(
                              parent: animationController!,
                              curve: Curves.fastOutSlowIn,
                            ),
                          )
                          .value *
                      38.0,
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 62,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 4,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TabIcons(
                                tabIconData: widget.tabIconsList?[0],
                                onItemTaped: () {
                                  widget.changeIndex!(0);
                                },
                              ),
                            ),
                            Expanded(
                              child: TabIcons(
                                tabIconData: widget.tabIconsList?[1],
                                onItemTaped: () {
                                  widget.changeIndex!(1);
                                },
                              ),
                            ),
                            SizedBox(
                              width:
                                  Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(
                                        CurvedAnimation(
                                          parent: animationController!,
                                          curve: Curves.fastOutSlowIn,
                                        ),
                                      )
                                      .value *
                                  64.0,
                            ),
                            Expanded(
                              child: TabIcons(
                                tabIconData: widget.tabIconsList?[2],
                                onItemTaped: () {
                                  widget.changeIndex!(2);
                                },
                              ),
                            ),
                            Expanded(
                              child: TabIcons(
                                tabIconData: widget.tabIconsList?[3],
                                onItemTaped: () {
                                  widget.changeIndex!(3);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: SizedBox(
            width: 38 * 2.0,
            height: 38 + 62.0,
            child: Container(
              alignment: Alignment.topCenter,
              color: Colors.transparent,
              child: SizedBox(
                width: 38 * 2.0,
                height: 38 * 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animationController!,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                    child: Container(
                      // alignment: Alignment.center,s
                      decoration: BoxDecoration(
                        color: Color(0xFF2633C5),
                        gradient: LinearGradient(
                          colors: [Color(0xFF2633C5), Color(0x006a88e5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0xFF2633C5).withOpacity(0.4),
                            offset: const Offset(0.0, 8.0),
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.1),
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onTap: widget.addClick,
                          child: Icon(Icons.add, color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TabIcons extends StatefulWidget {
  const TabIcons({super.key, this.tabIconData, this.onItemTaped});

  final TabIconData? tabIconData;
  final Function()? onItemTaped;
  @override
  State<TabIcons> createState() => _TabIconsState();
}

class _TabIconsState extends State<TabIcons> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: widget.onItemTaped,
      child: Center(
        child: IgnorePointer(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              widget.tabIconData!.isSelected
                  ? SvgPicture.asset(
                      widget.tabIconData!.selectedImagePath,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      widget.tabIconData!.imagePath,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                        Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabClipper extends CustomClipper<Path> {
  TabClipper({this.radius = 38.0});

  final double radius;

  @override
  Path getClip(Size size) {
    final Path path = Path();

    final double v = radius * 2;
    path.lineTo(0, 0);
    path.arcTo(
      Rect.fromLTWH(0, 0, radius, radius),
      degreeToRadians(180),
      degreeToRadians(90),
      false,
    );
    path.arcTo(
      Rect.fromLTWH(
        ((size.width / 2) - v / 2) - radius + v * 0.04,
        0,
        radius,
        radius,
      ),
      degreeToRadians(270),
      degreeToRadians(70),
      false,
    );

    path.arcTo(
      Rect.fromLTWH((size.width / 2) - v / 2, -v / 2, v, v),
      degreeToRadians(160),
      degreeToRadians(-140),
      false,
    );

    path.arcTo(
      Rect.fromLTWH(
        (size.width - ((size.width / 2) - v / 2)) - v * 0.04,
        0,
        radius,
        radius,
      ),
      degreeToRadians(200),
      degreeToRadians(70),
      false,
    );
    path.arcTo(
      Rect.fromLTWH(size.width - radius, 0, radius, radius),
      degreeToRadians(270),
      degreeToRadians(90),
      false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(TabClipper oldClipper) => true;

  double degreeToRadians(double degree) {
    final double redian = (math.pi / 180) * degree;
    return redian;
  }
}
