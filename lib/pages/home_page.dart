import 'package:audio_plus/audio_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_antrian_app/core/constants/colors.dart';
import 'package:flutter_antrian_app/data/datasources/antrian_print.dart';
import 'package:flutter_antrian_app/data/models/antrian.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../data/datasources/antrian_local_datasource.dart';
import 'antrian_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Antrian> listAntrian = [];

  Future<void> getAntrian() async {
    //get all antrian
    final result = await AntrianLocalDatasource.instance.getAllAntrian();
    setState(() {
      listAntrian = result;
    });
  }

  @override
  void initState() {
    getAntrian();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Antrian Code with Bahri',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: listAntrian.isEmpty
            ? const Center(
                child: Text('Tidak ada antrian'),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: listAntrian.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () async {
                      await AudioPlus.play('assets/audio/pressed.mp3');
                      final noAntrian =
                          listAntrian[index].noAntrian.split('-').last;
                      final newAntrian = listAntrian[index].copyWith(
                        noAntrian:
                            '${listAntrian[index].noAntrian.split('-').first}-${int.parse(noAntrian) + 1}',
                      );

                      AntrianLocalDatasource.instance.updateAntrian(newAntrian);
                      getAntrian();
                      final printValue =
                          await AntrianPrint.instance.printAntrian(
                        newAntrian,
                      );
                      await PrintBluetoothThermal.writeBytes(printValue);
                    },
                    child: Card(
                      //border radius
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      //background color
                      color: AppColors.card,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //text nama antrian
                          Text(
                            listAntrian[index].nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          //text
                          Text(
                            listAntrian[index].noAntrian,
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Add your onPressed code here!
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const AntrianPage();
            }));

            getAntrian();
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.settings, color: Colors.white),
        ));
  }
}
