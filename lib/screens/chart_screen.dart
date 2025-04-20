import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
import 'chart/widgets/chart_widget.dart';
import 'chart/widgets/kundali_table_widget.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<ChartProvider>(context, listen: false);
    // if (provider.chart == null && !provider.isLoading) {
    //   provider.fetchChart(
    //     year: 1990,
    //     month: 5,
    //     day: 15,
    //     hour: 10.0,
    //     minute: 30.0,
    //     latitude: 28.66694444,
    //     longitude: 77.21694444,
    //     tzOffset: 5.5,
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ChartProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }
        if (provider.isLoading || provider.chart == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chart Details'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ChartWidget(chart: provider.chart!),
                ),
                const KundaliTableWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}