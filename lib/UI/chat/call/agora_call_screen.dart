import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/chat/agora_call_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_text.dart';

class AgoraCallScreen extends StatefulWidget {
  final int uid;
  final String token;
  final String appId;
  final bool isVideo;
  final int receiverId;
  final String channelName;

  const AgoraCallScreen({
    super.key,
    required this.uid,
    required this.token,
    required this.appId,
    required this.isVideo,
    required this.receiverId,
    required this.channelName,
  });

  @override
  State<AgoraCallScreen> createState() => _AgoraCallScreenState();
}

class _AgoraCallScreenState extends State<AgoraCallScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  AgoraCallProvider? _callProvider;
  bool _isDisposed = false;
  bool _isNavigatingBack = false;
  bool _isCallConnected = false;

  String get _formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startTimer() {
    if (_timer == null && !_isDisposed && !_isCallConnected) {
      _isCallConnected = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_isDisposed && mounted) {
          setState(() {
            _secondsElapsed++;
          });
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isCallConnected = false;
  }

  void _resetTimer() {
    _secondsElapsed = 0;
    _stopTimer();
  }

  void _handleRemoteEndCall() {
    debugPrint("🔴 Remote end call triggered in CallScreen");

    if (_isNavigatingBack || _isDisposed) {
      debugPrint("🔴 Already navigating back or disposed, returning");
      return;
    }

    _isNavigatingBack = true;
    _resetTimer();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_isDisposed) {
        debugPrint("🔴 Navigating back due to remote end call");
        Get.back();
      }
    });
  }

  Future<void> _handleLocalEndCall() async {
    if (_isNavigatingBack) return;

    _isNavigatingBack = true;
    debugPrint("🔴 Local end call triggered");

    try {
      if (_callProvider != null) {
        // Send end signal first
        await _callProvider!.sendEndCallSignal();

        // Then end the call
        await _callProvider!.endCall(
          onCallEnded: () {
            debugPrint("🔵 Local call ended callback");
            _resetTimer();
            if (mounted && !_isDisposed) {
              Get.back();
            }
          },
        );
      }
    } catch (e) {
      debugPrint("🔴 Error ending call: $e");
      _resetTimer();
      if (mounted && !_isDisposed) {
        Get.back();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint("🟢 CallScreen initState");
  }

  @override
  void dispose() {
    debugPrint("🔴 CallScreen dispose");
    _isDisposed = true;
    _resetTimer();

    // Clean up provider if call hasn't ended
    if (_callProvider != null && !_callProvider!.callEnded) {
      _callProvider!.endCall();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _handleLocalEndCall();
        }
      },
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: ChangeNotifierProvider(
          create: (_) {
            debugPrint("🟡 Creating CallProvider");
            final provider = AgoraCallProvider();
            _callProvider = provider;

            // Initialize Agora with a small delay
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!_isDisposed) {
                provider.initializeAgora(
                  uid: widget.uid,
                  token: widget.token,
                  appId: widget.appId,
                  isVideo: widget.isVideo,
                  channelName: widget.channelName,
                  onRemoteEndCall: _handleRemoteEndCall,
                );
              }
            });

            return provider;
          },
          child: Consumer<AgoraCallProvider>(
            builder: (context, provider, _) {
              _callProvider = provider;
              // Start timer when both users are connected
              if (provider.localUserJoined &&
                  provider.remoteUid != null &&
                  !_isCallConnected &&
                  !provider.callEnded) {
                debugPrint("📱 Starting timer - both users connected");
                _startTimer();
              }

              // Stop timer when call ends
              if (provider.callEnded && _timer != null) {
                debugPrint("📱 Stopping timer - call ended");
                _resetTimer();
              }

              return SafeArea(
                child: Stack(
                  children: [
                    // Main content area
                    Center(child: _buildMainContent(provider)),

                    // Local video preview for video calls (small window in corner)
                    if (provider.isVideoCall &&
                        provider.isEngineReady &&
                        provider.engine != null &&
                        provider.localUserJoined)
                      Positioned(
                        top: 50,
                        right: 20,
                        width: 120,
                        height: 160,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blackColor,
                            border: Border.all(
                              width: 2,
                              color: AppColors.whiteColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: provider.engine!,
                                canvas: const VideoCanvas(
                                  uid: 0,
                                  mirrorMode:
                                      VideoMirrorModeType
                                          .videoMirrorModeEnabled,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Call status info
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorsScheme.onSecondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              text: _getCallStatus(provider),
                              color: context.colorsScheme.onPrimary,
                            ),

                            if (provider.localUserJoined &&
                                provider.remoteUid != null &&
                                !provider.callEnded) ...[
                              const SizedBox(height: 4),
                              AppText(
                                fontSize: 14,
                                text: _formattedTime,
                                color: context.colorsScheme.onPrimary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Control buttons
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Mute button
                          _buildControlButton(
                            heroTag: "mute",
                            icon: provider.muted ? Icons.mic_off : Icons.mic,
                            backgroundColor:
                                provider.muted ? Colors.red : Colors.grey[800]!,
                            onPressed:
                                provider.callEnded
                                    ? null
                                    : () {
                                      debugPrint("📱 Mute button pressed");
                                      provider.toggleMute();
                                    },
                          ),

                          // End call button
                          _buildControlButton(
                            isLarge: true,
                            heroTag: "end",
                            icon: Icons.call_end,
                            backgroundColor: Colors.red,
                            onPressed:
                                provider.callEnded
                                    ? null
                                    : () {
                                      debugPrint("📱 End call button pressed");
                                      _handleLocalEndCall();
                                    },
                          ),
                          // Camera switch button (for video calls only)
                          if (provider.isVideoCall)
                            _buildControlButton(
                              onPressed:
                                  provider.callEnded
                                      ? null
                                      : () {
                                        debugPrint(
                                          "📱 Camera switch button pressed",
                                        );
                                        provider.switchCamera();
                                      },
                              icon: Icons.cameraswitch,
                              backgroundColor: Colors.grey[800]!,
                              heroTag: "switch",
                            )
                          else
                            // Placeholder to maintain spacing for audio calls
                            const SizedBox(width: 60),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(AgoraCallProvider provider) {
    if (!provider.isEngineReady) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CommonLoader(),
          const SizedBox(height: 20),

          AppText(text: provider.connectionStatus, fontSize: 16),
        ],
      );
    }

    if (provider.isVideoCall) {
      return _buildVideoCallContent(provider);
    } else {
      return _buildAudioCallContent(provider);
    }
  }

  Widget _buildVideoCallContent(AgoraCallProvider provider) {
    if (provider.remoteUid != null &&
        !provider.callEnded &&
        provider.engine != null) {
      // Show remote user's video
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: provider.engine!,
            canvas: VideoCanvas(
              uid: provider.remoteUid,
              mirrorMode: VideoMirrorModeType.videoMirrorModeDisabled,
            ),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          size: 100,
          provider.callEnded ? Icons.call_end : Icons.videocam,
          color: provider.callEnded ? AppColors.errorColor : Colors.white54,
        ),
        AppText(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.justify,
          text:
              provider.callEnded
                  ? "Video call ended"
                  : "Waiting for remote user to join...",
        ),
        const SizedBox(height: 10),
        AppText(
          fontSize: 14,
          color: Colors.white70,
          textAlign: TextAlign.center,
          text: provider.connectionStatus,
        ),
      ],
    );
  }

  Widget _buildAudioCallContent(AgoraCallProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          size: 100,
          provider.callEnded ? Icons.call_end_rounded : Icons.call_sharp,
          color: provider.callEnded ? AppColors.errorColor : Colors.green,
        ),
        const SizedBox(height: 20),
        AppText(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor,
          text: provider.callEnded ? "Call ended" : "Audio Call",
        ),
        const SizedBox(height: 10),
        AppText(
          fontSize: 16,
          color: Colors.white70,
          textAlign: TextAlign.center,
          text: provider.connectionStatus,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    bool isLarge = false,
    required IconData icon,
    required String heroTag,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    return FloatingActionButton(
      elevation: 8,
      mini: !isLarge,
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      child: Icon(icon, color: AppColors.whiteColor, size: isLarge ? 32 : 24),
    );
  }

  String _getCallStatus(AgoraCallProvider provider) {
    if (provider.callEnded) return "Call Ended";
    if (!provider.localUserJoined) return "Connecting...";
    if (provider.remoteUid != null) return "Connected";
    return "Waiting for user...";
  }
}
