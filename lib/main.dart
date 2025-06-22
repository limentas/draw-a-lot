import 'package:draw_a_lot/src/os_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';

import 'src/app_config.dart';
import 'src/ui/app_widget.dart';

final megabyte = 1024 * 1024;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("Debug mode               : $kDebugMode");
    print("Kernel architecture      : ${SysInfo.kernelArchitecture}");
    print("Kernel name              : ${SysInfo.kernelName}");
    print("Kernel version           : ${SysInfo.kernelVersion}");
    print("Operating system name    : ${SysInfo.operatingSystemName}");
    print("Operating system version : ${SysInfo.operatingSystemVersion}");
    print(
      "Total physical memory    : ${SysInfo.getTotalPhysicalMemory() ~/ megabyte} MB",
    );
    print(
      "Free physical memory     : ${SysInfo.getFreePhysicalMemory() ~/ megabyte} MB",
    );
    print(
      "Total virtual memory     : ${SysInfo.getTotalVirtualMemory() ~/ megabyte} MB",
    );
    print(
      "Free virtual memory      : ${SysInfo.getFreeVirtualMemory() ~/ megabyte} MB",
    );
  } catch (e) {
    print("system_info exception    : $e");
  }

  var systemInfo = await OsFunctions.getSystemInfo();
  AppConfig.isX86_32 = systemInfo.isX86_32 && !kDebugMode;
  print("ABIs                     : ${systemInfo.supportedABIs}");
  print("Build time               : ${systemInfo.buildTime}");
  print("Tags                     : ${systemInfo.tags}");
  print("Hardware                 : ${systemInfo.hardware}");
  print("Device                   : ${systemInfo.device}");
  print("Brand                    : ${systemInfo.brand}");
  print("Is x86                   : ${AppConfig.isX86_32}");
  print("Is Little endian         : ${Endian.host == Endian.little}");

  // var style = SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.purple,
  //   systemNavigationBarDividerColor: Colors.green,
  //   systemNavigationBarIconBrightness: Brightness.dark,
  //   systemNavigationBarContrastEnforced: false,
  //   statusBarColor: Colors.transparent,
  //   statusBarBrightness: Brightness.light,
  //   statusBarIconBrightness: Brightness.dark,
  //   systemStatusBarContrastEnforced: false,
  // );

  runApp(AppWidget());
}
