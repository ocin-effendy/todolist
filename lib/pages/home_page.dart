import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/widget/navigation_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _key = GlobalKey<AnimatedListState>();
  List<Map<String, dynamic>> nameList = [];
  final _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

	void _getLocalData() async {
    final pref = await SharedPreferences.getInstance();
    final String? getData = pref.getString('data');
    if (getData != null) {
      List<dynamic> dataTemp = jsonDecode(getData);
      setState(() {
        for (int i = dataTemp.length - 1; i >= 0; i--) {
          _addDataToNameList(i, dataTemp[i]['name'], dataTemp[i]['isChecked']);
        }
      });
    }
  }

	void _setLocalData() async {
    final pref = await SharedPreferences.getInstance();
    String setData = json.encode(nameList);
    pref.setString('data', setData);
  }

  void _removeLocalData() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('data');
  }

  void _addDataToNameList(int id, String name, bool isChecked) {
    nameList.insert(0, {'id': id, 'name': name, 'isChecked': isChecked});
    _key.currentState!
        .insertItem(0, duration: const Duration(milliseconds: 100));
  }

  void _addNameList() {
    _controller.clear();
    nameList.insert(0, {'id': 0, 'name': '', 'isChecked': false});
    _key.currentState!
        .insertItem(0, duration: const Duration(milliseconds: 800));
  }

  void _removeItem(int index) {
    _key.currentState!.removeItem(
      index,
      (_, animation) {
        return SizeTransition(
          sizeFactor: animation,
        );
      },
    );
    nameList.removeAt(index);
    _setLocalData();
  }

  @override
  void initState() {
    super.initState();
    _getLocalData();
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..forward();
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animation,
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
                      key: _key,
                      initialItemCount: nameList.length,
                      itemBuilder: (context, index, animation) {
                        final item = nameList[index];
                        return SizeTransition(
                          key: UniqueKey(),
                          sizeFactor: animation,
                          child: Dismissible(
                              key: Key(item['name']),
                              onDismissed: (direction) {
                                _removeLocalData();
                                _removeItem(index);
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
                              child: buildList(nameList[index])),
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
      floatingActionButton: Visibility(
        visible: !showFab,
        child: FloatingActionButton(
          onPressed: () {
            _addNameList();
          },
          backgroundColor: const Color.fromRGBO(212, 144, 112, 1),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }


 Widget buildList(Map<String, dynamic> data) => FadeTransition(
        opacity: _animation,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _removeLocalData();
              data['isChecked'] = !data['isChecked'];
              _setLocalData();
            });
          },
          child: ListTile(
            visualDensity: const VisualDensity(vertical: -3, horizontal: 3),
            leading: Checkbox(
              activeColor: Colors.blue,
              value: data['isChecked'],
              onChanged: (bool? value) => setState(() {
                _removeLocalData();
                data['isChecked'] = value!;
                _setLocalData();
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
                            controller: _controller,
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
                                  _removeLocalData();
                                  data['name'] = _controller.text;
                                  _setLocalData();
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
      );
  
}
