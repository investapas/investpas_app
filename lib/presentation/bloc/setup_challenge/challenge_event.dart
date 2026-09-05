enum ChallengeDuration { fiveDays, tenDays, paid }

abstract class ChallengeEvent {}

class LoadCapitalListEvent extends ChallengeEvent {}

class LoadTradeListEvent extends ChallengeEvent {}

class SelectCapitalEvent extends ChallengeEvent {
  final int capital;
  SelectCapitalEvent(this.capital);
}

class SelectMinProfitEvent extends ChallengeEvent {
  final int capital;
  SelectMinProfitEvent(this.capital);
}

class SelectMaxProfitEvent extends ChallengeEvent {
  final int capital;
  SelectMaxProfitEvent(this.capital);
}

class SelectMinLossEvent extends ChallengeEvent {
  final int capital;
  SelectMinLossEvent(this.capital);
}

class SelectMaxLossEvent extends ChallengeEvent {
  final int capital;
  SelectMaxLossEvent(this.capital);
}

class SelectMaxTradeEvent extends ChallengeEvent {
  final int capital;
  SelectMaxTradeEvent(this.capital);
}

class SelectNiftyEvent extends ChallengeEvent {
  final int capital;
  SelectNiftyEvent(this.capital);
}

class SelectBankNiftyEvent extends ChallengeEvent {
  final int capital;
  SelectBankNiftyEvent(this.capital);
}

class SelectFinNiftyEvent extends ChallengeEvent {
  final int capital;
  SelectFinNiftyEvent(this.capital);
}

class SelectMidCapNiftyEvent extends ChallengeEvent {
  final int capital;
  SelectMidCapNiftyEvent(this.capital);
}

class SelectSenSexEvent extends ChallengeEvent {
  final int capital;
  SelectSenSexEvent(this.capital);
}

class SelectDurationEvent extends ChallengeEvent {
  final ChallengeDuration duration;
  SelectDurationEvent(this.duration);
}

class SelectTradingStyleEvent extends ChallengeEvent {
  final String style;
  SelectTradingStyleEvent(this.style);
}

class SelectCooldownEvent extends ChallengeEvent {
  final int minutes;
  SelectCooldownEvent(this.minutes);
}

class SelectConsecutiveLossLimitEvent extends ChallengeEvent {
  final int limit;
  SelectConsecutiveLossLimitEvent(this.limit);
}

class SelectMaxCapitalPerTradeEvent extends ChallengeEvent {
  final int pct;
  SelectMaxCapitalPerTradeEvent(this.pct);
}

class ToggleHeroTradeEvent extends ChallengeEvent {
  final bool allowed;
  ToggleHeroTradeEvent(this.allowed);
}

class SubmitChallengeEvent extends ChallengeEvent {}

class LoadChallengeDataEvent extends ChallengeEvent {}