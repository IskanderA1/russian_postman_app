import 'package:flutter/material.dart';
import 'package:russian_postman_app/model/task.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:russian_postman_app/screens/map_task_screen.dart';
import 'package:russian_postman_app/screens/task_screen.dart';
import 'package:russian_postman_app/util/constants.dart';
import 'package:russian_postman_app/widgets/divider_with_text_widget.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<TaskModel> _placesList;
  String _heading;


  @override
  void initState() {
    super.initState();
    _placesList = List<TaskModel>();
    _placesList.add(TaskModel(taskID: "151246", taskDescription: "Есть адрес, нету точки, определить наличие точки по этому адресу", city: "Казань", street: "Мавлютова",house: "15", type: 1));
    _placesList.add(TaskModel(taskID: "123512", taskDescription: "Есть точка (метка на карте), определить, есть ли адрес",city: "Казань", lat: 55.857678, lon: 48.888236, type: 2));
    _placesList.add(TaskModel(taskID: "634524", taskDescription: "Есть точка (метка на карте), определить, есть ли адрес", lat: 55.850464, lon: 48.895049, type: 2));
    _placesList.add(TaskModel(taskID: "523532", taskDescription: "Есть точка (метка на карте), определить, есть ли адрес", lat: 55.8502344, lon: 48.89435, type: 2));
    if(_placesList.isEmpty){
      _heading = "Нет заявок";
    }else{
      _heading = "Кол-во: ${_placesList.length} штук";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Задачи"
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: mainColor,

      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0,bottom: 14,top: 16),
              child: DividerWithText(
                  dividerText: _heading
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _placesList.length,
                itemBuilder: (BuildContext context, int index) =>
                    buildPlaceCard(context, index),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0,bottom: 14,top: 16),
                child:  MaterialButton(
                  onPressed: ()  {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context){
                      return MapTaskScreen(placesList: _placesList);
                    }));
                  },
                  color: mainColor,
                  child: Text(
                    "Показать на карте",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ),
          ],

        ),
      ),
    );
  }



  Widget buildPlaceCard(BuildContext context, int index) {
    return Hero(
      tag: "SelectedTrip-${index}",
      transitionOnUserGestures: true,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Card(
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text("Задача:",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: mainColor
                                          )
                                      ),
                                    ),
                                    AutoSizeText(_placesList[index].taskDescription,
                                        maxLines: 3,
                                        style: TextStyle(fontSize: 14.0)
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4, top: 8),
                                      child: Text(_placesList[index].type==1?"Адресс:":"Координаты точки:",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: mainColor
                                          )
                                      ),
                                    ),
                                    AutoSizeText(_placesList[index].type==1?"${_placesList[index].city==null?"...":_placesList[index].city},${_placesList[index].street==null?"...":_placesList[index].street}, ${_placesList[index].house==null?"...":_placesList[index].house},":"x: ${_placesList[index].lat} y: ${_placesList[index].lon}",
                                        maxLines: 3,
                                        style: TextStyle(fontSize: 14.0)
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return TaskScreen(taskModel: _placesList[index],);
                }
                ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

