CREATE DATABASE flights_eda;
CREATE TABLE flights_cleaned (
    day_of_week INT,
    iata_code VARCHAR(10),
    flight_number INT,
    origin_airport_x VARCHAR(10),
    destination_airport VARCHAR(10),
    scheduled_departure TIME,
    departure_time TIME,
    departure_delay_min FLOAT,
    distance INT,
    scheduled_arrival TIME,
    arrival_time TIME,
    arrival_delay_min FLOAT,
    cancelled INT,
    cancellation_re_desc VARCHAR(50),
    air_system_delay_min FLOAT,
    security_delay_min FLOAT,
    airline_delay_min FLOAT,
    late_aircraft_delay_min FLOAT,
    weather_delay_min FLOAT,
    flight_datetime TIMESTAMP
);

SELECT * FROM public.flights_cleaned;
SELECT COUNT(*) FROM flights_cleaned;


--Analyze Primary Causes and Patterns of Delays and Cancellations
--1.1 Total Cancelled Flights and Reasons
SELECT 
  cancellation_re_desc,
  COUNT(*) AS cancelled_flights
FROM flights_cleaned
WHERE cancelled = 1
GROUP BY cancellation_re_desc
ORDER BY cancelled_flights DESC;

--1.2 Delay Type Contributions (Only for Non-Cancelled Flights)
SELECT 
  ROUND(AVG(air_system_delay_min)::NUMERIC, 2) AS air_system_avg,
  ROUND(AVG(security_delay_min)::NUMERIC, 2) AS security_avg,
  ROUND(AVG(airline_delay_min)::NUMERIC, 2) AS airline_avg,
  ROUND(AVG(late_aircraft_delay_min)::NUMERIC, 2) AS late_aircraft_avg,
  ROUND(AVG(weather_delay_min)::NUMERIC, 2) AS weather_avg
FROM flights_cleaned
WHERE cancelled = 0;
--Overall Cancellation Rate
SELECT 
    COUNT(*) AS total_flights,
    SUM(cancelled) AS total_cancelled,
    ROUND(100.0 * SUM(cancelled) / COUNT(*), 2) AS cancellation_rate_percent
FROM flights_cleaned;

--Cancellations by Reason
SELECT 
    cancellation_re_desc,
    COUNT(*) AS cancelled_flights,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM flights_cleaned WHERE cancelled = 1), 2) AS percent_of_cancelled
FROM flights_cleaned
WHERE cancelled = 1
GROUP BY cancellation_re_desc
ORDER BY cancelled_flights DESC;






--Benchmark Airlines for On-Time Performance & Cancellation Rates
--2.1 On-Time Performance per Airline (Define on-time as arrival_delay_min <= 15)
SELECT 
  iata_code,
  COUNT(*) AS total_flights,
  SUM(CASE WHEN arrival_delay_min <= 15 THEN 1 ELSE 0 END) AS on_time_flights,
  ROUND(100.0 * SUM(CASE WHEN arrival_delay_min <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS on_time_rate
FROM flights_cleaned
WHERE cancelled = 0
GROUP BY iata_code
ORDER BY on_time_rate DESC;

--2.2 Cancellation Rate per Airline
SELECT 
  iata_code,
  COUNT(*) AS total_flights,
  SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS cancelled_flights,
  ROUND(100.0 * SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate
FROM flights_cleaned
GROUP BY iata_code
ORDER BY cancellation_rate DESC;

--Evaluate Airport Performance for Bottlenecks
--3.1 Average Arrival Delay by Destination Airport
SELECT 
  destination_airport,
  COUNT(*) AS total_flights,
  ROUND(AVG(arrival_delay_min)::NUMERIC, 2) AS avg_arrival_delay
FROM flights_cleaned
WHERE cancelled = 0
GROUP BY destination_airport
ORDER BY avg_arrival_delay DESC;

--3.2 Most Cancelled Airports (Origin)
SELECT 
  origin_airport_x,
  COUNT(*) AS total_departures,
  SUM(cancelled) AS total_cancellations,
  ROUND(100.0 * SUM(cancelled)::NUMERIC / COUNT(*), 2) AS cancellation_rate
FROM flights_cleaned
GROUP BY origin_airport_x
ORDER BY cancellation_rate DESC;

--Time-based Operational Impact
--4.1 Flight Volume by Day of Week
SELECT 
  day_of_week,
  COUNT(*) AS total_flights,
  ROUND(AVG(departure_delay_min)::NUMERIC, 2) AS avg_dep_delay,
  ROUND(AVG(arrival_delay_min)::NUMERIC, 2) AS avg_arr_delay
FROM flights_cleaned
WHERE cancelled = 0
GROUP BY day_of_week
ORDER BY day_of_week;

--4.2 Hourly Trends (if TIME columns are parsable to hour)
SELECT 
  EXTRACT(HOUR FROM flight_datetime) AS hour_of_day,
  COUNT(*) AS total_flights,
  ROUND(AVG(departure_delay_min)::NUMERIC, 2) AS avg_dep_delay
FROM flights_cleaned
WHERE cancelled = 0
GROUP BY hour_of_day
ORDER BY hour_of_day;

--Recommendations Support (Aggregation Base)
--5.1 Delay Cause Share (Percent Contribution)
SELECT 
  ROUND(AVG(air_system_delay_min)::NUMERIC, 2) AS air_system,
  ROUND(AVG(security_delay_min)::NUMERIC, 2) AS security,
  ROUND(AVG(airline_delay_min)::NUMERIC, 2) AS airline,
  ROUND(AVG(late_aircraft_delay_min)::NUMERIC, 2) AS late_aircraft,
  ROUND(AVG(weather_delay_min)::NUMERIC, 2) AS weather
FROM flights_cleaned
WHERE cancelled = 0;




