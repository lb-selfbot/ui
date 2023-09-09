import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class ActivityImage extends StatelessWidget {
  const ActivityImage({
    Key? key,
    required this.activityType,
    required this.clientId,
    required this.image,
  }) : super(key: key);

  final String activityType;
  final String clientId;
  final String image;

  Widget errorIcon() {
    return const Icon(Icons.error, size: 70);
  }

  Widget buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorIcon();
      },
      height: 70,
      width: 70,
    );
  }

  String getImageId(List<dynamic> data) {
    for (final item in data) {
      if (item["name"] == image) {
        return item["id"];
      }
    }

    return "";
  }

  Widget buildRPCImage() {
    final isValidUri = Uri.tryParse(image)?.isAbsolute;

    if (isValidUri == true) {
      return buildNetworkImage(image);
    }

    final apiUrl =
        "https://discordapp.com/api/oauth2/applications/$clientId/assets";

    return FutureBuilder(
      future:
          http.get(Uri.parse(apiUrl)).then((value) => json.decode(value.body)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return errorIcon();
        }

        if (snapshot.data is! List<dynamic>) {
          return errorIcon();
        }

        final imageId = getImageId(snapshot.data as List<dynamic>);

        if (imageId.isEmpty) {
          return errorIcon();
        }

        final imageUrl =
            "https://cdn.discordapp.com/app-assets/$clientId/$imageId.png";

        return buildNetworkImage(imageUrl);
      },
    );
  }

  Widget buildCustomActivityImage() {
    if (image.startsWith("mp:external")) {
      final imageUrl = image.replaceAll(
        "mp:external",
        "https://images-ext-1.discordapp.net/external",
      );

      return buildNetworkImage(imageUrl);
    }

    return errorIcon();
  }

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) return Container();

    if (activityType == "RPC") {
      return buildRPCImage();
    } else if (activityType == "CustomActivity") {
      return buildCustomActivityImage();
    } else {
      return errorIcon();
    }
  }
}
