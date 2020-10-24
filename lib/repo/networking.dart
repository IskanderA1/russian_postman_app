import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart';

import 'dart:typed_data';

import 'package:russian_postman_app/model/task.dart';

class NetworkHelper{


  final contentType = "application/json";
  final url = "http://percypostapp.herokuapp.com/";

  final newAddressPost = "address/new_address";
  final setCordPost = "address/set_coords";
  final roadPost = "road";


  Future<bool> SendCord(TaskModel taskModel) async{
    Client client = Client();
    Map<String,dynamic> jsonMap = {'address_id':taskModel.taskID,'lon': taskModel.lat, 'lat': taskModel.lon};
    Response response = await client.post(
        url+setCordPost,
        body: json.encode(jsonMap),
        headers: {'Content-type': contentType}
    );
    print(response.statusCode);
    print(response.body);
    if(response.statusCode >= 200&&response.statusCode<300){
      client.close();
      return true;
    }else{
      client.close();
      return false;
    }

  }

  Future<bool> SendAddress(TaskModel taskModel) async{
    Client client = Client();
    Map<String,dynamic> jsonMap = {'address_id':taskModel.taskID,'city': '${taskModel.city}', 'street': '${taskModel.street}','house': '${taskModel.house}','description':'${taskModel.taskDescription}'};
    Response response = await client.post(
        url+newAddressPost,
        body: json.encode(jsonMap),
        headers: {'Content-type': contentType}
    );
    print(response.statusCode);
    print(response.body);
    if(response.statusCode >= 200&&response.statusCode<300){
      client.close();
      return true;
    }else{
      client.close();
      return false;
    }

  }

}