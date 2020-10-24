import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:russian_postman_app/model/task.dart';
import 'package:russian_postman_app/util/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:russian_postman_app/services/location.dart';

class SideBar extends StatefulWidget {
  final TaskModel taskModel;
  final Function searchByCord;
  SideBar({Key key, @required this.taskModel, this.searchByCord}) : super(key: key);
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar>
    with SingleTickerProviderStateMixin<SideBar> {
  Function _searchByCord;
  TaskModel _taskModel;
  bool addressEnable;
  bool locationEnable;

  AnimationController _animationController;
  StreamController<bool> isSidebarOpenedStreamController;
  Stream<bool> isSidebarOpenedStream;
  StreamSink<bool> isSidebarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _taskModel = widget.taskModel;
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;

    if (_taskModel.address == null) {
      addressEnable = true;
    } else {
      addressEnable = false;
    }
    if (_taskModel.lat != null && _taskModel.lon != null) {
      locationEnable = true;
    } else {
      locationEnable = false;
    }
    _searchByCord = widget.searchByCord;
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    isSidebarOpenedSink.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      isSidebarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSideBarOpenedAsync) {
        return AnimatedPositioned(
          duration: _animationDuration,
          top: isSideBarOpenedAsync.data ? 0 : -screenHeight,
          bottom: isSideBarOpenedAsync.data ? 0 : screenHeight - 130,
          left: 0,
          right: 0,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: screenWidth,
                  padding: const EdgeInsets.only(
                    top: 48,
                    bottom: 16,
                    left: 32,
                    right: 32,
                  ),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildAddress(),
                        locationEnable?_buildLocation():SizedBox(),
                        _buildDescription(),
                        _buildTrackRoad()
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.9),
                child: GestureDetector(
                  onTap: () {
                    onIconPressed();
                  },
                  child: ClipPath(
                    clipper: CustomMenuClipper(),
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: AnimatedIcon(
                        progress: _animationController.view,
                        icon: AnimatedIcons.menu_close,
                        color: mainColor,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Aдрес: ',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          child: TextField(
            enabled: addressEnable,
            controller: !addressEnable
                ? TextEditingController.fromValue(
                    TextEditingValue(
                      text: _taskModel.address,
                      selection: TextSelection.collapsed(
                          offset: _taskModel.address.length),
                    ),
                  )
                : null,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            style: TextStyle(
              color: mainColor,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.0),
              hintText: 'Введите адрес',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'Координаты: ',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    "x = ${_taskModel.lat}",
                    textAlign: TextAlign.start,
                  ),
                  Text("y = ${_taskModel.lon}"),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 1,
              child: MaterialButton(
                onPressed: () async {
                  onIconPressed();
                  await _searchByCord(_taskModel.lat,_taskModel.lon);
                },
                color: Colors.white,
                child: Text(
                  "Показать",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'Описание: ',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 100.0,
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            style: TextStyle(
              color: mainColor,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.0),
              hintText: 'Введите описание',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackRoad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: MaterialButton(
                onPressed: () {},
                color: mainColor,
                child: Text(
                  "Запись пути",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        )
      ],
    );
  }


}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    Path path = Path();
    path.moveTo(0, 0);

    path.addRRect(RRect.fromRectAndCorners(
        Rect.fromPoints(Offset(0, 0), Offset(100, 50)),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10)));

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
