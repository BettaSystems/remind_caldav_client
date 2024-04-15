import 'package:remind_caldav_client/caldav_client.dart';

void main() async {
  var client = CalDavClient(
    baseUrl: 'http://localhost:8080/',
    headers: Authorization('juli', '1234').basic(),
  );

  // initialSync
  var initialSyncResult = await client.initialSync('dav.php/calendars/juli/default/');

  var calendars = <String>[];

  // Print calendars and save calendars path
  for (var result in initialSyncResult.multistatus!.response) {
    print('PATH: ${result.href}');

    if (result.propstat.status == 200) {
      var displayname = result.propstat.prop['displayname'];
      var ctag = result.propstat.prop['getctag'];

      if (displayname != null && ctag != null) {
        print('CALENDAR: $displayname');
        print('CTAG: $ctag');

        calendars.add(result.href);
      } else {
        print('This collection is not a calendar');
      }
    } else {
      print('Bad prop status');
    }
  }

  // Print calendar objects info
  if (calendars.isNotEmpty) {
    var getObjectsResult = await client.getObjects(calendars.first, depth: 1);


    for (var result in getObjectsResult.multistatus!.response) {
      print('PATH: ${result.href}');

      if (result.propstat.status == 200) {
        print('CALENDAR DATA:\n${result.propstat.prop['calendar-data']}');
        print("iCal: ${result.propstat.parsed}");
        print('ETAG: ${result.propstat.prop['getetag']}');
        print('type: ${result.propstat.prop['calendar-data'].runtimeType}');
      } else {
        print('Bad prop status');
      }
    }

//     final calendar = '''
// BEGIN:VCALENDAR
// VERSION:2.0
// PRODID:-//PYVOBJECT//NONSGML Version 1//EN
// BEGIN:VEVENT
// UID:20010712T182145Z-123401@example.com
// DTSTAMP:20060712T182145Z
// DTSTART:20060714T170000Z
// DTEND:20060715T040000Z
// SUMMARY:Bastille Day Party
// END:VEVENT
// END:VCALENDAR''';

    // // Create calendar
    // var createCalResponse = await client.createCal(join(calendars.first, '/example.ics'), calendar);

    // if (createCalResponse.statusCode == 201) print('Created');
  }
}
