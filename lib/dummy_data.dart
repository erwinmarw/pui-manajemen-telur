class Pengiriman {
  final String id, tujuan, alamat, kendaraan, jumlah, supir, status;
  
  // Include optional key or fallback fields if needed by Firebase/DistribusiProvider
  final String key;
  final String estimasi;
  final String jenisTelur;

  Pengiriman({
    required this.id,
    required this.tujuan,
    required this.alamat,
    required this.kendaraan,
    required this.jumlah,
    required this.supir,
    required this.status,
    this.key = '',
    this.estimasi = '-',
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
      'key': key,
      'estimasi': estimasi,
      'jenis_telur': jenisTelur,
    };
  }

  factory Pengiriman.fromMap(Map<String, dynamic> map) {
    return Pengiriman(
      id: map['id'] ?? '',
      tujuan: map['tujuan'] ?? '',
      alamat: map['alamat'] ?? '',
      kendaraan: map['kendaraan'] ?? '',
      jumlah: map['jumlah'] ?? '',
      supir: map['supir'] ?? '',
      status: map['status'] ?? '',
      key: map['key'] ?? '',
      estimasi: map['estimasi'] ?? '-',
      jenisTelur: map['jenis_telur'] ?? 'Telur Ayam Negeri',
    );
  }
}

final List<Pengiriman> dataPengirimanGlobal = [
  Pengiriman(id: '#DIS-004', tujuan: 'Agen Telur Berkah', alamat: 'Ruko Sentosa No. 5, Sidoarjo', kendaraan: 'L300 (N 8271 AB)', jumlah: '750 kg', supir: 'Mita', status: 'Pending', jenisTelur: 'Telur Puyuh'),
  Pengiriman(id: '#DIS-002', tujuan: 'Pasar Kramat Jati', alamat: 'Kios B-14, Kramat Jati, Jakarta', kendaraan: 'Truk Engkel (B 9182 T)', jumlah: '1200 kg', supir: 'Mudi', status: 'Perjalanan', jenisTelur: 'Telur Ayam Kampung'),
  Pengiriman(id: '#DIS-001', tujuan: 'Toko Sinar Jaya', alamat: 'Jl. Kenanga No. 12, Malang', kendaraan: 'L300 (N 8271 AB)', jumlah: '850 kg', supir: 'Slamet', status: 'Selesai', jenisTelur: 'Telur Ayam Negeri'),
  Pengiriman(id: '#DIS-003', tujuan: 'Warung Bu Ani', alamat: 'Gg. Mangga II, Surabaya', kendaraan: 'Carry PickUp (L 1290 XY)', jumlah: '300 kg', supir: 'Mita', status: 'Selesai', jenisTelur: 'Telur Bebek'),
];
