import Toybox.Lang;
import Toybox.Math;

class HeartTooMath {

    static function pushWindow(values as Array<Numeric>, nextValue as Numeric) as Array<Numeric> {
        values.add(nextValue);
        return values.slice(1, null);
    }

    static function mean(values as Array<Numeric>) as Float {
        var size = values.size();
        var sum = 0.0f;

        for (var index = 0; index < size; index++) {
            if (values[index] != null) {
                sum += values[index];
            } else {
                sum = 0.0f;
            }
        }

        return sum / size;
    }

    static function normalizeHistogram(powerValues as Array<Float>, maxGridHeight as Numeric, normalizeOn as Boolean) as Array<Float> {
        var maximumValue = 0.0f;
        var normalized = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

        for (var zoneIndex = 0; zoneIndex < 7; zoneIndex++) {
            var value = powerValues[zoneIndex].toFloat();
            normalized[zoneIndex] = value;
            if (value > maximumValue) {
                maximumValue = value;
            }
        }

        if (maximumValue == 0) {
            return powerValues;
        }

        if (normalizeOn) {
            for (var arrayIndex = 0; arrayIndex < 7; arrayIndex++) {
                normalized[arrayIndex] = powerValues[arrayIndex] / maximumValue * maxGridHeight;
            }
        }

        return normalized;
    }

    static function updateNormalizedPowerMean(previousNormalizedPower as Numeric, normalizedPowerCounter as Numeric, averagePower30Seconds as Numeric) as Numeric {
        var calculatedPower;

        switch(normalizedPowerCounter) {
            case 0:
                calculatedPower = averagePower30Seconds;
                break;
            default:
                var previousFraction = (normalizedPowerCounter - 1.0) / normalizedPowerCounter;
                var currentFraction = 1.0 / normalizedPowerCounter;
                calculatedPower = Math.pow(previousNormalizedPower, 4) * previousFraction + Math.pow(averagePower30Seconds, 4) * currentFraction;
                calculatedPower = Math.pow(calculatedPower, 0.25);
        }

        return calculatedPower;
    }
}

