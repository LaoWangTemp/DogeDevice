import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:windows_system_info/windows_system_info.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DeviceInfoScreen(),
    );
  }
}

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidDeviceInfo(await _deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      } else if (Platform.isMacOS) {
        deviceData = _readMacOsDeviceInfo(await _deviceInfoPlugin.macOsInfo);
      } else if (Platform.isWindows) {
        deviceData = await _readWindowsDeviceInfo();
      } else if (Platform.isLinux) {
        deviceData = _readLinuxDeviceInfo(await _deviceInfoPlugin.linuxInfo);
      }
    } catch (e) {
      deviceData = {'Error': 'Failed to get platform version: ${e.toString()}'};
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
    return {
      'Model': info.model,
      'Brand': info.brand,
      'Device': info.device,
      'Manufacturer': info.manufacturer,
      'Product': info.product,
      'Android Version': info.version.release,
      'SDK Version': info.version.sdkInt,
      'Hardware': info.hardware,
      'Type': info.type,
      'Board': info.board,
      'Bootloader': info.bootloader,
      'Display': info.display,
      'Fingerprint': info.fingerprint,
      'Security Patch': info.version.securityPatch,
      'Device Type': info.isPhysicalDevice ? 'Physical' : 'Virtual',
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
    return {
      'Name': info.name,
      'Model': info.model,
      'System Name': info.systemName,
      'System Version': info.systemVersion,
      'Device': info.utsname.machine,
      'Localized Model': info.localizedModel,
      'Identifier for Vendor': info.identifierForVendor,
      'Device Type': info.isPhysicalDevice ? 'Physical' : 'Virtual',
      'Kernel Version': info.utsname.version,
      'Release Version': info.utsname.release,
      'System Architecture': info.utsname.sysname,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo info) {
    return {
      'Computer Name': info.computerName,
      'Host Name': info.hostName,
      'System Version': info.osRelease,
      'Model': info.model,
      'Kernel Version': info.kernelVersion,
      'CPU Architecture': info.arch,
      'Active CPUs': info.activeCPUs,
      'Memory Size':
          '${(info.memorySize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
      'System Build Number': info.systemGUID,
    };
  }

  Future<Map<String, dynamic>> _readWindowsDeviceInfo() async {
    await WindowsSystemInfo.initWindowsInfo(
      requiredValues: [WindowsSystemInfoFeat.all],
    );
    if (await WindowsSystemInfo.isInitilized) {
      final deviceInfo = <String, dynamic>{
        'User Name': WindowsSystemInfo.userName,
        'Device Name': WindowsSystemInfo.deviceName,
      };

      final staticInfo = WindowsSystemInfo.windowsSystemStaticInformation;

      if (staticInfo != null) {
        deviceInfo.addAll({
          'staticInfo': staticInfo,
        });
      }
      if (WindowsSystemInfo.os != null) {
        deviceInfo.addAll({
          'OS Architecture': WindowsSystemInfo.is64bit ? '64-bit' : '32-bit',
        });
      }

      if (WindowsSystemInfo.system != null) {
        deviceInfo.addAll({
          'Manufacturer': WindowsSystemInfo.system?.manufacturer,
          'Model': WindowsSystemInfo.system?.model,
        });
      }

      if (WindowsSystemInfo.chassis != null) {
        deviceInfo.addAll({
          'Chassis': WindowsSystemInfo.chassis,
        });
      }

      deviceInfo['Processor'] = WindowsSystemInfo.cpu;

      return deviceInfo;
    } else {
      return {'Error': 'Failed to initialize Windows System Info'};
    }
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo info) {
    return {
      'Name': info.name,
      'Version': info.version,
      'ID': info.id,
      'Pretty Name': info.prettyName,
      'Build ID': info.buildId,
      'Variant': info.variant,
      'Variant ID': info.variantId,
      'Machine ID': info.machineId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: _initPlatformState,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: _deviceData.keys.map(
            (String property) {
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(
                    property,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    '${_deviceData[property]}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      height: 1.5,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}