import 'dart:async';
import 'dart:ffi';
import 'dart:math';

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
        body: ctrl.stage.value == Stages.home ? primeraVista() : vistaJuego(),
      ),
    );
  }

  Widget primeraVista() {
    HomeController ctrl = Get.find();

    return Column(
      children: [
        const Text("Piedra, Papel o Muerte"),
        const SizedBox(height: 100),
        TextField(
          onChanged: (value) => ctrl.nombreJugador = value,
          decoration: const InputDecoration(hintText: "Tu nombre"),
        ),
        Obx(
          () => OutlinedButton(
            onPressed:
                ctrl.nombreJugador != "" ? () => {ctrl.empezarJuego()} : null,
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
    );
  }

  Widget vistaJuego() {
    HomeController ctrl = Get.find();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Piedra, Papel o Muerte"),
        Obx(
          () => filaJugadores(ctrl.stage.value),
        ),
        Obx(
          () => filaBotones(ctrl.stage.value),
        )
      ],
    );
  }

  Widget filaBotones(Stages stage) {
    HomeController ctrl = Get.find();

    Widget body;

    switch (stage) {
      case Stages.eleccion:
        body = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        );
      case Stages.confirmacion:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Estas seguro de tu eleccion?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ],
        );
      case Stages.resultado:
        if (ctrl.resultado == Resultados.victoria ||
            ctrl.resultado == Resultados.empate) {
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Revancha? o eres un cagon?"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ],
          );
        } else {
          body = const SizedBox(
            height: 100,
          );
        }
      default:
        body = const SizedBox(
          height: 100,
        );
    }

    return body;
  }

  Obx filaJugadores(Stages stage) {
    HomeController ctrl = Get.find();

    return Obx(
      () => Row(
        children: [
          Column(
            children: [
              Text(ctrl.nombreJugador),
              SizedBox(
                width: 500,
                height: 500,
                child: ctrl.eleccionJugador == ""
                    ? const Center(
                        child: Icon(Icons.question_mark_rounded),
                      )
                    : Image(
                        image: AssetImage('assets/${ctrl.eleccionJugador}.png'),
                      ),
              )
            ],
          ),
          SizedBox(
            child: Text(
              textoCentro(stage),
              textAlign: TextAlign.center,
            ),
            width: 200,
          ),
          Column(
            children: [
              Text(ctrl.nombrePc),
              SizedBox(
                width: 500,
                height: 500,
                child: ctrl.eleccionPc == ""
                    ? const Center(
                        child: Icon(Icons.question_mark_rounded),
                      )
                    : Image(
                        image: AssetImage('assets/${ctrl.eleccionPc}.png'),
                      ),
              )
            ],
          ),
        ],
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

    Timer.periodic(Duration(milliseconds: 50), (timer) {
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
