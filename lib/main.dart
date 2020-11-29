import 'package:draw_a_lot/src/os_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_info/system_info.dart';

import 'src/app_config.dart';
import 'src/ui/app_widget.dart';

final megabyte = 1024 * 1024;

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  print("Debug mode: $kDebugMode");
  try {
    print("Kernel architecture     : ${SysInfo.kernelArchitecture}");
    print("Kernel name             : ${SysInfo.kernelName}");
    print("Kernel version          : ${SysInfo.kernelVersion}");
    print("Operating system name   : ${SysInfo.operatingSystemName}");
    print("Operating system version: ${SysInfo.operatingSystemVersion}");
    print(
        "Total physical memory   : ${SysInfo.getTotalPhysicalMemory() ~/ megabyte} MB");
    print(
        "Free physical memory    : ${SysInfo.getFreePhysicalMemory() ~/ megabyte} MB");
    print(
        "Total virtual memory    : ${SysInfo.getTotalVirtualMemory() ~/ megabyte} MB");
    print(
        "Free virtual memory     : ${SysInfo.getFreeVirtualMemory() ~/ megabyte} MB");
  } catch (e) {
    print("system_info exception: $e");
  }

  // var systemInfo = OsFunctions.getSystemInfo();
  // systemInfo.then((value) {
  //   AppConfig.isX86_32 = value.isX86_32 && !kDebugMode;
  //   print("ABIs: ${value.supportedABIs}");
  //   print("Build time: ${value.buildTime}");
  //   print("Tags: ${value.tags}");
  //   print("Hardware: ${value.hardware}");
  //   print("Device: ${value.device}");
  //   print("Brand: ${value.brand}");
  //   print("Is x86: ${AppConfig.isX86_32}");

  //   runApp(AppWidget());
  // });
  runApp(AppWidget());
}
