import 'package:flutter/material.dart';
import '../models/property.dart';
import '../config/app_colors.dart';
import 'badge_widget.dart';
import 'package:intl/intl.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  
  const PropertyCard({
    Key? key,
    required this.property,
    required this.onTap,
  }) : super(key: key);

  String formatPrice(double price) {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} Lac';
    }
    return '₹${NumberFormat('#,##,###').format(price)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate200.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                // Property image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    property.images.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: AppColors.slate100,
                        child: Icon(Icons.home, size: 48, color: AppColors.slate400),
                      );
                    },
                  ),
                ),
                
                // Badges overlay
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (property.verified)
                            BadgeWidget(
                              text: 'Verified',
                              type: BadgeType.verified,
                              icon: Icons.check_circle,
                            ),
                          if (property.featured) ...[
                            SizedBox(width: 8),
                            BadgeWidget(
                              text: 'Featured',
                              type: BadgeType.featured,
                            ),
                          ],
                        ],
                      ),
                      
                      // Favorite button
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Purpose badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: BadgeWidget(
                    text: 'For ${property.purpose}',
                    type: BadgeType.purpose,
                  ),
                ),
              ],
            ),
            
            // Content section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.slate400),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  
                  // Property details
                  Container(
                    padding: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.slate100),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (property.bedrooms != null) ...[
                          Icon(Icons.bed, size: 16, color: AppColors.slate400),
                          SizedBox(width: 4),
                          Text(
                            '${property.bedrooms} BHK',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          SizedBox(width: 16),
                        ],
                        if (property.bathrooms != null) ...[
                          Icon(Icons.bathtub, size: 16, color: AppColors.slate400),
                          SizedBox(width: 4),
                          Text(
                            '${property.bathrooms} Bath',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          SizedBox(width: 16),
                        ],
                        Icon(Icons.straighten, size: 16, color: AppColors.slate400),
                        SizedBox(width: 4),
                        Text(
                          '${property.areaSqft} sqft',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Amenities
                  if (property.amenities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities.take(3).map((amenity) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amenity,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList()
                        ..add(
                          property.amenities.length > 3
                              ? Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${property.amenities.length - 3}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ),
                    ),
                  SizedBox(height: 16),
                  
                  // Price and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatPrice(property.price),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (property.purpose == 'rent' || property.purpose == 'flat')
                            Text(
                              '/month',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                      
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppColors.emeraldGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emeraldPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}