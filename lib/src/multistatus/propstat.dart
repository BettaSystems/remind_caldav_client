import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:remind_caldav_client/src/multistatus/element.dart';
import 'package:xml/xml.dart';

class Propstat {
  final ICalendar? parsed;
  final Map<String, dynamic> prop;
  final int status;

  Propstat({required this.prop, required this.status, required this.parsed});

  factory Propstat.fromXml(XmlElement element) {
    if (element.name.local == 'propstat') {
      final prop = <String, dynamic>{};

      final elements = element.children.whereType<XmlElement>();

      // get prop
      final props = elements.firstWhere((element) => element.name.local == 'prop').children.whereType<XmlElement>();

      // set prop value
      props.forEach((element) {
        var children = element.children.whereType<XmlElement>().map((element) => Element.fromXml(element)).toList();

        var value = children.isEmpty ? element.innerText : children;

        prop[element.name.local] = value;
      });

      final parsedICal = prop['calendar-data'] != null ? ICalendar.fromString(prop['calendar-data']!) : null;

      // get status
      final status = elements.firstWhere((element) => element.name.local == 'status').innerText.split(' ')[1];

      return Propstat(prop: prop, parsed: parsedICal, status: int.parse(status));
    }

    throw Error();
  }

  @override
  String toString() {
    var string = '';

    prop.forEach((key, value) {
      var valueString = value.toString();

      string += '$key: ${valueString.length > 200 ? '\n' : ''}$valueString';
    });

    return string;
  }
}
