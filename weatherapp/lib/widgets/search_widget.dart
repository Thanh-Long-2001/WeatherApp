import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:weatherapp_starter_project/api/fetch_weather.dart';
import 'package:weatherapp_starter_project/controller/app_controller.dart';
import 'package:weatherapp_starter_project/controller/global_controller.dart';
import 'package:weatherapp_starter_project/model/weather_data.dart';
import 'package:weatherapp_starter_project/screens/home_screen.dart';

// ignore: must_be_immutable
class SearchWeatherCity extends StatelessWidget {
  final _searchController = TextEditingController();

  final GlobalController globalController =
      Get.put(GlobalController(), permanent: true);
  SearchWeatherCity({super.key});
  final AppController appController = Get.put(AppController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    // ValueNotifier<bool> isArrowBackNotifier =
    //     ValueNotifier<bool>(appController.getArrowState());
    return Scaffold(
      
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: appController.getArrowState()
                ? const Icon(Icons.arrow_back, color: Colors.black)
                : const Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              "assets/weather/background2.png",
              fit: BoxFit.cover, // Tuỳ chỉnh cách ảnh được lấy về
              width: double.infinity,
              height: double.infinity,
            ),
            Column(
            children: [
              Container(
                
                padding: const EdgeInsets.all(16.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Quản lý thành phố',
                      style:
                          TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(25.0),
                  color: const Color.fromARGB(255, 226, 225, 225),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập vị trí',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (String searchText) async {
                          try {
                            List<Location> locations =
                                await locationFromAddress(searchText);
          
                            if (locations.isNotEmpty) {
                              Location location = locations.first;
                              // Lưu tọa độ vào globalController hoặc nơi khác
                              globalController.getLattitude().value =
                                  location.latitude;
                              globalController.getLongitude().value =
                                  location.longitude;
                              WeatherData weatherData = await FetchWeatherAPI()
                                  .processDataSearch(
                                      location.latitude, location.longitude);
          
                              // Cập nhật dữ liệu thời tiết cho globalController hoặc nơi khác
                              globalController.weatherData.value = weatherData;
                              // Gọi hàm getAddress để cập nhật thành phố
                            } else {
                              // print('Không tìm thấy địa chỉ');
                            }
                          } catch (e) {
                            // print('Lỗi: $e');
                          }
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                // ignore: prefer_const_constructors
                                builder: (context) => HomeScreen()),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.red,
                      onPressed: () async {
                        String searchText = _searchController.text;
                        try {
                          List<Location> locations =
                              await locationFromAddress(searchText);
          
                          if (locations.isNotEmpty) {
                            Location location = locations.first;
                            // Lưu tọa độ vào globalController hoặc nơi khác
                            globalController.getLattitude().value =
                                location.latitude;
                            globalController.getLongitude().value =
                                location.longitude;
          
                            WeatherData weatherData = await FetchWeatherAPI()
                                .processDataSearch(
                                    location.latitude, location.longitude);
          
                            // Cập nhật dữ liệu thời tiết cho globalController hoặc nơi khác
                            globalController.weatherData.value = weatherData;
                            // Gọi hàm getAddress để cập nhật thành ph
                          } else {
                            // print('không tìm thấy');
                          }
                        } catch (e) {
                          // print('Lỗi: $e');
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // ignore: prefer_const_constructors
                              builder: (context) => HomeScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 480,
                child: savedPositionList(),
              ),
            ],
          ),
          ],
          
        ));
  }
}

// ignore: use_key_in_widget_constructors, camel_case_types
class savedPositionList extends StatefulWidget {
  @override
  savedPositionListState createState() => savedPositionListState();
}

// ignore: camel_case_types
class savedPositionListState extends State<savedPositionList> {
  final AppController appController = Get.put(AppController(), permanent: true);

  List<Map<String, dynamic>> savedPositions =
      []; // Danh sách các thành phố đã lưu
  bool isLongPress = false;
  bool isChoose = false;
  int selectedPositionIndex = -1;
  List<int> selectedItemsIndexes = [];
  int countDeleteItem = 0;
  bool isDeleteButtonVisible = false;

  final GlobalController globalController =
      Get.put(GlobalController(), permanent: true);
  Future<void> fetchDataFromFirebase() async {
    // Tham chiếu đến nút 'weatherData' trong Firebase
    final databaseReference = FirebaseDatabase.instance.ref();

    // Lấy dữ liệu từ Firebase
    DatabaseEvent event =
        await databaseReference.child('weatherDataListPosition').once();
    Map<String, dynamic>? currentData =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>?;

    // Kiểm tra xem dữ liệu có tồn tại không
    List<dynamic>? yourArray = currentData?["jsonDataList"] as List<dynamic>?;

    // Kiểm tra xem mảng có giá trị không null
    if (yourArray != null) {
      // Duyệt qua mảng sử dụng forEach
      for (var element in yourArray) {
        setState(() {
          savedPositions.add(element);
        });
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    // Gọi fetchDataFromFirebase trong hàm initState để lấy dữ liệu khi widget được khởi tạo
    fetchDataFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      
      child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ignore: sized_box_for_whitespace
            Container(
              height: 420,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: savedPositions.length,
                itemBuilder: (context, index) {
                  var currentPosition = savedPositions[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onLongPress: () async {
                          setState(() {
                            isLongPress = true;
                            isDeleteButtonVisible = true;
                          });
                        },
                        onTap: () async {
                          if (!isLongPress) {
                            final databaseReference =
                                FirebaseDatabase.instance.ref();

                            // Lấy dữ liệu từ Firebase
                            DatabaseEvent event = await databaseReference
                                .child('weatherDataListPosition')
                                .once();
                            Map<String, dynamic>? currentData =
                                jsonDecode(jsonEncode(event.snapshot.value))
                                    as Map<String, dynamic>?;
                            var locationitem =
                                currentData?["jsonDataList"][index];
                            // Lưu tọa độ vào globalController hoặc nơi khác
                            globalController.getLattitude().value =
                                locationitem["location"]["lat"];
                            globalController.getLongitude().value =
                                locationitem["location"]["lon"];

                            WeatherData weatherData = await FetchWeatherAPI()
                                .processDataSearch(
                                    locationitem["location"]["lat"],
                                    locationitem["location"]["lon"]);

                            // Cập nhật dữ liệu thời tiết cho globalController hoặc nơi khác
                            globalController.weatherData.value = weatherData;
                            setState(() {
                              isLongPress = true;
                            });
                            // Gọi hàm getAddress để cập nhật thành ph
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  // ignore: prefer_const_constructors
                                  builder: (context) => HomeScreen()),
                            );
                          }
                          setState(() {
                            isLongPress = false;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (!isLongPress)
                              Column(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 350,
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 247, 238, 122),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "${currentPosition["location"]["name"]}",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (index == 0)
                                                    Container(
                                                      height: 20,
                                                      width: 20,
                                                      padding: const EdgeInsets
                                                          .fromLTRB(4, 0, 0, 0),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/icons/position.png",
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 18, 18, 19)),
                                                    )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    "AQI ${currentPosition["current"]["air_quality"]["gb-defra-index"]}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${currentPosition["forecast"]["forecastday"][0]["day"]["maxtemp_c"]}° / ${currentPosition["forecast"]["forecastday"][0]["day"]["mintemp_c"]}° ",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        // Cột bên phải (nhiệt độ)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Thêm dữ liệu nhiệt độ từ Map hoặc cấu trúc dữ liệu tương tự
                                              Text(
                                                "${currentPosition["current"]["temp_c"].round()}°C", // Thay đổi thành dữ liệu thực tế
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (isLongPress)
                              Column(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 350,
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 247, 238, 122),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "${currentPosition["location"]["name"]}",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (index == 0)
                                                    Container(
                                                      height: 20,
                                                      width: 20,
                                                      padding: const EdgeInsets
                                                          .fromLTRB(4, 0, 0, 0),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/icons/position.png",
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 18, 18, 19)),
                                                    )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    "AQI ${currentPosition["current"]["air_quality"]["gb-defra-index"]}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${currentPosition["forecast"]["forecastday"][0]["day"]["maxtemp_c"]}° / ${currentPosition["forecast"]["forecastday"][0]["day"]["mintemp_c"]}° ",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        // Cột bên phải (nhiệt độ)
                                        Expanded(
                                          // ignore: sized_box_for_whitespace
                                          child: Container(
                                            width: 100,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                // Thêm dữ liệu nhiệt độ từ Map hoặc cấu trúc dữ liệu tương tự
                                                Text(
                                                  "${currentPosition["current"]["temp_c"].round()}°C", // Thay đổi thành dữ liệu thực tế
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        isChoose = !isChoose;
                                                        if (selectedItemsIndexes
                                                            .contains(index)) {
                                                          selectedItemsIndexes
                                                              .remove(index);
                                                        } else {
                                                          selectedItemsIndexes
                                                              .add(index);
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 25,
                                                      width: 25,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                      ),
                                                      child: ColorFiltered(
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                          selectedItemsIndexes
                                                                  .contains(
                                                                      index)
                                                              ? Colors.blue
                                                              : Colors
                                                                  .transparent,
                                                          BlendMode.modulate,
                                                        ),
                                                        child: Image.asset(
                                                          'assets/icons/ticker1.png', // Thay đổi đường dẫn hình ảnh trong asset
                                                          fit: BoxFit.cover,
                                                          color: Colors.blue,
                                                          // color: Colors.white,
                                                        ),
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            if (isLongPress)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedItemsIndexes.length == savedPositions.length) {
          
                              selectedItemsIndexes.clear();
                              
                            } else {
                              for (int i = 0; i < savedPositions.length; i++) {
                                  selectedItemsIndexes.add(i);
                                }
                            }
                          });
                          
                        },
                        // ignore: sized_box_for_whitespace
                        child: Container(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            'assets/icons/selectAll.png', // Đường dẫn tới tập tin hình ảnh
                            fit: BoxFit.cover,
                            color: Colors.yellow // Cách hiển thị hình ảnh (có thể thay đổi tùy theo yêu cầu của bạn)
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 3), // Khoảng cách giữa hình ảnh và Text
                      const Text(
                        'Chọn tất cả',
                        style: TextStyle(fontSize: 12, color: Colors.yellow),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      // ignore: sized_box_for_whitespace
                      GestureDetector(
                        // Xử lí sự kiện Delete
                        onTap: () async {
                          final databaseReference =
                              FirebaseDatabase.instance.ref();

                          List<int> selectedIndexes =
                              List.from(selectedItemsIndexes);

                          // Xóa các phần tử đã chọn khỏi danh sách savedPositions
                          for (int i = selectedIndexes.length - 1;
                              i >= 0;
                              i--) {
                            int selectedIndex = selectedIndexes[i];
                            savedPositions.removeAt(selectedIndex);
                          }

                          // Cập nhật lại danh sách trong Firebase hoặc nơi lưu trữ dữ liệu
                          // Ở đây chúng ta giả sử savedPositions được lưu trữ trong Firebase
                          List<Map<String, dynamic>> dataToUpdate = [];
                          for (var position in savedPositions) {
                            dataToUpdate.add({
                              'location': position['location'],
                              'current': position['current'],
                              'forecast': position['forecast'],
                            });
                          }
                          // Cập nhật lại dữ liệu trong Firebase
                          await databaseReference
                              .child('weatherDataListPosition')
                              .set({'jsonDataList': dataToUpdate});

                          setState(() {
                            isLongPress = false;
                            isDeleteButtonVisible = false;
                            selectedItemsIndexes.clear();
                          });
                        },
                        // ignore: sized_box_for_whitespace
                        child: Container(
                          height: 38,
                          width: 38,
                          child: Image.asset(
                            'assets/icons/trash.png', // Đường dẫn tới tập tin hình ảnh
                            fit: BoxFit
                                .cover,
                            color: Colors.yellow // Cách hiển thị hình ảnh (có thể thay đổi tùy theo yêu cầu của bạn)
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 3), // Khoảng cách giữa hình ảnh và Text
                      Text(
                        'Xóa ${selectedItemsIndexes.length} mục',
                        style: const TextStyle(fontSize: 12, color: Colors.yellow),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedItemsIndexes.clear();
                            isChoose = false;
                            isLongPress = false;
                          });
                          
                        },
                        // ignore: sized_box_for_whitespace
                        child: Container(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            'assets/icons/cancel1.png', // Đường dẫn tới tập tin hình ảnh
                            fit: BoxFit.cover,
                            color: Colors.yellow, // Cách hiển thị hình ảnh (có thể thay đổi tùy theo yêu cầu của bạn)
                          ),
                          
                        ),
                      ),
                      const SizedBox(
                          height: 3), // Khoảng cách giữa hình ảnh và Text
                      const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 12, color: Colors.yellow),
                      ),
                    ],
                  )
                ],
              )
          ]),
    );
  }
}
