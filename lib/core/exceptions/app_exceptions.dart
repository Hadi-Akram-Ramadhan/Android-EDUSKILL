class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Tidak ada koneksi internet atau server tidak merespon.']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Sesi login telah berakhir. Silakan masuk kembali.']);

  @override
  String toString() => message;
}
