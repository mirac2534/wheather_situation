class WheatherModel {
  final String tarih;
  final String gun;
  final String ikon;
  final String durum;
  final String derece;
  final String min;
  final String max;
  final String gece;
  final String nem;

  WheatherModel(
    this.tarih,
    this.gun,
    this.ikon,
    this.durum,
    this.derece,
    this.min,
    this.max,
    this.gece,
    this.nem,
  );

  WheatherModel.fromJson(Map<String, dynamic> json)
      : tarih = json['date'] as String? ?? '',
        gun = json['day'] as String? ?? '',
        ikon = json['icon'] as String? ?? '',
        durum = json['description'] as String? ?? '',
        derece = json['degree'] as String? ?? '',
        min = json['min'] as String? ?? '',
        max = json['max'] as String? ?? '',
        gece = json['night'] as String? ?? '',
        nem = json['humidity'] as String? ?? '';
}
