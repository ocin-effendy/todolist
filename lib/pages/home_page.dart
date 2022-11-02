import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/controller/animation_controller.dart';
import 'package:todolist/controller/data_controller.dart';
import 'package:todolist/widget/navigation_drawer.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
	final getAnimationController = Get.find<GetAnimationController>();
	final dataController = Get.find<DataController>();


@override
  Widget build(BuildContext context) {
    bool showFab = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: NavigationDrawer(),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GetBuilder<GetAnimationController>(
				initState: (_){ getAnimationController.getAnimation();},
				dispose: (_)=> getAnimationController.animationController.dispose(),
        builder: (controller) => Stack(
          children: [
            FadeTransition(
              opacity: getAnimationController.animation,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                  image: AssetImage('assets/bg2.jpg'),
                  fit: BoxFit.cover,
                )),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 20, top: MediaQuery.of(context).size.height * 0.11),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        "Have a nice Day",
                        style: TextStyle(
													fontFamily: 'MochiyPopOne',
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                ),
                Expanded(
                    child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Material(
                    color: Colors.transparent,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: AnimatedList(
												physics: BouncingScrollPhysics(),
                        key: dataController.key,
                        initialItemCount: dataController.nameList.length,
                        itemBuilder: (context, index, animation) {
                          final item = dataController.nameList[index];
                          return SizeTransition(
                            key: UniqueKey(),
                            sizeFactor: animation,
                            child: Dismissible(
                                key: Key(item['name']),
                                onDismissed: (direction) {
                                  dataController.removeLocalData();
                                  dataController.removeItem(index);
                                },
                                background: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.grey,
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 20))
                                  ],
                                ),
                                child: buildList(dataController.nameList[index])),
                          );
                        },
                      ),
                    ),
                  ),
                )),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: !showFab,
        child: FloatingActionButton(
          onPressed: () {
            dataController.addNameList();
          },
          backgroundColor: const Color.fromRGBO(212, 144, 112, 1),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }


 Widget buildList(Map<String, dynamic> data) => GetBuilder<GetAnimationController>(
	 init: getAnimationController,
   builder: (controller) => FadeTransition(
          opacity: controller.animation,
          child: GestureDetector(
            onTap: () {
              setState(() {
                dataController.removeLocalData();
                data['isChecked'] = !data['isChecked'];
                dataController.setLocalData();
              });
            },
            child: ListTile(
              visualDensity: const VisualDensity(vertical: -3, horizontal: 3),
              leading: Checkbox(
                activeColor: Colors.blue,
                value: data['isChecked'],
                onChanged: (bool? value) => setState(() {
                  dataController.removeLocalData();
                  data['isChecked'] = value!;
                  dataController.setLocalData();
                }),
                side: const BorderSide(color: Colors.grey, width: 2),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
              ),
              title: data['name'] != ''
                  ? Text(
                      data['name'],
                      style: TextStyle(
											fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: data['isChecked']
                            ? Colors.grey
                            : Theme.of(context).secondaryHeaderColor,
                        decoration:
                            data['isChecked'] ? TextDecoration.lineThrough : null,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField(
                              controller: dataController.textController,
                              autofocus: true,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Input here',
                                  hintStyle: TextStyle(
																		fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey))),
                        ),
                        Expanded(
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    dataController.removeLocalData();
                                    data['name'] = dataController.textController.text;
                                    dataController.setLocalData();
                                  });
                                },
                                icon: Icon(
                                  Icons.done_rounded,
                                  color: Colors.grey[800],
                                )))
                      ],
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              horizontalTitleGap: -5,
            ),
          ),
        ),
 );
  
}
