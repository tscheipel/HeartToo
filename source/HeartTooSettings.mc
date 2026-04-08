import Toybox.Application;
import Toybox.Lang;

//! ==================== HeartToo Settings Manager ====================
//! Loads all user-configurable display settings.

module HeartTooSettings {

    function loadAll(displaySettings as Dictionary) as Void {
        if (!(Toybox.Application has :Properties)) {
            return;
        }

        displaySettings[:preferredSmallFont] = Application.Properties.getValue("fontSize") == 0;
        displaySettings[:showHeartZoneBar] = Application.Properties.getValue("showHeartZoneBar");
        displaySettings[:heartZoneBarHeight] = Application.Properties.getValue("heartZoneBarHeight");
        displaySettings[:heartZoneIndexHeight] = Application.Properties.getValue("heartZoneIndexHeight");
        displaySettings[:showHeartZoneHistory] = Application.Properties.getValue("showHeartZoneHistory");
        displaySettings[:drawLabels] = Application.Properties.getValue("drawLabels");
        displaySettings[:drawCurrentZone] = Application.Properties.getValue("drawCurrentZone");
        displaySettings[:nSecondInterval] = Application.Properties.getValue("averageSec");
        displaySettings[:averageMode] = Application.Properties.getValue("averageMode");
        displaySettings[:showAverageHeartRate] = Application.Properties.getValue("showAverageHeartRate");
    }

}

