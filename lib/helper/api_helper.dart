import 'global_helper.dart';

class ApiHelper {
  static final String prefix = 'https://';
  static final String localPrefix = 'http://';
  static final String domain = 'truhoist.com/';
  static final String localDomain = '192.168.31.67:8000/';
  static final String subdomain = GlobalHelper.getStringValuesSF('subdomain');

  static final String baseDomain = prefix + domain;
  static final String baseSubDomain = prefix + subdomain;
  static final String localBaseDomain = localPrefix + localDomain;
}
