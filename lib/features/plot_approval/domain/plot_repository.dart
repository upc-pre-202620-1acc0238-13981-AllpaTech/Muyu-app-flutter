import 'plot.dart';

abstract class PlotRepository {
  Future<List<Plot>> getPlots();
}
