class Product {
  String? id;
  String name;
  double price;
  String image;
  String? description;
  String? category;
  int stock;
  bool isAvailable;
  double? discount;
  double? rating;
  int reviewCount;
  DateTime createdAt;
  List<String>? tags;
  
  Product({
    this.id,
    required this.name,
    required this.price,
    required this.image,
    this.description,
    this.category = 'حلويات',
    this.stock = 100,
    this.isAvailable = true,
    this.discount,
    this.rating,
    this.reviewCount = 0,
    DateTime? createdAt,
    this.tags,
  }) : createdAt = createdAt ?? DateTime.now();

  double get discountedPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  bool get hasDiscount => discount != null && discount! > 0;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'category': category,
      'stock': stock,
      'isAvailable': isAvailable,
      'discount': discount,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'tags': tags,
      'updatedAt': DateTime.now(),
    };
  }

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? 'https://placehold.co/600x400/ea580c/white?text=Product',
      description: data['description'],
      category: data['category'] ?? 'حلويات',
      stock: (data['stock'] ?? 100).toInt(),
      isAvailable: data['isAvailable'] ?? true,
      discount: (data['discount'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
    );
  }
}
