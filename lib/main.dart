import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_projects/paytm.dart';
import 'package:uuid/uuid.dart';
import 'Shimmereffect/PopularShimmer.dart';
import 'Widgets/CategoryWidget.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/DetailScreen.dart';
import 'package:flutter_projects/Splashscreen.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui' as ui;
import 'package:shimmer/shimmer.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafeteria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:  buildMaterialColor(const Color(0xFFDE6262)),
      ),
      home:  const Pay()
    );
  }

}

class MyHomePage extends StatefulWidget {
   const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {


  //Firebase reference
  final ref=FirebaseDatabase.instance.ref("Food");
  final FirebaseAuth auth = FirebaseAuth.instance;
  late DatabaseReference favt;
  var uuid = const Uuid();
  List<dynamic> list=[];


  @override
  void initState() {

    FirebaseMessaging.instance.subscribeToTopic('all');

    //customising error screen
    RenderErrorBox.backgroundColor = Colors.transparent;
    RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
    ErrorWidget.builder = (FlutterErrorDetails details) => const Center(
      child: Text("SOMETHING WENT WRONG ):"),
    );
    super.initState();
  }



  @override
  Widget build(BuildContext context) {


    var mediaQuery=MediaQuery.of(context);

    //Category design
    Widget foodCard(String img,String foodname){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 5,
          ),
          Container(
            width: mediaQuery.size.width*0.25,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: const Offset(0,7),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Image.asset('assets/images/$img.png'
                    ,height: 70,),

                  const SizedBox(
                    height: 13,
                  ),

                  Text(foodname,style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold),textAlign: TextAlign.center)
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      );

    }

    //Food CardDesign
    Widget foodUi(String img,String foodname,String price){

      return Row(
        children: [
          const SizedBox(
            width: 2,
          ),
          Container(
            width: mediaQuery.size.width*0.32,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(foodname,style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold),textAlign: TextAlign.center),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                      height: 60,
                      child: FadeInImage.assetNetwork(placeholder: 'assets/gifs/loading3.gif', image: img
                        ,height: 60,)
                  ),
                  const SizedBox(
                    height:  10
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Rs",style: TextStyle(fontSize:  13, fontWeight: FontWeight.bold,color: Colors.red),),
                      Text(price,style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.black),),

                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      );
    }

    List cat = [
      "Snacks",
      "SouthIndian",
      "Chinese",
      "Regional",
      "Beverages",
      "Sweets",
    ];

    List banner = [
      "snacksbanner.png",
      "southindianbanner.jpeg",
      "chinesebanner2.png",
      "regionalbanner.jpeg",
      "beveragesbanner.png",
      "sweetsbanner.png",
    ];

    List catImg=[
      "snacks","southindian","chinese","regionall","beverages","sweets"
    ];


    return WillPopScope(

        onWillPop: () async {
          onBackPress(); // Action to perform on back pressed
          return false;
        },

        child: Scaffold(

            appBar: AppBar(
              title: Text(widget.title),
              automaticallyImplyLeading: false,
            ),

            body: SingleChildScrollView(

              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [

                    //lottie animation
                    SizedBox(
                      height: 200,
                      child:Lottie.asset(
                          "assets/lottie/mainbanner.json",
                          height: 200,
                          fit: BoxFit.cover
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('CATEGORIES',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                        ),
                      ),
                    ),

                    //Category
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          height: 140,
                          child:ListView.builder(
                              itemBuilder: (context,index){
                                return InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryWidget(banner[index],cat[index],)));
                                  },
                                    child: foodCard(catImg[index], cat[index])
                                );
                              },
                            itemCount: cat.length,scrollDirection: Axis.horizontal,
                          )
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('POPULAR',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                        ),
                      ),
                    ),

                    //Popular
                    StreamBuilder(
                    stream: ref.child('Popular').onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot == null || !snapshot.hasData) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              height: 170,
                              width: double.infinity,
                              child: foodUiShimmer(context),
                            ),
                          ),
                        );
                      }else if (snapshot.hasError) {
                        return const Text('Error fetching data');
                      }
                      else if (snapshot.data!.snapshot.value == null) {
                        return const Text('No data available');
                      } else {
                        Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                        List<dynamic> list = map.values.toList();
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            height: 170,
                            width: double.infinity,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                final imageUrl = list[index]['imageurl'] ?? '';
                                final foodName = list[index]['foodname'] ?? 'Unknown';
                                final price = list[index]['price'] ?? 0;
                                return InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        imageUrl,
                                        foodName,
                                        price,
                                        list[index]['desc'],
                                        list[index]['stockStatus'],
                                        "Popular",
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    child: foodUi(imageUrl, foodName, price),
                                  ),
                                );
                              },
                              itemCount: list.length,
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                        );
                      }
                    },
                  ),


                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('FEATURED ITEMS',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                        ),
                      ),
                    ),

                    //Featured
                    StreamBuilder(
                        stream: ref.child('Featured').onValue,
                        builder: (context,AsyncSnapshot<DatabaseEvent> snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error fetching data');
                          } else if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                            return const Text('No data available');
                          }
                          else{
                            Map<dynamic,dynamic> map=snapshot.data!.snapshot.value as dynamic;
                            List<dynamic> list1=[];
                            list1.clear();
                            list1=map.values.toList();
                            return SizedBox(
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context,index){
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 40,
                                          child: Container(
                                            height: 200,
                                            width: mediaQuery.size.width*0.9,
                                            margin: const EdgeInsets.only(left: 25,right: 25,top: 15),
                                            decoration:  BoxDecoration(
                                                color:const Color(0xFFD07777),
                                                borderRadius:const BorderRadius.only(
                                                    topLeft: Radius.circular(100),
                                                    bottomRight: Radius.circular(100),
                                                ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 10,
                                                  blurRadius: 12,
                                                  offset: const Offset(0,20),
                                                ),
                                              ],
                                            ),
                                            child:Row (
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const SizedBox(
                                                  width: 25,
                                                ),
                                                Container(
                                                  width: 100,
                                                    margin: const EdgeInsets.only(bottom: 40,left: 15),
                                                    child: Text(list1[index]['foodname'] ?? "Unknown",textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white,),)),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                        width: 70,
                                                        height: 45,
                                                        margin: const EdgeInsets.only(left: 80,bottom: 30),
                                                        decoration: BoxDecoration(
                                                            color: const Color.fromRGBO(
                                                                249, 188, 118, 1.0),
                                                            borderRadius:BorderRadius.circular(15)
                                                        ),
                                                        child: Center(child: Text("Rs ${list1[index]['price'] ?? ""}",style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)),
                                                    ),

                                                    InkWell(
                                                      onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailScreen(
                                                        list1[index]['imageurl'] ?? '',
                                                        list1[index]['foodname'] ?? '',
                                                        list1[index]['price'] ?? '',
                                                        list1[index]['desc'] ?? '',
                                                        list1[index]['stockStatus'] ?? '',
                                                        'Featured',
                                                      ),
                                                      )
                                                      ),
                                                      child: Container(
                                                        width: 70,
                                                        height: 50,
                                                        margin: const EdgeInsets.only(left: 80,bottom: 30),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:BorderRadius.only(
                                                                topLeft: Radius.circular(30),
                                                                bottomRight: Radius.circular(30)

                                                            )
                                                        ),
                                                        child: const Center(child: Text("Order",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.amber),)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: mediaQuery.size.width*0.48,
                                          child: Container(
                                            height: 150,
                                            width: mediaQuery.size.width*0.4,
                                            // margin: EdgeInsets.only(left: 20,right: 20,top: 20),
                                            decoration:  const BoxDecoration(
                                                borderRadius:BorderRadius.only(
                                                    topLeft: Radius.circular(100),
                                                    bottomRight: Radius.circular(100)

                                                ),
                                            ),

                                            child:FadeInImage.assetNetwork(placeholder: 'assets/gifs/loading3.gif', image: list1[index]["imageurl"] ?? ""
                                              ,height: 150,width: mediaQuery.size.width*0.4,),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                                itemCount: snapshot.data!.snapshot.children.length,scrollDirection: Axis.vertical,
                              ),
                            );
                          }
                        }),

                  ],
                ),
              ),
            )
        ),

    );

  }

  void onBackPress() {
    exit(0);
  }


}




