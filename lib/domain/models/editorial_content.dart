String? editorialImageDataUrl(String? encoded) {
  if (encoded == null || encoded.isEmpty) return null;

  final mime = encoded.startsWith('iVBOR')
      ? 'image/png'
      : encoded.startsWith('UklG')
      ? 'image/webp'
      : 'image/jpeg';

  return 'data:$mime;base64,$encoded';
}

class PublicHeroContent {
  const PublicHeroContent({
    required this.mainText,
    required this.subText,
    required this.buttonText,
    required this.buttonRoute,
    required this.visible,
    required this.isVideo,
    this.mediaBase64,
    this.mediaName = '',
  });

  final String mainText;
  final String subText;
  final String buttonText;
  final String buttonRoute;
  final bool visible;
  final bool isVideo;
  final String? mediaBase64;
  final String mediaName;

  String? get imageDataUrl =>
      isVideo ? null : editorialImageDataUrl(mediaBase64);

  String? get videoDataUrl {
    if (!isVideo || mediaBase64 == null || mediaBase64!.isEmpty) return null;
    final name = mediaName.toLowerCase();
    final mime = name.endsWith('.mp4') ? 'video/mp4'
        : name.endsWith('.webm') ? 'video/webm'
        : name.endsWith('.mov') ? 'video/quicktime' : null;
    return mime == null ? null : 'data:$mime;base64,$mediaBase64';
  }

  factory PublicHeroContent.fromJson(Map<String, dynamic> json) =>
      PublicHeroContent(
        mainText: json['main_text'] as String? ?? '',
        subText: json['sub_text'] as String? ?? '',
        buttonText: json['button_text'] as String? ?? '',
        buttonRoute: json['button_route'] as String? ?? '/new',
        visible: json['is_visible'] == true,
        isVideo: json['is_video'] == true,
        mediaBase64: json['media_base64'] as String?,
        mediaName: json['media_name'] as String? ?? '',
      );
}

class PublicHomeContent {
  const PublicHomeContent({
    required this.hero,
    required this.classicVisible,
    required this.workVisible,
    required this.newArrivalProductIds,
    this.classicImageBase64,
    this.workImageBase64,
  });

  final PublicHeroContent hero;
  final bool classicVisible;
  final bool workVisible;
  final List<String> newArrivalProductIds;
  final String? classicImageBase64;
  final String? workImageBase64;

  String? get classicImageDataUrl =>
      editorialImageDataUrl(classicImageBase64);

  String? get workImageDataUrl =>
      editorialImageDataUrl(workImageBase64);

  factory PublicHomeContent.fromJson(Map<String, dynamic> json) =>
      PublicHomeContent(
        hero: PublicHeroContent.fromJson(
          Map<String, dynamic>.from(json['hero'] as Map),
        ),
        classicVisible: json['classic_visible'] == true,
        workVisible: json['work_visible'] == true,
        newArrivalProductIds:
        (json['new_arrival_product_ids'] as List<dynamic>? ?? const [])
            .map((id) => id.toString())
            .toList(growable: false),
        classicImageBase64: json['classic_image_base64'] as String?,
        workImageBase64: json['work_image_base64'] as String?,
      );
}

class PublicJournal {
  const PublicJournal({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    required this.publishAt,
    required this.relatedProductIds,
    this.coverImageBase64,
    this.additionalImageBase64 = const [],
  });

  final String id;
  final String title;
  final String category;
  final String body;
  final DateTime publishAt;
  final String? coverImageBase64;
  final List<String> additionalImageBase64;
  final List<String> relatedProductIds;

  String? get coverImageDataUrl =>
      editorialImageDataUrl(coverImageBase64);

  String get preview =>
      body.length <= 110 ? body : '${body.substring(0, 110)}…';

  factory PublicJournal.fromJson(Map<String, dynamic> json) =>
      PublicJournal(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String? ?? 'JOURNAL',
        body: json['body'] as String? ?? '',
        publishAt: DateTime.parse(json['publish_at'] as String),
        coverImageBase64: json['cover_image_base64'] as String?,
        additionalImageBase64:
        (json['additional_image_base64'] as List<dynamic>? ?? const [])
            .cast<String>(),
        relatedProductIds:
        (json['related_product_ids'] as List<dynamic>? ?? const [])
            .cast<String>(),
      );
}