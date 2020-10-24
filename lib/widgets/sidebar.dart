import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:russian_postman_app/model/task.dart';
import 'package:russian_postman_app/repo/networking.dart';
import 'package:russian_postman_app/util/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:russian_postman_app/services/location_service.dart';

class SideBar extends StatefulWidget {
  final TaskModel taskModel;
  final Function searchByCord;
  final Function createMarker;
  final Function trackLocationUpdate;
  final Function setAddressLocation;
  final Function clearRoad;
  final Function addSituation;
  SideBar(
      {Key key,
      @required this.taskModel,
      this.searchByCord,
      this.createMarker,
      this.trackLocationUpdate,
      this.setAddressLocation,
      this.clearRoad,
        this.addSituation})
      : super(key: key);
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar>
    with SingleTickerProviderStateMixin<SideBar> {
  Function _searchByCord;
  Function _createMarker;
  Function _trackLocationUpdate;
  Function _setAddressLocation;
  Function _clearRoad;
  Function _addSituation;
  TaskModel _taskModel;
  String _response = "";
  bool cityEnable;
  bool streetEnable;
  bool houseEnable;
  bool locationEnable;
  bool _trackLocationEnable = false;
  List<String> _listDescription;
  String _description = "Неорпределено";

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

    _taskModel.city == null ? cityEnable = true : cityEnable = false;
    _taskModel.street == null ? streetEnable = true : streetEnable = false;
    _taskModel.house == null ? houseEnable = true : houseEnable = false;
    _taskModel.lat == null ? locationEnable = true : locationEnable = false;

    _searchByCord = widget.searchByCord;
    _createMarker = widget.createMarker;
    _trackLocationUpdate = widget.trackLocationUpdate;
    _setAddressLocation = widget.setAddressLocation;
    _clearRoad = widget.clearRoad;
    _addSituation = widget.addSituation;

    _listDescription = <String>[
      "Частный дом",
      "Многоквартирный дом",
      "Магазин",
      "Заброшенное здание",
      "Предприятие",
      "Неорпределено",
    ];
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
    print(
        "roadLength = ${_taskModel.road.length == null ? 0 : _taskModel.road.length}");
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
                    top: 12,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildCity(),
                        /*Row(
                          children: [ ],
                        ),*/
                        _buildStreet(),
                        _buildHouse(),
                        !locationEnable
                            ? _buildLocation()
                            : _buildGetLocation(),
                        _buildDescription(),
                        _buildTrackRoad(),
                        _buildSendButton(),
                        _buildResponseText()
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

  Widget _buildCity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'Город: ',
          style: kLabelStyle,
        ),
        SizedBox(height: 8.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          child: TextField(
            onChanged: (value) {
              setState(() {
                _taskModel.city = value;
              });
            },
            enabled: cityEnable,
            controller: !cityEnable
                ? TextEditingController.fromValue(
                    TextEditingValue(
                      text: _taskModel.city,
                      selection: TextSelection.collapsed(
                          offset: _taskModel.city.length),
                    ),
                  )
                : null,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 2,
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

  Widget _buildStreet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'Улица: ',
          style: kLabelStyle,
        ),
        SizedBox(height: 8.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          child: TextField(
            onChanged: (value) {
              setState(() {
                _taskModel.street = value;
              });
            },
            enabled: streetEnable,
            controller: !streetEnable
                ? TextEditingController.fromValue(
                    TextEditingValue(
                      text: _taskModel.street,
                      selection: TextSelection.collapsed(
                          offset: _taskModel.street.length),
                    ),
                  )
                : null,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 2,
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

  Widget _buildHouse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'Дом: ',
          style: kLabelStyle,
        ),
        SizedBox(height: 8.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          child: TextField(
            onChanged: (value) {
              setState(() {
                _taskModel.house = value;
              });
            },
            enabled: houseEnable,
            controller: !houseEnable
                ? TextEditingController.fromValue(
                    TextEditingValue(
                      text: _taskModel.house,
                      selection: TextSelection.collapsed(
                          offset: _taskModel.house.length),
                    ),
                  )
                : null,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 2,
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
              flex: 7,
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
              flex: 5,
              child: MaterialButton(
                onPressed: () async {
                  onIconPressed();
                  await _createMarker(2, _taskModel.lat, _taskModel.lon);
                  await _searchByCord(_taskModel.lat, _taskModel.lon);
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

  Widget _buildGetLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          'Определить координаты: ',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Text(
                    "x = ${_taskModel.lat == null ? 0 : _taskModel.lat}",
                    textAlign: TextAlign.start,
                  ),
                  Text("y = ${_taskModel.lon == null ? 0 : _taskModel.lon}"),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 5,
              child: MaterialButton(
                onPressed: () async {
                  onIconPressed();
                  LatLng latLng = await _setAddressLocation();
                  setState(() {
                    _taskModel.lat = latLng.latitude;
                    _taskModel.lon = latLng.longitude;
                  });
                },
                color: Colors.white,
                child: Text(
                  "Определить",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 15,
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

  /*Widget _buildDescription() {
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
  }*/

  Widget _buildTrackRoad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: MaterialButton(
                onPressed: () async {
                  setState(() {
                    _trackLocationEnable
                        ? _trackLocationEnable = false
                        : _trackLocationEnable = true;
                    _trackLocationUpdate();
                  });
                },
                color: mainColor,
                child: !_trackLocationEnable
                    ? Text(
                        "Запись пути",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        "Стоп",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            _trackLocationEnable
            ?Expanded(
              flex: 2,
              child: MaterialButton(
                onPressed: () async {
                  _addSituation();
                },
                color: Colors.yellow,
                child: Icon(
                  Icons.assistant_photo
                ),
              ),
            ):SizedBox(),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 5,
              child: _taskModel.road.isNotEmpty
                  ? MaterialButton(
                      onPressed: () async {
                        setState(() {
                          _clearRoad();
                        });
                      },
                      color: Colors.red,
                      child: Text(
                        "Очистить",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : SizedBox(),
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
          DropdownButton<String>(
            hint: Text("Выберите тип объекта"),
            value: _description,
            onChanged: (String value) {
              setState(() {
                this._description = value;
                _taskModel.taskDescription = value;
                print(_taskModel.taskDescription);
              });
            },
            items: _listDescription.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ]);
  }

  Widget _buildSendButton() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          MaterialButton(
              onPressed: () async {
                NetworkHelper networkHelper = NetworkHelper();
                try {
                  if (_taskModel.type == 1 && _taskModel.lat > 0) {
                    if (await networkHelper.SendCord(_taskModel)) {
                      setState(() {
                        _response = "Передано: Координаты адресата";
                      });
                      if (_taskModel.road.isNotEmpty) {
                        setState(() {
                          _response += "\nи запись пути";
                        });
                      }
                    } else {
                      setState(() {
                        _response = "Не отправилось";
                      });
                    }
                  } else if (_taskModel.type == 2 &&
                      (_taskModel.street.isNotEmpty ||
                          _taskModel.house.isNotEmpty)) {
                    if (await networkHelper.SendAddress(_taskModel)) {
                      setState(() {
                        _response = "Передано: Адрес";
                      });
                      if (_taskModel.road.isNotEmpty) {
                        setState(() {
                          _response += "\nи запись пути";
                        });
                      }
                    } else {
                      setState(() {
                        _response = "Не отправилось";
                      });
                    }
                  } else {
                    setState(() {
                      _response = "Заполните поля";
                    });
                  }
                } catch (e) {
                  setState(() {
                    _response = "Нет сети интернета";
                  });
                }
              },
              color: mainColor,
              child: Text(
                "Отправить данные",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )),
        ]);
  }

  Widget _buildResponseText() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(
            _response,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]);
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
