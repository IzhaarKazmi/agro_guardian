# TensorFlow Lite GPU optional classes (missing on some devices/configs)
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.gpu.**

# Keep TFLite classes used by the plugin
-keep class org.tensorflow.lite.** { *; }
-keep class sq.flutter.tflite.** { *; }
