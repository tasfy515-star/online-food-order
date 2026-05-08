class StorageService {
  static String getPlaceholderImage(String type) {
    switch (type) {
      case 'restaurant':
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400';
      case 'food':
        return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
      case 'profile':
        return 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400';
      default:
        return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
    }
  }
}
