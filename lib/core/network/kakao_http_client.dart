import 'package:http/http.dart' as http;

import 'kakao_http_client_stub.dart'
if (dart.library.js_interop) 'kakao_http_client_web.dart' as implementation;

http.Client createKakaoHttpClient() =>
    implementation.createKakaoHttpClient();