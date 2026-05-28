import 'radio_category.dart';

class RadioStation {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String country;
  final String? city;
  final RadioCategory category;
  final List<String> tags;
  final String? websiteUrl;
  final int? bitrate;
  final String? codec;
  final bool isVerified;
  final String? lastChecked;
  final String? source;
  final int sortOrder;
  bool isFavorite;

  RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.country = 'Bulgaria',
    this.city,
    this.category = RadioCategory.other,
    this.tags = const [],
    this.websiteUrl,
    this.bitrate,
    this.codec,
    this.isVerified = false,
    this.lastChecked,
    this.source,
    this.sortOrder = 999,
    this.isFavorite = false,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    return RadioStation(
      id: json['id'] as String,
      name: json['name'] as String,
      streamUrl: json['streamUrl'] as String,
      logoUrl: json['logoUrl'] as String?,
      country: json['country'] as String? ?? 'Bulgaria',
      city: json['city'] as String?,
      category: RadioCategory.fromString(json['category'] as String? ?? 'other'),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      websiteUrl: json['websiteUrl'] as String?,
      bitrate: json['bitrate'] as int?,
      codec: json['codec'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      lastChecked: json['lastChecked'] as String?,
      source: json['source'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 999,
      isFavorite: isFavorite,
    );
  }

  RadioStation copyWith({bool? isFavorite}) {
    return RadioStation(
      id: id,
      name: name,
      streamUrl: streamUrl,
      logoUrl: logoUrl,
      country: country,
      city: city,
      category: category,
      tags: tags,
      websiteUrl: websiteUrl,
      bitrate: bitrate,
      codec: codec,
      isVerified: isVerified,
      lastChecked: lastChecked,
      source: source,
      sortOrder: sortOrder,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) => other is RadioStation && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RadioStation($id, $name)';
}
