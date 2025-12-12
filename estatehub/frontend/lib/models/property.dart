class Property {
  final String id;
  final String title;
  final String propertyType; // 'plot', 'flat', 'apartment'
  final String purpose; // 'rent', 'buy', 'flat'
  final double areaSqft;
  final double price;
  final String address;
  final String city;
  final String state;
  final String location; // Display location
  final String? locality;
  final int? bedrooms;
  final int? bathrooms;
  final String? furnishingStatus;
  final String description;
  final List<String> amenities;
  final List<String> images;
  final bool verified;
  final bool featured;
  final DateTime postedDate;
  
  Property({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.purpose,
    required this.areaSqft,
    required this.price,
    required this.address,
    required this.city,
    required this.state,
    required this.location,
    this.locality,
    this.bedrooms,
    this.bathrooms,
    this.furnishingStatus,
    required this.description,
    this.amenities = const [],
    this.images = const [],
    this.verified = false,
    this.featured = false,
    required this.postedDate,
  });
  
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      propertyType: json['property_type'] ?? '',
      purpose: json['purpose'] ?? '',
      areaSqft: (json['area_sqft'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      location: json['location'] ?? '${json['city']}, ${json['state']}',
      locality: json['locality'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      furnishingStatus: json['furnishing_status'],
      description: json['description'] ?? '',
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : [],
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
      verified: json['verified'] ?? false,
      featured: json['featured'] ?? false,
      postedDate: json['posted_date'] != null 
          ? DateTime.parse(json['posted_date']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'property_type': propertyType,
      'purpose': purpose,
      'area_sqft': areaSqft,
      'price': price,
      'address': address,
      'city': city,
      'state': state,
      'locality': locality,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'furnishing_status': furnishingStatus,
      'description': description,
      'amenities': amenities,
      'images': images,
      'verified': verified,
      'featured': featured,
      'posted_date': postedDate.toIso8601String(),
    };
  }
}