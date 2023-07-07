import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Model/Classes/stream_status_details.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:e_jam/src/controller/Streams/streams_controller.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DataExporter {
  static const String eJamIntro =
      'E Jam is a tool for generating and verifying network traffic.'
      'It is a tool used to test the performance and reliability of network switches.'
      'The tool is designed to be used by network engineers, network administrators, and network security professionals.\n\n'
      'For more information, please visit the E Jam website';

  static const String eJamLogoImage = 'assets/images/icon.png';
  static const double imageWidth = 150,
      imageHeight = 150,
      imageTopOffset = 70,
      imageLeftOffset = 180;

  static const List<String> dataTypes = [
    'Devices',
    'Stream Status Details',
    'Stream Entries',
    'Generator Statistics',
    'Verifier Statistics',
  ];

  static const List<Function> toListFunctions = [
    devicesList,
    streamStatusDetailsToList,
    streamEntriesToList,
    generatorInstancesToList,
    verifierStatisticsInstanceToList,
  ];

  static const List<Function> saveAsFunctions = [saveAsCSV, saveAsPdf];

  static exportSelectedData(
      BuildContext context, List<bool> choices, int saveAs) {
    // show error dialog if the platform is not supported
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Platform not supported'),
          content: const Text(
              'Exporting data is only supported on Windows, Linux, and MacOS. Please use one of these platforms to export data for now.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      return;
    }

    // export the data root folder
    for (int i = 0; i < choices.length; i++) {
      if (choices[i]) {
        toListFunctions[i](context)
            .then((data) => saveAsFunctions[saveAs](data, dataTypes[i]));
      }
    }
  }

  static Future<List<List<dynamic>>> devicesList(BuildContext context) async {
    // devices
    List<List<dynamic>> rows = [];

    // add header
    rows.add([
      'Device Name',
      'Description',
      'Location',
      'IP',
      'Port Number',
      'Mac Address',
      'Processes Generating',
      'Processes Verifying',
      'Device Status',
      'Last Updated',
    ]);

    List<Device> devices = context.read<DevicesController>().getDevices ?? [];
    // add data
    for (var device in devices) {
      rows.add([
        device.name,
        device.description,
        device.location,
        device.ipAddress,
        device.port,
        device.macAddress,
        device.genProcesses,
        device.verProcesses,
        device.status,
        device.lastUpdated,
      ]);
    }

    return rows;
  }

  static Future<List<List<dynamic>>> streamStatusDetailsToList(
      BuildContext context) async {
    // stream status details
    List<List<dynamic>> rows = [];

    // add header
    rows.add([
      'Name',
      'Stream ID',
      'Stream Status',
      'Last Updated',
      'Start Time',
      'End Time',
    ]);

    List<StreamStatusDetails> streamStatusDetails =
        context.read<StreamsController>().getStreamsStatusDetails ?? [];
    for (var streamStatusDetail in streamStatusDetails) {
      rows.add([
        streamStatusDetail.name,
        streamStatusDetail.streamId,
        streamStatusDetail.streamStatus,
        streamStatusDetail.lastUpdated,
        streamStatusDetail.startTime,
        streamStatusDetail.endTime,
      ]);
    }

    return rows;
  }

  static Future<List<List<dynamic>>> streamEntriesToList(
      BuildContext context) async {
    // stream details
    List<List<dynamic>> rows = [];

    // add header
    rows.add([
      'Name',
      'Description',
      'Last Updated',
      'Start Time',
      'End Time',
      'Delay',
      'Stream ID',
      'Generators IDs',
      'Verifiers IDs',
      'Payload Type',
      'Burst Length',
      'Burst Delay',
      'Number of Packets',
      'Payload Length',
      'Seed',
      'Broadcast Frames',
      'Inter-Frame Gap',
      'Duration',
      'Transport Layer Protocol',
      'Flow Type',
      'Check Content',
      'Running Generators',
      'Running Verifiers',
      'Stream Status',
    ]);

    List<StreamEntry> streamEntries =
        context.read<StreamsController>().getStreams ?? [];
    // Add data
    for (var streamEntry in streamEntries) {
      rows.add([
        streamEntry.name,
        streamEntry.description,
        streamEntry.lastUpdated,
        streamEntry.startTime,
        streamEntry.endTime,
        streamEntry.delay,
        streamEntry.streamId,
        streamEntry.generatorsIds,
        streamEntry.verifiersIds,
        streamEntry.payloadType,
        streamEntry.burstLength,
        streamEntry.burstDelay,
        streamEntry.numberOfPackets,
        streamEntry.payloadLength,
        streamEntry.seed,
        streamEntry.broadcastFrames,
        streamEntry.interFrameGap,
        streamEntry.duration,
        streamEntry.transportLayerProtocol,
        streamEntry.flowType,
        streamEntry.checkContent,
        streamEntry.runningGenerators,
        streamEntry.runningVerifiers,
        streamEntry.streamStatus,
      ]);
    }
    return rows;
  }

  static Future<List<List<dynamic>>> generatorInstancesToList(
      BuildContext context) async {
    List<List<dynamic>> rows = [];
    // Add headers

    rows.add([
      'MAC Address',
      'Stream ID',
      'Packets Sent',
      'Packets Errors',
      'Timestamp',
    ]);

    // Get data
    List<GeneratorStatisticsInstance> generatorStatisticsInstanceList =
        context.read<StatisticsController>().getGeneratorStatistics;

    // Add data
    for (var generatorStatisticsInstance in generatorStatisticsInstanceList) {
      rows.add([
        generatorStatisticsInstance.macAddress,
        generatorStatisticsInstance.streamId,
        generatorStatisticsInstance.packetsSent,
        generatorStatisticsInstance.packetsErrors,
        generatorStatisticsInstance.timestamp,
      ]);
    }

    return rows;
  }

  static Future<List<List<dynamic>>> verifierStatisticsInstanceToList(
      BuildContext context) async {
    List<List<dynamic>> rows = [];

    // Add headers
    rows.add([
      'MAC Address',
      'Stream ID',
      'Packets Correct',
      'Packets Errors',
      'Packets Dropped',
      'Packets Out of Order',
      'Timestamp',
    ]);

    List<VerifierStatisticsInstance> verifierStatisticsInstancesList =
        context.read<StatisticsController>().getVerifierStatistics;

    // Add data
    for (var verifierStatisticsInstance in verifierStatisticsInstancesList) {
      rows.add([
        verifierStatisticsInstance.macAddress,
        verifierStatisticsInstance.streamId,
        verifierStatisticsInstance.packetsCorrect,
        verifierStatisticsInstance.packetsErrors,
        verifierStatisticsInstance.packetsDropped,
        verifierStatisticsInstance.packetsOutOfOrder,
        verifierStatisticsInstance.timestamp,
      ]);
    }

    return rows;
  }

  static saveAsCSV(List<List<dynamic>> data, String dataType) async {
    String csv = const ListToCsvConverter().convert(data);
    //Create date now string
    String dateNow = DateFormat('yyyy_MM_dd_kk:mm').format(DateTime.now());
    String fileName = '${dataType}_$dateNow';

    // save file
    File file = File('$fileName.csv');
    file.writeAsString(csv);
  }

  static saveAsPdf(List<List<dynamic>> data, String dataType) async {
    if (data.isEmpty) {
      return;
    }

    // Create a new PDF document.
    final PdfDocument document = PdfDocument();

    //Create a PDF page template and add header content.
    final PdfPageTemplateElement headerTemplate =
        PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));

    //Create date now string
    String dateNow = DateFormat('yyyy_MM_dd_kk:mm').format(DateTime.now());
    String fileName = '${dataType}_$dateNow';

    //Draw text in the header.
    headerTemplate.graphics.drawString(
      'E Jam for monitoring, testing, and debugging Switches.\n\t$fileName',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      brush: PdfSolidBrush(PdfColor(36, 34, 34)),
      bounds: const Rect.fromLTWH(0, 0, 515, 50),
    );

    //Add the header element to the document.
    document.template.bottom = headerTemplate;

    // Add Cover page
    final PdfPage cover = document.pages.add();

    // Add Cover top rectangle
    cover.graphics.drawRectangle(
      bounds: const Rect.fromLTWH(0, 0, 515, 60),
      brush: PdfSolidBrush(PdfColor(0, 27, 61)),
    );

    //Read image logo.
    final Uint8List imageData = File(eJamLogoImage).readAsBytesSync();

    //Load the image using PdfBitmap.
    final PdfBitmap image = PdfBitmap(imageData);

    //Draw the image to the PDF page.
    cover.graphics.drawImage(
        image,
        const Rect.fromLTWH(
            imageLeftOffset, imageTopOffset, imageWidth, imageWidth));

    //E Jam Title
    cover.graphics.drawString('E Jam',
        PdfStandardFont(PdfFontFamily.helvetica, 28, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, imageHeight + imageTopOffset + 5,
            cover.getClientSize().width, 100),
        brush: PdfSolidBrush(PdfColor(36, 34, 34)),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    //Small description
    final PdfLayoutResult layoutResult = PdfTextElement(
            text: eJamIntro,
            font: PdfStandardFont(PdfFontFamily.helvetica, 12,
                style: PdfFontStyle.regular),
            brush: PdfSolidBrush(PdfColor(0, 0, 0)),
            format: PdfStringFormat(alignment: PdfTextAlignment.center))
        .draw(
            page: cover,
            bounds: Rect.fromLTWH(0, imageHeight + imageTopOffset + 50,
                cover.getClientSize().width, cover.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;

    // Draw the line below the description
    cover.graphics.drawLine(
        PdfPen(PdfColor(0, 27, 61)),
        Offset(0, layoutResult.bounds.bottom + 10),
        Offset(cover.getClientSize().width, layoutResult.bounds.bottom + 10));

    // Add a new page to the document for Data Table.
    final PdfPage page = document.pages.add();

    // Create a PDF grid class to add tables.
    final PdfGrid grid = PdfGrid();

    // Specify the grid column count.
    grid.columns.add(count: data[0].length);

    // Add a grid header row.
    final PdfGridRow headerRow = grid.headers.add(1)[0];

    for (int i = 0; i < data[0].length; i++) {
      headerRow.cells[i].value = data[0][i];
    }

    // Set header style.
    headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 138, 255));
    headerRow.style.textBrush = PdfBrushes.white;

    // Add rows to the grid.
    for (int i = 1; i < data.length; i++) {
      final PdfGridRow row = grid.rows.add();
      for (int j = 0; j < data[i].length; j++) {
        row.cells[j].value = data[i][j].toString();
      }
    }

    // Set grid format.
    grid.style.cellPadding = PdfPaddings(left: 5, top: 5);

    // Draw table in the PDF page.
    grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 0, page.getClientSize().width, page.getClientSize().height));

    // Save the document.
    File('$fileName.pdf').writeAsBytes(await document.save());

    // Dispose the document.
    document.dispose();
  }
}
