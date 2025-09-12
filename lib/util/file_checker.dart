bool isVideoFile(String url) {
  final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
  return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
}

bool isImageFile(String url) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
}
