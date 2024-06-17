import 'package:flutter/material.dart';

enum PreviewType { permission, loading, error }

class PreviewPlaceholder extends StatelessWidget {
  final PreviewType type;
  final VoidCallback? onAction;

  const PreviewPlaceholder._({
    required this.type,
    this.onAction,
  });

  factory PreviewPlaceholder.noPermission({
    required VoidCallback onAskForPermissions,
  }) =>
      PreviewPlaceholder._(
        type: PreviewType.permission,
        onAction: onAskForPermissions,
      );

  factory PreviewPlaceholder.loadingPreview() => const PreviewPlaceholder._(
        type: PreviewType.loading,
      );

  factory PreviewPlaceholder.previewError({required VoidCallback onRetry}) =>
      PreviewPlaceholder._(
        type: PreviewType.error,
        onAction: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (type == PreviewType.permission)
          ElevatedButton(
            onPressed: onAction,
            child: const Text("Ask for camera permisions"),
          ),
        if (type == PreviewType.error) ...[
          const Text("Couldn't load camera preview"),
          ElevatedButton(
            onPressed: onAction,
            child: const Text("Ask for camera permisions"),
          ),
        ],
        if (type == PreviewType.loading) ...const [
          Text("Loading preview"),
          Center(
            child: LinearProgressIndicator(),
          )
        ],
      ],
    );
  }
}
