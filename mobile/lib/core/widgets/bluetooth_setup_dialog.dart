import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../services/print_launcher.dart';

class BluetoothSetupDialog extends StatefulWidget {
  final Function(BluetoothInfo)? onDeviceConnected;
  final bool autoConnectAndPrint;

  const BluetoothSetupDialog({
    super.key,
    this.onDeviceConnected,
    this.autoConnectAndPrint = false,
  });

  @override
  State<BluetoothSetupDialog> createState() => _BluetoothSetupDialogState();
}

class _BluetoothSetupDialogState extends State<BluetoothSetupDialog> {
  final PrintLauncher _printLauncher = PrintLauncher();
  
  List<BluetoothInfo> _pairedDevices = [];
  List<BluetoothInfo> _nearbyDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectingToMac;
  String? _errorMessage;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialDevices();
  }

  Future<void> _loadInitialDevices() async {
    await _loadPairedDevices();
    await _scanForNearbyDevices();
  }

  Future<void> _loadPairedDevices() async {
    try {
      final devices = await _printLauncher.getPairedDevices();
      if (mounted) {
        setState(() {
          _pairedDevices = devices;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load paired devices: $e';
        });
      }
    }
  }

  Future<void> _scanForNearbyDevices() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      // For Android/iOS, we use the same API as paired devices
      // but we'll show all available devices
      final devices = await _printLauncher.getPairedDevices();
      
      if (mounted) {
        setState(() {
          _nearbyDevices = devices;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = 'Failed to scan for devices: $e';
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothInfo device) async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _connectingToMac = device.macAdress;
      _errorMessage = null;
    });

    try {
      final connected = await _printLauncher.connectToPrinter(device.macAdress);
      
      if (connected) {
        if (mounted) {
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected to ${device.name.isNotEmpty ? device.name : device.macAdress}'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Call the callback if provided
          widget.onDeviceConnected?.call(device);

          // Auto print test page if requested
          if (widget.autoConnectAndPrint) {
            await _printTestPage();
          }

          // Close the dialog
          if (mounted && context.mounted) {
            Navigator.of(context).pop(device);
          }
        }
      } else {
        throw Exception('Connection failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to connect to ${device.name}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectingToMac = null;
        });
      }
    }
  }

  Future<void> _printTestPage() async {
    try {
      await _printLauncher.printTestPage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test page printed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print test page: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _showManualConnectionDialog() async {
    final TextEditingController macController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Printer Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your thermal printer details manually. You can find the MAC address in your printer settings or on a label.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Printer Name (Optional)',
                hintText: 'e.g., My Thermal Printer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: macController,
              decoration: const InputDecoration(
                labelText: 'MAC Address *',
                hintText: 'e.g., 00:11:22:33:44:55',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                // Auto-format MAC address with colons
                String formatted = value.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
                if (formatted.length > 12) formatted = formatted.substring(0, 12);
                
                String result = '';
                for (int i = 0; i < formatted.length; i += 2) {
                  if (i > 0) result += ':';
                  result += formatted.substring(i, i + 2 > formatted.length ? formatted.length : i + 2);
                }
                
                if (result != value) {
                  macController.value = TextEditingValue(
                    text: result.toUpperCase(),
                    selection: TextSelection.collapsed(offset: result.length),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'MAC address format: XX:XX:XX:XX:XX:XX',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final mac = macController.text.trim();
              if (mac.isEmpty || !RegExp(r'^[0-9A-Fa-f:]{17}$').hasMatch(mac)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid MAC address'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop({
                'name': nameController.text.trim().isEmpty 
                  ? 'Manual Printer' 
                  : nameController.text.trim(),
                'mac': mac.toUpperCase(),
              });
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );

    if (result != null) {
      // Create a fake BluetoothInfo object and connect
      final fakeDevice = BluetoothInfo(
        name: result['name']!,
        macAdress: result['mac']!,
      );
      
      await _connectToDevice(fakeDevice);
    }
  }

  Widget _buildDeviceList(List<BluetoothInfo> devices, {required bool showRefresh}) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              showRefresh ? 'No devices found' : 'No paired devices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              showRefresh 
                ? 'Make sure your printer is turned on and discoverable'
                : 'Pair your printer in device Bluetooth settings first',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (showRefresh) ...[
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanForNearbyDevices,
                icon: _isScanning 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
              ),
              const SizedBox(height: 12),
            ],
            // Manual connection option
            OutlinedButton.icon(
              onPressed: _showManualConnectionDialog,
              icon: const Icon(Icons.edit),
              label: const Text('Enter MAC Address'),
            ),
            const SizedBox(height: 8),
            Text(
              'If you\'re having permission issues, you can enter your printer\'s MAC address manually',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final isConnecting = _connectingToMac == device.macAdress;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.print,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              device.name.isNotEmpty ? device.name : 'Unknown Device',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MAC: ${device.macAdress}'),
                if (showRefresh)
                  const Text(
                    'Tap to connect',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: isConnecting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.bluetooth),
            onTap: _isConnecting ? null : () => _connectToDevice(device),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Setup Thermal Printer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isConnecting 
                      ? null 
                      : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Select your thermal printer from the list below. Make sure your printer is turned on and nearby.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentTabIndex == 0 
                                ? Theme.of(context).primaryColor 
                                : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices,
                              color: _currentTabIndex == 0 
                                ? Theme.of(context).primaryColor 
                                : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Paired (${_pairedDevices.length})',
                              style: TextStyle(
                                color: _currentTabIndex == 0 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[600],
                                fontWeight: _currentTabIndex == 0 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentTabIndex == 1 
                                ? Theme.of(context).primaryColor 
                                : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                              color: _currentTabIndex == 1 
                                ? Theme.of(context).primaryColor 
                                : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isScanning ? 'Scanning...' : 'Available (${_nearbyDevices.length})',
                              style: TextStyle(
                                color: _currentTabIndex == 1 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[600],
                                fontWeight: _currentTabIndex == 1 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  // Paired devices tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDeviceList(_pairedDevices, showRefresh: false),
                  ),
                  // Nearby devices tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDeviceList(_nearbyDevices, showRefresh: true),
                  ),
                ],
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _isConnecting 
                      ? null 
                      : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  if (_currentTabIndex == 1)
                    ElevatedButton.icon(
                      onPressed: _isScanning || _isConnecting 
                        ? null 
                        : _scanForNearbyDevices,
                      icon: _isScanning 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                      label: Text(_isScanning ? 'Scanning...' : 'Refresh'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}