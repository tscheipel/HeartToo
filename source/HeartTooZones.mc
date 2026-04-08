import Toybox.Graphics;
import Toybox.Lang;
import Toybox.UserProfile;

//! ==================== HeartToo Zone Manager ====================
//! Handles heartrate zone calculations, color mapping, and zone indexing.

module HeartTooZones {

    function getHeartRateThresholds() as Array<Number> {
        var thresholds = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_BIKING);
        if (thresholds == null || thresholds.size() < 6 || thresholds[0] == null || thresholds[0] == 0) {
            return [117, 144, 160, 171, 189, 192];
        }
        return thresholds;
    }

    //! Calculate current heartrate zone and fractional position within zone.
    //! Zone values: 0 (below Z1) to 5.
    function calculateZone(heartRate as Numeric?, thresholds as Array<Number>, outZone as Dictionary, outDecimal as Dictionary) as Void {
        outZone[:value] = 0;
        outDecimal[:value] = 0.0;

        if (heartRate == null) {
            return;
        }

        if (heartRate < thresholds[0]) {
            return;
        }

        if (heartRate > thresholds[5]) {
            outZone[:value] = 5;
            outDecimal[:value] = 1.0;
            return;
        }

        for (var i = 1; i < 6; i++) {
            if (heartRate > thresholds[i - 1] && heartRate <= thresholds[i]) {
                outZone[:value] = i;
                var minZone = thresholds[i - 1].toFloat();
                var maxZone = thresholds[i].toFloat();
                outDecimal[:value] = (heartRate.toFloat() - minZone) / (maxZone - minZone);
                return;
            }
        }
    }

    function getZoneColor(zone as Numeric, colorArray as Array<Number>) as Number {
        if (zone < 0 || zone > 5 || colorArray.size() < 6) {
            return Graphics.COLOR_LT_GRAY;
        }
        return colorArray[zone] as Number;
    }

    function initializeZoneColors() as Array<Number> {
        return [
            Graphics.COLOR_LT_GRAY,
            Graphics.COLOR_LT_GRAY,
            Graphics.COLOR_BLUE,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_RED
        ];
    }

}

