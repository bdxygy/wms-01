import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../generated/app_localizations.dart';
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

class _BluetoothSetupDialogState extends State<BluetoothSetupDialog> 
    with TickerProviderStateMixin {
  final PrintLauncher _printLauncher = PrintLauncher();
  
  List<BluetoothInfo> _pairedDevices = [];
  List<BluetoothInfo> _nearbyDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectingToMac;
  String? _errorMessage;
  int _currentTabIndex = 0;
  
  late AnimationController _scanAnimationController;
  late AnimationController _connectionAnimationController;
  late Animation<double> _scanRotationAnimation;
  late Animation<double> _connectionPulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialDevices();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _connectionAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _connectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scanRotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.linear,
    ));
    
    _connectionPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _connectionAnimationController,
      curve: Curves.easeInOut,
    ));
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
    
    // Start scan animation
    _scanAnimationController.repeat();

    try {
      // For Android/iOS, we use the same API as paired devices
      // but we'll show all available devices
      final devices = await _printLauncher.getPairedDevices();
      
      if (mounted) {
        setState(() {
          _nearbyDevices = devices;
          _isScanning = false;
        });
        _scanAnimationController.stop();
        _scanAnimationController.reset();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = 'Failed to scan for devices: $e';
        });
        _scanAnimationController.stop();
        _scanAnimationController.reset();
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
    
    // Start connection animation
    _connectionAnimationController.repeat(reverse: true);

    try {
      final connected = await _printLauncher.connectToPrinter(device.macAdress);
      
      if (connected) {
        if (mounted) {
          // Stop animation and show success
          _connectionAnimationController.stop();
          _connectionAnimationController.reset();
          
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected to ${device.name.isNotEmpty ? device.name : device.macAdress}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          // Call the callback if provided
          widget.onDeviceConnected?.call(device);

          // Auto print test page if requested
          if (widget.autoConnectAndPrint) {
            await _printTestPage();
          }

          // Close the dialog with a slight delay for better UX
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && context.mounted) {
            Navigator.of(context).pop(device);
          }
        }
      } else {
        throw Exception('Connection failed');
      }
    } catch (e) {
      if (mounted) {
        _connectionAnimationController.stop();
        _connectionAnimationController.reset();
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
    final l10n = AppLocalizations.of(context)!;
    try {
      await _printLauncher.printTestPage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bluetooth_test_print_success),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bluetooth_test_print_failed(e.toString())),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showManualConnectionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController macController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bluetooth_manual_connection,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.bluetooth_enter_mac_manually,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Information card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.bluetooth_mac_address_help,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Form fields
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.bluetooth_printer_name_optional,
                  hintText: l10n.bluetooth_printer_name_hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.print_outlined),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: macController,
                decoration: InputDecoration(
                  labelText: l10n.bluetooth_mac_address_required,
                  hintText: '00:11:22:33:44:55',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.bluetooth_outlined),
                  helperText: l10n.bluetooth_mac_format,
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
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.common_button_cancel),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final mac = macController.text.trim();
                      if (mac.isEmpty || !RegExp(r'^[0-9A-Fa-f:]{17}$').hasMatch(mac)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.bluetooth_invalid_mac_address),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      
                      Navigator.of(context).pop({
                        'name': nameController.text.trim().isEmpty 
                          ? l10n.bluetooth_manual_printer_default_name
                          : nameController.text.trim(),
                        'mac': mac.toUpperCase(),
                      });
                    },
                    icon: const Icon(Icons.bluetooth_connected),
                    label: Text(l10n.bluetooth_connect),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    final l10n = AppLocalizations.of(context)!;
    
    if (devices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.bluetooth_disabled,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                showRefresh ? l10n.bluetooth_no_devices_found : l10n.bluetooth_no_paired_devices,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                showRefresh 
                  ? l10n.bluetooth_make_printer_discoverable
                  : l10n.bluetooth_pair_printer_first,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (showRefresh) ...[
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scanForNearbyDevices,
                  icon: _isScanning 
                    ? AnimatedBuilder(
                        animation: _scanRotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _scanRotationAnimation.value * 2 * 3.14159,
                            child: const Icon(Icons.bluetooth_searching, size: 20),
                          );
                        },
                      )
                    : const Icon(Icons.refresh),
                  label: Text(_isScanning ? l10n.bluetooth_scanning : l10n.bluetooth_scan_again),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Manual connection option
              OutlinedButton.icon(
                onPressed: _showManualConnectionDialog,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.bluetooth_enter_mac_address),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.bluetooth_manual_connection_help,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final device = devices[index];
        final isConnecting = _connectingToMac == device.macAdress;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isConnecting ? null : () => _connectToDevice(device),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Device icon with animation
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: isConnecting
                        ? AnimatedBuilder(
                            animation: _connectionPulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _connectionPulseAnimation.value,
                                child: Icon(
                                  Icons.bluetooth_connected,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              );
                            },
                          )
                        : Icon(
                            Icons.print_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Device info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name.isNotEmpty ? device.name : l10n.bluetooth_unknown_device,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            device.macAdress,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (isConnecting) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.bluetooth_connecting,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ] else if (showRefresh) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.bluetooth_tap_to_connect,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Connection status indicator
                    if (!isConnecting)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.bluetooth,
                          color: Colors.green[600],
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bluetooth_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bluetooth_setup_title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.bluetooth_setup_subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isConnecting 
                      ? null 
                      : () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.bluetooth_setup_instructions,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Modern Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        onTap: () => setState(() => _currentTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _currentTabIndex == 0 
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.devices_outlined,
                                color: _currentTabIndex == 0 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  l10n.bluetooth_paired_tab(_pairedDevices.length),
                                  style: TextStyle(
                                    color: _currentTabIndex == 0 
                                      ? Theme.of(context).primaryColor 
                                      : Colors.grey[600],
                                    fontWeight: _currentTabIndex == 0 
                                      ? FontWeight.bold 
                                      : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        onTap: () => setState(() => _currentTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _currentTabIndex == 1 
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isScanning
                                ? AnimatedBuilder(
                                    animation: _scanRotationAnimation,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _scanRotationAnimation.value * 2 * 3.14159,
                                        child: Icon(
                                          Icons.bluetooth_searching,
                                          color: _currentTabIndex == 1 
                                            ? Theme.of(context).primaryColor 
                                            : Colors.grey[600],
                                          size: 20,
                                        ),
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.bluetooth_outlined,
                                    color: _currentTabIndex == 1 
                                      ? Theme.of(context).primaryColor 
                                      : Colors.grey[600],
                                    size: 20,
                                  ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _isScanning 
                                    ? l10n.bluetooth_scanning 
                                    : l10n.bluetooth_available_tab(_nearbyDevices.length),
                                  style: TextStyle(
                                    color: _currentTabIndex == 1 
                                      ? Theme.of(context).primaryColor 
                                      : Colors.grey[600],
                                    fontWeight: _currentTabIndex == 1 
                                      ? FontWeight.bold 
                                      : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: [
                    // Paired devices tab
                    _buildDeviceList(_pairedDevices, showRefresh: false),
                    // Nearby devices tab  
                    _buildDeviceList(_nearbyDevices, showRefresh: true),
                  ],
                ),
              ),
            ),

            // Modern Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bluetooth_error_title,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Modern Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _isConnecting 
                      ? null 
                      : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.common_button_cancel),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const Spacer(),
                  if (_currentTabIndex == 1)
                    ElevatedButton.icon(
                      onPressed: _isScanning || _isConnecting 
                        ? null 
                        : _scanForNearbyDevices,
                      icon: _isScanning 
                        ? AnimatedBuilder(
                            animation: _scanRotationAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _scanRotationAnimation.value * 2 * 3.14159,
                                child: const Icon(Icons.bluetooth_searching, size: 18),
                              );
                            },
                          )
                        : const Icon(Icons.refresh, size: 18),
                      label: Text(_isScanning ? l10n.bluetooth_scanning : l10n.bluetooth_refresh),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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