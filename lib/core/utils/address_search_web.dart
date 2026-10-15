import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'address_search_result.dart';

@JS('daum.Postcode')
extension type _DaumPostcode._(JSObject _) implements JSObject {
  external _DaumPostcode(_PostcodeOptions options);
  external void embed(JSObject element);
}

extension type _PostcodeOptions._(JSObject _) implements JSObject {
  external _PostcodeOptions({
    required JSFunction oncomplete,
    String? width,
    String? height,
  });
}

extension type _PostcodeData._(JSObject _) implements JSObject {
  external String? get zonecode;
  external String? get roadAddress;
  external String? get jibunAddress;
}

Future<void>? _scriptFuture;

Future<void> _ensurePostcodeScript() {
  return _scriptFuture ??= _loadPostcodeScript().catchError((Object error) {
    _scriptFuture = null;
    throw error;
  });
}

Future<void> _loadPostcodeScript() {
  final completer = Completer<void>();
  final script = web.HTMLScriptElement()
    ..src =
        'https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js'
    ..async = true;

  script.onload = ((web.Event event) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }).toJS;

  script.onerror = ((web.Event event) {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError('우편번호 검색 서비스를 불러오지 못했습니다.'),
      );
    }
  }).toJS;

  web.document.head!.appendChild(script);

  return completer.future.timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      throw TimeoutException('우편번호 검색 서비스 연결 시간이 초과됐습니다.');
    },
  );
}

Future<AddressSearchResult?> searchKoreanAddress(
    BuildContext context,
    ) {
  return showDialog<AddressSearchResult>(
    context: context,
    builder: (dialogContext) {
      final height = MediaQuery.sizeOf(dialogContext).height;

      return Dialog(
        child: SizedBox(
          width: 570,
          height: height > 592 ? 560 : height - 32,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '주소 찾기',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: HtmlElementView.fromTagName(
                  tagName: 'div',
                  onElementCreated: (element) async {
                    final container = element as web.HTMLDivElement;

                    container.style.width = '100%';
                    container.style.height = '100%';
                    container.style.overflow = 'auto';
                    container.textContent = '주소 검색을 불러오는 중입니다.';

                    try {
                      await _ensurePostcodeScript();

                      if (!dialogContext.mounted) return;

                      container.textContent = '';

                      final postcode = _DaumPostcode(
                        _PostcodeOptions(
                          width: '100%',
                          height: '100%',
                          oncomplete: ((JSObject result) {
                            final data = _PostcodeData._(result);

                            final zonecode = data.zonecode?.trim() ?? '';
                            final roadAddress =
                                data.roadAddress?.trim() ?? '';
                            final jibunAddress =
                                data.jibunAddress?.trim() ?? '';

                            final selectedAddress =
                            roadAddress.isNotEmpty
                                ? roadAddress
                                : jibunAddress;

                            if (!dialogContext.mounted) return;

                            if (zonecode.isEmpty ||
                                selectedAddress.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '우편번호 또는 주소를 확인할 수 없습니다.',
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.of(dialogContext).pop(
                              AddressSearchResult(
                                postcode: zonecode,
                                address: selectedAddress,
                              ),
                            );
                          }).toJS,
                        ),
                      );

                      postcode.embed(container);
                    } catch (error) {
                      if (!dialogContext.mounted) return;

                      Navigator.of(dialogContext).pop();

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('주소 검색 실패: $error'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}