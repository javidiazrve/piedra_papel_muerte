import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:process_run/shell.dart';

enum Elecciones { piedra, papel, tijeras }

enum Stages {
  home,
  eleccion,
  confirmacion,
  jugada,
  resultado,
}

enum Resultados { victoria, empate, derrota, ninguno }

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController ctrl = Get.put(HomeController());

    return Obx(
      () => Scaffold(
        backgroundColor: Color.fromARGB(255, 24, 24, 24),
        body: ctrl.stage.value == Stages.home
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: primeraVista(),
              )
            : vistaJuego(),
      ),
    );
  }

  Widget primeraVista() {
    HomeController ctrl = Get.find();

    return Center(
      child: SizedBox(
        width: Get.width / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Piedra, Papel o Muerte",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              onChanged: (value) => ctrl.nombreJugador = value,
              decoration:
                  const InputDecoration(hintText: "Coloca aqui tu nombre..."),
            ),
            const SizedBox(height: 20),
            Obx(
              () => TextButton(
                onPressed: ctrl.nombreJugador != ""
                    ? () => {ctrl.empezarJuego()}
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  "Jugar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget vistaJuego() {
    HomeController ctrl = Get.find();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Piedra, Papel o Muerte",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Obx(
              () => filaJugadores(ctrl.stage.value),
            ),
          ),
          Expanded(
            flex: 3,
            child: Obx(
              () => filaBotones(ctrl.stage.value),
            ),
          )
        ],
      ),
    );
  }

  Widget filaBotones(Stages stage) {
    HomeController ctrl = Get.find();
    List<Widget> listaBodyColumn = [];
    TextStyle styleTexto =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 23);
    switch (stage) {
      case Stages.eleccion:
        listaBodyColumn = [
          Container(
            child: const Text(
              "Tu turno",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => {ctrl.elegirJugada(Elecciones.piedra.name)},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  "Piedra",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              OutlinedButton(
                onPressed: () => {ctrl.elegirJugada(Elecciones.papel.name)},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  "Papel",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              OutlinedButton(
                onPressed: () => {ctrl.elegirJugada(Elecciones.tijeras.name)},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  "Tijeras",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ];
      case Stages.confirmacion:
        listaBodyColumn = [
          Text(
            "Estas seguro de tu eleccion?",
            style: styleTexto,
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => {ctrl.confirmarJugada(false)},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              OutlinedButton(
                onPressed: () => {ctrl.confirmarJugada(true)},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  "Confirmar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ];
      case Stages.resultado:
        if (ctrl.resultado == Resultados.victoria ||
            ctrl.resultado == Resultados.empate) {
          listaBodyColumn = [
            Text(
              "Revancha? o eres un cagon?",
              style: styleTexto,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => {ctrl.revancha(false)},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text(
                    "No",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => {ctrl.revancha(true)},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text(
                    "Si",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ];
        } else {
          listaBodyColumn = [
            const SizedBox(
              height: 100,
            )
          ];
        }
      default:
        listaBodyColumn = [
          const SizedBox(
            height: 100,
          )
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: listaBodyColumn,
    );
  }

  Obx filaJugadores(Stages stage) {
    HomeController ctrl = Get.find();

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          playerCard(ctrl.nombreJugador, ctrl.eleccionJugador),
          Expanded(
            flex: 2,
            child: SizedBox(
              width: 200,
              child: Text(
                textoCentro(stage),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          playerCard(ctrl.nombrePc, ctrl.eleccionPc)
        ],
      ),
    );
  }

  Widget playerCard(String nombreJugador, String eleccionJugador) {
    return Expanded(
      flex: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        constraints: const BoxConstraints(minHeight: 300, maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.redAccent,
                ),
                child: Center(
                  child: Text(
                    nombreJugador,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 10,
              child: eleccionJugador == ""
                  ? const Center(
                      child: Icon(Icons.question_mark_rounded),
                    )
                  : Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Image(
                        image: AssetImage('assets/$eleccionJugador.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  textoCentro(Stages stage) {
    HomeController ctrl = Get.find();

    switch (stage) {
      case Stages.eleccion:
      case Stages.confirmacion:
      case Stages.jugada:
        return "VS";
      case Stages.resultado:
        return switch (ctrl.resultado) {
          Resultados.victoria => "Victoria\nFelicidades Has Ganado!!!",
          Resultados.empate => "Empate\nIntenta otra vez",
          Resultados.derrota =>
            "Derrota\nLastima me caias bien \nbuena suerte ahora.",
          Resultados.ninguno => ""
        };
      default:
        return "VS";
    }
  }
}

class HomeController extends GetxController {
  final RxBool _partidaEmpezada = false.obs;
  final RxMap<String, String> _jugador = {"nombre": "", "eleccion": ""}.obs;

  final RxMap<String, String> _pc = {"nombre": "Javi", "eleccion": ""}.obs;
  Rx<Stages> stage = Stages.home.obs;
  Rx<Resultados> _resultado = Resultados.ninguno.obs;
  List<String> elecciones = [
    Elecciones.piedra.name,
    Elecciones.papel.name,
    Elecciones.tijeras.name
  ];

  empezarJuego() {
    stage.value = Stages.eleccion;
    print("awdawd");
  }

  elegirJugada(String eleccion) {
    eleccionJugador = eleccion;
    stage.value = Stages.confirmacion;
  }

  confirmarJugada(bool continuar) {
    stage.value = continuar ? Stages.jugada : Stages.eleccion;
    if (continuar) {
      jugadaPc();
    }
  }

  jugadaPc() {
    int counterTime = 0;
    int counterEleccion = 0;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (counterTime >= 30) {
        terminarRonda();
        timer.cancel();
      } else {
        eleccionPc = elecciones[counterEleccion];

        if (counterEleccion == 2) counterEleccion = -1;

        counterTime++;
        counterEleccion++;
      }
    });
  }

  terminarRonda() {
    Random random = Random();

    int randomNumber = random.nextInt(3);

    eleccionPc = elecciones[randomNumber];

    if (eleccionJugador == Elecciones.piedra.name) {
      switch (eleccionPc) {
        case "tijeras":
          resultado = Resultados.victoria;
          break;
        case "piedra":
          resultado = Resultados.empate;
          break;
        case "papel":
          resultado = Resultados.derrota;
          break;
        default:
          print("ninguno");
          break;
      }
    } else if (eleccionJugador == Elecciones.papel.name) {
      switch (eleccionPc) {
        case "tijeras":
          resultado = Resultados.derrota;
          break;
        case "piedra":
          resultado = Resultados.victoria;
          break;
        case "papel":
          resultado = Resultados.empate;
          break;
        default:
          print("ninguno");
          break;
      }
    } else {
      switch (eleccionPc) {
        case "tijeras":
          resultado = Resultados.empate;
          break;
        case "piedra":
          resultado = Resultados.derrota;
          break;
        case "papel":
          resultado = Resultados.victoria;
          break;
        default:
          print("ninguno");
          break;
      }
    }

    stage.value = Stages.resultado;
  }

  revancha(bool revancha) {
    eleccionJugador = "";
    eleccionPc = "";
    resultado = Resultados.ninguno;

    if (revancha) {
      stage.value = Stages.eleccion;
    } else {
      partidaEmpezada = false;
      nombreJugador = "";
      stage.value = Stages.home;
    }
  }

  set partidaEmpezada(bool value) {
    _partidaEmpezada.value = value;
  }

  bool get partidaEmpezada => _partidaEmpezada.value;

  set nombreJugador(String nombre) {
    _jugador.update("nombre", (value) => nombre);
  }

  String get nombreJugador => _jugador["nombre"]!;

  set eleccionJugador(String eleccion) {
    _jugador.update("eleccion", (value) => eleccion);
  }

  String get eleccionJugador => _jugador["eleccion"]!;

  set eleccionPc(String eleccion) {
    _pc.update("eleccion", (value) => eleccion);
  }

  String get eleccionPc => _pc["eleccion"]!;

  String get nombrePc => _pc["nombre"]!;

  set resultado(Resultados resultado) {
    _resultado.value = resultado;
  }

  Resultados get resultado => _resultado.value;

  /* trollear() async {
  //   var shell = Shell();

  //   await shell.run('''

  //   @echo off 
  //   :A 
  //   msg * hello xd 
  //   goto:A

  //   ''');
  // }*/
}
