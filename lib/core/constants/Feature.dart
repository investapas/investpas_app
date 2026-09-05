// ignore_for_file: public_member_api_docs

part of 'constants.dart';

///Features are the deep leveled versions of [Masters], used to give [Crud] permissions for indidual users
enum Feature {
  User,
  Sell,
  BillingDesk,
  Masters,
  Reports
}

///Returns the [Feature] from [String]
Feature featureFromString(String? source) {
  return Feature.values.singleWhere(
        (Feature e) => e.name == source,
    orElse: () => Feature.Reports,
  );
}
