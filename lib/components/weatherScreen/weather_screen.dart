import 'package:cs492_weather_app/models/weather_forecast.dart';
import '../../models/user_location.dart';
import 'package:flutter/material.dart';
import '../location/location.dart';
import '../../data/weather_map.dart';
import 'package:intl/intl.dart';


class WeatherScreen extends StatefulWidget {
  final Function getLocation;
  final Function getForecasts;
  final Function getForecastsHourly;
  final Function setLocation;

  const WeatherScreen(
      {super.key,
      required this.getLocation,
      required this.getForecasts,
      required this.getForecastsHourly,
      required this.setLocation});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int selectedDailyForecastIndex = 0;
  int selectedHourlyForecastIndex = 0;
  bool isHourlySelected = false;

  void setSelectedForecast(int index, {required bool hourly}) {
    setState(() {
      if (hourly) {
        selectedHourlyForecastIndex = index;
        isHourlySelected = true;
      } else {
        selectedDailyForecastIndex = index;
        isHourlySelected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var forecasts = widget.getForecasts();
    var forecastsHourly = widget.getForecastsHourly();
    return (widget.getLocation() != null && widget.getForecasts().isNotEmpty
        ? ForecastWidget(
            context: context,
            location: widget.getLocation(),
            // forecasts: widget.getForecastsHourly()
            forecasts: forecasts,
            forecastsHourly: forecastsHourly,
            selectedDailyForecastIndex: selectedDailyForecastIndex,
            selectedHourlyForecastIndex: selectedHourlyForecastIndex,
            isHourlySelected: isHourlySelected,
            onForecastSelected: setSelectedForecast,
          )
        : LocationWidget(widget: widget));
  }
}

class ForecastWidget extends StatelessWidget {
  final BuildContext context;
  final UserLocation location;
  final List<WeatherForecast> forecasts;
  final List<WeatherForecast> forecastsHourly;
  final int selectedDailyForecastIndex;
  final int selectedHourlyForecastIndex;
  final bool isHourlySelected;
  final Function(int, {required bool hourly}) onForecastSelected;

  const ForecastWidget({
    required this.context,
    super.key,
    required this.location,
    required this.forecasts,
    required this.forecastsHourly,
    required this.selectedDailyForecastIndex,
    required this.selectedHourlyForecastIndex,
    required this.isHourlySelected,
    required this.onForecastSelected,
  });

  String convertDateTime(String isoDateTime) {
    DateTime dateTime = DateTime.parse(isoDateTime);
    String formattedDateTime = "${DateFormat('MMMM d').format(dateTime)}th, ${DateFormat('ha').format(dateTime)}";
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    WeatherForecast selectedForecast = isHourlySelected
        ? forecastsHourly[selectedHourlyForecastIndex]
        : forecasts[selectedDailyForecastIndex];
    return Column(
      children: [
        LocationTextWidget(location: location),
        TemperatureWidget(forecasts: [selectedForecast]),
        const SizedBox(height: 16),
        IconWidget(description: selectedForecast.shortForecast),
        const SizedBox(height: 16), 
        DescriptionWidget(forecasts: [selectedForecast]),
        // Widgets for displaying selected forecast or current weather above the lists
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Hourly Forecasts', style: Theme.of(context).textTheme.headlineSmall),
                ),
// Hourly Forecasts
                Container(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forecastsHourly.length,
                    itemBuilder: (context, index) {
                      final forecast = forecastsHourly[index];
                      final timeStr = convertDateTime(forecast.startTime);
                      return GestureDetector(
                        onTap: () => onForecastSelected(index, hourly: true), // Update this if needed
                        child: Card(
                          child: Container(
                            width: 160,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  timeStr,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                IconWidget(description: forecast.shortForecast),
                                Text('${forecast.temperature}°', style: Theme.of(context).textTheme.headlineSmall),
                                Text(forecast.shortForecast),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Daily Forecasts', style: Theme.of(context).textTheme.headlineSmall),
                ),
// Daily Forecasts
                Container(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forecasts.length,
                    itemBuilder: (context, index) {
                      final forecast = forecasts[index];
                      final timeStr = convertDateTime(forecast.startTime);
                      return GestureDetector(
                        onTap: () => onForecastSelected(index, hourly: false), // Update this if needed
                        child: Card(
                          child: Container(
                            width: 160,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  timeStr,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                IconWidget(description: forecast.shortForecast),
                                Text('${forecast.temperature}°', style: Theme.of(context).textTheme.headlineSmall),
                                Text(forecast.shortForecast),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DescriptionWidget extends StatelessWidget {
  const DescriptionWidget({
    super.key,
    required this.forecasts,
  });

  final List<WeatherForecast> forecasts;

  String getIconPathFromDescription(String description) {
    return weatherDescriptionsToIcon[description] ?? 'assets/icons/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 500,
      child: Center(
          child: Text(forecasts.elementAt(0).shortForecast,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium)),
    );
  }
}

class IconWidget extends StatelessWidget {
  final String description;

  const IconWidget({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    String iconPath = getIconPathFromDescription(description);
    double screenWidth = MediaQuery.of(context).size.width;
    return Image.asset(iconPath, width: screenWidth / 3); // Adjust size as needed
  }

  String getIconPathFromDescription(String description) {
    return weatherDescriptionsToIcon[description] ?? 'assets/icons/default.png';
  }
}

class TemperatureWidget extends StatelessWidget {
  const TemperatureWidget({
    super.key,
    required this.forecasts,
  });

  final List<WeatherForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 60,
      child: Center(
        child: Text('${forecasts.elementAt(0).temperature}º',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }
}

class LocationTextWidget extends StatelessWidget {
  const LocationTextWidget({
    super.key,
    required this.location,
  });

  final UserLocation location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 500,
        child: Text("${location.city}, ${location.state}, ${location.zip}",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}

class LocationWidget extends StatelessWidget {
  const LocationWidget({
    super.key,
    required this.widget,
  });

  final WeatherScreen widget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Requires a location to begin"),
          ),
          Location(
              setLocation: widget.setLocation,
              getLocation: widget.getLocation),
        ],
      ),
    );
  }
}
