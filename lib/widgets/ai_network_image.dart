import 'package:flutter/material.dart';

class NetworkImageFromAi extends StatelessWidget {
  const NetworkImageFromAi({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
              const SizedBox(
                height: 25.0,
              ),
              Text(
                  '${(loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! * 100).toStringAsFixed(1)}%')
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Placeholder(
          child: Text(error.toString()),
        );
      },
    );
  }
}
