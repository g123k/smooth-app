part of 'tagline_provider.dart';

/// Content from the JSON and converted to what's in "tagmodel.dart"

class _TagLineJSON {
  _TagLineJSON.fromJson(Map<dynamic, dynamic> json)
      : news = (json['news'] as Map<dynamic, dynamic>).map(
          (dynamic id, dynamic value) => MapEntry<String, _TagLineItemNewsItem>(
            id,
            _TagLineItemNewsItem.fromJson(id, value),
          ),
        ),
        taglineFeed = _TaglineJSONFeed.fromJson(json['tagline_feed']);

  final _TagLineJSONNewsList news;
  final _TaglineJSONFeed taglineFeed;

  TagLine toTagLine(String locale) {
    final Map<String, TagLineNewsItem> tagLineNews = news.map(
      (String key, _TagLineItemNewsItem value) =>
          MapEntry<String, TagLineNewsItem>(
        key,
        value.toTagLineItem(locale),
      ),
    );

    final _TagLineJSONFeedLocale localizedFeed = taglineFeed.loadNews(locale);
    final Iterable<TagLineFeedItem> feed =
        localizedFeed.news.map((_TagLineJSONFeedLocaleItem item) {
      if (news[item.id] == null) {
        // The asked ID doesn't exist in the news
        return null;
      }
      return item.overrideNewsItem(news[item.id]!, locale);
    }).whereNotNull();

    return TagLine(
      news: TagLineNewsList(tagLineNews),
      feed: TagLineFeed(
        feed.toList(growable: false),
      ),
    );
  }
}

typedef _TagLineJSONNewsList = Map<String, _TagLineItemNewsItem>;

class _TagLineItemNewsItem {
  const _TagLineItemNewsItem._({
    required this.id,
    required this.url,
    required _TagLineItemNewsTranslations translations,
    this.startDate,
    this.endDate,
    this.style,
  }) : _translations = translations;

  _TagLineItemNewsItem.fromJson(this.id, Map<dynamic, dynamic> json)
      : assert((json['url'] as String).isNotEmpty),
        url = json['url'],
        assert((json['translations'] as Map<dynamic, dynamic>)
            .containsKey('default')),
        _translations = (json['translations'] as Map<dynamic, dynamic>)
            .map((dynamic key, dynamic value) {
          if (key == 'default') {
            return MapEntry<String, _TagLineItemNewsTranslation>(
                key, _TagLineItemNewsTranslationDefault.fromJson(value));
          } else {
            return MapEntry<String, _TagLineItemNewsTranslation>(
              key,
              _TagLineItemNewsTranslation.fromJson(value),
            );
          }
        }),
        startDate = DateTime.tryParse(json['start_date']),
        endDate = DateTime.tryParse(json['end_date']),
        style = json['style'] == null
            ? null
            : _TagLineNewsStyle.fromJson(json['style']);

  final String id;
  final String url;
  final _TagLineItemNewsTranslations _translations;
  final DateTime? startDate;
  final DateTime? endDate;
  final _TagLineNewsStyle? style;

  _TagLineItemNewsTranslation loadTranslation(String locale) {
    _TagLineItemNewsTranslation? translation;
    // Direct match
    if (_translations.containsKey(locale)) {
      translation = _translations[locale];
    } else if (locale.contains('_')) {
      final String languageCode = locale.split('_').first;
      if (_translations.containsKey(languageCode)) {
        translation = _translations[languageCode];
      }
    }

    return _translations['default']!.merge(translation);
  }

  TagLineNewsItem toTagLineItem(String locale) {
    final _TagLineItemNewsTranslation translation = loadTranslation(locale);
    // We can assume the default translation has a non-null title and message
    return TagLineNewsItem(
      id: id,
      title: translation.title!,
      message: translation.message!,
      url: translation.url ?? url,
      buttonLabel: translation.buttonLabel,
      startDate: startDate,
      endDate: endDate,
      style: style?.toTagLineStyle(),
      image: translation.image?.toTagLineImage(),
    );
  }

  _TagLineItemNewsItem copyWith({
    String? url,
    _TagLineItemNewsTranslations? translations,
    DateTime? startDate,
    DateTime? endDate,
    _TagLineNewsStyle? style,
  }) {
    return _TagLineItemNewsItem._(
      id: id,
      // Still the same
      url: url ?? this.url,
      translations: translations ?? _translations,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      style: style ?? this.style,
    );
  }
}

typedef _TagLineItemNewsTranslations = Map<String, _TagLineItemNewsTranslation>;

class _TagLineItemNewsTranslation {
  _TagLineItemNewsTranslation._({
    this.title,
    this.message,
    this.url,
    this.buttonLabel,
    this.image,
  });

  _TagLineItemNewsTranslation.fromJson(Map<dynamic, dynamic> json)
      : assert(json['title'] == null || (json['title'] as String).isNotEmpty),
        assert(
            json['message'] == null || (json['message'] as String).isNotEmpty),
        assert(json['url'] == null || (json['url'] as String).isNotEmpty),
        assert(json['button_label'] == null ||
            (json['button_label'] as String).isNotEmpty),
        title = json['title'],
        message = json['message'],
        url = json['url'],
        buttonLabel = json['button_label'],
        image = json['image'] == null
            ? null
            : _TagLineNewsImage.fromJson(json['image']);
  final String? title;
  final String? message;
  final String? url;
  final String? buttonLabel;
  final _TagLineNewsImage? image;

  _TagLineItemNewsTranslation copyWith({
    String? title,
    String? message,
    String? url,
    String? buttonLabel,
    _TagLineNewsImage? image,
  }) {
    return _TagLineItemNewsTranslation._(
      title: title ?? this.title,
      message: message ?? this.message,
      url: url ?? this.url,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      image: image ?? this.image,
    );
  }

  _TagLineItemNewsTranslation merge(_TagLineItemNewsTranslation? other) {
    if (other == null) {
      return this;
    }

    return copyWith(
      title: other.title,
      message: other.message,
      url: other.url,
      buttonLabel: other.buttonLabel,
      image: other.image,
    );
  }
}

class _TagLineItemNewsTranslationDefault extends _TagLineItemNewsTranslation {
  _TagLineItemNewsTranslationDefault.fromJson(Map<dynamic, dynamic> json)
      : assert((json['title'] as String).isNotEmpty),
        assert((json['message'] as String).isNotEmpty),
        super.fromJson(json);
}

class _TagLineNewsImage {
  _TagLineNewsImage.fromJson(Map<dynamic, dynamic> json)
      : assert((json['url'] as String).isNotEmpty),
        assert(json['width'] == null ||
            ((json['width'] as num) >= 0.0 && (json['width'] as num) <= 1.0)),
        assert(json['alt'] == null || (json['alt'] as String).isNotEmpty),
        url = json['url'],
        width = json['width'],
        alt = json['alt'];

  final String url;
  final double? width;
  final String? alt;

  TagLineImage toTagLineImage() {
    return TagLineImage(
      src: url,
      width: width,
      alt: alt,
    );
  }
}

class _TagLineNewsStyle {
  _TagLineNewsStyle._({
    this.titleBackground,
    this.titleTextColor,
    this.titleIndicatorColor,
    this.messageBackground,
    this.messageTextColor,
    this.buttonBackground,
    this.buttonTextColor,
    this.contentBackgroundColor,
  });

  _TagLineNewsStyle.fromJson(Map<dynamic, dynamic> json)
      : assert(json['title_background'] == null ||
            (json['title_background'] as String).startsWith('#')),
        assert(json['title_text_color'] == null ||
            (json['title_text_color'] as String).startsWith('#')),
        assert(json['title_indicator_color'] == null ||
            (json['title_indicator_color'] as String).startsWith('#')),
        assert(json['message_background'] == null ||
            (json['message_background'] as String).startsWith('#')),
        assert(json['message_text_color'] == null ||
            (json['message_text_color'] as String).startsWith('#')),
        assert(json['button_background'] == null ||
            (json['button_background'] as String).startsWith('#')),
        assert(json['button_text_color'] == null ||
            (json['button_text_color'] as String).startsWith('#')),
        assert(json['content_background_color'] == null ||
            (json['content_background_color'] as String).startsWith('#')),
        titleBackground = json['title_background'],
        titleTextColor = json['title_text_color'],
        titleIndicatorColor = json['title_indicator_color'],
        messageBackground = json['message_background'],
        messageTextColor = json['message_text_color'],
        buttonBackground = json['button_background'],
        buttonTextColor = json['button_text_color'],
        contentBackgroundColor = json['content_background_color'];

  final String? titleBackground;
  final String? titleTextColor;
  final String? titleIndicatorColor;
  final String? messageBackground;
  final String? messageTextColor;
  final String? buttonBackground;
  final String? buttonTextColor;
  final String? contentBackgroundColor;

  _TagLineNewsStyle copyWith({
    String? titleBackground,
    String? titleTextColor,
    String? titleIndicatorColor,
    String? messageBackground,
    String? messageTextColor,
    String? buttonBackground,
    String? buttonTextColor,
    String? contentBackgroundColor,
  }) {
    return _TagLineNewsStyle._(
      titleBackground: titleBackground ?? this.titleBackground,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      titleIndicatorColor: titleIndicatorColor ?? this.titleIndicatorColor,
      messageBackground: messageBackground ?? this.messageBackground,
      messageTextColor: messageTextColor ?? this.messageTextColor,
      buttonBackground: buttonBackground ?? this.buttonBackground,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      contentBackgroundColor:
          contentBackgroundColor ?? this.contentBackgroundColor,
    );
  }

  TagLineStyle toTagLineStyle() => TagLineStyle.fromHexa(
        titleBackground: titleBackground,
        titleTextColor: titleTextColor,
        titleIndicatorColor: titleIndicatorColor,
        messageBackground: messageBackground,
        messageTextColor: messageTextColor,
        buttonBackground: buttonBackground,
        buttonTextColor: buttonTextColor,
        contentBackgroundColor: contentBackgroundColor,
      );
}

class _TaglineJSONFeed {
  _TaglineJSONFeed.fromJson(Map<dynamic, dynamic> json)
      : assert(json.containsKey('default')),
        _news = json.map(
          (dynamic key, dynamic value) =>
              MapEntry<String, _TagLineJSONFeedLocale>(
            key,
            _TagLineJSONFeedLocale.fromJson(value),
          ),
        );

  final _TagLineJSONFeedList _news;

  _TagLineJSONFeedLocale loadNews(String locale) {
    // Direct match
    if (_news.containsKey(locale)) {
      return _news[locale]!;
    }

    // Try by language
    if (locale.contains('_')) {
      final String languageCode = locale.split('_').first;
      if (_news.containsKey(languageCode)) {
        return _news[languageCode]!;
      }
    }

    return _news['default']!;
  }
}

typedef _TagLineJSONFeedList = Map<String, _TagLineJSONFeedLocale>;

class _TagLineJSONFeedLocale {
  _TagLineJSONFeedLocale.fromJson(Map<dynamic, dynamic> json)
      : assert(json['news'] is Iterable<dynamic>),
        news = (json['news'] as Iterable<dynamic>)
            .map((dynamic json) => _TagLineJSONFeedLocaleItem.fromJson(json));

  final Iterable<_TagLineJSONFeedLocaleItem> news;
}

class _TagLineJSONFeedLocaleItem {
  _TagLineJSONFeedLocaleItem.fromJson(Map<dynamic, dynamic> json)
      : assert((json['id'] as String).isNotEmpty),
        id = json['id'],
        overrideContent = json['override'] != null
            ? _TagLineJSONFeedNewsItemOverride.fromJson(
                json['override'] as Map<dynamic, dynamic>)
            : null;

  final String id;
  final _TagLineJSONFeedNewsItemOverride? overrideContent;

  TagLineFeedItem overrideNewsItem(
    _TagLineItemNewsItem newsItem,
    String locale,
  ) {
    _TagLineItemNewsItem item = newsItem;

    if (overrideContent != null) {
      item = newsItem.copyWith(
        url: overrideContent!.url ?? newsItem.url,
        startDate: overrideContent!.startDate ?? newsItem.startDate,
        endDate: overrideContent!.endDate ?? newsItem.endDate,
        style: overrideContent!.style ?? newsItem.style,
      );
    }

    final TagLineNewsItem tagLineItem = item.toTagLineItem(locale);

    return TagLineFeedItem(
      news: tagLineItem,
      startDate: tagLineItem.startDate,
      endDate: tagLineItem.endDate,
    );
  }
}

class _TagLineJSONFeedNewsItemOverride {
  _TagLineJSONFeedNewsItemOverride.fromJson(Map<dynamic, dynamic> json)
      : assert(json['url'] == null || (json['url'] as String).isNotEmpty),
        url = json['url'],
        startDate = json['start_date'] != null
            ? DateTime.tryParse(json['start_date'])
            : null,
        endDate = json['end_date'] != null
            ? DateTime.tryParse(json['end_date'])
            : null,
        style = json['style'] == null
            ? null
            : _TagLineNewsStyle.fromJson(json['style']);

  final String? url;
  final DateTime? startDate;
  final DateTime? endDate;
  final _TagLineNewsStyle? style;
}
