class DistributionItem {
  final String id;
  final String tujuan;
  final String alamat;
  final String kendaraan;
  final String jumlah;
  final String supir;
  final String status;
  final String estimasi;
  final String jenisTelur;

  const DistributionItem({
    required this.id,
    required this.tujuan,
    required this.alamat,
    required this.kendaraan,
    required this.jumlah,
    required this.supir,
    required this.status,
    required this.estimasi,
    this.jenisTelur = 'Telur Ayam Negeri',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tujuan': tujuan,
      'alamat': alamat,
      'kendaraan': kendaraan,
      'jumlah': jumlah,
      'supir': supir,
      'status': status,
      'estimasi': estimasi,
      'jenis_telur': jenisTelur,
    };
  }
}

final List<DistributionItem> centralizedDistributions = [
  const DistributionItem(
    id: '#DIS-004',
    tujuan: 'Agen Telur Berkah',
    alamat: 'Ruko Sentosa No. 5, Sidoarjo',
    kendaraan: 'L300 (N 8271 AB)',
    jumlah: '750 kg',
    supir: 'Mita',
    status: 'Pending',
    estimasi: 'Besok',
    jenisTelur: 'Telur Puyuh',
  ),
  const DistributionItem(
    id: '#DIS-002',
    tujuan: 'Pasar Kramat Jati',
    alamat: 'Kios B-14, Kramat Jati, Jakarta',
    kendaraan: 'Truk Engkel (B 9182 T)',
    jumlah: '1200 kg',
    supir: 'Mudi',
    status: 'Perjalanan',
    estimasi: '30 menit',
    jenisTelur: 'Telur Ayam Kampung',
  ),
  const DistributionItem(
    id: '#DIS-001',
    tujuan: 'Toko Sinar Jaya',
    alamat: 'Jl. Kenanga No. 12, Malang',
    kendaraan: 'L300 (N 8271 AB)',
    jumlah: '850 kg',
    supir: 'Slamet',
    status: 'Selesai',
    estimasi: '-',
    jenisTelur: 'Telur Ayam Negeri',
  ),
  const DistributionItem(
    id: '#DIS-003',
    tujuan: 'Warung Bu Ani',
    alamat: 'Gg. Mangga II, Surabaya',
    kendaraan: 'Carry PickUp (L 1290 XY)',
    jumlah: '300 kg',
    supir: 'Mita',
    status: 'Selesai',
    estimasi: '-',
    jenisTelur: 'Telur Bebek',
  ),
];
