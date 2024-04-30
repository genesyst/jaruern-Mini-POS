
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceScan.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';

class ProdScanPage extends StatelessWidget{
  const ProdScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProdScanPage();
  }
}

class _ProdScanPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ProdScanPageState();
  }
}

class _ProdScanPageState extends State<_ProdScanPage> with AutomaticKeepAliveClientMixin{
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  final TextEditingController _summTextFieldController = TextEditingController(text:'0');
  ServiceScan serviceScan = ServiceScan();
  ServiceSound serviceSound = ServiceSound();


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(child: Scaffold(
      body: const SingleChildScrollView(
        child: Column(
          children: [

          ],
        ),
      ),
      bottomNavigationBar: Footer(),
    ),);
  }

  Widget Footer(){
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 70,
            color: Colors.lightBlue.shade200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextField(
                    controller: _summTextFieldController,
                    decoration: const InputDecoration(
                                labelText: 'รวม(บาท)',
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                            ),
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.top,
                      readOnly: true,
                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 22.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClearButton(),
                  ),
                  const SizedBox(
                    width: 20
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScanButton(),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget ScanButton(){
    return GestureDetector(
        onTap: ()  async {
          serviceScan.scanBarcodeNormal().then((value) async {
              serviceSound.ScanSound();
              Fluttertoast.showToast(msg: value);

            }
          );
        },
        child: Image.asset('assets/images/barcode_scanner.png')
    );
  }

  Widget ClearButton(){
    return GestureDetector(
        onTap: () {

        },
        child: Image.asset('assets/images/clear.png')
    );
  }







}