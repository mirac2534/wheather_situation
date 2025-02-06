class WheatherModel {
  final String tarih; //date
  final String gun; // day
  final String ikon; // icon
  final String durum; //situation
  final String derece; //degree
  final String min; // min degree
  final String max; // max degree
  final String gece; // night degree
  final String nem; // humidity

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
