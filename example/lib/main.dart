import 'package:flutter/material.dart';
import 'package:futronic/enum/ftr_signal_status.dart';
import 'package:futronic/futronic_enroll_result.dart';
import 'package:futronic/futronic_utils.dart';
import 'package:futronic/futronico.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FutronicoExample());
}

class FutronicoExample extends StatelessWidget {
  const FutronicoExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FutronicExamplePage(title: 'Futronico exemplo'),
    );
  }
}

class FutronicExamplePage extends StatefulWidget {
  const FutronicExamplePage({super.key, required this.title});

  final String title;

  @override
  State<FutronicExamplePage> createState() => _FutronicExamplePageState();
}

class _FutronicExamplePageState extends State<FutronicExamplePage> {
  @override
  void dispose() {
    futronico.terminate();
    super.dispose();
  }

  Futronico futronico = Futronico();

  @override
  void initState() {
    setListener();
    super.initState();
  }

  void setListener() {
    Futronico.futronicStatusController.stream.listen((event) {
      if (event.currentStatus == FTR_SIGNAL_STATUS.touch_sensor) {
        setState(() {
          textoResultado = "Coloque o dedo";
        });
      }
      if (event.currentStatus == FTR_SIGNAL_STATUS.take_off) {
        setState(() {
          textoResultado = "Tire o dedo";
        });
      }
    });
  }

  bool hasReceivedSomeBiometry = false;
  String textoResultado = "Aguardando digital";
  List<int> ultimaDigital = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              textoResultado,
            ),
            TextButton(
                onPressed: () {
                  futronico.cancelOperation();
                },
                child: Text("Cancelar leitura"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            if (!hasReceivedSomeBiometry) {
              FutronicEnrollResult enrollResult =
                  await futronico.enrollTemplate();
              ultimaDigital = enrollResult.enrollTemplate;
              setState(() {
                textoResultado =
                    "Digital recebida com a qualidade ${enrollResult.quality} de 10";
              });
              hasReceivedSomeBiometry = true;
            } else {
              bool isTheSame = await futronico.verify(ultimaDigital);
              setState(() {
                textoResultado =
                    isTheSame ? "Digital é a mesma" : "Digital é feike";
              });
            }
          } on FutronicError catch (e) {
            setState(() {
              textoResultado = e.message;
            });
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
