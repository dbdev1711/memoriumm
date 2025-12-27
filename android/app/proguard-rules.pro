# Evita que ProGuard doni avisos (warnings) sobre classes de Google que no pot trobar
-dontwarn com.google.android.gms.**
-dontwarn com.google.ads.**

# Manté les interfícies de JavaScript (molt important per a anuncis web/interstitials)
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
