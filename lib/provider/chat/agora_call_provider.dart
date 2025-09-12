import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallProvider extends ChangeNotifier {
  int? remoteUid;
  int? _dataStreamId;
  bool muted = false;
  bool callEnded = false;
  bool isVideoCall = false;
  bool isEngineReady = false;
  bool localUserJoined = false;

  String connectionStatus = "Initializing...";

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  Timer? _signalTimer;
  bool _isDisposing = false;
  Function? _onRemoteEndCall;
  bool _isInitializing = false;

  Future<void> createDataStream() async {
    if (_engine != null && !callEnded && !_isDisposing) {
      try {
        _dataStreamId = await _engine!.createDataStream(
          const DataStreamConfig(syncWithAudio: false, ordered: true),
        );
        debugPrint("🟢 Data stream created successfully: $_dataStreamId");
      } catch (e) {
        debugPrint("🔴 Error creating data stream: $e");
        // Retry after a delay
        Timer(const Duration(milliseconds: 1000), () {
          if (!callEnded && !_isDisposing) {
            createDataStream();
          }
        });
      }
    }
  }

  /// Initialize Agora
  Future<void> initializeAgora({
    required int uid,
    required bool isVideo,
    required String appId,
    required String token,
    required String channelName,
    required Function onRemoteEndCall,
  }) async {
    if (_isInitializing || callEnded) {
      debugPrint("⚠️ Already initializing or call ended, skipping");
      return;
    }

    _isInitializing = true;
    isVideoCall = isVideo;
    _onRemoteEndCall = onRemoteEndCall;

    debugPrint("🟡 Starting Agora initialization...");
    debugPrint("🟡 Channel: $channelName, UID: $uid, Video: $isVideo");

    try {
      // Request permissions first
      final permissions = [Permission.microphone];
      if (isVideo) permissions.add(Permission.camera);

      Map<Permission, PermissionStatus> status = await permissions.request();

      if (status[Permission.microphone] != PermissionStatus.granted ||
          (isVideo && status[Permission.camera] != PermissionStatus.granted)) {
        debugPrint("🔴 Permission denied");
        connectionStatus = "Permission denied";
        _isInitializing = false;
        notifyListeners();
        return;
      }

      // Create engine
      _engine = createAgoraRtcEngine();

      // Initialize engine
      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
 
      debugPrint("🟢 Agora engine initialized");

      // Configure engine before joining
      if (isVideo) {
        await _engine!.enableVideo();
        await _engine!.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            bitrate: 0,
            frameRate: 15,
            dimensions: VideoDimensions(width: 640, height: 480),
          ),
        );
      } else {
        await _engine!.disableVideo();
      }

      await _engine!.enableAudio();
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Set audio profile
      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming,
      );

      // Register event handlers
     

      _engine!.registerEventHandler(
        
        RtcEngineEventHandler(
          
          onJoinChannelSuccess: (connection, elapsed) async {
            debugPrint("🟢 Local user joined channel successfully");
            localUserJoined = true;
            connectionStatus =
                isVideo ? "Video call connected" : "Audio call connected";
            isEngineReady = true;
            notifyListeners();

            // Create data stream after successful join
            await Future.delayed(const Duration(milliseconds: 1000));
            await createDataStream();
          },

          onUserJoined: (connection, uid, elapsed) {
            if (!callEnded && !_isDisposing) {
              debugPrint("🟢 Remote user joined: $uid");
              remoteUid = uid;
              connectionStatus = "Remote user connected";
              notifyListeners();
            }
          },

          onUserOffline: (connection, uid, reason) {
            debugPrint("🔴 User $uid went offline, reason: $reason");
            if (remoteUid == uid && !callEnded && !_isDisposing) {
              debugPrint("🔴 Remote user left the call");
              _handleRemoteUserLeft();
            }
          },

          onRemoteVideoStateChanged: (
            connection,
            remoteUid,
            state,
            reason,
            elapsed,
          ) {
            debugPrint(
              "🟡 Remote video state changed: $state, reason: $reason",
            );
            notifyListeners();
          },

          onRemoteAudioStateChanged: (
            connection,
            remoteUid,
            state,
            reason,
            elapsed,
          ) {
            debugPrint(
              "🟡 Remote audio state changed: $state, reason: $reason",
            );
            notifyListeners();
          },

          onError: (err, msg) {
            debugPrint("🔴 Agora Error: $err - $msg");
            connectionStatus = "Connection error: $msg";
            notifyListeners();
          },

          onConnectionStateChanged: (connection, state, reason) {
            debugPrint("🟡 Connection state changed: $state, reason: $reason");
            if (state == ConnectionStateType.connectionStateFailed) {
              connectionStatus = "Connection failed";
              notifyListeners();
            }
          },

          onStreamMessage: (
            connection,
            remoteUid,
            streamId,
            data,
            length,
            sentTs,
          ) {
            try {
              final msg = String.fromCharCodes(data);

              debugPrint(
                "📨 Received stream message: '$msg' from user: $remoteUid",
              );

              if (msg == "END_CALL" && !callEnded && !_isDisposing) {
                debugPrint("🔴 Received END_CALL signal from remote user");
                _handleRemoteEndCall();
              }
            } catch (e) {
              debugPrint("🔴 Error parsing stream message: $e");
            }
          },

          onStreamMessageError: (
            connection,
            remoteUid,
            streamId,
            error,
            missed,
            cached,
          ) {
            debugPrint("🔴 Stream message error: $error");
          },
        ),
      );

      // Start preview for video calls
      if (isVideo) {
        await _engine!.startPreview();
      }

      // Join channel
      debugPrint("🟡 Joining channel: $channelName");
      await _engine!.joinChannel(
        token: token.isEmpty ? "" : token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(
          publishCameraTrack: isVideo,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: isVideo,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _isInitializing = false;

      debugPrint("🟢 Agora initialization completed successfully");
    } catch (e) {
      debugPrint("🔴 Error in Agora initialization: $e");
      connectionStatus = "Initialization failed: $e";
      _isInitializing = false;
      notifyListeners();
    }
  }

  void _handleRemoteUserLeft() {
    debugPrint("🔴 Handling remote user left");
    if (!callEnded && !_isDisposing) {
      remoteUid = null;
      connectionStatus = "Remote user disconnected";
      notifyListeners();

      // Don't immediately end call, wait a bit for reconnection
      Timer(const Duration(seconds: 5), () {
        if (!callEnded && remoteUid == null && !_isDisposing) {
          debugPrint("🔴 Remote user didn't reconnect, ending call");
          _triggerCallEnd();
        }
      });
    }
  }

  void _handleRemoteEndCall() {
    debugPrint("🔴 Handling remote end call signal");
    if (!callEnded && !_isDisposing) {
      _triggerCallEnd();
    }
  }

  void _triggerCallEnd() {
    if (!callEnded && !_isDisposing) {
      debugPrint("🔴 Triggering call end");
      callEnded = true;
      connectionStatus = "Call ended";
      notifyListeners();

      // Clean up and notify UI
      _cleanup().then((_) {
        _onRemoteEndCall?.call();
      });
    }
  }

  void toggleMute() {
    if (!callEnded && !_isDisposing && _engine != null) {
      muted = !muted;
      _engine!.muteLocalAudioStream(muted);
      debugPrint("🔵 Mute toggled: $muted");
      notifyListeners();
    }
  }

  Future<void> switchCamera() async {
    if (isVideoCall && !callEnded && !_isDisposing && _engine != null) {
      try {
        await _engine!.switchCamera();
        debugPrint("🔵 Camera switched");
      } catch (e) {
        debugPrint("🔴 Error switching camera: $e");
      }
    }
  }

  /// Send end call signal to remote user
  Future<void> sendEndCallSignal() async {
    if (_engine != null &&
        _dataStreamId != null &&
        !callEnded &&
        !_isDisposing) {
      try {
        final data = "END_CALL".codeUnits;
        await _engine!.sendStreamMessage(
          streamId: _dataStreamId!,
          data: Uint8List.fromList(data),
          length: data.length,
        );
        debugPrint("🟢 End call signal sent successfully");

        // Wait a bit to ensure signal is sent
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint("🔴 Error sending end call signal: $e");
      }
    } else {
      debugPrint(
        "🔴 Cannot send signal - Engine: ${_engine != null}, StreamId: $_dataStreamId, CallEnded: $callEnded",
      );
    }
  }

  Future<void> _cleanup() async {
    if (_isDisposing) return;
    _isDisposing = true;

    debugPrint("🟡 Starting cleanup process...");

    try {
      // Cancel timers
      _signalTimer?.cancel();
      _signalTimer = null;

      if (_engine != null) {
        // Stop preview if video call
        if (isVideoCall) {
          try {
            await _engine!.stopPreview();
          } catch (e) {
            debugPrint("🔴 Error stopping preview: $e");
          }
        }

        // Leave channel
        debugPrint("🟡 Leaving channel...");
        await _engine!.leaveChannel();
        debugPrint("🟢 Channel left successfully");

        // Wait before releasing engine
        await Future.delayed(const Duration(milliseconds: 500));

        // Release engine
        debugPrint("🟡 Releasing engine...");
        await _engine!.release();
        debugPrint("🟢 Engine released successfully");
      }
    } catch (e) {
      debugPrint("🔴 Error during cleanup: $e");
    }

    // Reset state
    _engine = null;
    _dataStreamId = null;
    localUserJoined = false;
    remoteUid = null;
    isEngineReady = false;

    debugPrint("🟢 Cleanup completed");
  }

  /// End call for both users
  Future<void> endCall({Function? onCallEnded}) async {
    if (callEnded) {
      debugPrint("⚠️ Call already ended, skipping");
      onCallEnded?.call();
      return;
    }

    debugPrint("🔴 Ending call...");
    callEnded = true;
    connectionStatus = "Ending call...";
    notifyListeners();

    // Send end signal first
    await sendEndCallSignal();

    // Then cleanup
    await _cleanup();

    connectionStatus = "Call ended";
    notifyListeners();

    onCallEnded?.call();
    debugPrint("🟢 Call ended successfully");
  }

  @override
  void dispose() {
    debugPrint("🔴 CallProvider disposing...");
    if (!callEnded) {
      callEnded = true;
      _cleanup();
    }
    super.dispose();
  }
}
