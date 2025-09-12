# Keep SLF4J Logger classes
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Some transitive dependencies also need this
-keep class ch.qos.logback.** { *; }
-dontwarn ch.qos.logback.**

# MediaKit specific (depends on build)
-keep class xyz.doikki.videoplayer.** { *; }
-dontwarn xyz.doikki.videoplayer.**

# Prevent removal of generated R classes
-keep class **.R$* { *; }
# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Google Maps
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

# Keep Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; } 