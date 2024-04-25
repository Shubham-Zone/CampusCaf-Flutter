import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import '../DetailScreen.dart';
import 'package:flutter_projects/Widgets/constants.dart';
import '../Shimmereffect/FoodCardShimmer.dart';

class CategoryWidget extends StatefulWidget{

  final banner,category;

  const CategoryWidget(this.banner,this.category, {super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {

  @override
  void initState() {

    RenderErrorBox.backgroundColor = Colors.transparent;
    RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
    ErrorWidget.builder = (FlutterErrorDetails details) => const Center(
      child: Text("SOMETHING WENT WRONG ):"),
    );
    super.initState();
  }

  final ref=FirebaseDatabase.instance.ref("Food");


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.category),
      ),
      body:  MediaQuery.of(context).orientation==Orientation.portrait
          ?
      Column(
        children: [

          FractionallySizedBox(
            widthFactor: 1.0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/${widget.banner}"),
                  fit: BoxFit.fill,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),


          StreamBuilder(
              stream: ref.child(widget.category).onValue,
              builder: (context,AsyncSnapshot<DatabaseEvent> snapshot){
                if(!snapshot.hasData){
                  return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: foodCardShimmer(context)
                  );
                }else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading data'),
                  );
                } else if (snapshot.data == null || snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text('No data available'),
                  );
                }
                else{
                  Map<dynamic,dynamic> map=snapshot.data!.snapshot.value as dynamic;
                  List<dynamic> list=[];
                  list.clear();
                  list=map.values.toList();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: GridView.builder(itemBuilder: (context,index){
                          return InkWell(
                            onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailScreen(list[index]['imageurl'], list[index]['foodname'], list[index]['price'],list[index]['desc'],list[index]['stockStatus'],widget.category),)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: foodUi(list[index]['imageurl'], list[index]['foodname'], list[index]['price'],context),
                                ),
                              ],
                            ),
                          );
                        },
                            itemCount: snapshot.data!.snapshot.children.length,scrollDirection: Axis.vertical, shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 9,
                                mainAxisSpacing: 9
                            )
                        ),
                      ),
                    ),
                  );
                }
              }),
        ],
      )
          :
      Column(
        children: [

          FractionallySizedBox(
            widthFactor: 1.0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/${widget.banner}"),
                  fit: BoxFit.fill,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),


          StreamBuilder(
              stream: ref.child(widget.category).onValue,
              builder: (context,AsyncSnapshot<DatabaseEvent> snapshot){
                if(!snapshot.hasData){
                  return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: foodCardShimmer(context)
                  );
                }else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading data'),
                  );
                } else if (snapshot.data == null || snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text('No data available'),
                  );
                }
                else{
                  Map<dynamic,dynamic> map=snapshot.data!.snapshot.value as dynamic;
                  List<dynamic> list=[];
                  list.clear();
                  list=map.values.toList();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: GridView.builder(itemBuilder: (context,index){
                          return InkWell(
                            onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailScreen(list[index]['imageurl'], list[index]['foodname'], list[index]['price'],list[index]['desc'],list[index]['stockStatus'],widget.category),)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: foodUi(list[index]['imageurl'], list[index]['foodname'], list[index]['price'],context),
                                ),
                              ],
                            ),
                          );
                        },
                            itemCount: snapshot.data!.snapshot.children.length,scrollDirection: Axis.vertical, shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 9,
                                mainAxisSpacing: 9
                            )
                        ),
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}