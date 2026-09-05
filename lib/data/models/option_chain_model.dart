class OptionChainModel {
  final String callOi;
  final String putOi;
  final String changeOi;
  final String strike;
  final String callVolume; // CE LTP for LTP tab
  final String putVolume;  // PE LTP for LTP tab
  final String callSecId;  // CE security_id for live price
  final String putSecId;   // PE security_id for live price
  final bool isAtm;        // is this strike near ATM

  OptionChainModel({
    required this.callOi,
    required this.putOi,
    required this.changeOi,
    required this.strike,
    required this.callVolume,
    this.putVolume = '—',
    this.callSecId = '',
    this.putSecId = '',
    this.isAtm = false,
  });
}
