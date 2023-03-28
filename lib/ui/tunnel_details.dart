import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wireguard_flutter/repository/models.dart';
import 'package:wireguard_flutter/ui/common/text_styles.dart';

import '../log.dart';
import 'common/texts.dart';
import 'ui_constants.dart';

const initName = 'my-tunnel';
const initAddress = "10.10.0.4/32";
const initPort = "1280";
const initDnsServer = "8.8.8.8";
const initPrivateKey = "2P23r4Oj0wZEoMdXwJv3gVOYCkhPCrnG0AtRQ1G/m1U=";
const initAllowedIp = "0.0.0.0/0";
const initPublicKey = "WPte+VNVZknRVDEi2OmlUzBL6GwM5d06NxQAKSDAsws=";
const initEndpoint = "74.208.203.188:443";

class TunnelDetails extends StatefulWidget {
  @override
  createState() => _TunnelDetailsState();
}

class _TunnelDetailsState extends State<TunnelDetails> {
  static const platform = const MethodChannel('tark.pro/wireguard-flutter');
  String _name = initName;
  String _address = initAddress;
  String _listenPort = initPort;
  String _dnsServer = initDnsServer;
  String _privateKey = initPrivateKey;
  String _peerAllowedIp = initAllowedIp;
  String _peerPublicKey = initPublicKey;
  String _peerEndpoint = initEndpoint;
  bool _connected = false;
  bool _scrolledToTop = true;
  bool _gettingStats = true;
  Stats? _stats;
  Timer? _gettingStatsTimer;

  int sliderIndex = -1;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStateChange':
          try {
            final stats = StateChangeData.fromJson(jsonDecode(call.arguments));
            if (stats.tunnelState) {
              setState(() => _connected = true);
              _startGettingStats(context);
            } else {
              setState(() => _connected = false);
              _stopGettingStats();
            }
          } catch (e) {
            l('initState', 'error', e);
          }

          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            setState(() => _scrolledToTop = notification.metrics.pixels == 0);
            return true;
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'V-Tell VPN',
                          style: TextStyles.regular14,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SvgPicture.asset('assets/icon/burger.svg'),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/netherlands.svg',
                          ),
                          SizedBox(width: 35),
                          Text('Netherlands', style: TextStyles.regular16,),
                          const Spacer(),
                          CupertinoSwitch(
                            value: sliderIndex == index,
                            onChanged: (res) {
                              setState(() {
                                res ? sliderIndex = index : sliderIndex = -1;
                              });
                              _setTunnelState(context);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _setTunnelState(BuildContext context) async {
    try {
      final result = await platform.invokeMethod(
        'setState',
        jsonEncode(SetStateParams(
          state: !_connected,
          tunnel: Tunnel(
            name: _name,
            address: _address,
            dnsServer: _dnsServer,
            listenPort: _listenPort,
            peerAllowedIp: _peerAllowedIp,
            peerEndpoint: _peerEndpoint,
            peerPublicKey: _peerPublicKey,
            privateKey: _privateKey,
          ),
        ).toJson()),
      );
      /*if (result == true) {
        setState(() => _connected = !_connected);
      }*/
    } on PlatformException catch (e) {
      l('_setState', e.toString());
      _showError(context, e.toString());
    }
  }

  _getTunnelNames(BuildContext context) async {
    try {
      final result = await platform.invokeMethod('getTunnelNames');
    } on PlatformException catch (e) {
      l('_getTunnelNames', e.toString());
      _showError(context, e.toString());
    }
  }

  _showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Texts.semiBold(error, color: Colors.white),
      backgroundColor: Colors.red[400],
    ));
  }

  _showSuccess(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Texts.semiBold(
        error,
        color: Colors.white,
      ),
      backgroundColor: Colors.green[500],
    ));
  }

  _startGettingStats(BuildContext context) {
    _gettingStatsTimer?.cancel();
    _gettingStatsTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!_gettingStats) {
        timer.cancel();
      }
      try {
        final result = await platform.invokeMethod('getStats', _name);
        final stats = Stats.fromJson(jsonDecode(result));
        setState(() => _stats = stats);
      } catch (e) {
        // can't get scaffold context from initState. todo: fix this
        //_showError(context, e.toString());
      }
    });
  }

  _stopGettingStats() {
    setState(() => _gettingStats = false);
  }

  Widget _input({
    required String hint,
    required ValueChanged<String> onChanged,
    bool enabled = true,
    required TextEditingController controller,
  }) {
    return Container(
      padding: AppPadding.horizontalSmall,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        border: Border.fromBorderSide(
          BorderSide(
            color: enabled ? Colors.black12 : Colors.black.withOpacity(0.05),
            width: 1.0,
          ),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          const Vertical.micro(),
          Row(
            children: [
              Texts(
                hint,
                textSize: AppSize.fontSmall,
                color: Colors.black38,
                height: 1.5,
              ),
            ],
          ),
          TextField(
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
            ),
            style: GoogleFonts.openSans(
              textStyle: TextStyle(fontWeight: FontWeight.w600),
              height: 1.0,
            ),
            controller: controller,
            onChanged: onChanged,
          ),
          const Vertical.micro(),
        ],
      ),
    );
  }

  Widget _divider(String title) {
    return Padding(
      padding: AppPadding.verticalNormal,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: AppPadding.rightNormal,
              child: Container(
                height: 0.5,
                color: Colors.black.withOpacity(0.08),
              ),
            ),
          ),
          Texts.smallVery(
            title.toUpperCase(),
            color: Colors.black45,
          ),
          Expanded(
            child: Padding(
              padding: AppPadding.leftNormal,
              child: Container(
                height: 0.5,
                color: Colors.black.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsWidget(Stats? stats) {
    return Container(
      padding: AppPadding.horizontalSmall,
      //height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(
          BorderSide(
            color: Colors.black12,
            width: 1.0,
          ),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Vertical.micro(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Texts(
                      'Upload',
                      textSize: AppSize.fontSmall,
                      color: Colors.black38,
                      height: 1.5,
                    ),
                  ],
                ),
                Texts.semiBold(
                    _formatBytes(stats?.totalUpload.toInt() ?? 0, 0)),
                const Vertical.medium(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Vertical.micro(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Texts(
                      'Download',
                      textSize: AppSize.fontSmall,
                      color: Colors.black38,
                      height: 1.5,
                    ),
                  ],
                ),
                Texts.semiBold(
                    _formatBytes(stats?.totalDownload.toInt() ?? 0, 0)),
                const Vertical.medium(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}
