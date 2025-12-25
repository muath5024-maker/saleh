import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_icons.dart';

/// ============================================================================
/// Error Boundary - معالØ¬ الأخطاء الشامل
/// ============================================================================
///
/// يلتقط الأخطاء غير المعالØ¬Ø© ÙÙŠ التطبيق ويعرض واجهة بديلة
/// بدلاً من crash التطبيق
///
/// الاستخدام:
/// ```dart
/// ErrorBoundary(
///   child: MyWidget(),
///   onError: (error, stackTrace) => logError(error),
/// )
/// ```

/// Error Boundary Widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
  }

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: _resetError,
          );
    }

    return ErrorWidgetBuilder(
      onError: (error, stackTrace) {
        widget.onError?.call(error, stackTrace);
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
          });
        }
      },
      child: widget.child,
    );
  }
}

/// Error Widget Builder - يلتقط الأخطاء من الÙ€ Widget Tree
class ErrorWidgetBuilder extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  const ErrorWidgetBuilder({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<ErrorWidgetBuilder> createState() => _ErrorWidgetBuilderState();
}

class _ErrorWidgetBuilderState extends State<ErrorWidgetBuilder> {
  @override
  Widget build(BuildContext context) {
    // ÙÙŠ Debug modeØŒ لا Ù†Ù„ØªÙ‚Ø· الأخطاء Ù„Ù†Ø±Ù‰ الÙ€ Red Screen
    if (kDebugMode) {
      return widget.child;
    }

    // ÙÙŠ ProductionØŒ Ù†Ø³ØªØ®Ø¯Ù… ErrorWidget.builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      widget.onError(details.exception, details.stack);
      return _DefaultErrorWidget(
        error: details.exception,
        stackTrace: details.stack,
        onRetry: () {
          // ÙŠÙ…ÙƒÙ† Ù„Ù„Ù…Ø³ØªØ®Ø¯Ù… الØ¶ØºØ· Ù„Ù„Ø¹ÙˆØ¯Ø©
        },
      );
    };

    return widget.child;
  }
}

/// واجهة الØ®Ø·Ø£ الØ§ÙØªØ±Ø§Ø¶ÙŠØ©
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppIcons.error,
                  width: 64,
                  height: 64,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              const Text(
                'حدث خطأ غير Ù…ØªÙˆÙ‚Ø¹',
                style: TextStyle(
                  fontSize: AppDimensions.fontHeadline,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              const Text(
                'Ù†Ø£Ø³Ù Ù„هذا الØ®Ø·Ø£. ÙŠØ±Ø¬Ù‰ الÙ…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰\nØ£Ùˆ الØªÙˆØ§ØµÙ„ مع الØ¯Ø¹Ù… Ø¥Ø°Ø§ Ø§Ø³تمØ±Øª الÙ…Ø´كلØ©.',
                style: TextStyle(
                  fontSize: AppDimensions.fontBody,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: AppDimensions.spacing16),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: AppDimensions.borderRadiusM,
                  ),
                  child: Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontCaption,
                      color: Colors.red,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.spacing32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: SvgPicture.asset(
                        AppIcons.refresh,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text('إعادة الÙ…Ø­Ø§ÙˆÙ„Ø©'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing24,
                          vertical: AppDimensions.spacing12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderRadiusM,
                        ),
                      ),
                    ),
                  const SizedBox(width: AppDimensions.spacing12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: SvgPicture.asset(
                      AppIcons.home,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text('الرئيسية'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing24,
                        vertical: AppDimensions.spacing12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusM,
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
  }
}

/// Global Error Handler - معالØ¬ Ø£Ø®Ø·Ø§Ø¡ Ø¹Ø§Ù…
/// ÙŠÙØ³ØªØ®Ø¯Ù… Ù„ØªØ³Ø¬ÙŠÙ„ الأخطاء ÙˆØ¥Ø±Ø³الÙ‡Ø§ Ù„Ø®Ø¯Ù…Ø© Ù…Ø±Ø§Ù‚Ø¨Ø©
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  final List<void Function(Object error, StackTrace? stackTrace)> _listeners =
      [];

  /// ØªÙ‡ÙŠØ¦Ø© معالØ¬ الأخطاء
  void initialize() {
    // الØªÙ‚Ø§Ø· Ø£Ø®Ø·Ø§Ø¡ Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack);
      // ÙÙŠ DebugØŒ Ù†Ø·Ø¨Ø¹ الØ®Ø·Ø£
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // الØªÙ‚Ø§Ø· Ø£Ø®Ø·Ø§Ø¡ Dart غير المعالØ¬Ø©
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleError(error, stack);
      return true;
    };
  }

  /// Ø¥Ø¶Ø§ÙØ© Ù…Ø³تمØ¹ Ù„Ù„Ø£Ø®Ø·Ø§Ø¡
  void addListener(
    void Function(Object error, StackTrace? stackTrace) listener,
  ) {
    _listeners.add(listener);
  }

  /// Ø¥Ø²الØ© Ù…Ø³تمØ¹
  void removeListener(
    void Function(Object error, StackTrace? stackTrace) listener,
  ) {
    _listeners.remove(listener);
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    // ØªØ³Ø¬ÙŠÙ„ الØ®Ø·Ø£
    debugPrint('ðŸ”´ Error: $error');
    if (stackTrace != null) {
      debugPrint('ðŸ“ StackTrace: $stackTrace');
    }

    // Ø¥Ø®Ø·Ø§Ø± الÙ…Ø³تمØ¹ÙŠÙ†
    for (final listener in _listeners) {
      listener(error, stackTrace);
    }

    // NOTE: ÙŠÙ…ÙƒÙ† Ø¥Ø¶Ø§ÙØ© ØªÙƒØ§Ù…Ù„ مع Ø®Ø¯Ù…Ø§Øª الÙ…Ø±Ø§Ù‚Ø¨Ø© Ù…Ø«Ù„:
    // - Firebase Crashlytics
    // - Sentry
    // _sendToMonitoringService(error, stackTrace);
  }
}

/// App Error Reporter - Ù„ØªØ³Ø¬ÙŠÙ„ الأخطاء الÙ…Ø®ØµØµØ©
class AppErrorReporter {
  /// ØªØ³Ø¬ÙŠÙ„ Ø®Ø·Ø£ Ù…Ø®ØµØµ
  static void reportError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? extras,
  }) {
    debugPrint('ðŸ”´ [Error Report] ${context ?? 'Unknown context'}');
    debugPrint('   Error: $error');
    if (extras != null) {
      debugPrint('   Extras: $extras');
    }
    if (stackTrace != null) {
      debugPrint('   Stack: $stackTrace');
    }

    // NOTE: ÙŠÙ…ÙƒÙ† Ø¥Ø¶Ø§ÙØ© ØªÙƒØ§Ù…Ù„ مع Ø®Ø¯Ù…Ø§Øª الÙ…Ø±Ø§Ù‚Ø¨Ø© هنا
  }

  /// ØªØ³Ø¬ÙŠÙ„ ØªحذفŠØ±
  static void reportWarning(String message, {Map<String, dynamic>? extras}) {
    debugPrint('ðŸŸ¡ [Warning] $message');
    if (extras != null) {
      debugPrint('   Extras: $extras');
    }
  }

  /// ØªØ³Ø¬ÙŠÙ„ معÙ„ÙˆÙ…Ø©
  static void reportInfo(String message, {Map<String, dynamic>? extras}) {
    debugPrint('ðŸ”µ [Info] $message');
    if (extras != null) {
      debugPrint('   Extras: $extras');
    }
  }
}
