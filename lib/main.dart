// ignore_for_file: library_prefixes

import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'process.dart';
import 'startPackage.dart';
import 'dart:math';

void main() {
  runApp(const EscalonadorWeb());
}

class EscalonadorWeb extends StatelessWidget {
  const EscalonadorWeb({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escalonador SO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'Sistemas Operacionais - Escalonador'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  
  @override
  State<HomeScreen> createState(){
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  String activeButtonProcess= 'fifo'; //1= FIFO, 2=EDF, 3= RR, 4=SJF
  String activeButtonMemory= 'fifo'; //1= FIFO, 2= LRU
  double delayValue= 0.5;
  var buttonColorsProcess= [Colors.purple, Colors.white, Colors.white, Colors.white];
  var textColorProcess= [
    const Color.fromRGBO(255, 255, 255, 1),
    const Color.fromRGBO(156, 39, 176, 1),
    const Color.fromRGBO(156, 39, 176, 1),
    const Color.fromRGBO(156, 39, 176, 1)
  ];
  var buttonColorsMemory= [Colors.purple, Colors.white];
  var textColorMemory= [
    const Color.fromRGBO(255, 255, 255, 1),
    const Color.fromRGBO(156, 39, 176, 1)
  ];

  TextEditingController quantumValue= TextEditingController();
  TextEditingController overheadValue= TextEditingController();
  TextEditingController execTimeValue= TextEditingController();
  TextEditingController pagesValue= TextEditingController();
  TextEditingController deadlineValue= TextEditingController();
  TextEditingController arrivalValue= TextEditingController();

  //Lista de processos
  List<Process> process= List.empty(growable: true);
  int processId= 1;

  //Cores dos processos
  Random random= Random();
  List<Color> processColors= List.empty(growable: true);

  //Valor do switch (True= mostrar id, false= mostrar cores)
  bool switchValue= false;

  //String JSON de configuração inicial
  late String startConfig;

// webSocket para comunicação com Backend
  late IO.Socket socket;

// Valor do disco atual
  List<int> disk= List.filled(250, 0); //Valor Inicial

// Valor da RAM atual
  List<int> ram= List.filled(50, 0); //Valor Inicial

//Lista de TableRows para o disk
  List<TableRow> diskTableRows= [];

//Lista de TableRows para a ram
  List<TableRow> ramTableRows= [];

//Espaço livre no disco
  int diskSpace= 250;

//Tamanho da RAM
  final ramSize= 50;

//Mensagem de erro
  String errorProcessCreation= '';

//ResetState 0= nenhumReset, 1= Primeiro clique, 2= Segundo Clique
  int resetState= 0;

//Texto do botão de reset
  String resetButtonText= 'Reset Algorithm';

//Cor do botão de reset
  Color resetButtonColor= Colors.orange;


  @override
  void initState() {
    initSocket();
    diskTableRows= getRow(disk, 25);
    ramTableRows= getRow(ram, 10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              const SizedBox(height: 50,),

              const Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 70,),

              Row(
                
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  const SizedBox(width: 50),

                  //Botões do escalonador de processos
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Método de escalonamento',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 20,),

                      //Botões de cima para escalonador
                      Wrap(
                        spacing: 20,
                        children: <Widget>[
                          //Botão FIFO
                          OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    foregroundColor: Colors.purple,
                                    backgroundColor: buttonColorsProcess[0],
                                    side: const BorderSide(
                                      color: Colors.purple,
                                      width: 2
                                    ),
                                  ),
                                  onPressed:(){
                                    setState(() {
                                      activeButtonProcess= 'fifo';
                                      buttonColorsProcess[0]= Colors.purple;
                                      buttonColorsProcess[1]= Colors.white;
                                      buttonColorsProcess[2]= Colors.white;
                                      buttonColorsProcess[3]= Colors.white;
                                      textColorProcess[0]= const Color.fromRGBO(255, 255, 255, 1);
                                      textColorProcess[1]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[2]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[3]= const Color.fromRGBO(156, 39, 176, 1);
                                    });
                                  },
                                  child: Text(
                                    'First In First Out',
                                    style: TextStyle(
                                      color: textColorProcess[0],
                                    ),
                                  ),
                                ),

                          //Botão EDF
                          OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    foregroundColor: Colors.purple,
                                    backgroundColor: buttonColorsProcess[1],
                                    side: const BorderSide(
                                      color: Colors.purple,
                                      width: 2
                                    ),
                                  ),
                                  onPressed:(){
                                    setState(() {
                                      activeButtonProcess= 'edf';
                                      buttonColorsProcess[0]= Colors.white;
                                      buttonColorsProcess[1]= Colors.purple;
                                      buttonColorsProcess[2]= Colors.white;
                                      buttonColorsProcess[3]= Colors.white;
                                      textColorProcess[0]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[1]= const Color.fromRGBO(255, 255, 255, 1);
                                      textColorProcess[2]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[3]= const Color.fromRGBO(156, 39, 176, 1);
                                    });
                                  },
                                  child: Text(
                                    'Earliest Deadline First',
                                    style: TextStyle(
                                      color: textColorProcess[1],
                                    ),
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: 20,), //Espaço entre Rows

                      //Botões de baixo para o escalonador
                      Wrap(
                        spacing: 20,
                        children: <Widget>[

                          //Botão Round Robin
                          OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    foregroundColor: Colors.purple,
                                    backgroundColor: buttonColorsProcess[2],
                                    side: const BorderSide(
                                      color: Colors.purple,
                                      width: 2
                                    ),
                                  ),
                                  onPressed:(){
                                    setState(() {
                                      activeButtonProcess= 'rr';
                                      buttonColorsProcess[0]= Colors.white;
                                      buttonColorsProcess[1]= Colors.white;
                                      buttonColorsProcess[2]= Colors.purple;
                                      buttonColorsProcess[3]= Colors.white;
                                      textColorProcess[0]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[1]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[2]= const Color.fromRGBO(255, 255, 255, 1);
                                      textColorProcess[3]= const Color.fromRGBO(156, 39, 176, 1);
                                    });
                                  },
                                  child: Text(
                                    'Round Robin',
                                    style: TextStyle(
                                      color: textColorProcess[2],
                                    ),
                                  ),
                                ),

                          //Botão Shortest Job First
                          OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    foregroundColor: Colors.purple,
                                    backgroundColor: buttonColorsProcess[3],
                                    side: const BorderSide(
                                      color: Colors.purple,
                                      width: 2
                                    ),
                                  ),
                                  onPressed:(){
                                    setState(() {
                                      activeButtonProcess= 'sjf';
                                      buttonColorsProcess[0]= Colors.white;
                                      buttonColorsProcess[1]= Colors.white;
                                      buttonColorsProcess[2]= Colors.white;
                                      buttonColorsProcess[3]= Colors.purple;
                                      textColorProcess[0]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[1]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[2]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorProcess[3]= const Color.fromRGBO(255, 255, 255, 1);
                                    });
                                  },
                                  child: Text(
                                    'Shortest Job First',
                                    style: TextStyle(
                                      color: textColorProcess[3],
                                    ),
                                  ),
                                ),
                        ],
                      ),

                    ],
                  ),

                  const SizedBox(width: 50,),

                  //Botões da MMU
                  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Método de Paginação',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                      ),
                      

                      const SizedBox(height: 20,),

                      //Botões de cima para escalonador
                      Wrap(
                        spacing: 20,
                        children: <Widget>[
                          //Botão FIFO
                          OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    foregroundColor: Colors.purple,
                                    backgroundColor: buttonColorsMemory[0],
                                    side: const BorderSide(
                                      color: Colors.purple,
                                      width: 2
                                    ),
                                  ),
                                  onPressed:(){
                                    setState(() {
                                      activeButtonMemory= 'fifo';
                                      buttonColorsMemory[0]= Colors.purple;
                                      buttonColorsMemory[1]= Colors.white;
                                      textColorMemory[0]= const Color.fromRGBO(255, 255, 255, 1);
                                      textColorMemory[1]= const Color.fromRGBO(156, 39, 176, 1);
                                    });
                                  },
                                  child: Text(
                                    'First in First Out',
                                    style: TextStyle(
                                      color: textColorMemory[0],
                                    ),
                                  ),
                                ),

                          //Botão LRU
                          OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    foregroundColor: Colors.purple,
                                    backgroundColor: buttonColorsMemory[1],
                                    side: const BorderSide(
                                      color: Colors.purple,
                                      width: 2
                                    ),
                                  ),
                                  onPressed:(){
                                    setState(() {
                                      activeButtonMemory= 'lru';
                                      buttonColorsMemory[0]= Colors.white;
                                      buttonColorsMemory[1]= Colors.purple;
                                      textColorMemory[0]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorMemory[1]= const Color.fromRGBO(255, 255, 255, 1);

                                    });
                                  },
                                  child: Text(
                                    'Least Recently Used',
                                    style: TextStyle(
                                      color: textColorMemory[1],
                                    ),
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: 20,),

                      const Text(
                        'Visualizar memória por PID',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 10,),

                      //TODO fazer funcionar a visualização
                      Switch(
                        value: switchValue, 
                        onChanged: (value){
                          setState(() {
                            switchValue= value;
                          });
                        }
                      ),

                    ],
                  ),

                const SizedBox(width: 50,),

                //Configurações do quantum, Overhead e Delay
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Configurações Adicionais',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),

                  //Quantum
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: quantumValue,
                      decoration: const InputDecoration(
                        label: Text(
                          'Quantum',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 16,
                          ),
                        )
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),

                  //Overhead
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: overheadValue,
                      decoration: const InputDecoration(
                        label: Text(
                          'Overhead',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 16,
                          ),
                        )
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),

                  const SizedBox(height: 20,),

                  const Text(
                    'Delay de execução',
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontSize: 16,
                    )
                  ),
                  //Slider para o delay
                  Slider(
                    min: 0.1,
                    max: 2,
                    value: delayValue, 
                    onChanged: (value){
                      setState(() {
                        delayValue= double.parse(value.toStringAsFixed(3));
                      });
                    }
                  ),
                  Text(
                    'Delay de $delayValue segundos',
                    style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                    )
                  ),

                  ],
                ),
              ],
              ),
              
              const SizedBox(height: 60),

              const Text(
                'Editor de processos',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 10),

              //Mensagem de erro
              Text(
                errorProcessCreation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red
                ),
              ),
              const SizedBox(height: 10),


              Wrap(
                alignment: WrapAlignment.start,
                children: <Widget>[
                  Container(
                    height: 400,
                    width: 500,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      color: Colors.purple
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Wrap(
                          spacing: 20,
                          children: <Widget>[


                            //Tempo de execução
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: execTimeValue,
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  label: Text(
                                    'Tempo de Execução',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),

                            //Número de páginas
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: pagesValue,
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  label: Text(
                                    'Páginas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),


                          ],
                        ),
                  
                        Wrap(
                          spacing: 20,
                          children: <Widget>[

                            //Deadline
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: deadlineValue,
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  label: Text(
                                    'Deadline',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),

                            //Momento de chegada
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: arrivalValue,
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  ),
                                  label: Text(
                                    'Chegada',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),


                          ],
                        ),


                        //Botão para criar o processo
                        //TODO não deixar o usuário criar
                        //o processo se não couber no disco ou na ram
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(450, 40),
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2
                            ),
                          ),
                          onPressed:(){
                            String execTime= execTimeValue.text.trim();
                            String pages= pagesValue.text.trim();
                            String deadline= deadlineValue.text.trim();
                            String arrivalTime= arrivalValue.text.trim();
                            if(execTime.isNotEmpty && pages.isNotEmpty && deadline.isNotEmpty && arrivalTime.isNotEmpty){
                             
                              setState((){

                                //Processo não cabe no disco nem na ram
                                if(diskSpace - int.parse(pages) < 0 && int.parse(pages)>ramSize){
                                  errorProcessCreation= 'Espaço insuficiente na RAM e no Disco!';
                                }
                                //Processo não cabe no disco nem na ram
                                else if(diskSpace - int.parse(pages) < 0){
                                  errorProcessCreation= 'Espaço insuficiente no Disco!';
                                }
                                //Processo não cabe no disco nem na ram
                                else if(int.parse(pages)>ramSize){
                                  errorProcessCreation= 'Espaço insuficiente na RAM!';
                                }

                                //Criamos o processo e colocamos na lista
                                else{
                                  diskSpace-= int.parse(pages);
                                  errorProcessCreation= '';
                                  process.add(
                                    Process(
                                      id: processId, 
                                      arrivalTime: int.parse(arrivalTime), 
                                      execTime: int.parse(execTime), 
                                      deadline: int.parse(deadline), 
                                      numberOfPages: int.parse(pages)));

                                    processId++;

                                    execTimeValue.text= '';
                                    pagesValue.text= '';
                                    deadlineValue.text= '';
                                    arrivalValue.text= '';

                                  processColors.add(Color.fromRGBO(
                                    random.nextInt(255),
                                    random.nextInt(255),
                                    random.nextInt(255),
                                    1
                                  ));
                                }
                              });
                            }
                          },

                          //TODO recalcular IDs quando alguem é deletado
                          child: const Text(
                            'Criar Processo',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(width: 30,),

                  //Lista de processos criados
                  SizedBox(
                    width: 520,
                    height: 400,
                    child:ListView.builder(
                        itemCount: process.length,
                        itemBuilder: (context,index) => getTile(index, process, processColors),
                      )
                  ),

 
                ],
              ),

              const SizedBox(height: 60,),

              Wrap(
                children: <Widget>[

                  //Botão START
                  OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(300, 60),
                            foregroundColor: Colors.purple,
                            backgroundColor: Colors.green,
                            side: const BorderSide(
                              color: Colors.green,
                              width: 2
                            ),
                          ),
                          onPressed:(){
                            if(process.isNotEmpty && quantumValue.text != '' && overheadValue.text != ''){
                                //Objeto para enviar ao backend
                                StartPackage package= StartPackage(
                                  cpuAlgorithm: activeButtonProcess, 
                                  memoryAlgorithm: activeButtonMemory, 
                                  quantum: int.parse(quantumValue.text), 
                                  overHead: int.parse(overheadValue.text), 
                                  delay: delayValue, 
                                  process: process
                                );
                                startConfig= jsonEncode(package);
                                //Envia o JSON com os valores
                                socket.emit('start', startConfig);
                            }
                            setState(() {
                              resetButtonText= 'Reset Algorithm';
                              resetButtonColor= Colors.orange;
                              resetState= 0;
                            });
                          },
                          child: const Text(
                            'Start',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),

                  const SizedBox(width: 30,),

                  //Botão Reset
                  OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(300, 60),
                            foregroundColor: Colors.purple,
                            backgroundColor: resetButtonColor,
                            side: BorderSide(
                              color: resetButtonColor,
                              width: 2
                            ),
                          ),
                          onPressed:(){
                            socket.emit('reset_system');
                            //Reseta todos os valores        
                            setState(() {
                              if(resetState==0){//Primeiro clique
                                //Mantém os processos e config de timing
                                resetUI(false);
                                resetButtonText= 'Reset All';
                                resetButtonColor= Colors.red;
                                resetState++;
                              }   
                              else if(resetState==1){//Segundo clique
                                //Reset geral
                                resetUI(true);
                                resetButtonText= 'Reset Algorithm';
                                resetButtonColor= Colors.orange;
                                resetState= 0;
                              }
                            });
                          },
                          child:Text(
                            resetButtonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 80),


              //Gráfico de Gantt
              const Text(
                'Gráfico de Gantt',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 40),

              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  color: Colors.purple
                ),
                child: const Text('Placeholder')
              ),
          
              const SizedBox(height: 80),

              //Disco e Ram
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 100,
                children: <Widget>[
                  //DISCO
                  Column(
                    children: [
                      const Text(
                        'Disco',
                        style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        //height: 800,
                        width: 1000,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          //color: Colors.purple
                        ),
                        child: Table(
                          border: TableBorder.all(color: Colors.black),
                          children: diskTableRows,
                        ),
                      ),
                    ],
                  ),


                  //RAM
                  Column(
                    children: [
                      const Text(
                        'RAM',
                        style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        //height: 500,
                        width: 400,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          //color: Colors.purple
                        ),
                        child: Table(
                          border: TableBorder.all(color: Colors.black),
                          children: ramTableRows,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          
              const SizedBox(height: 80),

            ],
          ),
        ),
      ) 
    );
  }

  void recalculateProcessId(){
    processId= process.length+1;
    for(int i= 0; i<process.length; i++){
      process[i].id= i+1;
    }
  }

  Widget getTile(int index, List<Process> process, List<Color> processColors){
    return Card(
      child: ListTile(
        title: Text('Processo ${process[index].id}'),
        subtitle: Text(
         'Tempo: ${process[index].execTime} | Páginas: ${process[index].numberOfPages} | Deadline: ${process[index].deadline} | Chegada: ${process[index].arrivalTime}'
        ),
        trailing: IconButton(
          onPressed: (){
            setState(() {
              process.removeAt(index);
              processColors.removeAt(index);
              recalculateProcessId();
            });
          }, 
          icon: const Icon(Icons.delete)
        ),
        leading: Icon(Icons.circle, color: processColors[index]),
        contentPadding: const EdgeInsets.all(10),
      ),
    );
  }

  List<TableRow> getRow(List<int>itemList, int columns){
    List<TableRow> listaTableRow= [];
    // ignore: prefer_const_constructors
    TableRow row= TableRow(children: []);
    for(int i= 0; i<itemList.length; i+=columns){
      int iterationEnd= i+columns;
      for(int j= i; j<iterationEnd; j++){
        if(switchValue == false){//Mostrar por Cores
          row.children.add(
            Container(
              alignment: AlignmentDirectional.center,
              margin: const EdgeInsets.all(10),
              child: Icon(Icons.circle, color: findColor(itemList[j])),
            )
          );
        }
        else{//Mostrar por PID
          row.children.add(
            Container(
              alignment: AlignmentDirectional.center,
              margin: const EdgeInsets.all(10),
              child: Text('${itemList[j]}'),
            )
          );
        }
      }
      listaTableRow.add(row);
      // ignore: prefer_const_literals_to_create_immutables, prefer_const_constructors
      row= TableRow(children: []);
    }
    return listaTableRow;
  }

  Color findColor(int idToFind){
    if(idToFind == 0){//Branco 100% transparente (disco livre)
      return const Color.fromARGB(0, 255, 255, 255);
    }
    else{
      if(processColors.length < idToFind){
        return const Color.fromARGB(0, 255, 255, 255);
      }
      else{
        return processColors[idToFind-1];
      }
    }
  }


  initSocket(){
    socket = IO.io('http://127.0.0.1:5000', <String, dynamic>{
    'autoConnect': false,
    'transports': ['websocket'],
    });
    socket.connect();
    socket.onConnect((_){
      print('Connected!');
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
    socket.on('initialValues', (data){
      setState(() {
        disk= data[0]['disk'].cast<int>();
        diskTableRows= getRow(disk, 25);
        ram= data[1]['ram'].cast<int>();
        ramTableRows= getRow(ram, 10);
        //TODO get values from gantt matrix
      });
    });

    socket.on('updatedValues', (dataUpdate){
      setState(() {
        disk= dataUpdate[0]['disk'].cast<int>();
        diskTableRows= getRow(disk, 25);
        ram= dataUpdate[1]['ram'].cast<int>();
        ramTableRows= getRow(ram, 10);
        //TODO get values from gantt matrix
      });
    });
  }

  void resetUI(bool resetAll){
    setState(() {
      if(resetAll){
        process= List.empty(growable: true);
        processId= 1;
        processColors= List.empty(growable: true);
        quantumValue.text= '';
        overheadValue.text= '';
        delayValue= 0.5;
        switchValue= false;
      }
      activeButtonProcess= 'fifo'; //1= FIFO, 2=EDF, 3= RR, 4=SJF
      activeButtonMemory= 'fifo'; //1= FIFO, 2= LRU 
      buttonColorsProcess= [Colors.purple, Colors.white, Colors.white, Colors.white];
      textColorProcess= [
        const Color.fromRGBO(255, 255, 255, 1),
        const Color.fromRGBO(156, 39, 176, 1),
        const Color.fromRGBO(156, 39, 176, 1),
        const Color.fromRGBO(156, 39, 176, 1)
      ];
      buttonColorsMemory= [Colors.purple, Colors.white];
      textColorMemory= [
        const Color.fromRGBO(255, 255, 255, 1),
        const Color.fromRGBO(156, 39, 176, 1)
      ];
      disk= List.filled(250, 0); //Valor Inicial
      ram= List.filled(50, 0); //Valor Inicial
      diskTableRows= getRow(disk, 25);
      ramTableRows= getRow(ram, 10);

      execTimeValue.text= '';
      pagesValue.text= '';
      deadlineValue.text= '';
      arrivalValue.text= '';
      errorProcessCreation='';
    });
  }

}
