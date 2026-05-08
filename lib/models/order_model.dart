enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  onTheWay,
  delivered,
  cancelled,
}

enum PaymentMethod {
  cashOnDelivery,
  bkash,
  card,
}

class OrderItemModel {
  final String foodItemId;
  final String foodName;
  final String foodImage;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.foodItemId,
    required this.foodName,
    required this.foodImage,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      foodItemId: map['foodItemId'] ?? '',
      foodName: map['foodName'] ?? '',
      foodImage: map['foodImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodItemId': foodItemId,
      'foodName': foodName,
      'foodImage': foodImage,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? promoCode;
  final int estimatedDeliveryTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.totalAmount,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.promoCode,
    this.estimatedDeliveryTime = 30,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromMap(e))
          .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      status: OrderStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryLatitude: map['deliveryLatitude']?.toDouble(),
      deliveryLongitude: map['deliveryLongitude']?.toDouble(),
      promoCode: map['promoCode'],
      estimatedDeliveryTime: map['estimatedDeliveryTime'] ?? 30,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'promoCode': promoCode,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  OrderModel copyWith({OrderStatus? status, DateTime? updatedAt}) {
    return OrderModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress,
      estimatedDeliveryTime: estimatedDeliveryTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}