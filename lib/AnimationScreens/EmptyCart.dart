import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyCart extends StatelessWidget{

  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {

    var mediaquery=MediaQuery.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: mediaquery.size.height*0.02,
            ),
            Text("Cart is Empty",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: mediaquery.size.height*0.022,color: const Color.fromRGBO(
                  220, 69, 90, 1.0)),),
            SizedBox(
              height: mediaquery.size.height*0.03,
            ),
            SizedBox(
              height: mediaquery.size.height*0.3,
              child:Lottie.asset(
                  "assets/lottie/emptycart.json",
                  height: mediaquery.size.height*0.3,
                  fit: BoxFit.cover
              ),
            ),
          ],
        ),
      ),

    );
  }

}