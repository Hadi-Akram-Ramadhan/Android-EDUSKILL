import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/certificate_model.dart';
import '../../services/api_service.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _error;
  List<CertificateModel> _certificates = [];

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.get('/certificates');
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final list = data['data'] as List<dynamic>;
        _certificates = list.map((e) => CertificateModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_certificates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(color: AppTheme.primaryBlueLight, shape: BoxShape.circle),
                child: const Icon(Icons.workspace_premium_rounded, size: 48, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum Ada Sertifikat',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textMain),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selesaikan seluruh modul pada salah satu kursus di Roadmap untuk membuka sertifikat kompetensi resmi kamu!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCertificates,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _certificates.length,
        itemBuilder: (ctx, i) => _certificateCard(_certificates[i]),
      ),
    );
  }

  Widget _certificateCard(CertificateModel cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0xFFE2E8F0), offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.emeraldBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.verified_rounded, color: AppTheme.emeraldGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert.courseTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Diterbitkan ${cert.issueDate}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.slateBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cert.certCode, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 12)),
                Text(cert.grade, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
