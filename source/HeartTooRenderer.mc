import Toybox.Graphics;
import Toybox.Lang;

import HeartTooConstants;

//! ==================== HeartToo Renderer ====================
//! Handles all power data display rendering for different screen sizes and modes

module HeartTooRenderer {

    //! Determine display mode based on screen dimensions and font preferences
    //! @param width Screen width in pixels
    //! @param height Screen height in pixels
    //! @param referenceWidth Reference width from layout coordinates
    //! @param smallFont Whether small font is enabled
    //! @param averageMode The average display mode (0-6)
    //! @return Display mode number (0-5)
    function getDisplayMode(width as Numeric, height as Numeric, referenceWidth as Numeric, smallFont as Boolean, averageMode as Numeric) as Numeric {
        if (width > referenceWidth) {
            // Full width display
            return averageMode > 3 ? 1 : 0;
        } else if (!smallFont) {
            // Half width with large font
            return averageMode > 3 ? 3 : 2;
        } else {
            // Half width with small font
            return averageMode > 3 ? 5 : 4;
        }
    }

    //! Get power and zone display values for given display mode
    //! @param mode Display mode (0-5)
    //! @param coords Location coordinates array
    //! @param fonts Font definitions array
    //! @param width Screen width
    //! @param fontHeight Font height for device detection
    //! @param outPowerValues Output power display array [x, y, font]
    //! @param outZoneValues Output zone display array [x, y, font, justification]
    function getDisplayValues(
        mode as Numeric,
        coords as Array<Numeric>,
        fonts as Array,
        width as Numeric,
        fontHeight as Numeric,
        outPowerValues as Dictionary,
        outZoneValues as Dictionary) as Void {

        switch (mode) {
            case 0:  // Full width
                outPowerValues[:data] = [coords[2], coords[3], fonts[0]];
                outZoneValues[:data] = [coords[14], coords[1], fonts[2], HeartTooConstants.TEXT_LEFT];
                break;
            case 1:  // Full width x2
                outPowerValues[:data] = [coords[2], coords[3], fonts[0]];
                outZoneValues[:data] = [coords[14], coords[1], fonts[2], HeartTooConstants.TEXT_LEFT];
                break;
            case 2:  // Half width big font
                var powerData = [coords[4], coords[5], fonts[0]] as Array;
                if (width == 140 && fontHeight == 48) {
                    powerData[2] = Graphics.FONT_NUMBER_MEDIUM;
                }
                outPowerValues[:data] = powerData;
                outZoneValues[:data] = [coords[14], coords[9], fonts[1], HeartTooConstants.TEXT_LEFT_VCENTER] as Array;
                break;
            case 3:  // Half width big font x2
                var powerData3 = [coords[4], coords[5], fonts[0]] as Array;
                if (width == 140 && fontHeight == 48) {
                    powerData3[2] = Graphics.FONT_NUMBER_MEDIUM;
                }
                outPowerValues[:data] = powerData3;
                outZoneValues[:data] = [coords[14], coords[9], fonts[1], HeartTooConstants.TEXT_LEFT_VCENTER] as Array;
                break;
            case 4:  // Half width small font
                outPowerValues[:data] = [coords[2] * 0.95, coords[3], fonts[0]];
                outZoneValues[:data] = [coords[14], coords[1], fonts[2], HeartTooConstants.TEXT_LEFT];
                break;
            case 5:  // Half width small font x2
                outPowerValues[:data] = [coords[2] * 0.95, coords[3], fonts[0]];
                outZoneValues[:data] = [coords[14], coords[1], fonts[2], HeartTooConstants.TEXT_LEFT];
                break;
            default:
                outPowerValues[:data] = [coords[2], coords[3], fonts[0]];
                outZoneValues[:data] = [coords[14], coords[1], fonts[2], HeartTooConstants.TEXT_LEFT];
        }
    }

    //! Get display label based on interval
    //! @param interval Time interval in seconds
    //! @param modeLabels Array of mode label strings
    //! @return Appropriate label for the interval
    function getIntervalLabel(interval as Numeric, modeLabels as Array<String>) as String {
        switch(interval) {
            case 3:     return modeLabels[1];
            case 10:    return modeLabels[2];
            case 30:    return modeLabels[3];
            default:    return modeLabels[0];
        }
    }

    //! Get average mode label
    //! @param mode Average mode number (0-6)
    //! @param modeLabels Array of average mode label strings
    //! @return Label for the selected average mode
    function getAverageModeLabel(mode as Numeric, modeLabels as Array<String>) as String {
        if (mode >= 0 && mode < modeLabels.size()) {
            return modeLabels[mode];
        }
        return "Avg";
    }

    //! Build display title combining interval and average mode labels
    //! @param width Screen width
    //! @param displayMode Display mode (0-5)
    //! @param intervalLabel Label for time interval
    //! @param averageLabel Label for average mode
    //! @return Combined title string
    function buildDisplayTitle(width as Numeric, displayMode as Numeric, intervalLabel as String, averageLabel as String) as String {
        // Narrow screens show only interval label
        if (width == 114 || width == 115 || width == 99) {
            return intervalLabel;
        }
        // All other displays show combined label
        return intervalLabel + "/" + averageLabel;
    }

}

