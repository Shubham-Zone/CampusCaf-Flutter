import "package:flutter/material.dart";

Widget foodUi(String img,String foodname,String price,BuildContext context){

  var mediaQuery = MediaQuery.of(context);

  return Container(

    width: mediaQuery.size.width*0.31,
    height: 160,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 3,
          blurRadius: 10,
          offset: const Offset(0,7),
        ),
      ],
    ),

    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(foodname,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),textAlign: TextAlign.center),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
              height: 70,
              child: FadeInImage.assetNetwork(placeholder: 'assets/gifs/loading3.gif', image: img
                  ,height: 65)
          ),
          const SizedBox(
            height: 9,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text("Rs",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.red),),
              Text(price,style: const TextStyle(fontSize:13,fontWeight: FontWeight.bold,color: Colors.black),),

            ],
          ),


        ],
      ),
    ),

  );

}