import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'process.dart';
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
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int activeButtonProcess= 1; //1= FIFO, 2=EDF, 3= RR, 4=SJF
  int activeButtonMemory= 1; //1= FIFO, 2= LRU
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
                                      activeButtonProcess= 1;
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
                                      activeButtonProcess= 2;
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
                                      activeButtonProcess= 3;
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
                                      activeButtonProcess= 4;
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
                                      activeButtonMemory= 1;
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

                          //Botão EDF
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
                                      activeButtonMemory= 2;
                                      buttonColorsMemory[0]= Colors.white;
                                      buttonColorsMemory[1]= Colors.purple;
                                      textColorMemory[0]= const Color.fromRGBO(156, 39, 176, 1);
                                      textColorMemory[1]= const Color.fromRGBO(255, 255, 255, 1);

                                    });
                                  },
                                  child: Text(
                                    'Earliest Deadline First',
                                    style: TextStyle(
                                      color: textColorMemory[1],
                                    ),
                                  ),
                                ),
                        ],
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
              
              const SizedBox(height: 80),

              const Text(
                'Editor de processos',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 40),

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
                              
                              //Criamos o processo e colocamos na lista
                              setState(() {
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
                              });
                            }
                          },
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


              //Disco e memória
              const Text(
                'Disco e RAM',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 40),

              Wrap(
                spacing: 100,
                children: <Widget>[

                  //DISCO
                  Container(
                    height: 500,
                    width: 500,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      color: Colors.purple
                    ),
                    child: const Text('Placeholder')
                  ),

                  //RAM
                  Container(
                    height: 500,
                    width: 500,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      color: Colors.purple
                    ),
                    child: const Text('Placeholder')
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
            });
          }, 
          icon: const Icon(Icons.delete)
        ),
        leading: Icon(Icons.circle, color: processColors[index]),
        contentPadding: const EdgeInsets.all(10),
      ),
    );
  }

}
