import 'package:intl/intl.dart';

class DateHelper{

  static final DateHelper _instance = new DateHelper.internal();
    factory DateHelper() => _instance;

  static DateHelper _dh;
  
  DateHelper.internal();

  String getFormatDate(DateTime d)
  {
    var formatter = new DateFormat('HH:mm:ss dd-MM-yy');
    return formatter.format(d);
  }

}